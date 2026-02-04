const mongoose = require("mongoose");

const fileSchema = new mongoose.Schema({
  path: { type: String, required: true },
  filename: { type: String },
  type: {
    type: String,
    enum: ["identity", "skill", "other"],
    default: "other",
  },
  uploadedAt: { type: Date, default: Date.now },
});

const verificationStageSchema = new mongoose.Schema({
  status: {
    type: String,
    enum: ["pending", "approved", "rejected"],
    default: "pending",
  },
  approvedBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  approvedAt: { type: Date },
  reason: { type: String },
  documents: [fileSchema],
});

const providerSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      unique: true,
    },
    serviceCategory: { type: String },
    serviceAreas: [{ type: String }],
    experienceYears: { type: Number },
    verificationLevel: { type: Number, default: 0 }, // 0=applied,1=identity,2=skill,3=trusted
    verification: {
      identity: { type: verificationStageSchema, default: () => ({}) },
      skill: { type: verificationStageSchema, default: () => ({}) },
      trust: { type: verificationStageSchema, default: () => ({}) },
    },
    documents: [fileSchema],
  },
  { timestamps: true },
);

providerSchema.set("toJSON", {
  transform: (doc, ret) => {
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model("Provider", providerSchema);
