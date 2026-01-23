FROM ghcr.io/open-webui/open-webui:latest

COPY sync_data.sh /sync_data.sh
RUN chmod +x /sync_data.sh

ENV PORT=3000
EXPOSE 3000

CMD ["/bin/bash", "-c", "/sync_data.sh & python3 -m open_webui --host 0.0.0.0 --port $PORT"]
