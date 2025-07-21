function tc.Show-Profile
  # 查看指定 Profile 的详细配置
  if test -z "$argv"
    echo "Usage: tc.Show-Profile <profile-name>"
    return 1
  end

  set config_file ~/.tccli/$argv.configure
  if test -f $config_file
    cat $config_file
  else
    echo "Profile '$argv' not found"
  end
end