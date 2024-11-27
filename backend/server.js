// server.js
const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Room = require('./models/Room'); // Import the Room model
const chatRoutes = require('./routes/chat');

dotenv.config(); // Load environment variables

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

// Middleware for parsing JSON request bodies
app.use(express.json()); // Move this line to the top

// Use your chat routes
app.use('/api', chatRoutes);

// MongoDB connection
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB connected'))
  .catch((err) => console.error(err));

// Handle WebSocket connections
wss.on('connection', (ws) => {
  console.log('A new client connected');

  ws.on('message', async (message) => {
    const data = JSON.parse(message);

    // When a user sends a message to the chat
    if (data.type === 'message') {
      const room = await Room.findOne({ code: data.code });
      if (room) {
        wss.clients.forEach((client) => {
          if (client.readyState === WebSocket.OPEN && room.users.includes(client.username)) {
            client.send(JSON.stringify({
              type: 'message',
              sender: data.sender,
              text: data.text,
              timestamp: new Date(),
            }));
          }
        });
      }
    }
  });

  // When a user disconnects
  ws.on('close', () => {
    console.log('Client disconnected');
  });
});

// API to create a new room
app.post('/create-room', async (req, res) => {
  const code = Math.floor(1000 + Math.random() * 9000).toString(); // Generate a random 4-digit code

  const room = new Room({
    code: code,
    users: [], // Users will be added later
  });

  try {
    await room.save();
    res.json({ code });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Error creating room' });
  }
});

// API to join a room
app.post('/join-room', async (req, res) => {
  const { code, username } = req.body; // This line will now work

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

// Start the server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
