FROM ghcr.io/open-webui/open-webui:main

# 复制同步脚本
COPY sync_data.sh /app/sync_data.sh

# 仅设置权限，移除 sed 注入逻辑
RUN chmod -R 777 ./data && \
    chmod -R 777 ./open_webui && \
    chmod +x /app/sync_data.sh

# 使用后台运行符 & 确保同步脚本不阻塞主程序
CMD ["/bin/sh", "-c", "/app/sync_data.sh & ./start.sh"]
