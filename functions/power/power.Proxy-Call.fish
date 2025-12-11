function power.Proxy-Call -d "在需要时通过 proxychains 执行命令" -a cmd
  if command -s proxychains >/dev/null
    set cmd "proxychains $cmd"  # 动态添加代理前缀
  end
  eval $cmd
end
