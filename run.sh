#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Quote App...${NC}"

# Function to cleanup background processes when script exits
cleanup() {
    echo -e "\n${YELLOW}Shutting down servers...${NC}"
    kill $(jobs -p) 2>/dev/null
    exit 0
}

# Set up cleanup on script exit
trap cleanup SIGINT SIGTERM EXIT

# Check if Python is available
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo -e "${RED}Error: Python is not installed or not in PATH${NC}"
    exit 1
fi

# Use python3 if available, otherwise use python
PYTHON_CMD="python3"
if ! command -v python3 &> /dev/null; then
    PYTHON_CMD="python"
fi

# Check if Flask is installed
if ! $PYTHON_CMD -c "import flask" 2>/dev/null; then
    echo -e "${RED}Error: Flask is not installed. Run: pip install flask flask-cors${NC}"
    exit 1
fi

# Start Flask backend
echo -e "${GREEN}Starting Flask backend on http://127.0.0.1:5000${NC}"
$PYTHON_CMD app.py &
FLASK_PID=$!

# Wait a moment for Flask to start
sleep 2

# Check if Flask started successfully
if ! kill -0 $FLASK_PID 2>/dev/null; then
    echo -e "${RED}Error: Failed to start Flask backend${NC}"
    exit 1
fi

# Start frontend server
echo -e "${GREEN}Starting frontend server on http://127.0.0.1:8000${NC}"
$PYTHON_CMD -m http.server 8000 &
FRONTEND_PID=$!

# Wait a moment for frontend server to start
sleep 2

# Check if frontend started successfully
if ! kill -0 $FRONTEND_PID 2>/dev/null; then
    echo -e "${RED}Error: Failed to start frontend server${NC}"
    kill $FLASK_PID 2>/dev/null
    exit 1
fi

echo -e "${GREEN}✓ Both servers are running!${NC}"
echo -e "${YELLOW}Backend API: http://127.0.0.1:5000/quote${NC}"
echo -e "${YELLOW}Frontend App: http://127.0.0.1:8000${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop both servers${NC}"

# Keep script running and wait for user to stop
wait