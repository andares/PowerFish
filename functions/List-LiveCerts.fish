function List-LiveCerts -d "列出系统中现有的证书及到期时间"
  # 设置证书存储路径
  set live_dir "/etc/letsencrypt/live"

  # 检查目录是否存在
  if not sudo test -d "$live_dir"
    echo "Error: Let's Encrypt live directory not found" >&2
    return 1
  end

  # 列出所有证书目录（排除README文件）
  set cert_dirs (sudo ls -1 "$live_dir" | grep -v '^README$')

  # 验证结果
  if test (count $cert_dirs) -eq 0
    echo "No certificates found in $live_dir"
    return 0
  end

  # 输出结果
  echo "Available certificates:"
  for dir in $cert_dirs
    # 获取实际指向的archive目录
    set archive_path (sudo readlink -f "$live_dir/$dir")
    set cert_version (basename "$archive_path")

    # 获取原始有效期字符串
    set expiry_raw (sudo openssl x509 -enddate -noout -in "$live_dir/$dir/fullchain.pem" 2>/dev/null | cut -d= -f2)

    # 转换为 YYYY-MM-DD HH:MM 格式
    set expiry_fmt ""
    if test -n "$expiry_raw"
      set expiry_fmt (date -d "$expiry_raw" "+%Y-%m-%d %H:%M" 2>/dev/null)
      if test $status -ne 0
        set expiry_fmt "Invalid date"
      end
    end

    # 格式输出
    printf "• %-20s → %-20s (Expires: %s)\n" $dir $cert_version $expiry_fmt
  end
end