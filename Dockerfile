# 移除之前的 sed 注入逻辑
RUN chmod -R 777 ./data && \
    chmod -R 777 ./open_webui && \
    chmod +x sync_data.sh

# 修改启动命令：先后台运行同步脚本，再启动主程序
CMD ["/bin/sh", "-c", "./sync_data.sh & ./start.sh"]
