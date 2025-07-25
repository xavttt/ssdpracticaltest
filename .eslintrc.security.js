module.exports = {
  env: {
    node: true,
    es2021: true,
  },
  extends: [
    'eslint:recommended',
    'plugin:security/recommended',
    'plugin:node/recommended'
  ],
  plugins: [
    'security',
    'node'
  ],
  parserOptions: {
    ecmaVersion: 2021,
    sourceType: 'module',
  },
  rules: {
    // Security-focused rules
    'security/detect-buffer-noassert': 'error',
    'security/detect-child-process': 'warn',
    'security/detect-disable-mustache-escape': 'error',
    'security/detect-eval-with-expression': 'error',
    'security/detect-new-buffer': 'error',
    'security/detect-no-csrf-before-method-override': 'error',
    'security/detect-non-literal-fs-filename': 'warn',
    'security/detect-non-literal-regexp': 'warn',
    'security/detect-non-literal-require': 'warn',
    'security/detect-object-injection': 'warn',
    'security/detect-possible-timing-attacks': 'warn',
    'security/detect-pseudoRandomBytes': 'error',
    'security/detect-unsafe-regex': 'error',
    
    // Node.js specific security rules
    'node/no-deprecated-api': 'error',
    'node/no-extraneous-require': 'error',
    'node/no-missing-require': 'error',
    'node/no-unpublished-require': 'off', // Allow dev dependencies
    
    // General security best practices
    'no-eval': 'error',
    'no-implied-eval': 'error',
    'no-new-func': 'error',
    'no-script-url': 'error',
    'strict': ['error', 'global'],
  },
  overrides: [
    {
      files: ['test/**/*.js', '**/*.test.js'],
      rules: {
        'security/detect-non-literal-require': 'off',
        'node/no-unpublished-require': 'off'
      }
    },
    {
      files: ['healthcheck.js'],
      rules: {
        'no-process-exit': 'off',
        'no-unused-vars': 'off'
      }
    }
  ]
};
