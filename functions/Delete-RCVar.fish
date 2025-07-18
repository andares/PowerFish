function Delete-RCVar -a name
  if test -z "$name"
    echo "Usage: Delete-RCVar <name>"
    echo "  Variable name must be provided."
    return $OMF_MISSING_ARG
  end

  set rcfile "$HOME/.powerrc.fish"

  # 检查文件是否存在
  if not test -f "$rcfile"
    echo "Error: RC file not found."
    return $OMF_UNKNOWN_OPT
  end

  # 转义变量名中的正则特殊字符
  set name_esc (string escape --style=regex -- "$name")

  # 删除文件中设置该的变量
  sed -i "/^set -xg $name_esc /,/^end/d" "$rcfile"

  # 删除环境变量（如果存在）
  if set -q $name
    set -ge $name
  end
end