#!/bin/bash

# SonarQube Setup Script
# This script configures SonarQube with custom admin credentials

SONAR_URL="http://127.0.0.1:9000"
DEFAULT_USER="admin"
DEFAULT_PASS="admin"
NEW_USER="admin"
NEW_PASS="2301801@SIT.singaporetech.edu.sg"

echo "🔧 Configuring SonarQube with custom credentials..."

# Wait for SonarQube to be ready
echo "⏳ Waiting for SonarQube to start..."
timeout 300 bash -c 'until curl -f http://127.0.0.1:9000/api/system/status | grep -q "UP"; do sleep 10; done'

if [ $? -eq 0 ]; then
    echo "✅ SonarQube is running"
else
    echo "❌ SonarQube failed to start within timeout"
    exit 1
fi

# Change admin password using SonarQube API
echo "🔒 Changing admin password..."
response=$(curl -u "${DEFAULT_USER}:${DEFAULT_PASS}" \
    -X POST \
    "${SONAR_URL}/api/users/change_password" \
    -d "login=${NEW_USER}" \
    -d "password=${NEW_PASS}" \
    -d "previousPassword=${DEFAULT_PASS}" \
    -w "%{http_code}" \
    -s -o /dev/null)

if [ "$response" = "204" ]; then
    echo "✅ Admin password changed successfully"
    echo "🔐 New credentials: admin / 2301801@SIT.singaporetech.edu.sg"
else
    echo "⚠️  Password change response: $response"
    # Try to verify if password was already changed
    test_response=$(curl -u "${NEW_USER}:${NEW_PASS}" \
        -X GET \
        "${SONAR_URL}/api/users/search" \
        -w "%{http_code}" \
        -s -o /dev/null)
    
    if [ "$test_response" = "200" ]; then
        echo "✅ Custom credentials are already configured"
    else
        echo "❌ Failed to configure custom credentials"
        exit 1
    fi
fi

echo "🎉 SonarQube configuration completed!"
