#!/bin/bash
# restore-minikube-images.sh

BACKUP_DIR="$HOME/minikube-backup"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ 备份目录不存在: $BACKUP_DIR"
    exit 1
fi

echo "🔄 恢复 Minikube 镜像..."

# 先启动 Minikube
# minikube start --memory=22258MB --driver=docker --container-runtime=docker --gpus=all --force --addons=nvidia-device-plugin

# 恢复每个镜像
for tar_file in "$BACKUP_DIR"/*.tar; do
    if [ -f "$tar_file" ]; then
        echo "加载: $(basename $tar_file)"

        # 加载镜像到 Docker
        docker load -i "$tar_file"

        # 获取镜像名称（从文件名反推）
        image_name=$(basename "$tar_file" .tar | sed 's|_|/|' | sed 's|_|:|')

        # 加载到 Minikube
        minikube image load "$image_name" 2>/dev/null || true

        echo "  ✅ 恢复: $image_name"
    fi
done

echo ""
echo "✅ 恢复完成！"
minikube image ls
