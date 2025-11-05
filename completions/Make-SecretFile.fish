# Make-SecretFile 命令的补全定义
complete -c Make-SecretFile -s h -l help -d "Show help"

# 第一个参数：域名的补全（从现有目录中提取）
complete -c Make-SecretFile -n "not __fish_seen_subcommand_from Make-SecretFile; and not __fish_seen_argument -s h -l help" \
    -a "(set -q SECRET_NEW_DIR; or set -l SECRET_NEW_DIR ~/.local/.secret/new
         set -q SECRET_LNK_DIR; or set -l SECRET_LNK_DIR ~/.local/.secret/lnk

         # 获取所有已存在的域名
         find $SECRET_NEW_DIR $SECRET_LNK_DIR -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort | uniq
         find $SECRET_NEW_DIR $SECRET_LNK_DIR -mindepth 1 -maxdepth 1 -name '*.key' -exec basename {} .key \; 2>/dev/null | sort | uniq)" \
    -d "Encryption domain"

# 第二个参数：加密文件名（在第一个参数后）
complete -c Make-SecretFile -n "__fish_seen_subcommand_from Make-SecretFile; and not __fish_seen_argument -s h -l help; and __fish_seen_argument -a domain" \
    -d "Encrypted file name (without .enc extension)"

# 第三个参数：源文件路径（在前两个参数后，使用文件系统补全）
complete -c Make-SecretFile -n "__fish_seen_subcommand_from Make-SecretFile; and not __fish_seen_argument -s h -l help; and __fish_seen_argument -a domain; and __fish_seen_argument -a name" \
    -F -d "Source file path to encrypt"
