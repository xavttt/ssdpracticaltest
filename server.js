const express = require('express');
const path = require('path');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const validator = require('validator');

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ['\'self\''],
            styleSrc: ['\'self\'', '\'unsafe-inline\''],
            scriptSrc: ['\'self\''],
            imgSrc: ['\'self\'', 'data:', 'https:'],
        },
    },
}));

// Rate limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP, please try again later.'
});
app.use(limiter);

// Parse URL-encoded bodies
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Serve static files
app.use(express.static('public'));

// Input validation function based on OWASP Top 10 Proactive Control C5
function validateSearchInput(input) {
    if (!input || typeof input !== 'string') {
        return { isValid: false, reason: 'Invalid input type' };
    }

    // Trim whitespace
    input = input.trim();

    // Check for empty input
    if (input.length === 0) {
        return { isValid: false, reason: 'Empty input' };
    }

    // Check length (prevent excessive input)
    if (input.length > 100) {
        return { isValid: false, reason: 'Input too long' };
    }

    // XSS Prevention - Check for common XSS patterns (ReDoS-safe)
    const xssPatterns = [
        /<script[^>]*>/i,
        /<\/script>/i,
        /<iframe[^>]*>/i,
        /<object[^>]*>/i,
        /<embed[^>]*>/i,
        /<link[^>]*>/i,
        /javascript:/i,
        /vbscript:/i,
        /on\w+\s*=/i,
        /<[^>]{1,100}>/,
        /&lt;[^&]{1,50}&gt;/,
        /&#x?[0-9a-f]{1,6};/i
    ];

    for (const pattern of xssPatterns) {
        if (pattern.test(input)) {
            return { isValid: false, reason: 'Potential XSS attack detected' };
        }
    }

    // SQL Injection Prevention - Check for common SQL injection patterns (ReDoS-safe)
    const sqlPatterns = [
        /(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|EXECUTE|UNION|SCRIPT)\b)/gi,
        /(\b(OR|AND)\s+\d+\s*=\s*\d+)/gi,
        /(\b(OR|AND)\s+'\w{1,20}'\s*=\s*'\w{1,20}')/gi, // Limited repetition to prevent ReDoS
        /(\b(OR|AND)\s+"\w{1,20}"\s*=\s*"\w{1,20}")/gi, // Limited repetition to prevent ReDoS
        /(;[^;]{0,50}--|\/\*[^*]{0,100}\*\/|--\s[^\r\n]{0,50})/g, // Specific length limits for SQL comments
        /(\bUNION\b.*\bSELECT\b)/gi,
        /(\b(WAITFOR|DELAY)\b)/gi,
        /(\bCAST\s*\()/gi,
        /(\bCONVERT\s*\()/gi,
        /(\bDECLARE\s+@)/gi,
        /(\\x[0-9a-f]{2}|%[0-9a-f]{2})/gi,
        // Safe patterns for quote injection detection
        /('[^']{0,50}'[^']{0,20}=[^']{0,20}'[^']{0,50}')/gi,
        /("[^"]{0,50}"[^"]{0,20}=[^"]{0,20}"[^"]{0,50}")/gi
    ];

    for (const pattern of sqlPatterns) {
        if (pattern.test(input)) {
            return { isValid: false, reason: 'Potential SQL injection attack detected' };
        }
    }

    // Additional validation using validator library
    // Allow alphanumeric characters, spaces, hyphens, underscores, and periods
    if (!validator.isAlphanumeric(input, 'en-US', { ignore: ' -_.' })) {
        return { isValid: false, reason: 'Invalid characters detected' };
    }

    return { isValid: true, reason: 'Valid input' };
}

// Home page route
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Search route
app.post('/search', (req, res) => {
    const searchTerm = req.body.searchTerm;
    
    // Validate input
    const validation = validateSearchInput(searchTerm);
    
    if (!validation.isValid) {
        // If validation fails, redirect to home with error
        res.redirect('/?error=' + encodeURIComponent(validation.reason));
        return;
    }

    // If validation passes, redirect to results page
    res.redirect('/results?q=' + encodeURIComponent(searchTerm));
});

// Results page route
app.get('/results', (req, res) => {
    const searchTerm = req.query.q;
    
    if (!searchTerm) {
        res.redirect('/');
        return;
    }

    // Re-validate the search term (defense in depth)
    const validation = validateSearchInput(searchTerm);
    
    if (!validation.isValid) {
        res.redirect('/?error=' + encodeURIComponent(validation.reason));
        return;
    }

    res.sendFile(path.join(__dirname, 'public', 'results.html'));
});

// Start server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Access the application at: http://localhost:${PORT}`);
});

module.exports = app;
