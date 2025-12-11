function Exec-By -d "以指定用户执行命令或进入交互 shell"
    if not set -q argv[1]
        echo "Usage: Exec-By USERNAME [SCRIPT_COMMAND]"
        echo "Examples:"
        echo "  Exec-By webadmin"
        echo "  Exec-By deploy 'echo \$USER; ls -l'"
        echo "  Exec-By backup '"
        echo "    set backup_dir \"/backups/(date +%Y%m%d)\""
        echo "    mkdir -p \$backup_dir"
        echo "  '"
        return 1
    end

    set -l target_user $argv[1]
    set -l script_command $argv[2..-1]

    # 检查目标用户是否存在
    if not getent passwd $target_user >/dev/null
        echo "Error: User '$target_user' does not exist" >&2
        return 2
    end

    # 获取目标用户的默认shell
    set -l user_shell (getent passwd $target_user | cut -d: -f7)

    if test -n "$script_command"
        # 构建执行命令（处理多行命令）
        set -l cmd (string join ' ' -- $script_command)


        # 特殊处理 Fish shell 和其他 shell
        if test (path basename $user_shell) = "fish"
            sudo -u $target_user -i $user_shell -c "$cmd"
        else
            sudo -u $target_user -i $user_shell -c "eval \"$cmd\""
        end
    else
        # 启动交互式 shell
        sudo -u $target_user -i $user_shell
    end
end