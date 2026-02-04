const Booking = require("../models/Booking");

async function performTransition({ bookingId, filter = {}, setStatus, actor }) {
  // filter should include any necessary constraints: status, provider/client, etc
  // will perform atomic findOneAndUpdate to avoid races
  const q = Object.assign({ _id: bookingId }, filter);
  const update = {
    $set: { status: setStatus },
    $push: {
      auditTrail: {
        status: setStatus,
        actor: actor || null,
        at: new Date(),
      },
    },
  };

  const updated = await Booking.findOneAndUpdate(q, update, { new: true });
  if (!updated) {
    const reason =
      filter && filter.status
        ? `Expected status ${filter.status}`
        : "Invalid transition or no permission";
    const err = new Error(`Booking not available for transition: ${reason}`);
    err.status = 400;
    throw err;
  }
  return updated;
}

module.exports = { performTransition };
