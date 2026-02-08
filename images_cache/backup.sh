#!/bin/bash
# backup-minikube-images.sh

BACKUP_DIR="$HOME/minikube-backup"
mkdir -p "$BACKUP_DIR"

echo "📦 备份 Minikube 镜像..."

# 获取所有镜像列表
IMAGES=$(minikube image ls | tail -n +1)

# 保存每个镜像到 tar 文件
for image in $IMAGES; do
    # 处理 <none> 标签的镜像
    if [[ "$image" == *"<none>"* ]]; then
        continue
    fi

    echo "备份: $image"

    # 生成安全的文件名（替换 / 和 :）
    filename=$(echo "$image" | sed 's|[/:]|_|g').tar
    filepath="$BACKUP_DIR/$filename"

    # 从 Minikube 中拉取到本地 Docker
    docker pull $image 2>/dev/null || true

    # 保存镜像
    docker save $image -o "$filepath"

    echo "  ✅ 保存到: $filepath"
done

# 创建镜像列表文件
minikube image ls > "$BACKUP_DIR/images-list.txt"

echo ""
echo "🎉 备份完成！"
echo "📁 备份目录: $BACKUP_DIR"
echo "📋 镜像列表: $BACKUP_DIR/images-list.txt"
ls -lh "$BACKUP_DIR/"
