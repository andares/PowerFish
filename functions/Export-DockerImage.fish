function Export-DockerImage -a imageId filename
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