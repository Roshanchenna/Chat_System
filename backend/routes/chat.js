// routes/chat.js
const express = require('express');
const Room = require('../models/Room');
const router = express.Router();

router.post('/create-room', async (req, res) => {
  const code = Math.floor(1000 + Math.random() * 9000).toString();
  const room = new Room({ code });
  await room.save();
  res.json({ code });
});

router.post('/join-room', async (req, res) => {
  const { code, username } = req.body;
  const room = await Room.findOne({ code });
  if (!room) {
    return res.status(404).json({ message: 'Room not found' });
  }
  if (room.users.length >= 2) {
    return res.status(400).json({ message: 'Room is full' });
  }
  room.users.push(username);
  await room.save();
  res.json({ message: 'Joined room successfully' });
});

module.exports = router;
