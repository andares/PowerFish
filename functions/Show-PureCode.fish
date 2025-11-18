function Show-PureCode -a extension
    if test -z "$extension"
        echo "Usage: Show-PureCode <extension>" >&2
        return $OMF_UNKNOWN_ERR
    end
    find . -type f -name "*.$extension" -print0 | xargs -0 cat | grep -vE '^[[:space:]]*($|//|/\*|\*/|\*|\;|\#|\<\!\-\-)'
end
