const Joi = require("joi");
const Booking = require("../models/Booking");
const Provider = require("../models/Provider");
const User = require("../models/User");

const createSchema = Joi.object({
  serviceCategory: Joi.string().required(),
  serviceArea: Joi.string().required(),
  schedule: Joi.date().iso().required(),
  price: Joi.number().min(0).optional(),
  providerId: Joi.string().optional().allow(null),
});

const { normalizeCategory, isValidCategory } = require("../utils/categories");

// GET supported categories (static)
const CATEGORIES = ["maid", "plumber", "barber", "electrician", "carpenter"];

async function getCategories(req, res) {
  res.json({ categories: CATEGORIES });
}

// Provider search
async function searchProviders(req, res) {
  const rawCategory = req.query.category;
  const rawArea = req.query.area;

  if (!rawCategory || !rawArea)
    return res.status(400).json({ error: "category and area are required" });

  const { normalizeCategory } = require("../utils/categories");
  const category = normalizeCategory(rawCategory);
  const area = String(rawArea).trim().toLowerCase();

  // debug logs to help trace mismatches
  console.log(
    "searchProviders: category=",
    rawCategory,
    "=>",
    category,
    "area=",
    rawArea,
    "=>",
    area,
  );

  // Use normalized fields; if some old data exists with mixed case, also accept case-insensitive via regex
  const query = {
    serviceCategory: { $regex: new RegExp("^" + category + "$", "i") },
    serviceAreas: { $in: [new RegExp("^" + area + "$", "i")] },
    verificationLevel: { $gte: 2 },
  };

  let providers = await Provider.find(query).populate("user", "name");

  // debug: show providers count and ids
  console.log(
    "providers found (pre-sort):",
    providers.map((p) => ({
      id: p._id,
      serviceCategory: p.serviceCategory,
      serviceAreas: p.serviceAreas,
    })),
  );

  // sort by verificationLevel desc, then placeholder rating (null), then recency
  providers.sort((a, b) => {
    if (b.verificationLevel !== a.verificationLevel)
      return b.verificationLevel - a.verificationLevel;
    // ratings not implemented, keep stable
    return new Date(b.createdAt) - new Date(a.createdAt);
  });

  const safe = providers.map((p) => {
    const o = p.toJSON();
    // keep minimal public fields; do not expose phone/email
    return {
      id: o._id,
      name: p.user?.name || null,
      serviceCategory: o.serviceCategory,
      serviceAreas: o.serviceAreas,
      verificationLevel: o.verificationLevel,
      createdAt: o.createdAt,
    };
  });

  res.json({ providers: safe });
}

// POST /bookings - client creates booking
async function createBooking(req, res) {
  if (!req.user || req.user.role !== "client")
    return res.status(403).json({ error: "Only clients can create bookings" });

  const { error, value } = createSchema.validate(req.body);
  if (error) return res.status(400).json({ error: error.message });

  let {
    serviceCategory,
    serviceArea,
    schedule,
    price = 0,
    providerId = null,
  } = value;

  // normalize inputs
  serviceCategory = normalizeCategory(serviceCategory);
  serviceArea = String(serviceArea).trim().toLowerCase();
  if (!isValidCategory(serviceCategory))
    return res.status(400).json({ error: "Invalid serviceCategory" });

  let assignedProvider = null;

  if (providerId) {
    assignedProvider = await Provider.findById(providerId);
    if (!assignedProvider)
      return res.status(400).json({ error: "Provider not found" });
    if (assignedProvider.verificationLevel < 2)
      return res.status(400).json({ error: "Provider not eligible" });
  } else {
    // simple deterministic strategy: pick top-ranked provider matching category/area
    // use normalized matching (serviceCategory stored normalized, serviceAreas array contains normalized area values)
    const candidates = await Provider.find({
      serviceCategory: serviceCategory,
      serviceAreas: serviceArea,
      verificationLevel: { $gte: 2 },
    })
      .sort({ verificationLevel: -1, createdAt: -1 })
      .limit(1);
    if (candidates.length > 0) assignedProvider = candidates[0];
  }

  const booking = new Booking({
    client: req.user.sub,
    provider: assignedProvider ? assignedProvider._id : undefined,
    serviceCategory,
    serviceArea,
    schedule: new Date(schedule),
    price,
    status: "pendingAcceptance",
    auditTrail: [
      { status: "created", actor: req.user.sub, at: new Date() },
      { status: "pendingAcceptance", actor: req.user.sub, at: new Date() },
    ],
  });

  await booking.save();
  res.status(201).json({ booking: booking.toJSON() });
}

// GET bookings for current user
async function getMyBookings(req, res) {
  if (!req.user) return res.status(401).json({ error: "Unauthorized" });

  if (req.user.role === "client") {
    // show provider minimal info only
    const bookings = await Booking.find({ client: req.user.sub }).populate({
      path: "provider",
      populate: { path: "user", select: "name" },
    });
    const safe = bookings.map((b) => {
      const o = b.toJSON();
      if (o.provider) {
        const p = o.provider;
        o.provider = {
          id: p._id,
          name: p.user?.name || null,
          serviceCategory: p.serviceCategory,
          verificationLevel: p.verificationLevel,
        };
      }
      // do not expose client contact
      delete o.client;
      return o;
    });
    return res.json({ bookings: safe });
  }

  if (req.user.role === "provider") {
    // find provider id for this user
    const prov = await Provider.findOne({ user: req.user.sub });
    if (!prov)
      return res.status(404).json({ error: "Provider profile not found" });
    const bookings = await Booking.find({ provider: prov._id }).populate(
      "client",
      "name",
    );
    const safe = bookings.map((b) => {
      const o = b.toJSON();
      // expose client name only
      if (o.client) {
        o.client = { id: o.client._id, name: o.client.name };
      }
      return o;
    });
    return res.json({ bookings: safe });
  }

  res.status(403).json({ error: "Role not allowed" });
}

