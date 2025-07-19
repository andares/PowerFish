function power.Is-Truthy
  set -l value (string lower -- $argv[1])
  switch $value
    case '1' 'y' 'yes' 't' 'true' 'ok' 'on'
      return 0  # 返回真值状态
    case '*'
      return 1  # 返回假值状态
  end
end