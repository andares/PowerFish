function PowerFish -d "List commands for PowerFish package."
  # 新方案手动描述每个指令
  # 使用 begin/end 块组合多个 echo 命令
  begin
    echo "Build-DockerImage:构建当前目录下的Docker镜像"
    echo "Call-ComposeMysql:调用Docker Compose集群中的mysql指令"
    echo "Checkout-Repos:签出仓库分支"
    echo "Clone-Repos:克隆仓库到本地"
    echo "Delete-RCVar:移除一个RC文件中的环境变量设置"
  end | column -t -s ':' -o '  '

  #### 这里是老方案搜索文件
  # # 遍历目录中的文件（不包含子目录）
  # for file in $POWER_PATH/functions/*
  #     # 仅处理普通文件，并排除隐藏文件
  #     if test -f "$file"
  #         set -l filename (basename "$file")
  #         # 跳过隐藏文件（以点开头的文件）
  #         if string match -q '.*' $filename
  #             continue
  #         end

  #         # 去除最后一个后缀（如果有）
  #         set mainname (string replace -r '\.[^.]+$' '' -- $filename)
  #         # 输出结果
  #         echo $mainname
  #     end
  # end
end
