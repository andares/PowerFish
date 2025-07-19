function Update-NginxCert -a site
  set -l SECRET_DOMAIN tencentcloud

  # 检查sudo权限
  if not power.Has-Sudo
    echo "Error: Need sudo permission" >&2
    return $OMF_UNKNOWN_ERR
  end

  # 验证参数
  if test -z "$site"
    echo "Usage: Update-NginxCert <site>" >&2
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
  sudo certbot \
    --nginx \
    --keep-until-expiring \
    -d "$site" \
    --non-interactive \
    --agree-tos \
    --hsts \
    --post-hook "systemctl reload nginx" \
    --redirect

  # 清理密钥
  Clean-ExportedSecret $SECRET_DOMAIN $USER

end