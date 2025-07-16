function Raise-DockerCompose -a targetDir
  set -l command
  if test -z "$targetDir"
    if not test -e ./docker-compose.yml
      echo "Error: docker-compose.yml not found in current directory"
      return 1
    end
    set command Docker-Compose
  else
    if not test -e "$targetDir/docker-compose.yml"
      echo "Error: docker-compose.yml not found in $targetDir"
      return 1
    end
    set command Docker-Compose -f "$targetDir/docker-compose.yml"
  end

  # 检查服务是否存在（通过容器ID判断）
  set containers ($command ps -aq)

  if test -z "$containers"
    # 容器未创建：执行 up -d
    $command up -d
  else
    # 检查是否有运行中的容器
    set running_count (count ($command ps -q --status running))
    if test $running_count -gt 0
      # 有运行中的容器：执行 restart
      $command restart
    else
      # 容器存在但未运行：执行 start
      $command start
    end
  end
end