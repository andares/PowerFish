function __tc_cos_upload_aliases --description "读取 ~/.cos.yaml 中配置的 bucket alias"
  if not test -f "$HOME/.cos.yaml"
    return 0
  end

  grep -E '^[[:space:]]*alias:[[:space:]]*' "$HOME/.cos.yaml" 2>/dev/null \
    | string replace -r '^[[:space:]]*alias:[[:space:]]*' '' \
    | string trim \
    | string replace -r '[[:space:]]+#.*$' '' \
    | sort -u
end

function __tc_cos_upload_arg_count --description "返回 tc.Cos-Upload 已输入参数个数（不含命令名）"
  set -l tokens (commandline -opc)
  set -l token_count (count $tokens)

  if test $token_count -le 0
    echo 0
    return 0
  end

  math $token_count - 1
end

function __tc_cos_upload_need_alias --description "当前是否在填写第1参数 alias"
  set -l argc (__tc_cos_upload_arg_count)
  test $argc -le 1
end

function __tc_cos_upload_need_destination_or_source --description "当前是否在填写第2参数（可为 destination 或 source）"
  set -l argc (__tc_cos_upload_arg_count)
  test $argc -eq 2
end

function __tc_cos_upload_need_sources --description "当前是否在填写第3个及之后参数 source"
  set -l argc (__tc_cos_upload_arg_count)
  test $argc -ge 3
end

# 第 1 个参数：bucket alias
complete -c tc.Cos-Upload -n "__tc_cos_upload_need_alias" \
  -a "(__tc_cos_upload_aliases)" \
  -d "Bucket alias (~/.cos.yaml)"

# 第 2 个参数：COS 目标目录（可省略）
complete -c tc.Cos-Upload -n "__tc_cos_upload_need_destination_or_source" \
  -a "/" \
  -d "Destination prefix (default /)"

# 第 2 个参数也允许直接填 source（文件/目录）
complete -c tc.Cos-Upload -n "__tc_cos_upload_need_destination_or_source" \
  -F \
  -d "Source file or directory"

# 第 3 个及之后参数：source 路径
complete -c tc.Cos-Upload -n "__tc_cos_upload_need_sources" \
  -F \
  -d "Source file or directory"
