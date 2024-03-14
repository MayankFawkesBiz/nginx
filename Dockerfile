FROM ubuntu:22.04 as builder

ARG NGINX_VERSION=${NGINX_VERSION}
ARG NGINX_VERSION_NAME=${NGINX_VERSION_NAME}

RUN apt update \
    && apt upgrade -y \
    && apt install -y libpcre3 libpcre3-dev zlib1g zlib1g-dev openssl libssl-dev wget git gcc make libbrotli-dev

WORKDIR /app
RUN wget https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && tar -zxf nginx-$NGINX_VERSION.tar.gz
RUN git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli
RUN cd nginx-${NGINX_VERSION} && ./configure --with-compat --add-dynamic-module=../ngx_brotli \
    && make modules

FROM nginx:${NGINX_VERSION_NAME}
COPY --from=builder /app/nginx-$NGINX_VERSION/objs/ngx_http_brotli_static_module.so /etc/nginx/modules/
COPY --from=builder /app/nginx-$NGINX_VERSION/objs/ngx_http_brotli_filter_module.so /etc/nginx/modules/