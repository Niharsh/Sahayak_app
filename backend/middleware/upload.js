const path = require("path");
const fs = require("fs");
const multer = require("multer");

const uploadsDir = path.join(__dirname, "..", "uploads");
if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir);

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadsDir);
  },
  filename: function (req, file, cb) {
    const name = `${Date.now()}-${file.originalname.replace(/\s+/g, "_")}`;
    cb(null, name);
  },
});

const upload = multer({ storage });

module.exports = { upload };
