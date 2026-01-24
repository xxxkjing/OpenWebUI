FROM ghcr.io/open-webui/open-webui:main

LABEL "language"="python"
LABEL "framework"="open-webui"

WORKDIR /app

COPY sync_data.sh /app/sync_data.sh

RUN chmod +x /app/sync_data.sh && \
    chmod -R 777 /app/data && \
    chmod -R 777 /app/open_webui && \
    sed -i "1r /app/sync_data.sh" /app/start.sh && \
    chmod +x /app/start.sh

EXPOSE 3000

CMD ["/app/start.sh"]
