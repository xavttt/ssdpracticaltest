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

# Create authentication token for CI/CD
echo "🔑 Creating authentication token..."
token_response=$(curl -u "${NEW_USER}:${NEW_PASS}" \
    -X POST \
    "${SONAR_URL}/api/user_tokens/generate" \
    -d "name=ci-cd-token" \
    -s)

if echo "$token_response" | grep -q '"token"'; then
    token=$(echo "$token_response" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    echo "✅ Authentication token created successfully"
    echo "🔐 Token: $token"
    echo ""
    echo "📝 To use this token in CI/CD:"
    echo "   Set SONAR_TOKEN environment variable to: $token"
    echo "   Or use sonar.token property instead of sonar.login/sonar.password"
else
    echo "⚠️  Token creation failed or token already exists"
    echo "📝 You can manually create a token in SonarQube web interface:"
    echo "   Go to: Administration > Security > Users > admin > Tokens"
fi

echo "🎉 SonarQube configuration completed!"
