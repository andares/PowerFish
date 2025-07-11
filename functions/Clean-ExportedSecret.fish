function Clean-ExportedSecret
  # 确保目录存在
  if not test -d "$HOME/.local/.secret"
    echo "Error: secret dir does not exist" >&2
    return $OMF_UNKNOWN_ERR
  end

  set -l SECRET_TMP_DIR $HOME/.local/.secret/tmp
  # 目录为空时不操作
  if not test -n (find $SECRET_TMP_DIR -maxdepth 0 -type d -empty)
    rm -r $SECRET_TMP_DIR/*
  end
end