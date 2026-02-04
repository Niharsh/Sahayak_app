require("dotenv").config();
const http = require("http");
const app = require("./app");
const { connectDB } = require("./config/db");

const PORT = process.env.PORT || 5000;

connectDB()
  .then(() => {
    const server = http.createServer(app);
    server.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error("Failed to start server:", err);
    process.exit(1);
  });
