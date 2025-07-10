# Make-SecretFile 命令的补全定义
complete -c Make-SecretFile -n "__fish_use_subcommand" -f
complete -c Make-SecretFile -s h -l help -d "Show help"

# 域名的补全：从现有目录中提取
complete -c Make-SecretFile -n "__fish_seen_subcommand_from Make-SecretFile; and not __fish_seen_argument -s h -l help" \
    -a "(set -q SECRET_NEW_DIR; or set -l SECRET_NEW_DIR ~/.local/.secret/new
         set -q SECRET_LNK_DIR; or set -l SECRET_LNK_DIR ~/.local/.secret/lnk

         # 获取所有已存在的域名
         find $SECRET_NEW_DIR $SECRET_LNK_DIR -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort | uniq
         find $SECRET_NEW_DIR $SECRET_LNK_DIR -mindepth 1 -maxdepth 1 -name '*.key' -exec basename {} .key \; 2>/dev/null | sort | uniq)" \
    -d "Encryption domain"

# 加密文件名的补全：无特定建议
complete -c Make-SecretFile -n "__fish_seen_subcommand_from Make-SecretFile; and not __fish_seen_argument -s h -l help; and __fish_seen_argument" \
    -d "Secret name"

# 原始文件路径的补全：使用文件系统补全
complete -c Make-SecretFile -n "__fish_seen_subcommand_from Make-SecretFile; and not __fish_seen_argument -s h -l help; and __fish_seen_argument" \
    -F -d "Source file path"