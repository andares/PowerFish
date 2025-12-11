function Make-SecretLink -d "将密钥目录和密钥文件创建软链" -a domainPath
  # 确保目录存在
  if not test -d "$HOME/.local/.secret"
    echo "Error: secret dir does not exist" >&2
    return $OMF_UNKNOWN_ERR
  end

  if test -z "$domainPath"
    echo "Usage: Make-SecretLink <domainPath>" >&2
    return 1
  end

  set -l SECRET_LNK_DIR $HOME/.local/.secret/lnk

  # 验证源路径存在 INFO: 现在源路径和密钥文件允许分别软链
  set -l domain (basename "$domainPath")
  if test -d "$domainPath"
    # 获取域名（目录名）
    # 创建目录软链
    set -l target_dir "$SECRET_LNK_DIR/$domain"

    # 这里只创建一次
    if not test -L "$target_dir" -o -d "$target_dir"
      ln -s "$domainPath" "$target_dir"
      if test $status -ne 0
        echo "Failed to create directory link: $domainPath" >&2
        return 1
      end
      echo "Created dir links for domain: $domain"
    end
  end

  # 检查密钥文件是否存在
  set -l key_file "$domainPath.key"
  if test -f "$key_file"
    # 创建密钥文件软链
    set -l target_key "$SECRET_LNK_DIR/$domain.key"
    # 这里只创建一次
    if not test -L "$target_key" -o -f "$target_key"
      ln -s "$key_file" "$target_key"
      if test $status -ne 0
        echo "Failed to create key file link: $key_file" >&2
        return 1
      end
      echo "Created key links for domain: $domain"
    end
  end

end