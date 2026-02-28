function tc.Cos-Upload -d "上传本地文件/目录到腾讯云 COS"
  # 用法：tc.Cos-Upload <profile> <cos://bucket/path/> <source...>
  if test (count $argv) -lt 3
    echo "Usage: tc.Cos-Upload <profile> <cos://bucket/path/> <source...>"
    echo "Example: tc.Cos-Upload prod cos://example-1250000000/releases/ ./dist ./README.md"
    return 1
  end

  set -l profile "$argv[1]"
  set -l cos_dir "$argv[2]"
  set -l sources $argv[3..-1]

  # profile 必须存在
  if test -z "$profile"
    echo "Profile is required."
    return 1
  end

  # 目标目录格式：cos://bucket/path/（path 可为空，表示根目录）
  if not string match -qr '^cos://[^/]+(/.*)?$' -- "$cos_dir"
    echo "cos-dir must be in format: cos://<bucket>/<path/>"
    echo "Use cos://<bucket>/ for bucket root."
    return 1
  end

  # 确保 tccli 可用
  if not command -q tccli
    echo "tccli not found. Installing..."
    tc.Check-Tccli
    if not command -q tccli
      echo "tccli installation failed."
      return 1
    end
  end

  set -l bucket (string replace -r '^cos://([^/]+)(/.*)?$' '$1' -- "$cos_dir")
  set -l key_prefix (string replace -r '^cos://[^/]+/?' '' -- "$cos_dir")
  set key_prefix (string replace -r '^/+' '' -- "$key_prefix")
  if test -n "$key_prefix"
    set key_prefix (string replace -r '/+$' '' -- "$key_prefix")"/"
  end

  set -l has_error 0

  for src in $sources
    if not test -e "$src"
      echo "Source not found: $src"
      set has_error 1
      continue
    end

    if test -f "$src"
      set -l object_key "$key_prefix"(basename "$src")
      echo "Uploading: $src -> cos://$bucket/$object_key"
      tccli --profile "$profile" cos PutObject --Bucket "$bucket" --Key "$object_key" --Body "$src"
      if test $status -ne 0
        echo "Upload failed: $src"
        set has_error 1
      end
      continue
    end

    set -l src_dir (string replace -r '/+$' '' -- "$src")
    set -l src_name (basename "$src_dir")
    set -l src_len (string length -- "$src_dir")

    for file in (find "$src_dir" -type f)
      set -l rel_file (string sub -s (math $src_len + 2) -- "$file")
      set -l object_key "$key_prefix$src_name/$rel_file"
      echo "Uploading: $file -> cos://$bucket/$object_key"
      tccli --profile "$profile" cos PutObject --Bucket "$bucket" --Key "$object_key" --Body "$file"
      if test $status -ne 0
        echo "Upload failed: $file"
        set has_error 1
      end
    end
  end

  if test $has_error -ne 0
    return 1
  end

  echo "All uploads finished."
  return 0
end
