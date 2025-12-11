function tc.List-Profiles -d "列出 tccli 的配置文件"
  # 查看所有配置的 Profile
  set config_file ~/.tccli/*.configure
  if test -f $config_file
    cat $config_file | grep '^\[profile' | sed 's/\[profile \(.*\)\]/\1/'
  else
    echo "No tccli profiles found"
  end
end