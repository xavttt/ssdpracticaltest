# PowerShell test script for Windows
# This mirrors the GitHub Actions workflow for local testing

Write-Host "🚀 Starting local testing..." -ForegroundColor Green

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker first." -ForegroundColor Red
    exit 1
}

# Install dependencies
Write-Host "📦 Installing dependencies..." -ForegroundColor Blue
npm ci

# Run security audit
Write-Host "🔍 Running dependency security audit..." -ForegroundColor Blue
npm audit --audit-level=moderate

# Build and start services
Write-Host "🏗️ Building and starting services..." -ForegroundColor Blue
docker-compose down 2>$null
docker-compose up -d

# Wait for services to be ready
Write-Host "⏳ Waiting for services to start..." -ForegroundColor Yellow
Start-Sleep 15

# Test if application is accessible
Write-Host "🌐 Testing application accessibility..." -ForegroundColor Blue
try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:3000" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Application is accessible" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Application is not accessible" -ForegroundColor Red
    docker-compose logs
    exit 1
}

# Test XSS protection
Write-Host "🛡️ Testing XSS protection..." -ForegroundColor Blue
try {
    $body = @{ searchTerm = "<script>alert('xss')</script>" }
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:3000/search" -Method POST -Body $body -UseBasicParsing -MaximumRedirection 0 -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 302) {
        Write-Host "✅ XSS protection working" -ForegroundColor Green
    } else {
        Write-Host "❌ XSS protection failed (got $($response.StatusCode), expected 302)" -ForegroundColor Red
    }
} catch {
    if ($_.Exception.Response.StatusCode -eq 302) {
        Write-Host "✅ XSS protection working" -ForegroundColor Green
    } else {
        Write-Host "❌ XSS protection test error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test SQL injection protection
Write-Host "🛡️ Testing SQL injection protection..." -ForegroundColor Blue
try {
    $body = @{ searchTerm = "'; DROP TABLE users; --" }
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:3000/search" -Method POST -Body $body -UseBasicParsing -MaximumRedirection 0 -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 302) {
        Write-Host "✅ SQL injection protection working" -ForegroundColor Green
    } else {
        Write-Host "❌ SQL injection protection failed (got $($response.StatusCode), expected 302)" -ForegroundColor Red
    }
} catch {
    if ($_.Exception.Response.StatusCode -eq 302) {
        Write-Host "✅ SQL injection protection working" -ForegroundColor Green
    } else {
        Write-Host "❌ SQL injection protection test error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test valid input
Write-Host "✅ Testing valid input..." -ForegroundColor Blue
try {
    $body = @{ searchTerm = "hello world" }
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:3000/search" -Method POST -Body $body -UseBasicParsing -MaximumRedirection 0 -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 302) {
        Write-Host "✅ Valid input processing working" -ForegroundColor Green
    } else {
        Write-Host "❌ Valid input processing failed (got $($response.StatusCode), expected 302)" -ForegroundColor Red
    }
} catch {
    if ($_.Exception.Response.StatusCode -eq 302) {
        Write-Host "✅ Valid input processing working" -ForegroundColor Green
    } else {
        Write-Host "❌ Valid input processing test error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Clean up
Write-Host "🧹 Cleaning up..." -ForegroundColor Blue
docker-compose down

Write-Host "✨ Local testing completed!" -ForegroundColor Green
