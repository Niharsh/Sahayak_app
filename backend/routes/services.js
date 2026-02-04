const express = require("express");
const router = express.Router();
const bookingsController = require("../controllers/bookingController");

router.get("/categories", bookingsController.getCategories);

module.exports = router;
