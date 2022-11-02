FROM nginx:1.19

# Arguments defined in docker-compose.yml
ARG uid
ARG gid

COPY ./conf/default.conf /etc/nginx/conf.d/default.conf

# Set working directory
WORKDIR /var/www/app