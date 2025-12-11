function Export-DockerImage -d "导出镜像为 tar 文件" -a imageId filename
  if test -z $imageId
    echo Usage: Export-DockerImage \<imageId\> \<filename\>
    return $OMF_MISSING_AGE
  end
  if test -z $filename
    echo Usage: Export-DockerImage \<imageId\> \<filename\>
    return $OMF_MISSING_AGE
  end

  docker save $imageId -o $filename.tar
end