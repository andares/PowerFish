function Set-RCVar -d "在 RC 文件中设置环境变量" -a name value
  if test -z "$name"; or test -z "$value"
    echo "Usage: Set-RCVar <name> <value>"
    return 1  # 使用固定错误码
  end

  set rcfile "$HOME/.powerrc.fish"

  if not test -f "$rcfile"
    echo '# PowerFish RC File' > "$rcfile"
  end

  # 转义正则特殊字符
  set name_esc (string escape --style=regex -- "$name")

  # 删除旧设置（使用双引号展开变量）
  sed -i "/^set -xg $name_esc /d" "$rcfile"

  # 正确追加新设置（使用双引号展开变量）
  # 处理含换行符的值
  set value (string replace -a \n '\\n' -- "$value")
  echo "set -xg $name \"$value\"" >> "$rcfile"

  # 更新当前环境
  set -xg "$name" "$value"
end