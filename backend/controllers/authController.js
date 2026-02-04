const Joi = require("joi");
const bcrypt = require("bcryptjs");
const User = require("../models/User");
const { generateToken } = require("../utils/jwt");

const registerSchema = Joi.object({
  name: Joi.string().min(2).max(100).required(),
  email: Joi.string().email().required(),
  phone: Joi.string().optional(),
  password: Joi.string().min(6).required(),
  role: Joi.string().valid("client", "provider", "admin").required(),
});

async function register(req, res) {
  const { error, value } = registerSchema.validate(req.body);
  if (error) return res.status(400).json({ error: error.message });

  const { name, email, phone, password, role } = value;
  const existing = await User.findOne({ email });
  if (existing)
    return res.status(409).json({ error: "Email already registered" });

  const salt = await bcrypt.genSalt(10);
  const passwordHash = await bcrypt.hash(password, salt);

  const user = new User({ name, email, phone, passwordHash, role });
  await user.save();

  const token = generateToken({ sub: user._id.toString(), role: user.role });

  res.status(201).json({ token, user: user.toJSON() });
}

const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});

async function login(req, res) {
  const { error, value } = loginSchema.validate(req.body);
  if (error) return res.status(400).json({ error: error.message });

  const { email, password } = value;
  const user = await User.findOne({ email });
  if (!user) return res.status(401).json({ error: "Invalid credentials" });

  const match = await bcrypt.compare(password, user.passwordHash);
  if (!match) return res.status(401).json({ error: "Invalid credentials" });

  const token = generateToken({ sub: user._id.toString(), role: user.role });

  res.json({ token, user: user.toJSON() });
}

async function me(req, res) {
  // authMiddleware attached user
  const user = await User.findById(req.user.sub);
  if (!user) return res.status(404).json({ error: "User not found" });
  res.json({ user: user.toJSON() });
}

module.exports = { register, login, me };
