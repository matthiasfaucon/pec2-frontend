#!/bin/sh
set -e

# Make sure the assets directory exists
mkdir -p /usr/share/nginx/html/assets

# Create or update the .env file with environment variables
if [ -n "$API_BASE_URL" ]; then
  echo "API_BASE_URL_WEB=$API_BASE_URL" > /usr/share/nginx/html/assets/.env
  echo "API_BASE_URL_ANDROID=$API_BASE_URL" >> /usr/share/nginx/html/assets/.env
  echo "API_BASE_URL_DEFAULT=$API_BASE_URL" >> /usr/share/nginx/html/assets/.env
fi

envsubst < /etc/nginx/http.d/default.conf.template > /etc/nginx/http.d/default.conf

exec nginx -g 'daemon off;'