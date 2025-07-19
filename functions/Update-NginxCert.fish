function Update-NginxCert -a site cert
  set -l SECRET_DOMAIN tencentcloud

  # 检查sudo权限
  if not power.Has-Sudo
    echo "Error: Need sudo permission" >&2
    return $OMF_UNKNOWN_ERR
  end

  # 验证参数
  if test -z "$site"; or test -z "$cert"
    echo "Usage: Update-NginxCert <site> <cert>" >&2
    return 1
  end

  # 确认文件是否存在
  if not test -f "/etc/nginx/sites-available/$site"
    echo "Nginx site configuration file not found: /etc/nginx/sites-available/$site" >&2
    return 1
  end

  # 授权密钥
  Export-SecretFile $SECRET_DOMAIN $secretFile $secretFile $USER > /dev/null 2>&1

  # 检查依赖
  power.Check-Python
  power.Check-Certbot

  # 更新nginx配置
  # sudo certbot \
  #   --nginx \
  #   --keep-until-expiring \
  #   -d "$site" \
  #   --non-interactive \
  #   --agree-tos \
  #   --hsts \
  #   --post-hook "systemctl reload nginx" \
  #   --redirect
  sudo certbot --nginx \
    --non-interactive \
    --cert-name example.com \  # 指定证书名称
    --no-verify-ssl \         # 跳过 SSL 验证
    --no-autorenew \          # 禁用自动更新
    --no-directory-hooks \    # 跳过目录钩子
    --no-permissions \        # 跳过权限检查
    --no-random-sleep-on-renew \  # 禁用随机延迟
    --no-eff-email \          # 禁用 EFF 邮件
    --hsts \
    --redirect \
    --dry-run \               # 关键：模拟运行
    --post-hook "nginx -t && systemctl reload nginx"  # 实际执行重载

  # 清理密钥
  Clean-ExportedSecret $SECRET_DOMAIN $USER

end