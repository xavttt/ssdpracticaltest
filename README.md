# Secure Web Application

A secure Node.js web application that implements OWASP Top 10 Proactive Control C5: Validate All Inputs to prevent XSS and SQL injection attacks.

## Features

- 🔒 **Input Validation**: Comprehensive validation against XSS and SQL injection attacks
- 🛡️ **Security Headers**: Helmet.js for security headers including CSP
- ⚡ **Rate Limiting**: Protection against DoS and brute force attacks
- 🐳 **Dockerized**: Ready to run in a secure Docker container
- 📝 **User-Friendly Interface**: Clean, responsive web interface

## Security Implementation

### OWASP Top 10 Proactive Controls Implemented:
- **C5: Validate All Inputs** - Comprehensive input validation and sanitization
- **C6: Implement Digital Identity** - Secure session management
- **C7: Enforce Access Controls** - Rate limiting and security headers
- **C8: Protect Data Everywhere** - Secure data transmission

### Protection Against:
- Cross-Site Scripting (XSS)
- SQL Injection
- Script injection attacks
- Malicious payload execution
- DoS attacks via rate limiting

## Quick Start

### Using Docker (Recommended)

1. **Build and run with Docker Compose:**
   ```bash
   docker-compose up --build
   ```

2. **Or build and run with Docker:**
   ```bash
   docker build -t secure-web-app .
   docker run -p 3000:3000 secure-web-app
   ```

### Local Development

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Start the server:**
   ```bash
   npm start
   ```

3. **Access the application:**
   Open your browser and go to `http://localhost:3000`

## SonarQube Code Quality Analysis

This project includes SonarQube integration for continuous code quality and security analysis.

### Local SonarQube Setup:

1. **Start SonarQube with Docker Compose:**
   ```bash
   docker-compose up -d sonarqube db
   ```

2. **Set up SonarQube configuration:**
   ```bash
   chmod +x setup-local-sonarqube.sh
   ./setup-local-sonarqube.sh
   ```

3. **Access SonarQube Web Interface:**
   - URL: `http://localhost:9000`
   - Username: `admin`
   - Password: `2301801@SIT.singaporetech.edu.sg`

4. **Run code analysis:**
   ```bash
   # Method 1: Using token authentication (recommended)
   export SONAR_TOKEN=your-token-here  # Get token from setup script output
   ./run-sonar-analysis.sh
   
   # Method 2: Using deprecated username/password
   npm install -g sonarqube-scanner
   sonar-scanner
   ```

### Important Notes:
- **Token Authentication**: SonarQube now requires token-based authentication instead of username/password
- **Getting a Token**: Run `./setup-local-sonarqube.sh` and look for the generated token in the output
- **Environment Variable**: Set `SONAR_TOKEN` environment variable for seamless authentication

### CI/CD Integration:
SonarQube analysis runs automatically in GitHub Actions CI/CD pipeline with:
- Security hotspot detection
- Code quality metrics
- Vulnerability scanning
- Technical debt analysis

## How to Test Security Features

### Test XSS Protection:
Try entering these malicious inputs (they should be blocked):
- `<script>alert('XSS')</script>`
- `<img src=x onerror=alert('XSS')>`
- `javascript:alert('XSS')`

### Test SQL Injection Protection:
Try entering these malicious inputs (they should be blocked):
- `'; DROP TABLE users; --`
- `' OR '1'='1`
- `UNION SELECT * FROM users`

### Valid Inputs:
These should work fine:
- `hello world`
- `test search 123`
- `node.js security`

## Project Structure

```
├── server.js              # Main Express server with security validation
├── public/
│   ├── index.html         # Home page with search form
│   └── results.html       # Results page
├── package.json           # Node.js dependencies
├── Dockerfile            # Docker container configuration
├── docker-compose.yml    # Docker Compose setup
├── healthcheck.js        # Health check for Docker
└── README.md            # This file
```

## Security Features

### Input Validation
- Pattern matching for XSS attempts
- SQL injection pattern detection
- Character allowlist validation
- Length restrictions
- Type checking

### Server Security
- Helmet.js for security headers
- Content Security Policy (CSP)
- Rate limiting (100 requests per 15 minutes)
- HTTPS-ready configuration
- Non-root user in Docker

### Frontend Security
- No inline JavaScript execution
- Safe DOM manipulation using textContent
- Client-side validation as additional layer
- Automatic input clearing on security violations

## Environment Variables

- `PORT`: Server port (default: 3000)
- `NODE_ENV`: Environment mode (production/development)

## License

MIT License
