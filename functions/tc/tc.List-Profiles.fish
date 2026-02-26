function tc.List-Profiles -d "列出 tccli 的配置文件"
  set config_dir ~/.tccli
  if not test -d $config_dir
    return 0
  end

  set config_files (find $config_dir -maxdepth 1 -type f -name '*.configure' 2>/dev/null | sort)
  for config_file in $config_files
    basename $config_file .configure
  end
end