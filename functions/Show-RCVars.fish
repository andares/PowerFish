function Show-RCVars -a name
  if not test -f $HOME/.powerrc.fish
    return $OMF_UNKNOWN_OPT
  end

  set -l tmp
  for line in (string split "\n" (cat $HOME/.powerrc.fish))
    set tmp (string match -r '^set \-xg ([^\s]+) ([^\s]+)$' $line)
    if not test (count $tmp) -eq 3
      continue
    end

    if not test -z "$name"; and not test $tmp[2] = $name
      continue
    end
    echo {$tmp[2]}={$tmp[3]}
  end
end
