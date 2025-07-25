#!/bin/bash

# Local SonarQube Analysis Script
# This script runs SonarQube analysis locally using token authentication

echo "🔍 Running local SonarQube analysis..."

# Check if SonarQube is running
if ! curl -f http://localhost:9000/api/system/status >/dev/null 2>&1; then
    echo "❌ SonarQube is not running on localhost:9000"
    echo "   Please start SonarQube first: ./setup-local-sonarqube.sh"
    exit 1
fi

echo "✅ SonarQube is running"

# Install SonarQube scanner if not already installed
if ! command -v sonar-scanner &> /dev/null; then
    echo "📦 Installing SonarQube scanner..."
    npm install -g sonarqube-scanner
fi

# Check if token is available in environment
if [ -z "$SONAR_TOKEN" ]; then
    echo "⚠️  SONAR_TOKEN environment variable not set"
    echo "   Using username/password authentication (deprecated)"
    echo "   To use token authentication:"
    echo "   1. Run ./setup-local-sonarqube.sh to get a token"
    echo "   2. Export the token: export SONAR_TOKEN=your-token-here"
    echo "   3. Run this script again"
    echo ""
fi

# Create temporary sonar-project.properties with appropriate authentication
if [ -n "$SONAR_TOKEN" ]; then
    echo "🔑 Using token authentication"
    cat > sonar-project.local.properties << EOF
sonar.projectKey=secure-web-app
sonar.projectName=Secure Web Application
sonar.projectVersion=1.0
sonar.sources=.
sonar.exclusions=node_modules/**,test-results/**,tests/**,*.log,repos/**,volumes/**,setup-sonarqube.sh,*.local.properties
sonar.host.url=http://localhost:9000
sonar.token=$SONAR_TOKEN
sonar.javascript.file.suffixes=.js
sonar.sourceEncoding=UTF-8
EOF
    config_file="sonar-project.local.properties"
else
    echo "🔐 Using username/password authentication (deprecated)"
    config_file="sonar-project.properties"
fi

# Run analysis
echo "🚀 Starting SonarQube analysis..."
if sonar-scanner -Dproject.settings=$config_file; then
    echo "✅ SonarQube analysis completed successfully"
    echo "🌐 View results at: http://localhost:9000/dashboard?id=secure-web-app"
else
    echo "❌ SonarQube analysis failed"
    echo "💡 Check the SonarQube logs for more details"
fi

# Cleanup temporary file
if [ "$config_file" = "sonar-project.local.properties" ]; then
    rm -f sonar-project.local.properties
fi
