function Build-DockerImage -d "构建当前目录的 Docker 镜像" -a tagName
  if test -z $tagName
    echo Usage: Build-DockerImage \<tagName\>
    return $OMF_MISSING_AGE
  end

  if not test -e ./Dockerfile
    echo Dockerfile is not found in current directory. [.]
    return $OMF_UNKNOWN_ERR
  end

  docker build -t $tagName .
end