function Disable-NginxSite -a site -d "禁用指定站点"
  # 检查参数
  if test -z "$site"
    echo "Usage: Disable-NginxSite <site-config>"
    return 1
  end

  set target "$NGINX_ENABLED_DIR/$site"

  # 检查是否为符号链接
  if not test -L $target
    echo "Error: Site '$site' is not enabled or not a symbolic link"
    return 1
  end

  # 删除符号链接
  if sudo rm $target
    echo "Site '$site' disabled successfully"
    return 0
  else
    echo "Failed to disable site '$site'"
    return 1
  end
end