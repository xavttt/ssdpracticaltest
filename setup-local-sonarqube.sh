#!/bin/bash

# Local SonarQube Setup for Development
# Run this script after starting SonarQube with docker-compose

echo "🚀 Setting up SonarQube for local development..."

# Start SonarQube services
echo "📦 Starting SonarQube containers..."
docker-compose up -d sonarqube db

# Configure SonarQube
echo "⚙️ Configuring SonarQube..."
./setup-sonarqube.sh

echo "✅ Setup complete!"
echo ""
echo "🌐 SonarQube Web Interface: http://localhost:9000"
echo "🔐 Login Credentials:"
echo "   Username: admin"
echo "   Password: 2301801@SIT.singaporetech.edu.sg"
echo ""
echo "📊 To run analysis manually:"
echo "   npm install -g sonarqube-scanner"
echo "   sonar-scanner"
echo ""
echo "⚠️  Note: SonarQube now requires token authentication."
echo "   The setup script will create a token automatically."
echo "   Check the output above for the generated token."
