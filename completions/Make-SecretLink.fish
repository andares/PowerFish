# Make-SecretLink 命令的补全定义
complete -c Make-SecretLink -n "__fish_use_subcommand" -f
complete -c Make-SecretLink -s h -l help -d "Show help"

# 域路径的补全：仅补全目录
complete -c Make-SecretLink -n "__fish_seen_subcommand_from Make-SecretLink; and not __fish_seen_argument -s h -l help" \
    -a "(__fish_complete_directories)" \
    -d "Path to domain directory"

# 增强补全：只显示包含.key文件的目录
complete -c Make-SecretLink -n "__fish_seen_subcommand_from Make-SecretLink; and not __fish_seen_argument -s h -l help" \
    -a "(find ~/.local ~/.config -type d -exec sh -c 'test -f \"\$1.key\"' sh {} \; -print 2>/dev/null)" \
    -d "Domain directory with key"