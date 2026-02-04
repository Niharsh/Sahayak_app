const Location = require("../models/Location");

function escapeRegex(str) {
  // escape regex special chars
  return String(str).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

async function search(req, res) {
  const q = String(req.query.q || "").trim();
  if (!q) return res.json([]);

  const regex = new RegExp("^" + escapeRegex(q), "i");

  const docs = await Location.find({ name: { $regex: regex } })
    .limit(10)
    .select("name -_id")
    .lean();

  const names = docs.map((d) => d.name);
  res.json(names);
}

module.exports = { search };
