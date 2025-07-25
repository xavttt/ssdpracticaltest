#!/bin/bash

# Simple test script to run locally before pushing
# This mirrors the GitHub Actions workflow

echo "🚀 Starting local testing..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm ci

# Run security audit
echo "🔍 Running dependency security audit..."
npm audit --audit-level=moderate

# Build and start services
echo "🏗️ Building and starting services..."
docker-compose down 2>/dev/null || true
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 15

# Test if application is accessible
echo "🌐 Testing application accessibility..."
if curl -f http://127.0.0.1:3000 > /dev/null 2>&1; then
    echo "✅ Application is accessible"
else
    echo "❌ Application is not accessible"
    docker-compose logs
    exit 1
fi

# Test XSS protection
echo "🛡️ Testing XSS protection..."
response=$(curl -X POST -d "searchTerm=<script>alert('xss')</script>" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -w "%{http_code}" -o /dev/null -s \
    http://127.0.0.1:3000/search)

if [ "$response" == "302" ]; then
    echo "✅ XSS protection working"
else
    echo "❌ XSS protection failed (got $response, expected 302)"
fi

# Test SQL injection protection
echo "🛡️ Testing SQL injection protection..."
response=$(curl -X POST -d "searchTerm='; DROP TABLE users; --" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -w "%{http_code}" -o /dev/null -s \
    http://127.0.0.1:3000/search)

if [ "$response" == "302" ]; then
    echo "✅ SQL injection protection working"
else
    echo "❌ SQL injection protection failed (got $response, expected 302)"
fi

# Test valid input
echo "✅ Testing valid input..."
response=$(curl -X POST -d "searchTerm=hello world" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -w "%{http_code}" -o /dev/null -s \
    http://127.0.0.1:3000/search)

if [ "$response" == "302" ]; then
    echo "✅ Valid input processing working"
else
    echo "❌ Valid input processing failed (got $response, expected 302)"
fi

# Clean up
echo "🧹 Cleaning up..."
docker-compose down

echo "✨ Local testing completed!"
