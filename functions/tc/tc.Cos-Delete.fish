function tc.Cos-Delete -d "删除腾讯云 COS 上的文件/目录"
  # 用法：tc.Cos-Delete <bucket-alias> <target_path...>
  if test (count $argv) -lt 2
    echo "Usage: tc.Cos-Delete <bucket-alias> <target_path...>"
    echo "Example: tc.Cos-Delete bucket1 /admin/index.html"
    echo "Example: tc.Cos-Delete bucket1 /admin/  # 路径以 / 结尾时按目录递归删除"
    return 1
  end

  set -l bucket_alias "$argv[1]"
  set -l targets $argv[2..-1]

  if test -z "$bucket_alias"
    echo "bucket-alias is required."
    return 1
  end

  if test (count $targets) -lt 1
    echo "At least one target_path is required."
    return 1
  end

  tc.Check-Coscli
  if test $status -ne 0
    return 1
  end

  set -l coscli_cmd "coscli"
  if not command -q coscli
    set coscli_cmd "$HOME/.local/bin/coscli"
  end

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
  end

  set -l has_error 0
  for target in $targets
    if test -z "$target"
      echo "Skip empty target path."
      set has_error 1
      continue
    end

    set -l target_path "$target"
    if not string match -qr '^/' -- "$target_path"
      set target_path "/$target_path"
    end

    if test "$target_path" != "/"
      set target_path (string replace -r '/+$' '' -- "$target_path")
      if string match -qr '/$' -- "$target"
        set target_path "$target_path/"
      end
    end

    set -l target_uri "cos://$bucket_alias$target_path"

    if string match -qr '/$' -- "$target_path"
      echo "Delete (recursive): $target_uri"
      $coscli_cmd rm "$target_uri" -r -f
    else
      echo "Delete: $target_uri"
      $coscli_cmd rm "$target_uri" -f
    end

    if test $status -ne 0
      echo "Delete failed: $target"
      set has_error 1
    end
  end

  if test $has_error -ne 0
    return 1
  end

  echo "All deletions finished."
  return 0
end
