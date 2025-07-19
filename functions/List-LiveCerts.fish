function List-LiveCerts
  # 设置证书存储路径
  set live_dir "/etc/letsencrypt/live"

  # 检查目录是否存在
  if not test -d "$live_dir"
    echo "Error: Let's Encrypt live directory not found" >&2
    return 1
  end

  # 列出所有证书目录（排除README文件）
  set cert_dirs (ls -1 "$live_dir" | grep -v '^README$')

  # 验证结果
  if test (count $cert_dirs) -eq 0
    echo "No certificates found in $live_dir"
    return 0
  end

  # 输出结果
  echo "Available certificates:"
  for dir in $cert_dirs
    # 获取实际指向的archive目录
    set archive_path (readlink -f "$live_dir/$dir")
    set version (basename "$archive_path")

    # 获取证书有效期
    set expiry (openssl x509 -enddate -noout -in "$live_dir/$dir/fullchain.pem" 2>/dev/null | cut -d= -f2)

    # 格式输出
    printf "• %-30s → %-25s (Expires: %s)\n" $dir $version $expiry
  end
end