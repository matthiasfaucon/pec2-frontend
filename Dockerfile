FROM debian:latest AS build-env

RUN apt-get update && \
    apt-get install -y curl git unzip xz-utils libglu1-mesa clang cmake ninja-build pkg-config

ARG FLUTTER_SDK=/usr/local/flutter
ARG FLUTTER_VERSION=3.29.3
ARG APP=/app
ARG API_BASE_URL

ENV API_BASE_URL=$API_BASE_URL

RUN git clone https://github.com/flutter/flutter.git $FLUTTER_SDK && \
    cd $FLUTTER_SDK && \
    git fetch && \
    git checkout $FLUTTER_VERSION

ENV PATH="$FLUTTER_SDK/bin:$FLUTTER_SDK/bin/cache/dart-sdk/bin:$PATH"

RUN flutter doctor -v

WORKDIR $APP
COPY . $APP

RUN echo "API_BASE_URL_WEB=${API_BASE_URL}" > .env && \
    echo "API_BASE_URL_ANDROID=${API_BASE_URL}" >> .env && \
    echo "API_BASE_URL_IOS=${API_BASE_URL}" >> .env && \
    echo "API_BASE_URL_DEFAULT=${API_BASE_URL}" >> .env

RUN flutter clean && flutter pub get && flutter build web

FROM nginx:1.25.2-alpine

ENV NGINX_PORT=80

COPY --from=build-env /app/build/web /usr/share/nginx/html

RUN mkdir -p /usr/share/nginx/html/assets
COPY --from=build-env /app/.env /usr/share/nginx/html/assets/.env
COPY docker/nginx/nginx.conf /etc/nginx/http.d/default.conf.template
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]