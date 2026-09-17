# EventHub - Cross-Platform Event Booking Mobile Application

![Cross-Platform Flutter Application](https://img.shields.io/badge/Framework-Flutter%203.35-02569B?logo=flutter)
![Language-Dart](https://img.shields.io/badge/Language-Dart%203.9-0175C2?logo=dart)
![Backend-NodeJS](https://img.shields.io/badge/Backend-Node.js%20%7C%20Express-339933?logo=nodedotjs)
![Tests-Passing](https://img.shields.io/badge/Tests-100%25%20Passing-success)
![License-Academic](https://img.shields.io/badge/Exercise-Cross--Platform%20App%20Development-blueviolet)

A full-featured, cross-platform mobile application developed for the **Cross-Platform App Development: Event Booking Mobile Application** exercise. **EventHub** empowers attendees to discover, search, filter, and book local events and activities, while providing event organizers with tools to publish and manage events and inspect real-time attendee lists.

---

## Submission Information

- **Module**: Cross-Platform App Development
- **Project**: Exercise – Event Booking Mobile Application (EventHub)
- **Framework Chosen**: Flutter (Dart)
- **GitHub Repository**: [https://github.com/Imashaidk/EventHub](https://github.com/Imashaidk/EventHub)
- **Live Local Web App**: `http://localhost:3000`
- **Live REST API Backend**: `http://localhost:5000/api/health`

---

## Demo Accounts & Credentials

Pre-seeded accounts are provided with instant one-tap buttons on the login screen for quick evaluation:

| Account Role | Email | Password | Access Capabilities |
|---|---|---|---|
| **Regular Attendee** | `alex@eventhub.com` | `password123` | Browse, search, filter, book tickets, view digital pass, cancel bookings, toggle favorites |
| **Event Organizer** | `organizer@eventhub.com` | `password123` | Publish new events, edit details, set seat capacities, delete events, inspect attendee lists |

*(You can also register brand new accounts with full form validation).*

---

## Features & Assignment Requirements Coverage

### 1. User Account
- **Registration**: User and Organizer account creation with input validation (Email regex, password length >= 6, password confirmation match).
- **Authentication**: Login and logout with session persistence via `shared_preferences`.
- **Profile Management**: View and update user details (Full Name, Phone Number, Bio, Avatar).
- **Role Switching**: Seamlessly toggle between Attendee and Organizer mode directly in the Profile tab for testing.

### 2. Browse Events
- **Discovery View**: Shows event cards with cover images, category pills, title, date/time, venue address, price, and real-time seat availability.
- **Search**: Live instant search across event titles, venue locations, and keywords.
- **Category Filters**: Dedicated filter chips for `All`, `Technology`, `Music`, `Food & Drinks`, `Sports`, `Arts & Culture`, and `Business`.
- **View Modes**: Smoothly toggle between **Card List View** and **2-Column Grid View**.

### 3. Event Details
- Detailed view with collapsible SliverAppBar hero image and gradient overlays.
- Full event itinerary, organizer details, and tag highlights.
- Interactive venue location card with map directions indicator.
- Live seat availability check (shows exact remaining count or `Sold Out`).
- Sticky bottom booking bar with direct booking CTA.

### 4. Event Booking
- Modal bottom sheet booking flow with quantity increment/decrement (`+ / -`) selector.
- Real-time price calculation (Ticket Price × Quantity).
- Form validation for attendee contact details (Name, Email, Phone, Special Notes).
- Instant animated booking confirmation modal with a unique reference code (`EH-XXXXX-XX`).
- Automatic live decrement of available event seats upon confirmation.

### 5. My Bookings
- Tabbed interface separating **Confirmed** bookings from **All / Cancelled** bookings.
- Displays booking status badge (`CONFIRMED` / `CANCELLED`), reference number, and date/time.
- **Digital Pass**: View digital event ticket with simulated QR code and attendee details.
- **Cancellation**: Ability to cancel active bookings with a confirmation prompt, restoring seats back to the event pool.

### 6. Event Organizer Hub
- **Organizer Dashboard**: View all published events with stats on tickets sold vs. total capacity.
- **Publish New Event**: Comprehensive event creation form with date picker, category dropdown, price, capacity, and cover image URL.
- **Edit Event**: Modify existing event details, venue, time, and seat capacity.
- **Remove Event**: Delete events with safety confirmation alert.
- **Attendee Bookings**: View real-time attendee list showing attendee names, emails, phones, ticket counts, and status for each specific event.

### 7. Database & REST API
- **REST API Backend**: Node.js & Express server running on port `5000` with JSON database persistence (`backend/database.json`).
- **Endpoints**:
  - `POST /api/auth/register`, `POST /api/auth/login`, `GET/PUT /api/auth/profile/:id`
  - `GET /api/events`, `GET /api/events/:id`, `POST /api/events`, `PUT /api/events/:id`, `DELETE /api/events/:id`
  - `POST /api/bookings`, `GET /api/bookings/user/:userId`, `GET /api/bookings/event/:eventId`, `POST /api/bookings/:id/cancel`
- **Offline Resilience**: Built-in cache and fallback seed data in the mobile app ensuring zero crashes even if the network is disconnected.

### 8. Notifications
- Centralized `NotificationService` handling an in-app notification center modal with unread badge counter.
- Covers all 4 assignment notification examples:
  - **Booking confirmation**: Triggered on ticket purchase.
  - **Booking cancellation**: Triggered on booking cancellation.
  - **Event reminder**: Interactive reminder button on event details (`Alarm Icon`) scheduling a reminder alert.
  - **Event update**: Triggered when events are created, edited, or removed.

### 9. Local Data
- Uses `shared_preferences` for device-local storage:
  - User session & authentication token.
  - Favorite / Bookmarked events (persisted across app restarts).
  - User preferences (Dark Theme toggle).
  - Local notification history.

---

## Project Structure

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
    │   ├── screens/          # Screens (Home, Details, Booking, Organizer, Profile)
    │   └── main.dart         # App entrypoint and provider injection
    ├── test/                 # Unit and serialization tests
    └── pubspec.yaml          # Flutter dependencies
```

---

## How to Run Locally

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

# To run on Android Emulator:
flutter run -d android
```

---

## Quality Assurance & Test Results

- **Static Analysis**: `flutter analyze` executed with **0 issues found**.
- **Automated Tests**: `flutter test` executed with **3/3 unit tests passing (100%)**.
- **API Health**: Verified operational with HTTP 200 OK.
- **Git Commits**: 15 structured, semantic commits matching every exercise requirement pushed to `main`.
