require("dotenv").config();
const { connectDB, stopDB } = require("../config/db");
const Location = require("../models/Location");

const LOCATIONS = [
  "gurgaon",
  "ghaziabad",
  "noida",
  "delhi",
  "faridabad",
  "gandhinagar",
];

async function seed() {
  await connectDB();
  try {
    for (const name of LOCATIONS) {
      const normalized = String(name).trim().toLowerCase();
      await Location.updateOne(
        { name: normalized },
        { $setOnInsert: { name: normalized } },
        { upsert: true },
      );
      console.log("Upserted location", normalized);
    }
    console.log("Seed complete");
  } catch (err) {
    console.error("Seed failed", err);
    process.exit(1);
  } finally {
    await stopDB();
    process.exit(0);
  }
}

seed();
