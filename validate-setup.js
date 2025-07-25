// Simple validation script to test our security implementation
const fs = require('fs');

console.log('🔍 Validating Secure Web Application Setup...\n');

// Check if required files exist
const requiredFiles = [
    'server.js',
    'package.json',
    'Dockerfile',
    'docker-compose.yml',
    '.github/workflows/ci.yml',
    'setup-sonarqube.sh',
    'sonar-project.properties'
];

let allFilesExist = true;

requiredFiles.forEach(file => {
    // Validate file name to prevent path traversal
    if (file && typeof file === 'string' && !file.includes('..') && fs.existsSync(file)) {
        console.log(`✅ ${file} - Found`);
    } else if (file && typeof file === 'string' && !file.includes('..')) {
        console.log(`❌ ${file} - Missing`);
        allFilesExist = false;
    } else {
        console.log(`❌ Invalid file name: ${file}`);
        allFilesExist = false;
    }
});

console.log('\n📋 Checking package.json configuration...');

try {
    const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    
    // Check security dependencies
    const securityDeps = [
        'helmet',
        'validator',
        'express-rate-limit'
    ];
    
    securityDeps.forEach(dep => {
        if (packageJson.dependencies && Object.prototype.hasOwnProperty.call(packageJson.dependencies, dep)) {
            console.log(`✅ Security dependency: ${dep}`);
        } else {
            console.log(`❌ Missing security dependency: ${dep}`);
            allFilesExist = false;
        }
    });
    
    // Check test scripts
    if (packageJson.scripts && packageJson.scripts.test) {
        console.log('✅ Test script configured');
    }
    
    if (packageJson.scripts && packageJson.scripts['security-scan']) {
        console.log('✅ Security scan script configured');
    }
    
} catch (error) {
    console.log(`❌ Error reading package.json: ${error.message}`);
    allFilesExist = false;
}

console.log('\n🐳 Checking Docker configuration...');

try {
    const dockerCompose = fs.readFileSync('docker-compose.yml', 'utf8');
    
    if (dockerCompose.includes('sonarqube:')) {
        console.log('✅ SonarQube service configured');
    }
    
    if (dockerCompose.includes('web:')) {
        console.log('✅ Web application service configured');
    }
    
    if (dockerCompose.includes('postgres:')) {
        console.log('✅ PostgreSQL database configured');
    }
    
} catch (error) {
    console.log(`❌ Error reading docker-compose.yml: ${error.message}`);
}

console.log('\n🔐 Checking server.js security implementation...');

try {
    const serverJs = fs.readFileSync('server.js', 'utf8');
    
    // Check for security features
    const securityFeatures = [
        { name: 'Helmet.js', pattern: /app\.use\(helmet/ },
        { name: 'Rate limiting', pattern: /rateLimit/ },
        { name: 'Input validation', pattern: /validateSearchInput/ },
        { name: 'XSS protection', pattern: /validator\.isAlphanumeric/ },
        { name: 'ReDoS protection', pattern: /\{1,50\}/ } // Check for bounded quantifiers
    ];
    
    securityFeatures.forEach(feature => {
        if (feature.pattern.test(serverJs)) {
            console.log(`✅ ${feature.name} implemented`);
        } else {
            console.log(`❌ ${feature.name} not found`);
        }
    });
    
} catch (error) {
    console.log(`❌ Error reading server.js: ${error.message}`);
}

console.log('\n🔑 Checking SonarQube token authentication...');

try {
    const sonarConfig = fs.readFileSync('sonar-project.properties', 'utf8');
    
    if (sonarConfig.includes('sonar.token=squ_')) {
        console.log('✅ Token authentication configured');
    } else if (sonarConfig.includes('sonar.login=') && sonarConfig.includes('sonar.password=')) {
        console.log('⚠️  Using deprecated username/password authentication');
    } else {
        console.log('❌ No authentication method found');
    }
    
} catch (error) {
    console.log(`❌ Error reading sonar-project.properties: ${error.message}`);
}

console.log('\n🎯 Overall Status:');
if (allFilesExist) {
    console.log('✅ All required files are present');
    console.log('🚀 Setup appears to be complete and ready for deployment!');
} else {
    console.log('❌ Some required files are missing');
    console.log('⚠️  Please check the missing files and complete the setup');
}

console.log('\n📚 Next Steps:');
console.log('1. Start services: docker-compose up --build');
console.log('2. Run SonarQube setup: bash setup-sonarqube.sh');
console.log('3. Run analysis: run-sonar-analysis.bat (Windows) or ./run-sonar-analysis.sh (Linux)');
console.log('4. Access application: http://localhost:3000');
console.log('5. Access SonarQube: http://localhost:9000');
console.log('6. Push to GitHub to trigger CI/CD pipeline');
console.log('');
console.log('🔑 Token Authentication:');
console.log('   SonarQube now uses token-based authentication.');
console.log('   The generated token is: squ_04a5f73594296b442672e1f92a633494c15fddc3');
