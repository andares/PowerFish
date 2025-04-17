function PowerFish -d "List commands for PowerFish package."
  # 遍历目录中的文件（不包含子目录）
  for file in $POWER_PATH/functions/*
      # 仅处理普通文件，并排除隐藏文件
      if test -f "$file"
          set -l filename (basename "$file")
          # 跳过隐藏文件（以点开头的文件）
          if string match -q '.*' $filename
              continue
          end

          # 去除最后一个后缀（如果有）
          set mainname (string replace -r '\.[^.]+$' '' -- $filename)
          # 输出结果
          echo $mainname
      end
  end
end
