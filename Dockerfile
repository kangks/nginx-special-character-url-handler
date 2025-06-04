# Production stage
FROM nginx:alpine

COPY error.html /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80
