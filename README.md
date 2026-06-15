# Italia Hobby Motociclismo

Official iOS application for the **Italia Hobby Motociclismo** motorbike club.

> **UI style:** The `main` branch uses a modern, Apple-standard SwiftUI interface.
> The medieval-themed look and feel is preserved on the `medieval-style` branch.

## Overview

A native **iOS app built with SwiftUI** that lets club members:

- 📍 View all scheduled rides & events on an **interactive map** (MapKit)
- ✅ **Subscribe / unsubscribe** to events
- 💬 Join **private event chats** (only for subscribed members)
- 🏍️ Track your **trip history**
- 👤 Manage your **rider profile**

The app connects to a **MySQL/MariaDB backend hosted on Aruba.it** via a REST API, with full **offline support** through Core Data.

---

## Project Structure

```
ItaliaHobbyMotociclismo.xcodeproj/   ← Xcode project
ItaliaHobbyMotociclismo/
├── ItaliaHobbyMotociclismoApp.swift ← App entry point
├── ContentView.swift                ← Root view / tab bar
├── Info.plist
├── Assets.xcassets/
│
├── Models/          ← User, Event, Message, APIModels
├── Networking/      ← APIClient (URLSession + async/await)
├── LocalDB/         ← CoreDataManager + .xcdatamodeld
├── Repository/      ← UserRepository, EventRepository, ChatRepository
├── Services/        ← SyncManager (background polling)
├── Utilities/       ← KeychainManager
├── ViewModels/      ← AuthViewModel, EventsViewModel, ChatViewModel, ProfileViewModel
└── Views/
    ├── Auth/        ← RegistrationView
    ├── Map/         ← MapView, EventDetailView
    ├── Chat/        ← ChatListView, ChatRoomView
    ├── Trips/       ← TripsView
    └── Profile/     ← ProfileView

Backend/
├── api.php          ← PHP REST API (hosted on Aruba.it)
└── schema.sql       ← MySQL/MariaDB database schema
```

---

## Architecture

- **MVVM** — ViewModels drive the UI via `@Published` properties
- **Repository pattern** — decouples networking/local DB from ViewModels
- **Core Data** — local persistence and offline support
- **URLSession + async/await** — networking layer
- **Keychain** — secure storage for user credentials

---

## Backend Setup (Aruba.it)

1. Create a MySQL database using `Backend/schema.sql`
2. Upload `Backend/api.php` to your Aruba.it PHP hosting
3. Set environment variables: `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASS`
4. Update `APIEndpoint.baseURL` in `Networking/APIClient.swift` to your domain

### REST API Endpoints

| Method | Endpoint                   | Description                        |
|--------|----------------------------|------------------------------------|
| GET    | `/events`                  | List all events                    |
| POST   | `/events/subscribe`        | Subscribe a user to an event       |
| POST   | `/events/unsubscribe`      | Unsubscribe a user from an event   |
| GET    | `/events/{id}/chat`        | Get messages for an event's chat   |
| POST   | `/events/{id}/chat`        | Post a message to an event's chat  |
| POST   | `/user/register`           | Register or update a user profile  |
| GET    | `/user/{id}`               | Get a user's profile               |

---

## Requirements

- **iOS 17.0+**
- **Xcode 16+**
- Swift 5.9+

---

## Getting Started

1. Clone this repository
2. Open `ItaliaHobbyMotociclismo.xcodeproj` in Xcode
3. Set your development team in project settings
4. Update `APIEndpoint.baseURL` in `Networking/APIClient.swift`
5. Build and run on a simulator or device
