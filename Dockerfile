FROM ghcr.io/open-webui/open-webui:main

RUN apt-get update && apt-get install -y python3 python3-pip
RUN pip3 install --no-cache-dir huggingface_hub

COPY sync_data.sh sync_data.sh

RUN chmod -R 777 ./data && \
    chmod -R 777 /app/backend/open_webui/static && \
    chmod +x sync_data.sh && \
    sed -i "1r sync_data.sh" ./start.sh
