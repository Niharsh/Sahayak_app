const mongoose = require("mongoose");
let MongoMemoryServer;
try {
  MongoMemoryServer = require("mongodb-memory-server").MongoMemoryServer;
} catch (err) {
  MongoMemoryServer = null;
}

let mongod;

async function connectDB() {
  let uri = process.env.MONGODB_URI;

  if (!uri) {
    if (!MongoMemoryServer) {
      throw new Error(
        "MONGODB_URI not set and mongodb-memory-server is not available. Set MONGODB_URI in your .env to an Atlas or local MongoDB instance.",
      );
    }
    // Start an in-memory MongoDB for local development/testing
    mongod = await MongoMemoryServer.create();
    uri = mongod.getUri();
    console.log("Using in-memory MongoDB for development");
  }

  await mongoose.connect(uri, {
    // options if needed
  });
  console.log("Connected to MongoDB at", uri);
}

async function stopDB() {
  await mongoose.disconnect();
  if (mongod) await mongod.stop();
}

module.exports = { connectDB, stopDB };
