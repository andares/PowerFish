function Reload-Nginx -d "重载 Nginx 配置"
  # 测试配置语法
  if sudo nginx -t
    # 语法正确，执行重载
    if sudo systemctl reload nginx
      echo "Nginx reloaded successfully"
      return 0
    else
      echo "Failed to reload Nginx"
      return 1
    end
  else
    echo "Nginx configuration test failed. Reload aborted."
    return 1
  end
end