function Rebase-Repos -a target
    # 设置默认目标目录为当前目录
    if test -z "$target"
        set target .
    end

    # 检查目录是否存在
    if not test -d "$target"
        echo "Error: Directory '$target' does not exist" >&2
        return 1
    end

    # 检查是否在 Git 仓库中
    if not git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "Error: '$target' is not a Git repository" >&2
        return 1
    end

    # 获取当前分支
    set -l branch (
        git -C "$target" branch --show-current 2>/dev/null ||
        git -C "$target" rev-parse --abbrev-ref HEAD 2>/dev/null
    )

    # 验证分支状态
    if test -z "$branch" || string match -qr '^(HEAD|detached)' -- "$branch"
        echo "Error: Not on a valid branch (detached HEAD?) in '$target'" >&2
        return 1
    end

    # 检查工作区是否干净
    if not git -C "$target" diff-index --quiet HEAD --
        echo "Error: Working directory has uncommitted changes in '$target'" >&2
        echo "Please commit or stash your changes before rebasing" >&2
        return 1
    end

    # 检查远程分支是否存在
    if not git -C "$target" show-ref -q --verify "refs/remotes/origin/$branch"
        echo "Error: Remote branch 'origin/$branch' does not exist" >&2
        return 1
    end

    # 执行 rebase 更新
    echo "Updating '$target' via rebase on branch '$branch'..."

    git -C "$target" fetch --all --prune --quiet || return 1

    if git -C "$target" rebase --quiet "origin/$branch"
        echo "Successfully rebased '$target' onto origin/$branch"
        return 0
    else
        echo "Rebase conflict occurred in '$target'!" >&2
        echo "Resolve conflicts manually and then run 'git rebase --continue'" >&2
        return 1
    end
end