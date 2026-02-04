const express = require("express");
const router = express.Router();
const { authMiddleware } = require("../middleware/auth");
const { requireRole } = require("../middleware/rbac");
const { upload } = require("../middleware/upload");
const { apply, getMe, updateMe } = require("../controllers/providerController");

router.post(
  "/apply",
  authMiddleware,
  requireRole("provider"),
  upload.fields([
    { name: "identity", maxCount: 2 },
    { name: "skill", maxCount: 2 },
  ]),
  apply,
);
router.get("/me", authMiddleware, requireRole("provider"), getMe);
router.put(
  "/me",
  authMiddleware,
  requireRole("provider"),
  upload.fields([
    { name: "identity", maxCount: 2 },
    { name: "skill", maxCount: 2 },
  ]),
  updateMe,
);

// public provider search endpoint
const bookingsController = require("../controllers/bookingController");
router.get("/search", bookingsController.searchProviders);

module.exports = router;
