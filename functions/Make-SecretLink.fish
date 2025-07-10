function Make-SecretLink -a domainPath
  # 确保目录存在
  if not test -d "$HOME/.local/.secret"
    echo "Error: secret dir does not exist" >&2
    return $OMF_UNKNOWN_ERR
  end

  set -l SECRET_LNK_DIR $HOME/.local/.secret/lnk

  # 验证源路径存在
  if not test -d "$domainPath"
    echo "Error: Source directory not found: $domainPath" >&2
    return 1
  end

  # 获取域名（目录名）
  set -l domain (basename "$domainPath")

  # 检查密钥文件是否存在
  set -l key_file "$domainPath.key"
  if not test -f "$key_file"
    echo "Error: Key file not found: $key_file" >&2
    return 1
  end

  # 创建目录软链
  set -l target_dir "$SECRET_LNK_DIR/$domain"
  if test -L "$target_dir" -o -d "$target_dir"
    echo "Warning: Existing link/directory will be replaced: $target_dir" >&2
    rm -rf "$target_dir"
  end

  ln -s "$domainPath" "$target_dir"
  if test $status -ne 0
    echo "Failed to create directory link: $domainPath" >&2
    return 1
  end

  # 创建密钥文件软链
  set -l target_key "$SECRET_LNK_DIR/$domain.key"
  if test -L "$target_key" -o -f "$target_key"
    rm -f "$target_key"
  end

  ln -s "$key_file" "$target_key"
  if test $status -ne 0
    echo "Failed to create key file link: $key_file" >&2
    # 回滚目录软链
    rm -f "$target_dir"
    return 1
  end

  echo "Created links for domain: $domain"
end