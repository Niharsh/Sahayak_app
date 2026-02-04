const Joi = require("joi");
const Message = require("../models/Message");
const Booking = require("../models/Booking");
const Provider = require("../models/Provider");

const sendSchema = Joi.object({
  content: Joi.string().min(1).max(1000).required(),
});

function containsContactInfo(text) {
  // basic checks: phone numbers or emails
  const phoneRe = /\+?[0-9][0-9\-().\s]{6,}[0-9]/;
  const emailRe = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i;
  return phoneRe.test(text) || emailRe.test(text);
}

async function sendMessage(req, res) {
  const bookingId = req.params.id;
  const { error, value } = sendSchema.validate(req.body || {});
  if (error) return res.status(400).json({ error: error.message });

  const mongoose = require("mongoose");
  if (!mongoose.Types.ObjectId.isValid(bookingId))
    return res.status(400).json({ error: "Invalid booking id" });

  const booking = await Booking.findById(bookingId)
    .populate("provider")
    .populate("client");
  if (!booking) return res.status(404).json({ error: "Booking not found" });

  // only allowed states
  if (!["accepted", "inProgress"].includes(booking.status))
    return res
      .status(400)
      .json({ error: "Messaging not allowed in current booking state" });

  const senderId = req.user.sub;
  const senderRole = req.user.role;

  // sender must be booking participant
  const clientId = String(booking.client);
  const providerId = booking.provider ? String(booking.provider._id) : null;

  // resolve provider user id
  let providerUserId = null;
  if (booking.provider && booking.provider.user)
    providerUserId = String(booking.provider.user);

  if (senderRole === "client") {
    if (senderId !== clientId)
      return res.status(403).json({ error: "Not participant" });
    if (!providerUserId)
      return res.status(400).json({ error: "No provider assigned" });
  } else if (senderRole === "provider") {
    // provider's user must match booking.provider.user
    if (!providerUserId || senderId !== providerUserId)
      return res.status(403).json({ error: "Not participant" });
  } else return res.status(403).json({ error: "Role not allowed" });

  const content = value.content.trim();
  if (containsContactInfo(content))
    return res.status(400).json({
      error: "Message contains contact information which is not allowed",
    });

  // set receiver as the other participant
  const receiver = senderId === clientId ? providerUserId : clientId;

  const message = new Message({
    booking: booking._id,
    sender: senderId,
    receiver,
    content,
  });
  await message.save();
  res.status(201).json({ message: message.toJSON() });
}

async function getMessages(req, res) {
  const bookingId = req.params.id;
  const mongoose = require("mongoose");
  if (!mongoose.Types.ObjectId.isValid(bookingId))
    return res.status(400).json({ error: "Invalid booking id" });

  const booking = await Booking.findById(bookingId)
    .populate("provider")
    .populate("client");
  if (!booking) return res.status(404).json({ error: "Booking not found" });

  const senderId = req.user.sub;
  const senderRole = req.user.role;

  const clientId = String(booking.client);
  let providerUserId = null;
  if (booking.provider && booking.provider.user)
    providerUserId = String(booking.provider.user);

  if (senderRole === "client") {
    if (senderId !== clientId)
      return res.status(403).json({ error: "Not participant" });
  } else if (senderRole === "provider") {
    if (!providerUserId || senderId !== providerUserId)
      return res.status(403).json({ error: "Not participant" });
  } else return res.status(403).json({ error: "Role not allowed" });

  // messages allowed only in accepted or inProgress
  if (!["accepted", "inProgress"].includes(booking.status))
    return res
      .status(400)
      .json({ error: "Messaging not allowed in current booking state" });

  const messages = await Message.find({ booking: booking._id })
    .sort({ createdAt: 1 })
    .populate("sender", "name")
    .populate("receiver", "name");

  // redact any sensitive fields in user objects
  const out = messages.map((m) => {
    const obj = m.toJSON();
    if (obj.sender && obj.sender.email) delete obj.sender.email;
    if (obj.receiver && obj.receiver.email) delete obj.receiver.email;
    return obj;
  });

  res.json({ messages: out });
}

module.exports = { sendMessage, getMessages };
