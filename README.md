# Event Vendor Management Portal

Welcome to the **Event Vendor Management Portal**, a full-stack platform designed to connect event organizers with service vendors (such as catering, decoration, photography, and music). 

---

## 🚀 How to Run the Project (Quick Start)

To run the entire system (both backend and frontend) with a single command, you can use the provided startup scripts. These scripts automatically handle port cleanup, database creation, migrations, data seeding, and run both services.

> [!IMPORTANT]
> Ensure PostgreSQL is running on your machine and you have configured the database credentials in `backend/.env` before launching.

### macOS & Linux
```bash
chmod +x start_project.sh
./start_project.sh
```

### Windows
```cmd
start_project.bat
```

---

## 🔧 Manual Setup

If you prefer to run the components individually, follow the steps below.

### 1. Backend Setup
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Configure your Environment:
   * Create a `.env` file in the `backend/` directory (see `backend/.env` template).
   * Update the database credentials (`DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`).
4. Set up the Database:
   ```bash
   npx sequelize-cli db:create
   npx sequelize-cli db:migrate
   npx sequelize-cli db:seed:all
   ```
5. Start the Server:
   * **Development Mode (Auto-restart on change)**:
     ```bash
     npm run dev
     ```
   * **Production Mode**:
     ```bash
     npm start
     ```
   The backend API will run on `http://localhost:5001`.

### 2. Frontend Setup
1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the App:
   * Automatically detect available devices/emulators:
     ```bash
     flutter run
     ```
   * Force web execution in Chrome:
     ```bash
     flutter run -d chrome
     ```

---

## 🏗️ System Architecture

The project is split into two main components:
1. **Backend**: A Node.js & Express REST API with PostgreSQL (via Sequelize ORM) and real-time WebSockets (Socket.io).
2. **Frontend**: A cross-platform Flutter mobile & web application utilizing the Provider state management pattern.

```
event-vendor-management/
├── backend/                  # Node.js + Express + PostgreSQL API
│   ├── src/
│   │   ├── config/           # Database & environment configurations
│   │   ├── controllers/      # Route controllers (business logic)
│   │   ├── models/           # Sequelize database models
│   │   ├── routes/           # REST API route definitions
│   │   ├── seeders/          # Initial seed data for development
│   │   └── sockets/          # Socket.io notification handlers
│   └── server.js             # Main server entrypoint
│
├── frontend/                 # Flutter Application
│   ├── lib/
│   │   ├── models/           # Dart data models
│   │   ├── providers/        # State management (ChangeNotifiers)
│   │   ├── screens/          # UI Screens (Organizer, Vendor, Auth)
│   │   ├── services/         # API & WebSocket client connections
│   │   └── main.dart         # Flutter app entrypoint
│
├── start_project.sh          # One-click startup script for macOS/Linux
└── start_project.bat         # One-click startup script for Windows
```

---

## 🛠️ Technology Stack

### Backend
* **Runtime**: Node.js (v20 Recommended)
* **Framework**: Express.js
* **Database**: PostgreSQL
* **ORM**: Sequelize
* **Real-time**: Socket.io
* **Image Uploads**: Multer + Cloudinary
* **Validation**: Joi
* **Security**: JWT & Bcrypt.js

### Frontend
* **Framework**: Flutter SDK (v3.0.0+)
* **State Management**: Provider
* **Networking**: Http package
* **Real-time**: Socket.io Client
* **Storage**: Shared Preferences (JWT tokens persistence)

---

## 📡 Port & Network Configuration

* **Backend Port**: `5001` (configurable via `.env`)
* **Local Emulator Details**:
  * The Flutter app is configured to automatically communicate with the backend. 
  * If running on **Android Emulator**, it resolves API calls to `http://10.0.2.2:5001/api`.
  * If running on **Web/iOS Simulator/Desktop**, it resolves API calls to `http://localhost:5001/api`.
  * If you are running the app on a **physical device**, ensure the device is on the same Wi-Fi network and update the API base URL in `frontend/lib/services/api_service.dart` to your computer's local IP address.