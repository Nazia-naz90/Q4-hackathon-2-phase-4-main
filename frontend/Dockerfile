# Use official Node runtime as a parent image
FROM node:21-alpine AS builder

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY frontend/package.json frontend/package-lock.json ./

# Install dependencies
RUN npm ci --only=production

# Copy the rest of the frontend application
COPY frontend/ ./

# Build the Next.js application
RUN npm run build

# Production stage
FROM node:21-alpine

# Set the working directory
WORKDIR /app

# Copy package.json and installed dependencies from builder stage
COPY frontend/package.json ./
COPY --from=builder /app/node_modules ./node_modules

# Copy the built application from builder stage
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.ts ./
COPY --from=builder /app/package.json ./
COPY --from=builder /app/tsconfig.json ./

# Set environment variables
ENV NODE_ENV=production

# Expose port 3000 to allow communication to/from the frontend
EXPOSE 3000

# Create non-root user for security
RUN adduser --disabled-password --gecos '' appuser && \
    chown -R appuser:appuser /app
USER appuser

# Run the application
CMD ["npm", "start"]