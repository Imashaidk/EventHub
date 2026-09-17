const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 5000;
const DB_FILE = path.join(__dirname, 'database.json');

app.use(cors());
app.use(express.json());

// Initial Seed Data
const initialData = {
  users: [
    {
      id: "usr_1",
      name: "Alex Morgan",
      email: "alex@eventhub.com",
      password: "password123",
      phone: "+1 (555) 234-5678",
      role: "user",
      avatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80",
      bio: "Tech enthusiast, live music lover, and frequent weekend traveler.",
      createdAt: "2026-01-10T10:00:00.000Z"
    },
    {
      id: "usr_org1",
      name: "Summit Productions",
      email: "organizer@eventhub.com",
      password: "password123",
      phone: "+1 (555) 876-5432",
      role: "organizer",
      avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80",
      bio: "Premier event management team curating unforgettable tech summits and concerts.",
      createdAt: "2026-01-05T08:30:00.000Z"
    }
  ],
  events: [
    {
      id: "evt_1",
      title: "Global Tech Innovators Summit 2026",
      description: "Join world-class engineers, founders, and AI visionaries for three days of keynotes, breakthrough architecture showcases, and hands-on developer workshops. Network with over 2,000 attendees from leading tech companies.",
      category: "Technology",
      date: "2026-10-15",
      time: "09:00 AM - 05:00 PM",
      location: "Metropolitan Convention Center, New York, NY",
      price: 149.00,
      availableSeats: 85,
      totalSeats: 300,
      organizerId: "usr_org1",
      organizerName: "Summit Productions",
      image: "https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=1200&q=80",
      featured: true,
      tags: ["AI", "Cloud", "Developer", "Networking"],
      createdAt: "2026-01-12T12:00:00.000Z"
    },
    {
      id: "evt_2",
      title: "Neon Pulse Electronic Music Festival",
      description: "Experience electrifying soundscapes with top international DJs, mind-bending holographic visuals, laser displays, and premium open-air festival vibes.",
      category: "Music",
      date: "2026-10-24",
      time: "06:00 PM - 02:00 AM",
      location: "Pier 40 Waterfront Pavilion, San Francisco, CA",
      price: 79.50,
      availableSeats: 210,
      totalSeats: 500,
      organizerId: "usr_org1",
      organizerName: "Summit Productions",
      image: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=1200&q=80",
      featured: true,
      tags: ["Music", "Festival", "Nightlife", "EDM"],
      createdAt: "2026-01-14T14:20:00.000Z"
    },
    {
      id: "evt_3",
      title: "Artisan Coffee & Culinary Expo",
      description: "A celebration of world roast profiles, specialty brews, pastry pairing masterclasses, and live barista championship showdowns.",
      category: "Food & Drinks",
      date: "2026-11-02",
      time: "10:00 AM - 04:00 PM",
      location: "Grand Market Hall, Seattle, WA",
      price: 35.00,
      availableSeats: 42,
      totalSeats: 150,
      organizerId: "usr_org1",
      organizerName: "Summit Productions",
      image: "https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=1200&q=80",
      featured: false,
      tags: ["Coffee", "Food", "Culinary", "Tasting"],
      createdAt: "2026-01-18T09:00:00.000Z"
    },
    {
      id: "evt_4",
      title: "Urban Marathon & Charity 10K",
      description: "Lace up your running shoes and traverse scenic harbor trails in the annual city charity race. Includes finisher medals, timing chips, hydration stations, and after-party.",
      category: "Sports",
      date: "2026-11-14",
      time: "07:00 AM - 12:00 PM",
      location: "Downtown Harbor Trail, Boston, MA",
      price: 45.00,
      availableSeats: 120,
      totalSeats: 400,
      organizerId: "usr_org1",
      organizerName: "Summit Productions",
      image: "https://images.unsplash.com/photo-1452626038306-9aae5e071dd3?auto=format&fit=crop&w=1200&q=80",
      featured: true,
      tags: ["Fitness", "Marathon", "Running", "Charity"],
      createdAt: "2026-01-20T11:45:00.000Z"
    },
    {
      id: "evt_5",
      title: "Modern Canvas & Abstract Painting Workshop",
      description: "Unleash your artistic expression in an immersive studio workshop led by renowned contemporary artists. All canvases, acrylics, brushes, and complimentary wine included.",
      category: "Arts & Culture",
      date: "2026-11-20",
      time: "02:00 PM - 06:00 PM",
      location: "SoHo Art Collective, New York, NY",
      price: 60.00,
      availableSeats: 18,
      totalSeats: 30,
      organizerId: "usr_org1",
      organizerName: "Summit Productions",
      image: "https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?auto=format&fit=crop&w=1200&q=80",
      featured: false,
      tags: ["Art", "Workshop", "Painting", "Creativity"],
      createdAt: "2026-01-22T16:10:00.000Z"
    },
    {
      id: "evt_6",
      title: "Future of Clean Energy & Climate Summit",
      description: "Discover breakthrough renewable energy solutions, battery innovations, and ESG policies shaping sustainable industries worldwide.",
      category: "Business",
      date: "2026-12-05",
      time: "09:30 AM - 04:30 PM",
      location: "Green Center Hall, Austin, TX",
      price: 95.00,
      availableSeats: 70,
      totalSeats: 250,
      organizerId: "usr_org1",
      organizerName: "Summit Productions",
      image: "https://images.unsplash.com/photo-1497435334941-8c899ee9e8e9?auto=format&fit=crop&w=1200&q=80",
      featured: false,
      tags: ["Energy", "Sustainability", "Climate", "Business"],
      createdAt: "2026-01-25T10:00:00.000Z"
    }
  ],
  bookings: [
    {
      id: "bk_1",
      eventId: "evt_1",
      eventTitle: "Global Tech Innovators Summit 2026",
      eventImage: "https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=1200&q=80",
      eventDate: "2026-10-15",
      eventTime: "09:00 AM - 05:00 PM",
      eventLocation: "Metropolitan Convention Center, New York, NY",
      userId: "usr_1",
      userName: "Alex Morgan",
      userEmail: "alex@eventhub.com",
      userPhone: "+1 (555) 234-5678",
      ticketsCount: 2,
      ticketPrice: 149.00,
      totalPrice: 298.00,
      status: "confirmed", // 'confirmed', 'cancelled'
      bookingReference: "EH-89241-TX",
      createdAt: "2026-02-01T14:22:00.000Z"
    }
  ]
};

