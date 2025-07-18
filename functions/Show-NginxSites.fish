function Show-NginxSites -d "显示所有可用和已启用的站点"
  # 检查目录是否存在
  if not test -d $NGINX_AVAILABLE_DIR
    echo "Error: Directory $NGINX_AVAILABLE_DIR not found"
    return 1
  end

  if not test -d $NGINX_ENABLED_DIR
    echo "Error: Directory $NGINX_ENABLED_DIR not found"
    return 1
  end

  # 获取可用站点列表
  set available_sites (ls $NGINX_AVAILABLE_DIR)
  # 获取已启用站点列表（仅显示链接指向的源文件名）
  set enabled_sites (find $NGINX_ENABLED_DIR -type l -exec basename {} \; 2>/dev/null)

  # 显示已启用站点
  echo "Enabled sites:"
  if test -z "$enabled_sites"
    echo "  (no sites enabled)"
  else
    # 每行显示3个站点，对齐处理
    set col 0
    for site in $enabled_sites
      printf "  %-30s" $site
      set col (math $col + 1)
      if test $col -eq 3
        echo
        set col 0
      end
    end
    # 处理最后一行未满的情况
    if test $col -ne 0
      echo
    end
  end

  # 显示可用站点
  echo "Available sites:"
  if test -z "$available_sites"
    echo "  (no sites available)"
  else
    set col 0
    for site in $available_sites
      # 检查是否已启用
      if contains $site $enabled_sites
        printf "  %-30s" (set_color green)"$site ✓"(set_color normal)
      else
        printf "  %-30s" $site
      end

      set col (math $col + 1)
      if test $col -eq 3
        echo
        set col 0
      end
    end
    if test $col -ne 0
      echo
    end
  end
end