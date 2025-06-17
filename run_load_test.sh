#!/bin/bash

# Load Testing Script for Ruby Sinatra App
# Make sure your Sinatra app is running on localhost:4567 before running this

echo "🚀 Starting Load Test for Ruby Sinatra App"
echo "============================================"

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 is required but not installed."
    exit 1
fi

# Remove existing venv if it has issues
if [ -d "venv" ] && [ ! -f "venv/bin/locust" ]; then
    echo "🧹 Cleaning up problematic virtual environment..."
    rm -rf venv
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Upgrade pip first
echo "⬆️ Upgrading pip..."
python -m pip install --upgrade pip

# Install dependencies with compatibility flags
if ! python -c "import locust" &> /dev/null; then
    echo "📦 Installing Locust with compatibility settings..."
    
    # Install dependencies one by one for better error handling
    echo "Installing gevent..."
    pip install --no-cache-dir --force-reinstall "gevent==22.10.2"
    
    echo "Installing requests..."
    pip install --no-cache-dir "requests==2.31.0"
    
    echo "Installing locust..."
    pip install --no-cache-dir "locust==2.17.0"
fi

# Check if Sinatra app is running
if ! curl -s http://localhost:4567 > /dev/null; then
    echo "❌ Sinatra app is not running on localhost:4567"
    echo "Please start your app with: bundle exec ruby app.rb"
    exit 1
fi

echo "✅ Sinatra app is running!"
echo ""

# Locust configuration options
echo "Choose load test configuration:"
echo "1) Light load (10 users, 2 spawn rate)"
echo "2) Medium load (50 users, 5 spawn rate)" 
echo "3) Heavy load (100 users, 10 spawn rate)"
echo "4) Custom configuration"
echo "5) Quick test (5 users for 30 seconds)"
read -p "Enter choice (1-5): " choice

case $choice in
    1)
        USERS=10
        SPAWN_RATE=2
        ;;
    2) 
        USERS=50
        SPAWN_RATE=5
        ;;
    3)
        USERS=100
        SPAWN_RATE=10
        ;;
    4)
        read -p "Enter number of users: " USERS
        read -p "Enter spawn rate (users/second): " SPAWN_RATE
        ;;
    5)
        USERS=5
        SPAWN_RATE=1
        echo "Running quick 30-second test..."
        ;;
    *)
        echo "Invalid choice, using default (Light load)"
        USERS=10
        SPAWN_RATE=2
        ;;
esac

echo ""
echo "🎯 Starting load test with:"
echo "   Users: $USERS"
echo "   Spawn rate: $SPAWN_RATE per second"
echo "   Target: http://localhost:4567"
echo ""
echo "📊 Locust web UI will be available at: http://localhost:8089"
echo "   (Press Ctrl+C to stop the test)"
echo ""

# Run Locust
if [ "$choice" = "5" ]; then
    # Headless mode for quick test
    locust -f locustfile.py --host=http://localhost:4567 \
           --users=$USERS --spawn-rate=$SPAWN_RATE \
           --run-time=30s --headless
else
    # Web UI mode
    locust -f locustfile.py --host=http://localhost:4567 \
           --users=$USERS --spawn-rate=$SPAWN_RATE
fi

# Deactivate virtual environment when done
deactivate 