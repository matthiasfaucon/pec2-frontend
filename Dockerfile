# ---------- STAGE 1: Build Flutter ----------
FROM debian:latest AS build-env

# Install required dependencies
RUN apt-get update && \
    apt-get install -y curl git unzip xz-utils libglu1-mesa clang cmake ninja-build pkg-config

# Set up Flutter
ARG FLUTTER_SDK=/usr/local/flutter
ARG FLUTTER_VERSION=3.29.3
ARG APP=/app
ARG API_BASE_URL

# Set environment variables for build
ENV API_BASE_URL=$API_BASE_URL

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_SDK && \
    cd $FLUTTER_SDK && \
    git fetch && \
    git checkout $FLUTTER_VERSION

# Set environment path
ENV PATH="$FLUTTER_SDK/bin:$FLUTTER_SDK/bin/cache/dart-sdk/bin:$PATH"

# Disable Flutter analytics and run doctor
RUN flutter config --no-analytics && \
    # Configure to use the stable channel
    flutter channel stable && \
    flutter upgrade && \
    flutter doctor -v

# Set the working directory
WORKDIR $APP
COPY . $APP

# Create .env file if needed
RUN if [ -n "$API_BASE_URL" ]; then \
      echo "API_BASE_URL=${API_BASE_URL}" > .env; \
    fi

# If we're building from the CI workflow, the web build is already done
# If not, build the web app
RUN if [ ! -d "build/web" ]; then \
      flutter clean && \
      flutter pub get && \
      flutter build web --release; \
    fi

# ---------- STAGE 2: Serve via NGINX ----------
FROM nginx:1.25.2-alpine

COPY --from=build-env /app/build/web /usr/share/nginx/html
COPY docker/nginx/nginx.conf /etc/nginx/http.d/default.conf.template
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]