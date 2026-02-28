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

# 第 1 个参数：bucket alias
complete -c tc.Cos-Upload -n "__fish_is_nth_arg 1" \
  -a "(__tc_cos_upload_aliases)" \
  -d "Bucket alias (~/.cos.yaml)"

# 第 2 个参数：COS 目标目录（可省略）
complete -c tc.Cos-Upload -n "__fish_is_nth_arg 2" \
  -a "/" \
  -d "Destination prefix (default /)"

# 第 2 个参数也允许直接填 source（文件/目录）
complete -c tc.Cos-Upload -n "__fish_is_nth_arg 2" \
  -F \
  -d "Source file or directory"

# 第 3 个及之后参数：source 路径
complete -c tc.Cos-Upload -n "not __fish_is_nth_arg 1; and not __fish_is_nth_arg 2" \
  -F \
  -d "Source file or directory"
