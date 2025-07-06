function Import-DockerImage -a tagName filename
  if test -z $tagName
    echo Usage: Import-DockerImage \<tagName\> \<filename\>
    return $OMF_MISSING_AGE
  end
  if test -z $filename
    echo Usage: Import-DockerImage \<tagName\> \<filename\>
    return $OMF_MISSING_AGE
  end

  # 导入镜像并捕获输出
  set -l output (docker load -i $filename)
  echo $output

  # 提取导入的镜像ID
  set -l image_id (string match -r 'Loaded image: (.*)' $output | awk '{print $3}')

  # 检查是否成功获取镜像ID
  if test -z "$image_id"
    echo "Error: Failed to extract image ID from docker load output"
    return 1
  end

  # 给镜像添加新标签
  docker tag $image_id $tagName

  # 删除旧标签
  set -l old_tag (docker image inspect --format '{{range .RepoTags}}{{.}}{{break}}{{end}}' $image_id)
  if test -n "$old_tag" -a "$old_tag" != "<none>:<none>"
    docker rmi $old_tag
  end

  echo "Successfully imported, retagged as $tagName, and removed old tag"
end