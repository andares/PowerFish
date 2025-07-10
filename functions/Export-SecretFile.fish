function Export-SecretFile -a domain name
  # 确保目录存在
  if not test -d "$HOME/.local/.secret"
    echo "Error: secret dir does not exist" >&2
    return $OMF_UNKNOWN_ERR
  end

  set -l SECRET_LNK_DIR $HOME/.local/.secret/lnk
  set -l SECRET_NEW_DIR $HOME/.local/.secret/new
  set -l SECRET_TMP_DIR $HOME/.local/.secret/tmp

  # 尝试在lnk目录查找
  set -l encrypted_file
  set -l key_file

  if test -f "$SECRET_LNK_DIR/$domain/$name.age"
    set encrypted_file "$SECRET_LNK_DIR/$domain/$name.age"
    set key_file "$SECRET_LNK_DIR/$domain.key"
  else if test -f "$SECRET_NEW_DIR/$domain/$name.age"
    set encrypted_file "$SECRET_NEW_DIR/$domain/$name.age"
    set key_file "$SECRET_NEW_DIR/$domain.key"
  else
    echo "Error: Encrypted file not found for domain '$domain' and name '$name'" >&2
    return 1
  end

  # 检查密钥文件
  if not test -f "$key_file"
    echo "Error: Key file not found for domain '$domain'" >&2
    return 1
  end

  # 创建临时域目录
  set -l tmp_dir "$SECRET_TMP_DIR/$domain"
  if not test -d "$tmp_dir"
    mkdir -p "$tmp_dir"
    if test $status -ne 0
      echo "Failed to create temp directory: $tmp_dir" >&2
      return 1
    end
  end

  # 生成唯一临时文件名
  set -l tmp_file "$tmp_dir/$name.tmp"
  if test -f "$tmp_file"
    rm -f "$tmp_file"
  end

  # 解密到临时文件
  age -d -i "$key_file" -o "$tmp_file" "$encrypted_file" >/dev/null 2>&1
  if test $status -ne 0
    echo "Failed to decrypt file: $encrypted_file" >&2
    return 1
  end

  # 输出文件路径
  echo "$tmp_file"
end