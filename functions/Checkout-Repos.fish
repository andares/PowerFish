function Checkout-Repos -d "切换仓库到指定分支" -a reposDir branchName
  # 验证仓库目录参数
  if test -z "$reposDir"
    echo "Error: Repository directory is required" >&2
    return 1
  end

  # 验证分支名称参数
  if test -z "$branchName"
    echo "Error: Branch name is required" >&2
    return 1
  end

  # 检查目录是否存在
  if not test -d "$reposDir"
    echo "Error: Directory '$reposDir' does not exist" >&2
    return 1
  end

  # 检查是否为Git仓库
  if not test -d "$reposDir/.git"
    echo "Error: '$reposDir' is not a Git repository" >&2
    return 1
  end

  # 进入仓库目录
  pushd "$reposDir" > /dev/null

  # 检查是否有未提交的更改
  set hasChanges (git status --porcelain)
  if test -n "$hasChanges"
    echo "Staging all changes in '$reposDir'"
    git add .
  end

  # 尝试切换分支
  echo "Checking out branch '$branchName' in '$reposDir'"
  git checkout "$branchName" 2>/dev/null

  # 检查切换结果
  if test $status -eq 0
    set currentBranch (git branch --show-current)
    echo "Successfully switched to branch '$currentBranch'"
    popd > /dev/null
    return 0
  end

  # 切换失败处理
  popd > /dev/null
  echo "Error: Failed to switch to branch '$branchName'" >&2
  echo "Possible reasons:"
  echo " - Branch does not exist"
  echo " - Uncommitted changes conflict with branch"
  echo " - Local changes would be overwritten"
  return 1
end