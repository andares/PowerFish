function tc.List-Profiles
  # 查看所有配置的 Profile
  set config_file ~/.tccli/*.configure
  if test -f $config_file
    cat $config_file | grep '^\[profile' | sed 's/\[profile \(.*\)\]/\1/'
  else
    echo "No tccli profiles found"
  end
end