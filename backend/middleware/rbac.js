function requireRole(...roles) {
  return (req, res, next) => {
    const role = req.user && req.user.role;
    if (!role) return res.status(403).json({ error: "Missing role" });
    if (!roles.includes(role))
      return res.status(403).json({ error: "Insufficient permissions" });
    next();
  };
}

module.exports = { requireRole };
