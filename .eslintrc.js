module.exports = {
  env: {
    node: true,
    es2021: true,
  },
  extends: [
    'eslint:recommended',
    'plugin:security/recommended'
  ],
  plugins: [
    'security'
  ],
  parserOptions: {
    ecmaVersion: 2021,
    sourceType: 'commonjs',
  },
  rules: {
    // Security rules
    'security/detect-object-injection': 'warn',
    'security/detect-non-literal-fs-filename': 'warn',
    'security/detect-eval-with-expression': 'error',
    'security/detect-new-buffer': 'error',
    'security/detect-unsafe-regex': 'error',
    
    // Code quality
    'no-unused-vars': 'warn',
    'no-console': 'off', // Allow console for server logging
    'semi': ['error', 'always'],
    'quotes': ['error', 'single'],
  }
};
