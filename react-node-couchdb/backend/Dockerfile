# Use Node.js LTS
FROM node:18

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy rest of the backend code
COPY . .

# Expose the backend port
EXPOSE 5000

# Start the backend server
CMD ["node", "server.js"]
