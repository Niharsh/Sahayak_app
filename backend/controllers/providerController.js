const Joi = require("joi");
const Provider = require("../models/Provider");
const User = require("../models/User");

const applySchema = Joi.object({
  serviceCategory: Joi.string().required(),
  serviceAreas: Joi.array().items(Joi.string()).required(),
  experienceYears: Joi.number().min(0).max(100).required(),
});

async function apply(req, res) {
  // only provider role can apply
  if (!req.user || req.user.role !== "provider")
    return res.status(403).json({ error: "Only providers can apply" });

  const userId = req.user.sub;
  const user = await User.findById(userId);
  if (!user) return res.status(404).json({ error: "User not found" });

  const existing = await Provider.findOne({ user: userId });
  if (existing)
    return res.status(409).json({ error: "Provider profile already exists" });

  const body = req.body || {};
  // allow serviceAreas to be sent as JSON string from client
  if (typeof body.serviceAreas === "string") {
    try {
      body.serviceAreas = JSON.parse(body.serviceAreas);
    } catch (e) {
      // keep as string; Joi will reject
    }
  }

  const { error, value } = applySchema.validate(body);
  if (error) return res.status(400).json({ error: error.message });

  const { normalizeCategory, isValidCategory } = require("../utils/categories");
  const cat = normalizeCategory(value.serviceCategory);
  if (!isValidCategory(cat))
    return res.status(400).json({ error: "Invalid serviceCategory" });

  // normalize areas
  const areas = (value.serviceAreas || []).map((a) =>
    String(a).trim().toLowerCase(),
  );

  // Validate locations exist (no free-text allowed)
  const Location = require("../models/Location");
  const missing = [];
  for (const a of areas) {
    /* istanbul ignore next: defensive */
    if (!a) continue;
    const exists = await Location.exists({ name: a });
    if (!exists) missing.push(a);
  }
  if (missing.length > 0)
    return res
      .status(400)
      .json({ error: `Unknown locations: ${missing.join(", ")}` });

  // map files
  const filesMeta = [];
  if (req.files) {
    for (const fieldName of Object.keys(req.files)) {
      const fileArr = req.files[fieldName];
      for (const f of fileArr) {
        filesMeta.push({
          path: f.path,
          filename: f.filename,
          type:
            fieldName === "identity"
              ? "identity"
              : fieldName === "skill"
                ? "skill"
                : "other",
          uploadedAt: new Date(),
        });
      }
    }
  }

  const provider = new Provider({
    user: userId,
    serviceCategory: cat,
    serviceAreas: areas,
    experienceYears: value.experienceYears,
    verificationLevel: 0,
    verification: {
      identity: {
        status: "pending",
        documents: filesMeta.filter((d) => d.type === "identity"),
      },
      skill: {
        status: "pending",
        documents: filesMeta.filter((d) => d.type === "skill"),
      },
    },
    documents: filesMeta,
  });

  await provider.save();
  res.status(201).json({ provider: provider.toJSON() });
}

async function getMe(req, res) {
  if (!req.user || req.user.role !== "provider")
    return res.status(403).json({ error: "Only providers" });
  const provider = await Provider.findOne({ user: req.user.sub }).populate(
    "user",
    "name email",
  );
  if (!provider)
    return res.status(404).json({ error: "Provider profile not found" });
  // redact sensitive fields
  const obj = provider.toJSON();
  if (obj.user) delete obj.user.email; // do not expose email
  res.json({ provider: obj });
}

async function updateMe(req, res) {
  if (!req.user || req.user.role !== "provider")
    return res.status(403).json({ error: "Only providers can update" });
  const provider = await Provider.findOne({ user: req.user.sub });
  if (!provider)
    return res.status(404).json({ error: "Provider profile not found" });

  if (provider.verificationLevel >= 2)
    return res.status(403).json({
      error: "Cannot update profile after verification level 2 or higher",
    });

  const body = req.body || {};
  if (typeof body.serviceAreas === "string") {
    try {
      body.serviceAreas = JSON.parse(body.serviceAreas);
    } catch (e) {}
  }
  const { error, value } = applySchema.validate(body, {
    allowUnknown: true,
    stripUnknown: true,
  });
  if (error) return res.status(400).json({ error: error.message });

  const { normalizeCategory, isValidCategory } = require("../utils/categories");
  const cat = normalizeCategory(value.serviceCategory);
  if (!isValidCategory(cat))
    return res.status(400).json({ error: "Invalid serviceCategory" });
  const areas = (value.serviceAreas || []).map((a) =>
    String(a).trim().toLowerCase(),
  );

  // Validate that provided areas exist
  const Location = require("../models/Location");
  const missing = [];
  for (const a of areas) {
    if (!a) continue;
    const exists = await Location.exists({ name: a });
    if (!exists) missing.push(a);
  }
  if (missing.length > 0)
    return res
      .status(400)
      .json({ error: `Unknown locations: ${missing.join(", ")}` });

  provider.serviceCategory = cat;
  provider.serviceAreas = areas;
  provider.experienceYears = value.experienceYears;

  // append uploaded files if any
  if (req.files) {
    for (const fieldName of Object.keys(req.files)) {
      const fileArr = req.files[fieldName];
      for (const f of fileArr) {
        provider.documents.push({
          path: f.path,
          filename: f.filename,
          type:
            fieldName === "identity"
              ? "identity"
              : fieldName === "skill"
                ? "skill"
                : "other",
          uploadedAt: new Date(),
        });
      }
    }
  }

  await provider.save();
  res.json({ provider: provider.toJSON() });
}

module.exports = { apply, getMe, updateMe };
