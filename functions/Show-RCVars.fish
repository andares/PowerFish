function Show-RCVars -d "显示 RC 文件中的环境变量" -a name
  set rcfile "$HOME/.powerrc.fish"

  if not test -f "$rcfile"
    return $OMF_UNKNOWN_OPT
  end

  while read -l line
    # 跳过空行和注释行
    if test -z "$line"; or string match -q "#*" -- "$line"
      continue
    end

    # 匹配 set -xg 行，捕获变量名和值（包括引号和空格）
    if set match (string match -r '^set\s+(-[^ ]*\s+)*xg\s+(\S+)\s+(.*)' -- "$line")
      set var_name $match[2]
      set var_value $match[3]

      # 移除值周围可能的引号
      set var_value (string trim -c '\'"' -- "$var_value")

      # 如果指定了变量名，检查是否匹配
      if test -n "$name"; and test "$var_name" != "$name"
        continue
      end

      # 输出变量名和原始值
      echo "$var_name=$var_value"
    else
      # 如果行不是 set -xg 格式，直接跳过
      continue
    end
  end < "$rcfile"
end