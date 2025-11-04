#!/bin/sh
set -e
host="mysql"
port="3306"

echo " Waiting for MySQL ($host:$port)..."
until nc -z $host $port; do
  sleep 2
done

echo " MySQL is up - starting FastAPI app"
exec uvicorn app.main:app --host 0.0.0.0 --port 8000
