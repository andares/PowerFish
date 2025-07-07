function Renew-Repos -a target
    # 设置默认目标目录为当前目录
    if test -z "$target"
        set target .
    end

    # 检查目录是否存在
    if not test -d "$target"
        echo "Error: Directory '$target' does not exist" >&2
        return 1
    end

    # 获取当前分支（安全方式）
    set -l branch (
        git -C "$target" branch --show-current 2>/dev/null ||
        git -C "$target" rev-parse --abbrev-ref HEAD 2>/dev/null
    )

    # 验证是否获取到分支名
    if test -z "$branch" || string match -qr '^(HEAD|detached)' -- "$branch"
        echo "Error: Not on a valid branch (detached HEAD?) in '$target'" >&2
        return 1
    end

    # 检查远程分支是否存在
    if not git -C "$target" show-ref -q --verify "refs/remotes/origin/$branch"
        echo "Error: Remote branch 'origin/$branch' does not exist" >&2
        return 1
    end

    # 执行核心操作
    git -C "$target" fetch --all --prune --quiet || return 1
    git -C "$target" reset --hard "origin/$branch" || return 1
    echo "Successfully reset '$target' to origin/$branch"
end