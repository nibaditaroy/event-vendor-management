#!/bin/bash

# Configuration
DB_NAME="event_vendor_management"
PORT=5001

echo "🚀 Starting Event Vendor Management Portal Setup..."

# 0. Kill existing processes on backend port
echo "🧹 Cleaning up port $PORT..."
lsof -ti:$PORT | xargs kill -9 2>/dev/null || true

# Source NVM if it exists
if [ -f "$HOME/.nvm/nvm.sh" ]; then
    . "$HOME/.nvm/nvm.sh"
    nvm use 20 || echo "Using default node version"
fi

# 1. Backend Setup
echo "📂 Setting up Backend..."
cd backend

# Install dependencies
echo "📦 Installing Backend Dependencies..."
npm install

# Create database if it doesn't exist
echo "🗄️ Checking Database..."
npx sequelize-cli db:create || echo "Database already exists or could not be created."

# Run Migrations
echo "🏗️ Running Migrations..."
npx sequelize-cli db:migrate

# Seed initial data
echo "🌱 Seeding Data..."
npx sequelize-cli db:seed:all

# Start Backend in background
echo "📡 Starting Backend Server..."
npm run dev &
BACKEND_PID=$!

# 2. Frontend Setup
echo "📱 Setting up Frontend..."
cd ../frontend

# Start Frontend
echo "🌐 Starting Frontend (Auto-detecting device)..."
# If you want to force Chrome, use: flutter run -d chrome
/c/src/flutter/bin/flutter run -d chrome

# Cleanup: Kill backend when frontend is closed
if [ ! -z "$BACKEND_PID" ]; then
    kill $BACKEND_PID 2>/dev/null || true
fi
echo "👋 Shutdown complete."
