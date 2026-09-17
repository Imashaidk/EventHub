# EventHub - Cross-Platform Event Booking Mobile Application

A cross-platform mobile application designed and developed for the **Cross-Platform App Development** exercise. EventHub enables users to discover, search, filter, and book local events and activities, while empowering event organizers to publish and manage their events and attendee bookings.

---

## 📱 Features & Assignment Requirements Coverage

### 1. User Account
- **Registration**: User and Organizer account creation with full form validation (email format, password security).
- **Authentication**: Secure login/logout with credential verification.
- **Profile Management**: View and update profile information (Full name, phone number, bio, avatar).
- **Role-based Capabilities**: Attendee vs. Event Organizer roles.

### 2. Browse Events
- **Event Discovery**: Browse active events with cover images, category pills, title, date/time, venue, price, and real-time available seats.
- **Search**: Instant search by event title, keywords, tags, and location.
- **Category Filter**: Filter events across Technology, Music, Food & Drinks, Sports, Arts & Culture, and Business.
- **Dynamic View Modes**: Toggle smoothly between **Card List View** and **Grid View**.

### 3. Event Details
- Detailed view with collapsible hero image header and gradient overlay.
- Complete event description, organizer information, and tag highlights.
- Venue location card with interactive map placeholder.
- Live seat availability check and dynamic ticket pricing display.
- Direct booking CTA button with sold-out protection.

### 4. Event Booking
- Modal bottom sheet booking flow with quantity increment/decrement controls.
- Automatic live price calculation.
- Collects attendee name, contact email, phone number, and special request notes with input validation.
- Instant booking confirmation modal showing generated Reference Code (`EH-XXXXX-XX`), date, time, and ticket summary.
- Automatic decrement of available event seats upon confirmation.

### 5. My Bookings
- Tabbed interface separating **Confirmed** bookings from **Cancelled / History**.
- Displays booking status badge (Confirmed / Cancelled), reference number, and date/time.
- **Digital Pass**: View digital ticket with QR code simulation and attendee details.
- **Cancellation**: Ability to cancel active bookings with a confirmation prompt, restoring seats back to the event pool.

### 6. Event Organizer
- **Organizer Dashboard**: View all published events with stats on tickets sold and capacity.
- **Publish New Event**: Comprehensive event creation form with date picker, category dropdown, price, capacity, and cover image.
- **Edit Event**: Modify event information, schedule, pricing, and total seat capacity.
- **Remove Event**: Delete events with confirmation protection.
- **Attendee Bookings**: View real-time attendee list and booking details for each specific event.

### 7. Database & REST API Requirements
- **REST API Backend**: Node.js & Express server running on port `5000` with JSON/SQLite database storage (`backend/database.json`).
- **REST Endpoints**:
  - `POST /api/auth/register`, `POST /api/auth/login`, `GET/PUT /api/auth/profile/:id`
  - `GET /api/events` (supports query params: `category`, `search`, `organizerId`)
  - `GET /api/events/:id`, `POST /api/events`, `PUT /api/events/:id`, `DELETE /api/events/:id`
  - `POST /api/bookings`, `GET /api/bookings/user/:userId`, `GET /api/bookings/event/:eventId`, `POST /api/bookings/:id/cancel`
- **Graceful Fallback**: Integrated offline cache & fallback seed data in the mobile app ensuring zero crashes even when disconnected.

### 8. Notifications
- Centralized `NotificationService` handling in-app banners, badge count, and notification history.
- Triggers notifications on:
  - Booking confirmation
  - Booking cancellation
  - Event published / updated / removed
  - Welcome and login alerts.

### 9. Local Data
- Uses `shared_preferences` for device-local storage:
  - User session & authentication token.
  - Favorite / Bookmarked events (persisted across restarts).
  - User preferences (Dark Theme toggle).
  - Local notification history.

---

## 🛠️ Project Structure

```
Event hub/
├── backend/                  # Node.js Express REST API & Database
│   ├── database.json         # Persistent JSON database (Users, Events, Bookings)
│   ├── server.js             # REST API server & endpoints
│   └── package.json          # Express, Cors dependencies
│
└── event_hub_app/            # Flutter Cross-Platform Mobile Application
    ├── lib/
    │   ├── models/           # Data models (User, Event, Booking, Notification)
    │   ├── services/         # API client, Local Storage, Notification service
    │   ├── providers/        # State management (Auth, Events, Bookings, Theme)
    │   ├── theme/            # Material 3 light and dark theme configurations
    │   ├── widgets/          # Reusable UI components (Cards, Chips, Fields, Dialogs)
    │   ├── screens/          # Application screens (Home, Details, Booking, Organizer, Profile)
    │   └── main.dart         # App entrypoint and provider injection
    ├── test/                 # Widget and unit tests
    └── pubspec.yaml          # Flutter dependencies
```

---

## 🚀 How to Run Locally

### 1. Start the REST API Backend
```bash
cd backend
npm install
npm start
```
The server will start at `http://localhost:5000` (Health check: `http://localhost:5000/api/health`).

### 2. Run the Flutter Mobile App
In another terminal:
```bash
cd event_hub_app
flutter pub get

# To run on Chrome (Web):
flutter run -d chrome

# To run on Windows Desktop:
flutter run -d windows

# To run on Android Emulator (start emulator first):
flutter run -d android
```

---

## 🧪 Running Tests
```bash
cd event_hub_app
flutter test
flutter analyze
```

---

## 📦 Pushing to GitHub (Assignment Submission)
Follow these steps to submit your assignment:
```bash
# 1. Initialize git repository if not already done
git init

# 2. Add files and commit
git add .
git commit -m "Complete EventHub cross-platform mobile application and REST API"

# 3. Add your GitHub remote repository
git remote add origin https://github.com/<your-username>/eventhub-mobile-app.git

# 4. Push to main branch
git branch -M main
git push -u origin main
```
Copy your repository URL and submit it as specified in the assignment brief.
