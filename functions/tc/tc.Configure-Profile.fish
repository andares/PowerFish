function tc.Configure-Profile -d "使用 tccli 交互配置 profile"
  # 交互式配置新 Profile
  tccli configure --profile $argv
end