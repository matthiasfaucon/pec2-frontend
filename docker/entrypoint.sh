#!/bin/sh
set -e

envsubst < /etc/nginx/http.d/default.conf.template > /etc/nginx/http.d/default.conf

exec nginx -g 'daemon off;'