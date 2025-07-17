function tc.Check-Tccli -d "检查并安装 tccli 工具"
  # 首先检查 Python 和 pip 环境
  power.Check-Python
  if not command -q pip3
    echo "Python environment setup failed. Please check manually."
    return 1
  end

  # 检查 tccli 是否已安装
  if not command -q tccli
    echo "Installing tccli via pip3..."
    pip3 install tccli
  end

  # 验证安装结果
  if command -q tccli
    echo "tccli is ready: version (tccli --version)"
  else
    echo "Failed to install tccli. Please check pip installation."
    return 1
  end
end