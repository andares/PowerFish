function power.Check-Deno -d 'Check if Deno is already intsalled.'
  if not command -s deno >/dev/null # 这里也能用`if not type -q deno` 区别是会包含alias
    echo "Deno is not installed. Would you like to install it now? [y/N]"

    # 读取用户输入（自动转小写）
    read --prompt-str ">" -l confirm

    # 统计安装脚本
    set -l installer "curl -fsSL https://deno.land/install.sh | sh"

    # 处理用户输入
    switch (string lower $confirm)
      case y yes
        # 检查是否安装了 proxychains
        if command -s proxychains >/dev/null
          # 检测到 proxychains 存在时的逻辑
          echo "proxychains is detected. Use proxychains to install deno? [y/N]"
          read --prompt-str ">" -l confirm2

          switch (string lower $confirm2)
            case y yes
              # 使用 proxychains 安装
              echo "Installing deno with proxychains..."
              power.Proxy-Call $installer
              power.Proxy-Call "deno install -c $POWER_PATH/land/deno.json"

            case '*'
              # 正常安装流程
              echo "Installing deno without proxy..."
              deno install -c $POWER_PATH/land/deno.json

          end
        else
          # 没有 proxychains 时直接安装
          echo "Installing Deno..."
          # 使用官方安装脚本
          deno install -c $POWER_PATH/land/deno.json
        end

        # 提示可能需要手动添加环境变量
        # echo "\nInstallation complete! You may need to add Deno to your PATH:"
        # echo "set -Ua fish_user_paths ~/.deno/bin"
        # 不提示直接操作掉
        set -Ua fish_user_paths ~/.deno/bin

        if not command -s deno >/dev/null
          echo "Deno installation failed."
          return $OMF_UNKNOWN_ERR
        else
          return 0
        end

      case '*'
        echo "Installation canceled."
        return $OMF_UNKNOWN_ERR
    end
  else
    return 0
  end
end