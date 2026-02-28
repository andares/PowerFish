function __tc_cos_delete_aliases --description "读取 ~/.cos.yaml 中配置的 bucket alias"
  if not test -f "$HOME/.cos.yaml"
    return 0
  end

  grep -E '^[[:space:]]*alias:[[:space:]]*' "$HOME/.cos.yaml" 2>/dev/null \
    | string replace -r '^[[:space:]]*alias:[[:space:]]*' '' \
    | string trim \
    | string replace -r '[[:space:]]+#.*$' '' \
    | sort -u
end

function __tc_cos_delete_arg_count --description "返回 tc.Cos-Delete 已输入参数个数（不含命令名）"
  set -l tokens (commandline -opc)
  set -l token_count (count $tokens)

  if test $token_count -le 0
    echo 0
    return 0
  end

  math $token_count - 1
end

function __tc_cos_delete_need_alias --description "当前是否在填写第1参数 alias"
  set -l argc (__tc_cos_delete_arg_count)
  test $argc -le 1
end

function __tc_cos_delete_need_targets --description "当前是否在填写第2个及之后参数 target_path"
  set -l argc (__tc_cos_delete_arg_count)
  test $argc -ge 2
end

# 第 1 个参数：bucket alias
complete -c tc.Cos-Delete -n "__tc_cos_delete_need_alias" \
  -a "(__tc_cos_delete_aliases)" \
  -d "Bucket alias (~/.cos.yaml)"

# 第 2 个及之后参数：COS 目标路径（对象或目录前缀）
complete -c tc.Cos-Delete -n "__tc_cos_delete_need_targets" \
  -a "/" \
  -d "COS target path (end with / for recursive prefix delete)"
