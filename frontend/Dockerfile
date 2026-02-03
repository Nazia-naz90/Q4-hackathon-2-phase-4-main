# frontend/Dockerfile

# Multi-stage build for optimized production image
# Stage 1: Dependencies installation
FROM node:20-alpine AS deps

# Install curl for health check
RUN apk add --no-cache curl

# Working directory
WORKDIR /app

# Copy package files
COPY package.json ../package-lock.json* ./

# Install all dependencies (including dev dependencies) for the build process
RUN npm ci

# Stage 2: Build stage
FROM node:20-alpine AS builder

# Install curl for health check
RUN apk add --no-cache curl

# Working directory
WORKDIR /app

# Copy package files and installed dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY package.json ../package-lock.json* ./

# Copy entire frontend code (excluding files via .dockerignore)
COPY . .

# Build the application
RUN npm run build

# Stage 3: Production stage - Install only production dependencies
FROM node:20-alpine AS production-deps

# Install curl for health check
RUN apk add --no-cache curl

# Working directory
WORKDIR /app

# Copy package files and install only production dependencies
COPY package.json ../package-lock.json* ./
RUN npm ci --only=production

# Stage 4: Final production stage
FROM node:20-alpine AS production

# Install curl for health check
RUN apk add --no-cache curl

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Working directory
WORKDIR /app

# Copy necessary files from previous stages
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=production-deps /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Change ownership to non-root user
RUN chown -R nextjs:nodejs /app

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1

# Start Next.js app
CMD ["node", "server.js"]