function tc.Renew-Cert -a domain secretName mail
  set -l SECRET_DOMAIN tencentcloud

  # 检查sudo权限
  if not power.Has-Sudo
    echo "Error: Need sudo permission" >&2
    return $OMF_UNKNOWN_ERR
  end

  # 参数验证
  if test -z "$domain"; or test -z "$secretName"
    echo "Usage: Show-SecretFile <domain> <secretName>" >&2
    return 1
  end

  # 读密钥 (直接捕获输出)
  set -l tc_secret (Show-SecretFile $SECRET_DOMAIN $secretName 2>&1)

  # 增强错误检查
  if test $status -ne 0; or string match -q "Error:*" -- $tc_secret[1]
    echo "TencentCloud secret load fail: $tc_secret" >&2
    return $OMF_UNKNOWN_ERR
  end

  # 安全解析密钥 (避免全局导出)
  set -l TENCENTCLOUD_SECRET_ID
  set -l TENCENTCLOUD_SECRET_KEY

  for line in $tc_secret
    set -l kv (string split -m1 '=' -- $line | string trim)
    switch $kv[1]
      case "TENCENTCLOUD_SECRET_ID"
        set TENCENTCLOUD_SECRET_ID $kv[2]
      case "TENCENTCLOUD_SECRET_KEY"
        set TENCENTCLOUD_SECRET_KEY $kv[2]
    end
  end

  # 密钥验证
  if test -z "$TENCENTCLOUD_SECRET_ID"; or test -z "$TENCENTCLOUD_SECRET_KEY"
    echo "TencentCloud secret is not defined" >&2
    return $OMF_UNKNOWN_ERR
  end

  # 检查依赖
  power.Check-Python
  power.Check-Certbot
  if not pip3 show certbot-dns-tencentcloud >/dev/null 2>&1
    echo "Installing certbot-dns-tencentcloud..."
    sudo pip3 install certbot-dns-tencentcloud --break-system-packages || begin
      echo "Plugin installation failed" >&2
      return $OMF_UNKNOWN_ERR
    end
  end

  # 设置临时环境变量 (仅限当前命令)
  set -lx TENCENTCLOUD_SECRET_ID $TENCENTCLOUD_SECRET_ID
  set -lx TENCENTCLOUD_SECRET_KEY $TENCENTCLOUD_SECRET_KEY

  # 申请证书 (添加关键参数)
  echo "Renewing certificate for $domain..."
  if not test -z "$mail"
    sudo env TENCENTCLOUD_SECRET_ID="$TENCENTCLOUD_SECRET_ID" TENCENTCLOUD_SECRET_KEY="$TENCENTCLOUD_SECRET_KEY" \
      certbot certonly \
      --email "$mail" \
      --non-interactive \
      --agree-tos \
      --authenticator dns-tencentcloud \
      --dns-tencentcloud-propagation-seconds 60 \
      -d "$domain" \
      --server https://acme-v02.api.letsencrypt.org/directory
  else
    sudo env TENCENTCLOUD_SECRET_ID="$TENCENTCLOUD_SECRET_ID" TENCENTCLOUD_SECRET_KEY="$TENCENTCLOUD_SECRET_KEY" \
      certbot certonly \
      --non-interactive \
      --agree-tos \
      --authenticator dns-tencentcloud \
      --dns-tencentcloud-propagation-seconds 60 \
      -d "$domain" \
      --server https://acme-v02.api.letsencrypt.org/directory
  end


  # 检查Certbot执行状态
  if test $status -ne 0
    echo "Certbot failed to renew certificate" >&2
    return $OMF_UNKNOWN_ERR
  end

  # 验证证书文件是否存在
  set -l cert_path "/etc/letsencrypt/live/(string replace '*' 'wildcard' $domain)"
  if not test -f "$cert_path/fullchain.pem"
    echo "Certificate file not found: $cert_path/fullchain.pem" >&2
    return $OMF_UNKNOWN_ERR
  end

  # 安全重启nginx
  echo "Reloading Nginx..."
  sudo systemctl reload nginx || begin
    echo "Nginx reload failed, attempting restart..."
    sudo systemctl restart nginx || begin
      echo "Nginx restart failed!" >&2
      return $OMF_UNKNOWN_ERR
    end
  end

  echo "Certificate renewal successful"
end