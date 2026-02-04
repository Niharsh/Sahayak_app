const ALLOWED = [
  "maid",
  "plumber",
  "electrician",
  "painter",
  "gardener",
  "barber",
];

function normalizeCategory(v) {
  if (!v) return "";
  return String(v).trim().toLowerCase();
}

function isValidCategory(v) {
  const n = normalizeCategory(v);
  return ALLOWED.includes(n);
}

module.exports = { ALLOWED, normalizeCategory, isValidCategory };
