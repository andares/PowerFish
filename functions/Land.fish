function Land -a command
  # Check if command is provided
  if test -z "$command"
    echo "Error: No command specified"
    echo "Usage: Land <command> [args...]"
    return 1
  end

  power.Check-Deno || return $OMF_UNKNOWN_ERR

  # Execute the land command using Deno
  deno run "$POWER_PATH/land/main.ts" $command $argv[2..]
end
