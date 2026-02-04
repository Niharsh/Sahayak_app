const express = require("express");
const router = express.Router();
const { authMiddleware } = require("../middleware/auth");
const { requireRole } = require("../middleware/rbac");
const bookings = require("../controllers/bookingController");
const messageController = require("../controllers/messageController");
const { validateObjectId } = require("../middleware/validateObjectId");

// validate :id param for all routes that take booking id
router.param("id", validateObjectId);

router.get("/categories", bookings.getCategories);
router.get("/providers/search", bookings.searchProviders);

router.post("/", authMiddleware, requireRole("client"), bookings.createBooking);
router.get("/me", authMiddleware, bookings.getMyBookings);
router.post(
  "/:id/accept",
  authMiddleware,
  requireRole("provider"),
  bookings.acceptBooking,
);
router.post(
  "/:id/reject",
  authMiddleware,
  requireRole("provider"),
  bookings.rejectBooking,
);
router.post(
  "/:id/start",
  authMiddleware,
  requireRole("provider"),
  bookings.startBooking,
);
router.post(
  "/:id/complete",
  authMiddleware,
  requireRole("provider"),
  bookings.completeBooking,
);
router.post(
  "/:id/confirm",
  authMiddleware,
  requireRole("client"),
  bookings.confirmBooking,
);
router.post(
  "/:id/cancel",
  authMiddleware,
  requireRole("client"),
  bookings.cancelBooking,
);

// Messaging - booking linked
router.post("/:id/messages", authMiddleware, messageController.sendMessage);
router.get("/:id/messages", authMiddleware, messageController.getMessages);

module.exports = router;
