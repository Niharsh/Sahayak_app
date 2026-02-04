const mongoose = require("mongoose");

const auditSchema = new mongoose.Schema(
  {
    action: { type: String, required: true },
    admin: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    provider: { type: mongoose.Schema.Types.ObjectId, ref: "Provider" },
    details: { type: Object },
  },
  { timestamps: true },
);

module.exports = mongoose.model("Audit", auditSchema);
