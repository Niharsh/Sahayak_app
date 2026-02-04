const express = require("express");
const router = express.Router();
const { authMiddleware } = require("../middleware/auth");
const { requireRole } = require("../middleware/rbac");
const Provider = require("../models/Provider");
const Audit = require("../models/Audit");

// simple ping
router.get("/ping", authMiddleware, requireRole("admin"), (req, res) => {
  res.json({ ok: true, message: "Admin-only endpoint" });
});

// list providers by status (query ?status=pending)
router.get(
  "/providers",
  authMiddleware,
  requireRole("admin"),
  async (req, res) => {
    const status = req.query.status;
    let query = {};
    if (status === "pending") {
      // pending if identity or skill stage is pending
      query = {
        $or: [
          { "verification.identity.status": "pending" },
          { "verification.skill.status": "pending" },
        ],
      };
    }
    const providers = await Provider.find(query).populate("user", "name");
    const safe = providers.map((p) => {
      const o = p.toJSON();
      // redact sensitive info
      if (o.user) delete o.user.email;
      return o;
    });
    res.json({ providers: safe });
  },
);

// verify identity
router.post(
  "/providers/:id/verify-identity",
  authMiddleware,
  requireRole("admin"),
  async (req, res) => {
    const providerId = req.params.id;
    const { action, reason } = req.body; // action: approve | reject
    if (!["approve", "reject"].includes(action))
      return res.status(400).json({ error: "Invalid action" });

    const provider = await Provider.findById(providerId);
    if (!provider) return res.status(404).json({ error: "Provider not found" });

    if (
      provider.verification.identity &&
      provider.verification.identity.status === "approved"
    ) {
      return res.status(400).json({ error: "Identity already approved" });
    }

    if (action === "reject") {
      provider.verification.identity.status = "rejected";
      provider.verification.identity.approvedBy = req.user.sub;
      provider.verification.identity.approvedAt = new Date();
      provider.verification.identity.reason = reason;
    } else {
      provider.verification.identity.status = "approved";
      provider.verification.identity.approvedBy = req.user.sub;
      provider.verification.identity.approvedAt = new Date();
      // update verificationLevel monotonic
      if (provider.verificationLevel < 1) provider.verificationLevel = 1;
    }

    await provider.save();

    await Audit.create({
      action: `identity_${action}`,
      admin: req.user.sub,
      provider: provider._id,
      details: { reason },
    });

    res.json({ provider: provider.toJSON() });
  },
);

// verify skill
router.post(
  "/providers/:id/verify-skill",
  authMiddleware,
  requireRole("admin"),
  async (req, res) => {
    const providerId = req.params.id;
    const { action, reason } = req.body; // action: approve | reject
    if (!["approve", "reject"].includes(action))
      return res.status(400).json({ error: "Invalid action" });

    const provider = await Provider.findById(providerId);
    if (!provider) return res.status(404).json({ error: "Provider not found" });

    // cannot progress to skill unless identity approved
    if (
      !provider.verification.identity ||
      provider.verification.identity.status !== "approved"
    ) {
      return res
        .status(400)
        .json({ error: "Identity must be approved before skill verification" });
    }

    if (
      provider.verification.skill &&
      provider.verification.skill.status === "approved"
    ) {
      return res.status(400).json({ error: "Skill already approved" });
    }

    if (action === "reject") {
      provider.verification.skill.status = "rejected";
      provider.verification.skill.approvedBy = req.user.sub;
      provider.verification.skill.approvedAt = new Date();
      provider.verification.skill.reason = reason;
    } else {
      provider.verification.skill.status = "approved";
      provider.verification.skill.approvedBy = req.user.sub;
      provider.verification.skill.approvedAt = new Date();
      // update verificationLevel monotonic
      if (provider.verificationLevel < 2) provider.verificationLevel = 2;
    }

    await provider.save();

    await Audit.create({
      action: `skill_${action}`,
      admin: req.user.sub,
      provider: provider._id,
      details: { reason },
    });

    res.json({ provider: provider.toJSON() });
  },
);

module.exports = router;
