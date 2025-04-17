function Set-RCVar -a name value
  if test -z "$name"; or test -z "$value"
    echo Usage: Set-RCVar \<name\> \<value\>
    return $OMF_MISSING_ARG
  end

  if not test -f $HOME/.powerrc.fish
    echo '# PowerFish RC File' > $HOME/.powerrc.fish
  end

  koi exec-cmd "sed -i '/^set -xg $name=/d' $HOME/.powerrc.fish"
  koi exec-cmd "sed -i '\$a\\set -xg $name $value' $HOME/.powerrc.fish"

  set -xg "$name" "$value"
end
