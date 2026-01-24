FROM ghcr.io/open-webui/open-webui:v0.7.1

# 让同步脚本进入镜像
COPY sync_data.sh /sync_data.sh
RUN chmod +x /sync_data.sh

# 官方镜像默认在容器内监听 8080（文档示例是 -p 3000:8080）
EXPOSE 8080

# 先恢复数据并启动后台同步，再启动 Ope:contentReference[oaicite:5]{index=5}内部会把 sync_data 放后台运行（你原脚本最后就是 sync_data &）
CMD ["/bin/bash", "-lc", "/sync_data.sh; exec bash /app/backend/start.sh"]
