# Android Build Environment Dockerfile
FROM openjdk:17-slim

# Install necessary packages
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set up Android SDK
ENV ANDROID_SDK_ROOT=/android-sdk
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

# Download and install Android command line tools
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip -q commandlinetools-linux-9477386_latest.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm commandlinetools-linux-9477386_latest.zip

# Accept licenses and install SDK components
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" \
    "platforms;android-33" \
    "build-tools;33.0.2" \
    "extras;google;m2repository" \
    "extras;android;m2repository"

# Set working directory
WORKDIR /app

# Copy gradle files first for better caching
COPY gradle/ ./gradle/
COPY gradlew ./
COPY gradle.properties ./
COPY settings.gradle.kts ./
COPY build.gradle.kts ./

# Download dependencies
RUN ./gradlew dependencies

# Copy the rest of the application
COPY . .

# Build the application
RUN ./gradlew assembleDebug

# The APK will be available at app/build/outputs/apk/debug/app-debug.apk
CMD ["./gradlew", "assembleDebug"]