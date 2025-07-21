function Renew-DockerCompose -a composeFile
    # 设置默认目标目录为当前目录
    if test -z "$composeFile"
      Docker-Compose down && Docker-Compose up -d --build --remove-orphans
    else
      Docker-Compose -f "$composeFile" down && Docker-Compose -f "$composeFile" up -d --force-recreate --build --remove-orphans
    end
    return $status
end