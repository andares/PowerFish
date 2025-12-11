function Install-Docker -d "安装 Docker 引擎及配置"
    # 检查root权限
    # if not test (id -u) -eq 0
    #     echo "Error: Please run this script with sudo" >&2
    #     return 1
    # end

    # 检查sudo权限
    if not power.Has-Sudo
      echo "Error: Need sudo permission" >&2
      return $OMF_UNKNOWN_ERR
      # 这里可以执行需要 sudo 的操作
    end

    # 卸载旧版本
    echo "Step 1: Removing old Docker versions..."
    sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null
    sudo apt purge -y docker-ce docker-ce-cli containerd.io 2>/dev/null
    sudo rm -rf /var/lib/docker /etc/docker

    # 安装依赖
    echo "Step 2: Installing dependencies..."
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg apt-transport-https software-properties-common

    # 添加Docker GPG密钥
    echo "Step 3: Adding Docker GPG key..."
    set -l key_urls "https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg"
    for url in $key_urls
        if curl -fsSL $url | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            echo "GPG key added successfully"
            break
        else
            echo "Warning: Failed to download from $url, trying next mirror..." >&2
        end
    end

    # 添加APT源
    echo "Step 4: Configuring Docker repository..."
    set -l codename (lsb_release -cs)
    set -l sources_list deb [arch=(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $codename stable

    echo $sources_list | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # 安装Docker
    echo "Step 5: Installing Docker engine..."
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io

    # 启动服务
    echo "Step 6: Starting Docker service..."
    sudo systemctl enable --now docker

    # 配置镜像加速器
    echo "Step 7: Configuring registry mirrors..."
    echo '{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://registry.aliyuncs.com"
  ]
}' | sudo tee /etc/docker/daemon.json > /dev/null
    sudo systemctl restart docker

    # 添加当前用户到docker组
    echo "Step 8: Configuring user permissions..."
    sudo usermod -aG docker $USER
    echo "NOTE: User $USER added to docker group. Please re-login for this to take effect."

    # 验证安装
    echo "Step 9: Verifying installation..."
    if sudo docker run --rm hello-world | grep -q "Hello from Docker!"
        echo "SUCCESS: Docker installed successfully!"
        echo "Registry mirrors configured:"
        sudo docker info | grep -A 2 Mirrors
    else
        echo "ERROR: Docker installation verification failed" >&2
        return 1
    end
end
