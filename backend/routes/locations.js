const express = require("express");
const router = express.Router();
const { search } = require("../controllers/locationController");

// GET /locations/search?q=...
router.get("/search", search);

module.exports = router;
