FROM debian:bookworm-slim AS build

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa && \
    rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
WORKDIR /flutter
RUN git clone https://github.com/flutter/flutter.git -b stable
ENV PATH="/flutter/flutter/bin:/flutter/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run basic Flutter setup
RUN flutter doctor -v

# Set working directory for your app
WORKDIR /app

# Copy your Flutter app
COPY . .

# Clean & rebuild to ensure latest code
RUN flutter clean
RUN flutter pub get

#  Optional — Print your baseUrl for debugging
RUN grep "baseUrl" lib/api_service.dart || true

# Build Flutter web release
RUN flutter build web --release

# Stage 2 — Nginx Web Server
FROM nginx:alpine

# Copy built web files from Flutter stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose Nginx port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
