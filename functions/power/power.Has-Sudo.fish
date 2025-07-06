function power.Has-Sudo
    # 如果是 root 直接返回
    test (id -u) -eq 0; and return 0

    # 检查 sudo 组
    if groups | grep -q '\bsudo\b'
        return 0
    end

    # 验证 sudo 命令实际可用性
    sudo -n true 2>/dev/null
    return $status
end