// Database helper functions
function loadDatabase() {
  try {
    if (!fs.existsSync(DB_FILE)) {
      fs.writeFileSync(DB_FILE, JSON.stringify(initialData, null, 2), 'utf-8');
      return initialData;
    }
    const data = fs.readFileSync(DB_FILE, 'utf-8');
    return JSON.parse(data);
  } catch (err) {
    console.error('Error reading database file:', err);
    return initialData;
  }
}

function saveDatabase(data) {
  try {
    fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2), 'utf-8');
  } catch (err) {
    console.error('Error writing database file:', err);
  }
}

// Request logger middleware
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'EventHub REST API is operational',
    timestamp: new Date().toISOString()
  });
});

// Categories list
app.get('/api/categories', (req, res) => {
  const db = loadDatabase();
  const categories = Array.from(new Set(db.events.map(e => e.category)));
  res.json({ success: true, categories });
});

// ----------------------------------------------------
// AUTH & USERS ENDPOINTS
// ----------------------------------------------------
app.post('/api/auth/register', (req, res) => {
  const { name, email, password, phone, role } = req.body;
  if (!name || !email || !password) {
    return res.status(400).json({ success: false, message: 'Name, email, and password are required' });
  }

  const db = loadDatabase();
  const existingUser = db.users.find(u => u.email.toLowerCase() === email.toLowerCase());
  if (existingUser) {
    return res.status(409).json({ success: false, message: 'An account with this email already exists' });
  }

  const newUser = {
    id: `usr_${Date.now()}`,
    name,
    email,
    password,
    phone: phone || '',
    role: role || 'user',
    avatar: `https://api.dicebear.com/7.x/initials/svg?seed=${encodeURIComponent(name)}`,
    bio: '',
    createdAt: new Date().toISOString()
  };

  db.users.push(newUser);
  saveDatabase(db);

  // Exclude password from response
  const { password: _, ...userSafe } = newUser;
  res.status(201).json({
    success: true,
    message: 'Account created successfully',
    token: `token_${newUser.id}_${Date.now()}`,
    user: userSafe
  });
});

