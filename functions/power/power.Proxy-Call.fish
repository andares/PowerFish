function power.Proxy-Call -a cmd
  if command -s proxychains >/dev/null
    set cmd "proxychains $cmd"  # 动态添加代理前缀
  end
  eval $cmd
end
