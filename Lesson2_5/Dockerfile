FROM nginx:1.27-alpine

LABEL org.opencontainers.image.title="lesson2-5-practice"
LABEL org.opencontainers.image.description="Practical work: container management, logs, networks and volumes"

ENV LESSON="2.5"

COPY site/index.html /usr/share/nginx/html/index.html

HEALTHCHECK --interval=15s --timeout=3s --retries=3 \
  CMD wget -qO- http://127.0.0.1/ >/dev/null || exit 1

EXPOSE 80
