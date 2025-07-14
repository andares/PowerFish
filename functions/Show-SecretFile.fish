function Show-SecretFile -a domain name
  # 确保目录存在
  if not test -d "$HOME/.local/.secret"
    echo "Error: secret dir does not exist" >&2
    return $OMF_UNKNOWN_ERR
  end

  if test -z "$domain"; or test -z "$name"
    echo "Usage: Show-SecretFile <domain> <name>" >&2
    return 1
  end

  power.Check-Age
  set -l SECRET_LNK_DIR $HOME/.local/.secret/lnk
  set -l SECRET_NEW_DIR $HOME/.local/.secret/new

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

  # 解密并输出内容
  age -d -i "$key_file" "$encrypted_file" 2>/dev/null
  return $status
end