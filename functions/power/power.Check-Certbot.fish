function power.Check-Certbot -d "检查并安装 certbot 及插件"
  # Check if certbot is installed
  if not command -q certbot
    echo "Installing certbot..."
    if not sudo apt install -y certbot
      echo "Failed to install certbot!" >&2
      return 1
    end
    sudo apt install -y python3-certbot-nginx
  end

  if not pip3 show certbot-dns-multi >/dev/null 2>&1
    echo "Installing certbot-dns-multi..."
    sudo pip3 install certbot-dns-multi --break-system-packages || begin
      echo "Plugin installation failed" >&2
      return $OMF_UNKNOWN_ERR
    end
  end
end