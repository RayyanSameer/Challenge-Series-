ARG NGINX_VERSION=1.21.6
FROM nginx:${NGINX_VERSION}

WORKDIR /app

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

COPY . . 
EXPOSE 80