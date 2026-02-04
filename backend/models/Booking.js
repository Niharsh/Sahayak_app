const mongoose = require("mongoose");
const shortid = require("shortid");

const auditEntrySchema = new mongoose.Schema({
  status: { type: String, required: true },
  actor: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  note: { type: String },
  at: { type: Date, default: Date.now },
});

const bookingSchema = new mongoose.Schema(
  {
    bookingId: {
      type: String,
      default: () => shortid.generate(),
      unique: true,
    },
    client: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    provider: { type: mongoose.Schema.Types.ObjectId, ref: "Provider" },
    serviceCategory: { type: String, required: true },
    serviceArea: { type: String, required: true },
    schedule: { type: Date, required: true },
    price: { type: Number, default: 0 },
    status: {
      type: String,
      enum: [
        "created",
        "pendingAcceptance",
        "accepted",
        "inProgress",
        "completed",
        "clientConfirmed",
        "rejected",
        "cancelled",
      ],
      default: "created",
    },
    auditTrail: [auditEntrySchema],
  },
  { timestamps: true },
);

bookingSchema.set("toJSON", {
  transform: (doc, ret) => {
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model("Booking", bookingSchema);
