FROM docker.io/library/alpine:3.22.8

LABEL maintainer="HomeLabHD <homelabhelp@gmail.com>" \
    org.opencontainers.image.title="isync" \
    org.opencontainers.image.description="isync (mbsync): two-way IMAP mailbox synchronization, rootless." \
    org.opencontainers.image.source="https://github.com/HomeLabHD/isync" \
    org.opencontainers.image.url="https://hub.docker.com/r/hlhd/isync" \
    org.opencontainers.image.documentation="https://github.com/HomeLabHD/isync#readme" \
    org.opencontainers.image.licenses="GPL-2.0-or-later" \
    org.opencontainers.image.vendor="HomeLabHD"

ARG ISYNC_VERSION=1.5.1-r0

ENV HOME=/var/lib/mbsync

RUN apk add --no-cache "isync=${ISYNC_VERSION}" ca-certificates tini \
 && mbsync --version

# Sync state (mbsync's SyncState files) lives here; writable by any UID through group 0.
RUN mkdir -p /var/lib/mbsync \
 && chown -R 65532:0 /var/lib/mbsync \
 && chmod -R g+rwX /var/lib/mbsync

COPY --chmod=0755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

VOLUME ["/var/lib/mbsync"]
WORKDIR /var/lib/mbsync
USER 65532:0

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["--version"]