// Provider starts job (accepted -> inProgress)
async function startBooking(req, res) {
  if (!req.user || req.user.role !== "provider")
    return res.status(403).json({ error: "Only providers can start jobs" });
  const bookingId = req.params.id;
  const prov = await Provider.findOne({ user: req.user.sub });
  if (!prov)
    return res.status(404).json({ error: "Provider profile not found" });

  try {
    const updated =
      await require("../utils/bookingTransitions").performTransition({
        bookingId,
        filter: { status: "accepted", provider: prov._id },
        setStatus: "inProgress",
        actor: req.user.sub,
      });
    res.json({ booking: updated.toJSON() });
  } catch (err) {
    return res.status(err.status || 400).json({ error: err.message });
  }
}

// Provider completes job (inProgress -> completed)
async function completeBooking(req, res) {
  if (!req.user || req.user.role !== "provider")
    return res.status(403).json({ error: "Only providers can complete jobs" });
  const bookingId = req.params.id;
  const prov = await Provider.findOne({ user: req.user.sub });
  if (!prov)
    return res.status(404).json({ error: "Provider profile not found" });

  try {
    const updated =
      await require("../utils/bookingTransitions").performTransition({
        bookingId,
        filter: { status: "inProgress", provider: prov._id },
        setStatus: "completed",
        actor: req.user.sub,
      });
    res.json({ booking: updated.toJSON() });
  } catch (err) {
    return res.status(err.status || 400).json({ error: err.message });
  }
}

// Client confirms completion (completed -> clientConfirmed)
async function confirmBooking(req, res) {
  if (!req.user || req.user.role !== "client")
    return res
      .status(403)
      .json({ error: "Only clients can confirm completion" });
  const bookingId = req.params.id;

  try {
    const updated =
      await require("../utils/bookingTransitions").performTransition({
        bookingId,
        filter: { status: "completed", client: req.user.sub },
        setStatus: "clientConfirmed",
        actor: req.user.sub,
      });
    res.json({ booking: updated.toJSON() });
  } catch (err) {
    return res.status(err.status || 400).json({ error: err.message });
  }
}
// Provider accepts booking
async function acceptBooking(req, res) {
  if (!req.user || req.user.role !== "provider")
    return res
      .status(403)
      .json({ error: "Only providers can accept bookings" });

  const bookingId = req.params.id;

  const prov = await Provider.findOne({ user: req.user.sub });
  if (!prov)
    return res.status(404).json({ error: "Provider profile not found" });

  try {
    const updated =
      await require("../utils/bookingTransitions").performTransition({
        bookingId,
        filter: { status: "pendingAcceptance", provider: prov._id },
        setStatus: "accepted",
        actor: req.user.sub,
      });
    res.json({ booking: updated.toJSON() });
  } catch (err) {
    return res.status(err.status || 400).json({ error: err.message });
  }
}

// Provider rejects booking
async function rejectBooking(req, res) {
  if (!req.user || req.user.role !== "provider")
    return res
      .status(403)
      .json({ error: "Only providers can reject bookings" });

  const bookingId = req.params.id;
  const prov = await Provider.findOne({ user: req.user.sub });
  if (!prov)
    return res.status(404).json({ error: "Provider profile not found" });

  try {
    const updated =
      await require("../utils/bookingTransitions").performTransition({
        bookingId,
        filter: { status: "pendingAcceptance", provider: prov._id },
        setStatus: "rejected",
        actor: req.user.sub,
      });
    res.json({ booking: updated.toJSON() });
  } catch (err) {
    return res.status(err.status || 400).json({ error: err.message });
  }
}

// Client cancels booking (only before acceptance)
async function cancelBooking(req, res) {
  if (!req.user || req.user.role !== "client")
    return res.status(403).json({ error: "Only clients can cancel bookings" });

  const bookingId = req.params.id;
  const booking = await Booking.findById(bookingId);
  if (!booking) return res.status(404).json({ error: "Booking not found" });
  if (String(booking.client) !== req.user.sub)
    return res.status(403).json({ error: "Not your booking" });
  if (booking.status === "accepted")
    return res.status(400).json({ error: "Cannot cancel after acceptance" });

  booking.status = "cancelled";
  booking.auditTrail.push({
    status: "cancelled",
    actor: req.user.sub,
    at: new Date(),
  });
  await booking.save();

  res.json({ booking: booking.toJSON() });
}

module.exports = {
  getCategories,
  searchProviders,
  createBooking,
  getMyBookings,
  acceptBooking,
  rejectBooking,
  startBooking,
  completeBooking,
  confirmBooking,
  cancelBooking,
};
