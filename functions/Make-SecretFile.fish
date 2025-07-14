function Make-SecretFile -a domain name file
  # 确保目录存在
  if not test -d "$HOME/.local/.secret"
    echo "Error: secret dir does not exist" >&2
    return $OMF_UNKNOWN_ERR
  end

  if test -z "$domain"; or test -z "$name"; or test -z "$file"
    echo "Usage: Make-SecretFile <domain> <name> <file>" >&2
    return 1
  end

  power.Check-Age
  set -l SECRET_LNK_DIR $HOME/.local/.secret/lnk
  set -l SECRET_NEW_DIR $HOME/.local/.secret/new

  # 验证输入文件存在
  if not test -f "$file"
    echo "Error: Source file '$file' does not exist" >&2
    return 1
  end

  # 检查目标目录
  set -l target_dir
  set -l key_file

  if test -d "$SECRET_LNK_DIR/$domain"
    set target_dir "$SECRET_LNK_DIR/$domain"
    set key_file "$SECRET_LNK_DIR/$domain.key"

    # 检查密钥文件
    if not test -f "$key_file"
      echo "Error: Key file not found for domain '$domain'" >&2
      return 1
    end
  else
    set target_dir "$SECRET_NEW_DIR/$domain"
    set key_file "$SECRET_NEW_DIR/$domain.key"

    # 创建新域目录
    if not test -d "$target_dir"
      mkdir -p "$target_dir"
      if test $status -ne 0
        echo "Failed to create domain directory: $target_dir" >&2
        return 1
      end
    end

    # 创建新密钥
    if not test -f "$key_file"
      age-keygen -o "$key_file" >/dev/null 2>&1
      if test $status -ne 0
        echo "Failed to generate key for domain '$domain'" >&2
        return 1
      end
      echo "Generated new key for domain: $domain"
    end
  end

  # 检查目标文件是否已存在
  set -l output_file "$target_dir/$name.enc"
  if test -f "$output_file"
    echo "Warning: Encrypted file already exists. Overwriting: $output_file" >&2
  end

  # 获取公钥并进行加密
  age -e -a -o "$output_file" -r (age-keygen -y "$key_file") "$file" >/dev/null 2>&1

  if test $status -ne 0
    echo "Failed to encrypt file: $file" >&2
    return 1
  end

  echo "File encrypted: $output_file"
end