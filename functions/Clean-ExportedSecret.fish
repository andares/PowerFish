function Clean-ExportedSecret
  # 确保目录存在
  if not test -d "$HOME/.local/.secret"
    echo "Error: secret dir does not exist" >&2
    return $OMF_UNKNOWN_ERR
  end

  set -l SECRET_TMP_DIR $HOME/.local/.secret/tmp
  rm -r $SECRET_TMP_DIR/*
end