# Event Vendor Management Portal - Backend API

This is the backend API for the Event Vendor Management Portal, built using **Node.js**, **Express**, and **PostgreSQL** with **Sequelize ORM**.

---

## 🛠️ Tech Stack & Libraries
* **Express.js**: Core web application framework.
* **Sequelize ORM**: Promise-based Node.js ORM for PostgreSQL.
* **Socket.io**: Bidirectional and low-latency communication channel.
* **Multer & Cloudinary**: For handling and hosting media/image uploads.
* **Bcrypt.js & JWT**: For password hashing and JSON Web Token authentication.
* **Joi**: Object schema validation.

---

## ⚙️ Prerequisites
* **Node.js** (v20+ recommended)
* **PostgreSQL** (running locally or remotely)
* **npm** (comes with Node.js)

---

## 🚀 Setup & Installation

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install the dependencies:
   ```bash
   npm install
   ```

3. Configure your Environment Variables:
   * Create a `.env` file in the root of the `backend/` directory:
     ```env
     PORT=5001
     NODE_ENV=development

     # Database Configuration
     DB_HOST=127.0.0.1
     DB_PORT=5432
     DB_USER=postgres
     DB_PASSWORD=postgres
     DB_NAME=event_vendor_management

     # JWT Configuration
     JWT_SECRET=your_super_secret_jwt_key_here
     JWT_EXPIRES_IN=30d

     # Cloudinary Credentials (for image uploads)
     CLOUDINARY_CLOUD_NAME=your_cloud_name
     CLOUDINARY_API_KEY=your_api_key
     CLOUDINARY_API_SECRET=your_api_secret
     ```

---

## 🗄️ Database Lifecycle

This project uses Sequelize CLI to manage PostgreSQL database schemas and seed data.

### 1. Create Database
Create the database specified in your `.env`:
```bash
npx sequelize-cli db:create
```

### 2. Run Migrations
Generate the required tables (Users, Vendors, Services, Bookings, Reviews, Categories, Notifications, Status History):
```bash
npx sequelize-cli db:migrate
```

### 3. Seed Initial Data
Populate the database with pre-configured vendor categories, test users, and services:
```bash
npx sequelize-cli db:seed:all
```

> [!TIP]
> To reset the database (drop everything, migrate, and re-seed) during development:
> ```bash
> npx sequelize-cli db:migrate:undo:all
> npx sequelize-cli db:migrate
> npx sequelize-cli db:seed:all
> ```

---

## 📡 REST API Reference

All requests must be prefixed with `/api`.

### 🔐 Authentication (`/api/auth`)
| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `POST` | `/auth/register` | Register a new user (role: `organizer` or `vendor`) | No |
| `POST` | `/auth/login` | Log in and receive a JWT token | No |
| `GET` | `/auth/profile` | Retrieve the authenticated user's profile | Yes |
| `PUT` | `/auth/profile` | Update the authenticated user's base info | Yes |
| `PUT` | `/auth/change-password` | Change user password | Yes |

### 🏢 Vendors (`/api/vendors`)
| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `GET` | `/vendors` | Get a list of all vendors | No |
| `GET` | `/vendors/:id` | Get details of a specific vendor by ID | No |
| `GET` | `/vendors/profile` | Get the logged-in vendor's business profile | Yes |
| `POST` | `/vendors/profile` | Create a vendor profile for the logged-in user | Yes |
| `PUT` | `/vendors/profile` | Update the logged-in vendor's business details | Yes |

### 🛠️ Services (`/api/services`)
| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `GET` | `/services` | List all services (supports category filtering) | No |
| `POST` | `/services` | Create a new service (Vendors only) | Yes |
| `PUT` | `/services/:id` | Update an existing service (Owner only) | Yes |
| `DELETE` | `/services/:id` | Delete a service (Owner only) | Yes |

### 📅 Bookings (`/api/bookings`)
| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `POST` | `/bookings` | Request a new service booking (Organizers only) | Yes |
| `GET` | `/bookings` | List bookings (Organizers see their requests, Vendors see requests sent to them) | Yes |
| `PUT` | `/bookings/:id/status` | Update booking status (`pending`, `accepted`, `rejected`, `completed`) | Yes |
| `PUT` | `/bookings/:id/payment` | Update booking payment status (`pending`, `paid`) | Yes |

### 🏷️ Categories (`/api/categories`)
| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `GET` | `/categories` | Retrieve all available service categories | No |

### ⭐️ Reviews (`/api/reviews`)
| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `POST` | `/reviews` | Create a review for a completed service booking (Organizers only) | Yes |
| `GET` | `/reviews/vendor/:vendorId` | Get all reviews for a specific vendor | No |

### 🔔 Notifications (`/api/notifications`)
| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `GET` | `/notifications` | Get notifications for the authenticated user | Yes |
| `PUT` | `/notifications/:id/read` | Mark a notification as read | Yes |

### 📁 Media Uploads (`/api/upload`)
| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `POST` | `/upload` | Upload an image to Cloudinary. Returns JSON containing the image url. | Yes |

---

## ⚡ Real-Time Engine (Socket.io)
Socket.io is configured on top of the HTTP server inside `server.js` and allows for real-time WebSocket communication. 
* Port: Shares the port configured in `.env` (default: `5001`).
* CORS configuration is open (`*`) for easy debugging.