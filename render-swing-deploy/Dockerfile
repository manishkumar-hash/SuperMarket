FROM eclipse-temurin:27-jre-noble

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99 \
    JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"

RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb x11vnc fluxbox novnc websockify ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app/
RUN chmod +x /app/start.sh && mkdir -p /var/data

EXPOSE 10000
CMD ["/app/start.sh"]
