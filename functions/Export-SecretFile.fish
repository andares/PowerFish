function Export-SecretFile -a domain name exportName forUser -d "将密钥导出到/dev/shm中并可指定所使用用户"
  # 检查sudo权限
  if not power.Has-Sudo
    echo "Error: Need sudo permission" >&2
    return $OMF_UNKNOWN_ERR
  end

  # 确保目录存在
  if not test -d "$HOME/.local/.secret"
    echo "Error: secret dir does not exist" >&2
    return $OMF_UNKNOWN_ERR
  end

  if test -z "$domain"; or test -z "$name"; or test -z "$exportName"
    echo "Usage: Export-SecretFile <domain> <name> <exportName> [<forUser>]" >&2
    return 1
  end

  if test -z "$forUser"
    set forUser $USER
  end

  # 添加参数校验
  if string match -qr '\.\.' -- "$EXPORT_SECRETE_PATH$forUser$domain$exportName"
    echo "Error: Path traversal detected" >&2
    return 1
  end

  # 检查并安装age
  power.Check-Age

  # 设置基础目录
  set -l SECRET_LNK_DIR $HOME/.local/.secret/lnk
  set -l SECRET_NEW_DIR $HOME/.local/.secret/new

  # 加密文件定位
  # 尝试在lnk目录查找
  set -l encrypted_file
  set -l key_file

  if test -f "$SECRET_LNK_DIR/$domain/$name.enc"
    set encrypted_file "$SECRET_LNK_DIR/$domain/$name.enc"
  else if test -f "$SECRET_NEW_DIR/$domain/$name.enc"
    set encrypted_file "$SECRET_NEW_DIR/$domain/$name.enc"
  else if test -f "$name.enc"
    set encrypted_file "$name.enc"
  else
    echo "Error: Encrypted file not found for domain '$domain' and name '$name'" >&2
    return 1
  end

  # 查找密钥
  if test -f "$SECRET_LNK_DIR/$domain.key"
    set key_file "$SECRET_LNK_DIR/$domain.key"
  else if test -f "$SECRET_NEW_DIR/$domain.key"
    set key_file "$SECRET_NEW_DIR/$domain.key"
  else if test -f "$SECRET_LNK_DIR/_default.key"
    set key_file "$SECRET_LNK_DIR/_default.key"
  else
    echo "Error: Encrypt key not found for domain '$domain'" >&2
    return 1
  end

  # 检查密钥文件
  if not test -f "$key_file"
    echo "Error: Key file not found for domain '$domain'" >&2
    return 1
  end

  # 创建导出域目录
  set -l export_user_dir "$EXPORT_SECRETE_PATH/$forUser"
  if not sudo sh -c "test -d '$export_user_dir'"
    sudo mkdir -p "$export_user_dir"
    if test $status -ne 0
      echo "Failed to create export directory for user: $export_user_dir" >&2
      return 1
    end
  end
  sudo chmod 700 $export_user_dir
  sudo chown $forUser:$forUser $export_user_dir

  set -l export_dir "$export_user_dir/$domain"
  if not sudo sh -c "test -d '$export_dir'"
    sudo mkdir -p "$export_dir"
    if test $status -ne 0
      echo "Failed to create export directory: $export_dir" >&2
      return 1
    end
  end
  sudo chmod 700 $export_dir
  sudo chown $forUser:$forUser $export_dir

  # 生成导出文件名
  set -l export_file "$export_dir/$exportName"
  if test -f "$export_file"
    sudo rm -f "$export_file"
  end

  # 解密到临时文件
  if test -e "$export_file"
    sudo rm -r "$export_file"
  end
  sudo age -d -i "$key_file" -o "$export_file" "$encrypted_file" >/dev/null 2>&1
  if test $status -ne 0
    echo "Failed to decrypt file: $encrypted_file
to:
$export_file" >&2
    return 1
  end
  sudo chmod 600 $export_file
  sudo chown $forUser:$forUser $export_file

  # 输出文件路径
  echo "$export_file"
end