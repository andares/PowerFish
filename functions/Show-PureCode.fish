# Example with `exclude`: Show-PureCode php "./vendor/*"|wc -l
function Show-PureCode -a extension exclude
    if test -z "$extension"
        echo "Usage: Show-PureCode <extension>" >&2
        return $OMF_UNKNOWN_ERR
    end

    if test -z "$exclude"
        find . -type f -name "*.$extension" -print0 | xargs -0 cat | grep -vE '^[[:space:]]*($|//|/\*|\*/|\*|\;|\#|\<\!\-\-)'
    else
        find . -type f -name "*.$extension" -not -path "$exclude" -print0 | xargs -0 cat | grep -vE '^[[:space:]]*($|//|/\*|\*/|\*|\;|\#|\<\!\-\-)'
    end
end
