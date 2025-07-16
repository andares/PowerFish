function Clean-ExportedSecret -a forUser
  # 检查sudo权限
  if not power.Has-Sudo
    echo "Error: Need sudo permission" >&2
    return $OMF_UNKNOWN_ERR
  end

  if test -z "$forUser"
    echo "Usage: Clean-ExportedSecret <forUser>" >&2
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
  set -l export_user_dir "$EXPORT_SECRETE_PATH/$forUser"

  # 添加参数校验
  if string match -qr '\.\.' -- "$export_user_dir"
    echo "Error: Path traversal detected" >&2
    return 1
  end

  if sudo sh -c "test -d '$export_user_dir'"
    sudo rm -rf $export_user_dir
  end

  # INFO: 这是过去的逻辑目录为空时不操作
  # if not test -n (find $export_user_dir -maxdepth 0 -type d -empty)
  #   rm -r $export_user_dir/*
  # end
end