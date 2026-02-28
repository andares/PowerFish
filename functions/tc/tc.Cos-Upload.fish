# 执行 config init 时：
# - Input Your Mode: 时可以输入 AK/SK
# - Input Your Session Token: 可以直接回车留空
function tc.Cos-Upload -d "上传本地文件/目录到腾讯云 COS"
  # 用法：tc.Cos-Upload <bucket-alias> [destination_path] <source...>
  if test (count $argv) -lt 2
    echo "Usage: tc.Cos-Upload <bucket-alias> [destination_path] <source...>"
    echo "Example: tc.Cos-Upload bucket1 /release/ ./dist ./README.md"
    echo "Example: tc.Cos-Upload bucket1 ./dist  # destination_path 默认 /"
    return 1
  end

  set -l bucket_alias "$argv[1]"
  set -l destination_path "/"
  set -l sources

  # 规则：至少要有 alias 和一个 source；destination_path 可省略，省略时默认为 /
  if test (count $argv) -eq 2
    set sources "$argv[2]"
  else
    set destination_path "$argv[2]"
    set sources $argv[3..-1]
  end

  if test -z "$bucket_alias"
    echo "bucket-alias is required."
    return 1
  end

  if test (count $sources) -lt 1
    echo "At least one source_path is required."
    return 1
  end

  # prefix 规范化：确保以 / 开头；最终作为目录使用并确保以 / 结尾
  if test -z "$destination_path"
    set destination_path "/"
  end
  if not string match -qr '^/' -- "$destination_path"
    set destination_path "/$destination_path"
  end

  if test "$destination_path" = "/"
    set destination_path "/"
  else
    set destination_path (string replace -r '/+$' '' -- "$destination_path")"/"
  end

  # cos URI 说明：cos://<bucket-alias><prefix>/<filename>
  # - bucket-alias：coscli config 中配置的桶别名
  # - prefix：目标目录，函数保证以 / 开头；为 / 时不额外拼多余分隔
  # - filename：由 sync 命令按源文件名/目录结构处理，不在此函数中改名
  set -l destination_uri "cos://$bucket_alias$destination_path"

  # 确保 coscli 可用（按官方下载方式安装到 ~/.local/bin）
  set -l coscli_cmd "coscli"
  if not command -q $coscli_cmd
    echo "coscli not found. Installing..."

    set -l arch (uname -m)
    set -l binary_suffix ""

    switch $arch
      case x86_64 amd64
        set binary_suffix "linux-amd64"
      case i386 i686
        set binary_suffix "linux-386"
      case aarch64 arm64
        set binary_suffix "linux-arm64"
      case armv7l armv6l
        set binary_suffix "linux-arm"
      case '*'
        echo "Unsupported architecture for auto-install: $arch"
        return 1
    end

    set -l download_url "https://cosbrowser.cloud.tencent.com/software/coscli/coscli-$binary_suffix"
    set -l tmp_file "/tmp/coscli-$binary_suffix-"(random)

    if command -q wget
      wget -q -O "$tmp_file" "$download_url"
    else if command -q curl
      curl -fsSL -o "$tmp_file" "$download_url"
    else
      echo "Neither wget nor curl found. Please install one of them first."
      return 1
    end

    if test $status -ne 0; or not test -s "$tmp_file"
      echo "Failed to download coscli from: $download_url"
      return 1
    end

    chmod 755 "$tmp_file"
    mkdir -p "$HOME/.local/bin"
    mv -f "$tmp_file" "$HOME/.local/bin/coscli"

    if command -q coscli
      set coscli_cmd "coscli"
    else if test -x "$HOME/.local/bin/coscli"
      set coscli_cmd "$HOME/.local/bin/coscli"
    else
      echo "coscli installation failed."
      return 1
    end
  end

  # 初始化配置文件
  if not test -f "$HOME/.cos.yaml"
    echo "~/.cos.yaml not found, running coscli config init..."
    $coscli_cmd config init
    if test $status -ne 0
      echo "coscli config init failed."
      return 1
    end
  end

  # 检查 alias 是否已存在
  set -l alias_exists 0
  if test -f "$HOME/.cos.yaml"
    if grep -Eq '^[[:space:]]*alias:[[:space:]]*'"$bucket_alias"'([[:space:]]*$|[[:space:]]*#)' "$HOME/.cos.yaml"
      set alias_exists 1
    end
  end

  if test $alias_exists -eq 0
    echo "Bucket alias '$bucket_alias' not found in ~/.cos.yaml"
    echo "Please provide bucket info for: coscli config add"

    read -P "Bucket Name (e.g. examplebucket-1250000000): " bucket_name
    read -P "Region (e.g. ap-guangzhou): " region
    read -P "Endpoint (e.g. cos.ap-guangzhou.myqcloud.com): " endpoint
    read -P "Alias [$bucket_alias]: " alias_input

    if test -z "$alias_input"
      set alias_input "$bucket_alias"
    end

    if test -z "$bucket_name"; or test -z "$region"; or test -z "$endpoint"; or test -z "$alias_input"
      echo "Bucket Name / Region / Endpoint / Alias are required."
      return 1
    end

    $coscli_cmd config add -b "$bucket_name" -r "$region" -e "$endpoint" -a "$alias_input"
    if test $status -ne 0
      echo "coscli config add failed."
      return 1
    end

    set bucket_alias "$alias_input"
    set destination_uri "cos://$bucket_alias$destination_path"
  end

  set -l has_error 0
  for src in $sources
    if not test -e "$src"
      echo "Source not found: $src"
      set has_error 1
      continue
    end

    echo "Sync: $src -> $destination_uri"
    if test -d "$src"
      $coscli_cmd sync "$src" "$destination_uri" -r
    else
      $coscli_cmd sync "$src" "$destination_uri"
    end

    if test $status -ne 0
      echo "Upload failed: $src"
      set has_error 1
    end
  end

  if test $has_error -ne 0
    return 1
  end

  echo "All uploads finished."
  return 0
end
