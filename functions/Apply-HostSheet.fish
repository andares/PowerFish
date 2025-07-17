function Apply-HostSheet -a sheetFile -d "根据配置的Host Sheet对服务器进行基础配置"
  if test -z "$sheetFile"
    echo Usage: Apply-HostSheet \<tagName\>
    return $OMF_MISSING_AGE
  end
end