function Land -d "运行 Land 命令（通过 Deno）" -a command
  # Check if command is provided
  if test -z "$command"
    set command help
  end

  power.Check-Deno || return $OMF_UNKNOWN_ERR

  # Execute the land command using Deno
  deno run "$POWER_PATH/land/main.ts" $command $argv[2..]
end
