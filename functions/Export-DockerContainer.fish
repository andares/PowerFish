function Export-DockerContainer -a containerId filename
  if test -z $containerId
    echo Usage: Export-DockerImage \<containerId\> \<filename\>
    return $OMF_MISSING_AGE
  end
  if test -z $filename
    echo Usage: Export-DockerImage \<containerId\> \<filename\>
    return $OMF_MISSING_AGE
  end

  docker export $containerId > $filename.tar
end