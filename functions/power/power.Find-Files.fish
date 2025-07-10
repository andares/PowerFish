function power.Find-Files -d "Recursively find files with optional suffix filtering"
  # 检查参数数量
  if test (count $argv) -eq 0
    echo "Error: At least one directory path is required" >&2
    return 1
  end

  set -l target_dir $argv[1]   # 目标目录
  set -l suffixes $argv[2..]  # 后缀过滤参数

  # 验证目录是否存在
  if not test -d "$target_dir"
    echo "Error: Directory '$target_dir' does not exist" >&2
    return 1
  end

  # 构建find命令
  set -l find_cmd "find -L $target_dir -type f"

  # 添加后缀过滤条件
  if set -q suffixes[1]
    set find_cmd "$find_cmd \("
    for ext in $suffixes
      set find_cmd "$find_cmd -name '*.$ext' -o"
    end
    set find_cmd (string replace -r ' -o$' '' "$find_cmd")  # 移除最后一个 -o
    set find_cmd "$find_cmd \)"
  end

  # 执行查找并输出结果
  eval $find_cmd 2>/dev/null | while read -l line
    echo $line
  end
end