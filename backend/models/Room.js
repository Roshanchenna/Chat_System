// models/Room.js
const mongoose = require('mongoose');

const roomSchema = new mongoose.Schema({
  code: { type: String, required: true, unique: true },
  users: { type: [String], default: [] }, // Store user names or user IDs
});

const Room = mongoose.model('Room', roomSchema);
module.exports = Room;
