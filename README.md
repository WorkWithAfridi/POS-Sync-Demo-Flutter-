# POS Sync Demo (Flutter)

A simple **Point-of-Sale (POS) sync demo** app built with **Flutter** and **SQLite** that demonstrates **parent-child data synchronization** over a local network.

---

## Features

- **Parent & Child Modes**  
  - One device can act as a **Parent**, serving as the source of truth for data.  
  - Other devices act as **Children**, connecting to the parent to sync data.

- **Offline-First**  
  - Users can be created on any device, even without a parent connection.  
  - Local SQLite database ensures offline functionality.

- **Two-Way Sync**  
  - When connected, **children sync new users with the parent**.  
  - Parent merges new users from children and updates them in real-time.

- **Automatic Discovery**  
  - Child devices scan the local network to automatically detect the parent.  

- **Conflict Handling**  
  - Users are identified by their `name`. If a user already exists, it will **update** instead of creating duplicates.

---

## Tech Stack

- **Flutter**: Frontend framework
- **SQLite**: Local storage for offline-first functionality
- **Dio**: HTTP client for REST requests
- **Shelf & Shelf Router**: Lightweight server on parent devices
- **Logger**: Debug logging for network and sync activities

---

## How It Works

1. **Parent Device**
   - Enables "Parent Mode" via a switch in the app.  
   - Starts a local HTTP server (`Shelf`) exposing endpoints:
     - `GET /users` → Returns all users  
     - `POST /sync` → Receives new users from children and merges them into its database

2. **Child Devices**
   - Scan the local network to find a parent device.  
   - Connect to the parent and fetch users to update their local database.  
   - Push newly created local users to the parent for two-way synchronization.

3. **Database**
   - SQLite stores users with `id`, `name`, and `createdAt`.  
   - Insertions are merged using `id` or `name` to prevent duplicates.  
   - Both parent and child devices can independently create users.

4. **Sync Flow**
   - Child fetches all users from parent → merges into local database  
   - Child pushes new local users → parent merges them into its database  
   - Changes are reflected on all connected devices on next sync.

---

## Usage

1. Run the Flutter app on multiple devices (simulators, macOS, iOS, or Android).  
2. On one device, enable **Parent Mode**.  
3. On child devices, click **Connect to Parent** to sync users.  
4. Create users on either parent or child device; data will sync automatically when connected.

---

## Folder Structure (Simplified)

```
lib/
├─ models/
│  └─ user_m.dart        # User model
├─ services/
│  ├─ database_s.dart    # SQLite DB service
│  ├─ server_s.dart      # Parent server
│  ├─ sync_s.dart        # Sync service
│  ├─ user_s.dart        # User service
│  └─ discovery_s.dart   # Network discovery service
├─ views/
│  └─ home_v.dart        # Home page
├─ data/
│  └─ remote/controller/network_c.dart  # Dio network controller
└─ utils/
   └─ logger.dart        # Logging
```

---

## Notes

- Ensure all devices are on the **same local network**.  
- Port **8080** must be open on the parent device for discovery and syncing.  
- SQLite is used for simplicity; for production, consider secure syncing and conflict resolution strategies.