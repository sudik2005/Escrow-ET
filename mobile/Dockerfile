# Flutter release APK build
# Output: build/app/outputs/flutter-apk/app-release.apk
# Run via: docker compose --profile build run --rm mobile-build
FROM ghcr.io/cirruslabs/flutter:stable

WORKDIR /app

# Fetch dependencies before copying sources for better layer caching
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build apk --release

CMD ["sh", "-c", "echo 'APK ready at build/app/outputs/flutter-apk/app-release.apk'"]
