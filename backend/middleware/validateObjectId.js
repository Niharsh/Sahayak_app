const mongoose = require("mongoose");

function validateObjectId(req, res, next, id) {
  if (!mongoose.Types.ObjectId.isValid(id)) {
    return res.status(400).json({ error: "Invalid id" });
  }
  next();
}

module.exports = { validateObjectId };
