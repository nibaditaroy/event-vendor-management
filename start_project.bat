@echo off
set PORT=5001
set DB_NAME=event_vendor_management

echo 🚀 Starting Event Vendor Management Portal Setup (Windows)...

:: 0. Kill existing processes on backend port
echo 🧹 Cleaning up port %PORT%...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%PORT%') do taskkill /f /pid %%a 2>nul

:: 1. Backend Setup
echo 📂 Setting up Backend...
cd backend

:: Install dependencies
echo 📦 Installing Backend Dependencies...
call npm install

:: Create database
echo 🗄️ Checking Database...
call npx sequelize-cli db:create 2>nul || echo Database already exists or could not be created.

:: Run Migrations
echo 🏗️ Running Migrations...
call npx sequelize-cli db:migrate

:: Seed initial data
echo 🌱 Seeding Data...
call npx sequelize-cli db:seed:all

:: Start Backend in background
echo 📡 Starting Backend Server...
start /B npm run dev

:: 2. Frontend Setup
echo 📱 Setting up Frontend...
cd ../frontend

:: Start Frontend
echo 🌐 Starting Frontend (Auto-detecting device)...
call C:\src\flutter\bin\flutter.bat run -d chrome

echo 👋 Shutdown complete.