app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ success: false, message: 'Email and password are required' });
  }

  const db = loadDatabase();
  const user = db.users.find(
    u => u.email.toLowerCase() === email.toLowerCase() && u.password === password
  );

  if (!user) {
    return res.status(401).json({ success: false, message: 'Invalid email or password credentials' });
  }

  const { password: _, ...userSafe } = user;
  res.json({
    success: true,
    message: 'Login successful',
    token: `token_${user.id}_${Date.now()}`,
    user: userSafe
  });
});

app.get('/api/auth/profile/:id', (req, res) => {
  const db = loadDatabase();
  const user = db.users.find(u => u.id === req.params.id);
  if (!user) {
    return res.status(404).json({ success: false, message: 'User not found' });
  }
  const { password: _, ...userSafe } = user;
  res.json({ success: true, user: userSafe });
});

app.put('/api/auth/profile/:id', (req, res) => {
  const { name, phone, bio, avatar, role } = req.body;
  const db = loadDatabase();
  const userIndex = db.users.findIndex(u => u.id === req.params.id);

  if (userIndex === -1) {
    return res.status(404).json({ success: false, message: 'User not found' });
  }

  const user = db.users[userIndex];
  if (name !== undefined) user.name = name;
  if (phone !== undefined) user.phone = phone;
  if (bio !== undefined) user.bio = bio;
  if (avatar !== undefined) user.avatar = avatar;
  if (role !== undefined) user.role = role;

  saveDatabase(db);
  const { password: _, ...userSafe } = user;
  res.json({ success: true, message: 'Profile updated successfully', user: userSafe });
});

// ----------------------------------------------------
// EVENTS ENDPOINTS
// ----------------------------------------------------
app.get('/api/events', (req, res) => {
  const { category, search, organizerId } = req.query;
  const db = loadDatabase();
  let events = db.events;

  if (category && category.toLowerCase() !== 'all') {
    events = events.filter(e => e.category.toLowerCase() === category.toLowerCase());
  }

  if (search) {
    const q = search.toLowerCase();
    events = events.filter(e =>
      e.title.toLowerCase().includes(q) ||
      e.description.toLowerCase().includes(q) ||
      e.location.toLowerCase().includes(q) ||
      (e.tags && e.tags.some(t => t.toLowerCase().includes(q)))
    );
  }

  if (organizerId) {
    events = events.filter(e => e.organizerId === organizerId);
  }

  res.json({ success: true, count: events.length, events });
});

app.get('/api/events/:id', (req, res) => {
  const db = loadDatabase();
  const event = db.events.find(e => e.id === req.params.id);
  if (!event) {
    return res.status(404).json({ success: false, message: 'Event not found' });
  }
  res.json({ success: true, event });
});

app.post('/api/events', (req, res) => {
  const {
    title, description, category, date, time, location,
    price, totalSeats, organizerId, organizerName, image, tags
  } = req.body;

  if (!title || !category || !date || !location || totalSeats === undefined) {
    return res.status(400).json({ success: false, message: 'Required event fields are missing' });
  }

  const db = loadDatabase();
  const newEvent = {
    id: `evt_${Date.now()}`,
    title,
    description: description || '',
    category,
    date,
    time: time || 'TBD',
    location,
    price: parseFloat(price) || 0.0,
    availableSeats: parseInt(totalSeats, 10),
    totalSeats: parseInt(totalSeats, 10),
    organizerId: organizerId || 'usr_org1',
    organizerName: organizerName || 'Event Organizer',
    image: image || 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80',
    featured: false,
    tags: Array.isArray(tags) ? tags : [category],
    createdAt: new Date().toISOString()
  };

  db.events.unshift(newEvent);
  saveDatabase(db);
  res.status(201).json({ success: true, message: 'Event created successfully', event: newEvent });
});

app.put('/api/events/:id', (req, res) => {
  const db = loadDatabase();
  const eventIndex = db.events.findIndex(e => e.id === req.params.id);
  if (eventIndex === -1) {
    return res.status(404).json({ success: false, message: 'Event not found' });
  }

  const event = db.events[eventIndex];
  const {
    title, description, category, date, time, location,
    price, totalSeats, image, tags
  } = req.body;

  if (title !== undefined) event.title = title;
  if (description !== undefined) event.description = description;
  if (category !== undefined) event.category = category;
  if (date !== undefined) event.date = date;
  if (time !== undefined) event.time = time;
  if (location !== undefined) event.location = location;
  if (price !== undefined) event.price = parseFloat(price);
  if (image !== undefined) event.image = image;
  if (tags !== undefined) event.tags = tags;
  if (totalSeats !== undefined) {
    const seatDiff = parseInt(totalSeats, 10) - event.totalSeats;
    event.totalSeats = parseInt(totalSeats, 10);
    event.availableSeats = Math.max(0, event.availableSeats + seatDiff);
  }

  saveDatabase(db);
  res.json({ success: true, message: 'Event updated successfully', event });
});

