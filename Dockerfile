# Create build environment from Apline linux
FROM alpine:latest AS build

# Add packages
RUN apk add --no-cache znc znc-dev git g++ cmake make python3 openssl-dev icu-dev

# Compile extra modules
RUN git clone https://github.com/CyberShadow/znc-clientbuffer.git /tmp/znc-clientbuffer
WORKDIR /tmp/znc-clientbuffer
RUN PREFIX=/usr make

# Create runtime environment from Apline linux
FROM alpine:latest

# Args
ARG UID=29380
ARG GID=29380

# Add packages
RUN apk add --no-cache znc
COPY --from=build /tmp/znc-clientbuffer/clientbuffer.so /usr/lib/znc/

# Add user
RUN addgroup -g $GID user
RUN adduser -s /sbin/nologin -G user -D -u $UID user

# Drop root
USER user
WORKDIR /home/user

# Start znc
CMD ["znc", "-f"]
