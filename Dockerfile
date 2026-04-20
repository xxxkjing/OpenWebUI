FROM ghcr.io/open-webui/open-webui:main

# 复制同步脚本 [1]
COPY sync_data.sh sync_data.sh

# 赋予权限并注入到启动脚本 start.sh 的首行 [1]
RUN chmod -R 777 ./data && \
    chmod -R 777 ./open_webui && \
    chmod +x sync_data.sh && \
    sed -i "1r sync_data.sh" ./start.sh