app.delete('/api/events/:id', (req, res) => {
  const db = loadDatabase();
  const eventIndex = db.events.findIndex(e => e.id === req.params.id);
  if (eventIndex === -1) {
    return res.status(404).json({ success: false, message: 'Event not found' });
  }

  const deleted = db.events.splice(eventIndex, 1)[0];
  saveDatabase(db);
  res.json({ success: true, message: 'Event deleted successfully', event: deleted });
});

// ----------------------------------------------------
// BOOKINGS ENDPOINTS
// ----------------------------------------------------
app.post('/api/bookings', (req, res) => {
  const { eventId, userId, userName, userEmail, userPhone, ticketsCount, notes } = req.body;
  const count = parseInt(ticketsCount, 10) || 1;

  if (!eventId || !userId || !userName || !userEmail) {
    return res.status(400).json({ success: false, message: 'Event ID, User details and tickets count are required' });
  }

  const db = loadDatabase();
  const event = db.events.find(e => e.id === eventId);
  if (!event) {
    return res.status(404).json({ success: false, message: 'Event not found' });
  }

  if (event.availableSeats < count) {
    return res.status(400).json({
      success: false,
      message: `Only ${event.availableSeats} seats remaining. Cannot book ${count} tickets.`
    });
  }

  // Deduct available seats
  event.availableSeats -= count;

  const newBooking = {
    id: `bk_${Date.now()}`,
    eventId: event.id,
    eventTitle: event.title,
    eventImage: event.image,
    eventDate: event.date,
    eventTime: event.time,
    eventLocation: event.location,
    userId,
    userName,
    userEmail,
    userPhone: userPhone || '',
    ticketsCount: count,
    ticketPrice: event.price,
    totalPrice: +(event.price * count).toFixed(2),
    status: 'confirmed',
    bookingReference: `EH-${Math.floor(10000 + Math.random() * 90000)}-${Math.random().toString(36).substring(2, 5).toUpperCase()}`,
    notes: notes || '',
    createdAt: new Date().toISOString()
  };

  db.bookings.unshift(newBooking);
  saveDatabase(db);

  res.status(201).json({
    success: true,
    message: 'Booking confirmed successfully!',
    booking: newBooking
  });
});

app.get('/api/bookings/user/:userId', (req, res) => {
  const db = loadDatabase();
  const userBookings = db.bookings.filter(b => b.userId === req.params.userId);
  res.json({ success: true, count: userBookings.length, bookings: userBookings });
});

app.get('/api/bookings/event/:eventId', (req, res) => {
  const db = loadDatabase();
  const eventBookings = db.bookings.filter(b => b.eventId === req.params.eventId);
  res.json({ success: true, count: eventBookings.length, bookings: eventBookings });
});

app.post('/api/bookings/:id/cancel', (req, res) => {
  const db = loadDatabase();
  const booking = db.bookings.find(b => b.id === req.params.id);
  if (!booking) {
    return res.status(404).json({ success: false, message: 'Booking not found' });
  }

  if (booking.status === 'cancelled') {
    return res.status(400).json({ success: false, message: 'Booking is already cancelled' });
  }

  booking.status = 'cancelled';
  booking.cancelledAt = new Date().toISOString();

  // Restore available seats on event
  const event = db.events.find(e => e.id === booking.eventId);
  if (event) {
    event.availableSeats = Math.min(event.totalSeats, event.availableSeats + booking.ticketsCount);
  }

  saveDatabase(db);
  res.json({ success: true, message: 'Booking cancelled successfully', booking });
});

// Start Express server
const server = app.listen(PORT, () => {
  console.log(`=============================================`);
  console.log(` EventHub REST API Server running on port ${PORT}`);
  console.log(` http://localhost:${PORT}/api/health`);
  console.log(`=============================================`);
});

module.exports = { app, server };
