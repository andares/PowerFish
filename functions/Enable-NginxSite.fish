function Enable-NginxSite -a site -d "启用指定站点"
  # 检查参数
  if test -z "$site"
    echo "Usage: Enable-NginxSite <site-config>"
    return 1
  end

  set source "$NGINX_AVAILABLE_DIR/$site"
  set target "$NGINX_ENABLED_DIR/$site"

  # 检查源文件是否存在
  if not test -f $source
    echo "Error: Site config '$site' not found in available sites"
    return 1
  end

  # 检查是否已启用
  if test -L $target
    echo "Error: Site '$site' is already enabled"
    return 1
  end

  # 创建符号链接
  if sudo ln -s $source $target
    echo "Site '$site' enabled successfully"
    return 0
  else
    echo "Failed to enable site '$site'"
    return 1
  end
end
