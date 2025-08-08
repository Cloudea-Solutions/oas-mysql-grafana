#!/bin/bash

set -e

echo "📦 Installing OAS license host..."


echo "🛠️  Loading environment variables..."
export $(grep -v '^#' .env | xargs)

echo "📄 Generating MySQL init script..."
mkdir -p mysql/init
envsubst < templates/init-users.sql.tpl > mysql/init/init-users.sql

echo "📄 Generating Grafana datasource provisioning..."
mkdir -p grafana/provisioning/datasources
envsubst < templates/mysql.yml.tpl > grafana/provisioning/datasources/mysql.yml

echo "📄 Generating OAS account provisioning..."
mkdir -p scripts
envsubst < templates/admin-create.expect.tpl > scripts/admin-create.expect

echo "🐳 Starting Docker Compose..."
docker-compose up -d

# Wait for OAS container to be fully running
echo "⏳ Waiting for OAS container to initialize..."
sleep 10

# Install expect inside the container
echo "📦 Installing 'expect' inside OAS container..."
docker exec -it oas apt update
docker exec -it oas apt install -y expect

# Copy the expect script into the container
echo "📄 Copying admin creation script..."
docker cp ./scripts/admin-create.expect oas:/tmp/admin-create.expect

# Run the script inside the container
echo "🔐 Creating initial OAS admin user..."
docker exec -it oas expect /tmp/admin-create.expect
docker exec oas rm /tmp/admin-create.expect

echo "✅ All services are up!"
