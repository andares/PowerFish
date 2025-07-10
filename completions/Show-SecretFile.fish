# Show-SecretFile 命令的补全定义
complete -c Show-SecretFile -n "__fish_use_subcommand" -f
complete -c Show-SecretFile -s h -l help -d "Show help"

# 域名的补全
complete -c Show-SecretFile -n "__fish_seen_subcommand_from Show-SecretFile; and not __fish_seen_argument -s h -l help" \
    -a "(set -q SECRET_NEW_DIR; or set -l SECRET_NEW_DIR ~/.local/.secret/new
         set -q SECRET_LNK_DIR; or set -l SECRET_LNK_DIR ~/.local/.secret/lnk

         # 获取所有包含.age文件的域名
         find $SECRET_NEW_DIR $SECRET_LNK_DIR -mindepth 1 -maxdepth 1 -type d \
             -exec test -d '{}/' ';' -print 2>/dev/null | xargs -I{} basename {} | sort | uniq)" \
    -d "Encryption domain"

# 加密文件名的补全：基于选定的域名
complete -c Show-SecretFile -n "__fish_seen_subcommand_from Show-SecretFile; and not __fish_seen_argument -s h -l help; and __fish_seen_argument" \
    -a "(set -q SECRET_NEW_DIR; or set -l SECRET_NEW_DIR ~/.local/.secret/new
         set -q SECRET_LNK_DIR; or set -l SECRET_LNK_DIR ~/.local/.secret/lnk

         # 获取当前命令行中的域名
         set -l cmd (commandline -opc)
         set -l domain $cmd[2]

         # 查找该域名下所有.age文件
         for dir in $SECRET_LNK_DIR/$domain $SECRET_NEW_DIR/$domain
             if test -d $dir
                 find $dir -maxdepth 1 -type f -name '*.age' -exec basename {} .age \; 2>/dev/null
             end
         end | sort | uniq)" \
    -d "Secret name"