function Clone-Repos -a remoteUri targetDir
  # 验证远程URI是否为空
  if test -z "$remoteUri"
    echo "Error: Remote URI is required" >&2
    return 1
  end

  # 处理目标目录参数
  if test -z "$targetDir"
    # 从URI提取默认仓库名
    set repo_name (basename $remoteUri | string replace -r '\.git$' '')
    set targetDir $repo_name

    echo "Using default repository name: $repo_name"
  end

  # 检查目标目录是否已存在
  if test -e "$targetDir"
    echo "Error: Target directory '$targetDir' already exists" >&2
    return 1
  end

  # 执行克隆操作
  echo "Cloning repository from $remoteUri to $targetDir"
  git clone -- $remoteUri $targetDir

  # 检查克隆是否成功
  if test $status -eq 0
    echo "Successfully cloned repository to $targetDir"
  else
    echo "Error: Failed to clone repository" >&2
    return 1
  end
end