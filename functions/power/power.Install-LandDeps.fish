function power.Install-LandDeps -d 'Install Land library dependencies.'
  # 检查是否安装了 proxychains
  if command -s proxychains >/dev/null
    # 检测到 proxychains 存在时的逻辑
    echo "proxychains is detected. Use proxychains to install dependencies? [y/N]"
    read --prompt-str ">" -l confirm

    switch (string lower $confirm)
      case y yes
        # 使用 proxychains 安装
        power.Proxy-Call "deno install -c $POWER_PATH/land/deno.json"

      case '*'
        # 正常安装流程
        deno install -c $POWER_PATH/land/deno.json

    end
  else
    deno install -c $POWER_PATH/land/deno.json
  end
end