# Stage 1: Flutter Build
FROM debian:bookworm-slim AS build

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /flutter
RUN git clone https://github.com/flutter/flutter.git -b stable
ENV PATH="/flutter/flutter/bin:/flutter/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Pre-download Flutter dependencies
RUN flutter doctor -v

WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get

# Now copy the full app (so code change triggers rebuild)
COPY . .

# Clean and rebuild Flutter web app every time
RUN flutter clean && flutter pub get && flutter build web --release --no-tree-shake-icons

# Stage 2: Serve using Nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
