const mongoose = require("mongoose");

const LocationSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
    },
  },
  { timestamps: true },
);

// index to support fast prefix and exact search on name
LocationSchema.index({ name: 1 });

module.exports = mongoose.model("Location", LocationSchema);
