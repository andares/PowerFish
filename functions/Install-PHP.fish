function Install-PHP
  power.Check-Deno || return $OMF_UNKNOWN_ERR
  # 这里也可以通过`if test $status -ne 0`判断`$status`做出更复杂处理

  deno run -c $POWER_PATH/land/deno.json $POWER_PATH/land/php_helper.ts

end
