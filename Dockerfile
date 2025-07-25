# Use the official Node.js runtime as the base image
FROM node:18-alpine

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install dependencies with security flags
# --ignore-scripts: Prevents execution of potentially malicious pre/post install scripts
# --no-audit: Skips vulnerability audit for faster builds (auditing done in CI/CD)
# npm ci: More reliable than npm install for production builds
RUN npm ci --only=production --ignore-scripts --no-audit

# Copy only necessary application files (avoid copying sensitive data)
# Explicit file copying instead of COPY . . prevents accidental inclusion of:
# - .env files, SSH keys, certificates
# - .git directory, test files, documentation
# - .dockerignore provides additional protection
COPY server.js ./
COPY public/ ./public/
COPY healthcheck.js ./

# Create a non-root user and set up ownership
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001 && \
    chown -R nextjs:nodejs /app
USER nextjs

# Expose the port the app runs on
EXPOSE 3000

# Define environment variable
ENV NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js

# Command to run the application
CMD ["npm", "start"]
