const mongoose = require("mongoose");
const shortid = require("shortid");

const messageSchema = new mongoose.Schema(
  {
    messageId: {
      type: String,
      default: () => shortid.generate(),
      unique: true,
    },
    booking: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Booking",
      required: true,
    },
    sender: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    receiver: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    content: { type: String, required: true },
  },
  { timestamps: { createdAt: "createdAt" } },
);

messageSchema.set("toJSON", {
  transform: (doc, ret) => {
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model("Message", messageSchema);
