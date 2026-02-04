const express = require("express");
require("express-async-errors");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");
const authRoutes = require("./routes/auth");
const adminRoutes = require("./routes/admin");
const { errorHandler } = require("./middleware/errorHandler");

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan("dev"));

app.use("/auth", authRoutes);
app.use("/providers", require("./routes/providers"));
app.use("/services", require("./routes/services"));
app.use("/bookings", require("./routes/bookings"));
app.use("/admin", adminRoutes);

app.get("/", (req, res) =>
  res.json({ ok: true, message: "Sahayak API (Phase 1)" }),
);

app.use(errorHandler);

module.exports = app;
