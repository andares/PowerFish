function Delete-RCVar -a name
  if not set -q $name
    echo Usage: Delete-RCVar \<name\>
    echo - Variable must be defined.
    return $OMF_MISSING_ARG
  end

  if not test -f $HOME/.powerrc.fish
    return $OMF_UNKNOWN_OPT
  end

  koi exec-cmd "sed -i '/^set -xg $name /d' $HOME/.powerrc.fish"

  set -ge $name
end
