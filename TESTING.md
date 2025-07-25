# Testing Documentation

This project includes automated testing via GitHub Actions and local testing scripts.

## GitHub Actions Workflow

The CI/CD pipeline (`.github/workflows/ci.yml`) runs automatically on every push to the `main` branch and includes:

### 🔍 **Tests Performed:**

1. **Dependency Security Audit**
   - Checks for known vulnerabilities in npm packages
   - Fails on critical vulnerabilities
   - Warns on high severity issues

2. **Integration Testing**
   - Application accessibility test
   - Valid search input processing
   - XSS attack protection verification
   - SQL injection protection verification
   - Application responsiveness testing

3. **Security Headers Testing**
   - Verifies presence of security headers (X-Content-Type-Options, X-Frame-Options)
   - Ensures proper security configuration

4. **UI Testing with Playwright**
   - Home page load verification
   - Form presence and functionality
   - XSS protection user interface testing
   - Valid search flow testing

5. **Vulnerability Scanning**
   - JSON-formatted audit results
   - Automated threshold checking
   - Artifact upload for review

## Local Testing

### Windows (PowerShell)
```powershell
.\test-local.ps1
```

### Linux/Mac (Bash)
```bash
chmod +x test-local.sh
./test-local.sh
```

### Manual Testing

You can also test manually by:

1. Starting the application:
   ```bash
   docker-compose up -d
   ```

2. Testing endpoints:
   ```bash
   # Home page
   curl http://127.0.0.1
   
   # Valid search
   curl -X POST -d "searchTerm=hello world" http://127.0.0.1/search
   
   # XSS test (should be blocked)
   curl -X POST -d "searchTerm=<script>alert('xss')</script>" http://127.0.0.1/search
   
   # SQL injection test (should be blocked)
   curl -X POST -d "searchTerm='; DROP TABLE users; --" http://127.0.0.1/search
   ```

3. Cleaning up:
   ```bash
   docker-compose down
   ```

## Test Results

- ✅ **Pass**: All security measures working correctly
- ❌ **Fail**: Security vulnerability or test failure
- ⚠️ **Warning**: Non-critical issues found

## Security Features Tested

- **Input Validation**: OWASP Top 10 Proactive Control C5
- **XSS Protection**: Script injection prevention
- **SQL Injection Protection**: Database attack prevention
- **Security Headers**: Helmet.js configuration
- **Rate Limiting**: DoS protection
- **Content Security Policy**: Script execution control
