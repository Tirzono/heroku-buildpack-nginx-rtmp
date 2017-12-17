#!/bin/bash
# Build NGINX and modules on Heroku.

# This program is designed to run during the
# application build process.
# We would like to build an NGINX binary for the buildpack on the
# exact machine in which the binary will run.

NGINX_VERSION=nginx-1.11.3
NGINX_RTMP_MODULE_VERSION=1.1.9

INSTALL_ROOT=$1

nginx_tarball_url=https://nginx.org/download/${NGINX_VERSION}.tar.gz
rtmp_tarball_url=https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_MODULE_VERSION}.tar.gz

temp_dir=$(mktemp -d /tmp/nginx.XXXXXXXXXX)

cd $temp_dir
echo "Temp dir: $temp_dir"

echo "Downloading $nginx_tarball_url"
curl -L $nginx_tarball_url | tar xzv

echo "Downloading $pcre_tarball_url"
(cd ${NGINX_VERSION} && curl -L $rtmp_tarball_url | tar xzv )

echo "Starting build..."

(
	cd ${NGINX_VERSION}
	./configure \
	    --with-http_ssl_module \
	    --with-threads \
	    --with-ipv6 \
	    --prefix=${INSTALL_ROOT} \
	    --add-module=/${temp_dir}/${NGINX_VERSION}/nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION}
	    --with-debug
	make install
)

echo "Build completed successfully."
