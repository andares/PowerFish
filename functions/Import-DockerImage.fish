function Import-DockerImage -a filename tagName

  if test -z $filename
    echo Usage: Import-DockerImage \<tagName\> \<filename\>
    return $OMF_MISSING_AGE
  end

  # 导入镜像并捕获输出
  set -l output (docker load -i $filename)

  # 提取导入的镜像ID
  set -l imageId (string match -r 'Loaded image: (.*)' $output | awk '{print $3}')
  if test -z $tagName; or test $tagName = $imageId
    echo "Successfully imported. Image tag: $tagName"
    return 0
  end

  # 检查是否成功获取镜像ID
  if test -z "$imageId"
    echo "Error: Failed to extract image ID from docker load output"
    return 1
  end

  # 给镜像添加新标签
  docker tag $imageId $tagName

  # 删除旧标签
  set -l old_tag (docker image inspect --format '{{range .RepoTags}}{{.}}{{break}}{{end}}' $imageId)
  if test -n "$old_tag" -a "$old_tag" != "<none>:<none>"
    docker rmi $old_tag
  end

  echo "Successfully imported, retagged as $tagName, and removed old tag"
end