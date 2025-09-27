#!/bin/bash

# This script starts all microservices and the CMS frontend as background jobs.
# It is designed to be run from the project root.
# Press Ctrl+C to stop all services graceful

# Function to kill all background jobs on exit
cleanup() {
	echo "Stopping all services..."
	# The negative PID kills the entire process group
	kill -TERM -$$
	wait
	echo "All services stopped."
}

# Trap the EXIT signal (like SIGTERM) to run the cleanup function
trap cleanup EXIT

echo "Starting all services in the background..."

(cd services/users && echo "Starting users service..." && uv sync --all-groups --all-extras && . ./.venv/bin/activate && uvicorn main:app --port 8001 --reload) &
(cd services/contents && echo "Starting contents service..." && uv sync --all-groups --all-extras && . ./.venv/bin/activate && uvicorn main:app --port 8002 --reload) &
(cd services/payments && echo "Starting payments service..." && uv sync --all-groups --all-extras && . ./.venv/bin/activate && uvicorn main:app --port 8003 --reload) &
(cd services/_opi && echo "Starting OPI service..." && uv sync --all-groups --all-extras && . ./.venv/bin/activate && uvicorn main:app --port 8000 --reload) &

(cd apps/cms && echo "Starting CMS app..." && bun install && bun run dev) &

echo "All services are starting up."
echo "Press Ctrl+C to stop all services."

# Wait for any background process to exit, or for a signal (like Ctrl+C)
wait -n
