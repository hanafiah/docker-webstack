FROM nginx:latest

# Update www-data user/group to match PHP containers (UID/GID 1000)
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

# Expose ports
EXPOSE 80 443

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
