#!/bin/bash

mkdir -p ./data

# 生成校验和函数
generate_sum() {
    local file=$1
    local sum_file=$2
    sha256sum "$file" > "$sum_file"
}

# 🛠️ 修复版恢复逻辑：优先从 WebDAV 恢复数据，增加超时限制
if [ ! -z "$WEBDAV_URL" ] && [ ! -z "$WEBDAV_USERNAME" ] && [ ! -z "$WEBDAV_PASSWORD" ]; then
    echo "尝试从WebDAV恢复数据 (限时60秒)..."
    # 增加超时参数防止阻塞启动 [1]
    curl -L --fail --connect-timeout 15 --max-time 60 --user "$WEBDAV_USERNAME:$WEBDAV_PASSWORD" "$WEBDAV_URL/webui.db" -o "./data/webui.db" && {
        echo "从WebDAV恢复数据成功"
    } || {
        if [ ! -z "$G_NAME" ] && [ ! -z "$G_TOKEN" ]; then
            echo "WebDAV恢复失败, 尝试从GitHub恢复..."
            REPO_URL="https://${G_TOKEN}@github.com/${G_NAME}.git"
            git clone --depth 1 "$REPO_URL" ./data/temp && {
                if [ -f ./data/temp/webui.db ]; then
                    mv ./data/temp/webui.db ./data/webui.db
                    echo "从GitHub仓库恢复成功"
                    rm -rf ./data/temp
                else
                    echo "GitHub仓库中未找到webui.db"
                    rm -rf ./data/temp
                fi
            }
        else
            echo "恢复失败或超时，将以全新数据库启动..."
        fi
    }
else
    echo "未配置WebDAV,跳过数据恢复"
fi

# 🔄 后台同步循环函数
sync_data() {
    while true; do
        echo "开始定期同步检查..."
        HOUR=$(date +%H)
        
        if [ -f "./data/webui.db" ]; then
            generate_sum "./data/webui.db" "./data/webui.db.sha256.new"
            
            if [ ! -f "./data/webui.db.sha256" ] || ! cmp -s "./data/webui.db.sha256.new" "./data/webui.db.sha256"; then
                echo "检测到文件变化，开始同步到云端..."
                mv "./data/webui.db.sha256.new" "./data/webui.db.sha256"
                
                if [ ! -z "$WEBDAV_URL" ]; then
                    curl -L -T "./data/webui.db" --user "$WEBDAV_USERNAME:$WEBDAV_PASSWORD" "$WEBDAV_URL/webui.db" && echo "WebDAV更新成功"
                    
                    # 每日 0 点执行异地备份 [1]
                    if [ "$HOUR" = "00" ]; then
                        YESTERDAY=$(date -d "yesterday" '+%Y%m%d')
                        curl -L -T "./data/webui.db" --user "$WEBDAV_USERNAME:$WEBDAV_PASSWORD" "$WEBDAV_URL/webui_${YESTERDAY}.db"
                    fi
                fi
            fi
        fi
        sleep 300 # 每5分钟同步一次 [1]
    done
}

# 🚀 必须以后台方式启动同步，确保不阻塞 Web 服务
sync_data &
