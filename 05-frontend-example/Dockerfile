
FROM nginx:mainline-alpine3.21-slim
RUN rm -rf /etc/nginx/nginx.conf && \
    rm -rf /etc/nginx/conf.d/default.conf && \
    mkdir -p /var/cache/nginx/client_temp && \
    mkdir -p /var/cache/nginx/proxy_temp && \
    mkdir -p /var/cache/nginx/fastcgi_temp && \
    mkdir -p /var/cache/nginx/uwsgi_temp && \
    mkdir -p /var/cache/nginx/scgi_temp && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /etc/nginx/ && \
    chmod -R 755 /etc/nginx/ && \
    chown -R nginx:nginx /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid /run/nginx.pid
    # we need to create all the above directories as 
    # we are using alpine slim small image https://forums.docker.com/t/running-nginx-official-image-as-non-root/135759/8
COPY code /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
USER nginx
# with the above docker file code, the image size is of 13 MB





#BEFORE BEST PRACTICE IMPLEMENTATION - Docker image size is 193MB with below file
# take nginx official. It takes latest by default
FROM nginx
# copy the code from local to conatiner
COPY code /usr/share/nginx/html
# delete the existing default nginx configs
RUN rm -rf /etc/nginx/nginx.conf
RUN rm -rf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf
# COPY frontend.conf /etc/nginx/deafult.d/frontend.conf
