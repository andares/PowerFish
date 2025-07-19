function Clean-ExportedSecret -a domain forUser
  # 检查sudo权限
  if not power.Has-Sudo
    echo "Error: Need sudo permission" >&2
    return $OMF_UNKNOWN_ERR
  end

  if test -z "$domain"; or test -z "$forUser"
    echo "Usage: Clean-ExportedSecret <domain> <forUser>" >&2
    return $OMF_MISSING_ARG
  end

  # 限制用户名为合法字符
  if not string match -qr '^[a-z0-9_-]+$' -- "$forUser"
    echo "Invalid username" >&2
    return 1
  end

  if test -z "$EXPORT_SECRETE_PATH"
    echo "Environment variable [EXPORT_SECRETE_PATH] is not defined" >&2
    return $OMF_UNKNOWN_ERR
  end

  # 确保目录存在
  set -l export_user_dir "$EXPORT_SECRETE_PATH/$forUser/$domain"

  # 添加参数校验
  if string match -qr '\.\.' -- "$export_user_dir"
    echo "Error: Path traversal detected" >&2
    return 1
  end

  if sudo sh -c "test -d '$export_user_dir'"
    sudo rm -rf $export_user_dir
  end

end