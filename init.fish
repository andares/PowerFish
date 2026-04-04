# PowerFish initialization hook
#
# You can use the following variables in this file:
# * $package       package name
# * $path          package path
# * $dependencies  package dependencies

# self path
set -l DIR (dirname (status -f))
set -xg POWER_PATH $DIR

# init local directory
if not test -e $HOME/.local/bin
  mkdir -p $HOME/.local/bin
end
set -xg PATH $HOME/.local/bin $PATH

# init secret directory
if not test -e $HOME/.local/.secret
  mkdir -p $HOME/.local/.secret
end
if not test -e $HOME/.local/.secret/new
  mkdir -p $HOME/.local/.secret/new
end
if not test -e $HOME/.local/.secret/lnk
  mkdir -p $HOME/.local/.secret/lnk
end

set -xg EXPORT_SECRETE_PATH /dev/shm/.export-secret
if not test -e $EXPORT_SECRETE_PATH
  mkdir -p $EXPORT_SECRETE_PATH
  chmod 755 $EXPORT_SECRETE_PATH
end

# clean invalid soft link in $/.local/bin
if test (count (string split ' ' (ls $HOME/.local/bin))) -gt 0
  for file in (string split ' ' (echo $HOME/.local/bin/*))
    if not test -e $file
      rm $file
    end
  end
end
set -xg LOCAL_DIR $HOME/.local
set -xg LOCAL_BIN $HOME/.local/bin

# global variables 可以被rc file中覆盖
set -xg NGINX_AVAILABLE_DIR "/etc/nginx/sites-available"
set -xg NGINX_ENABLED_DIR "/etc/nginx/sites-enabled"

# rc file support
if test -f $HOME/.powerrc.fish
  source $HOME/.powerrc.fish
end

# rc directory support
if not test -e $HOME/.powerrc
  mkdir -p $HOME/.powerrc
end

# load all *.fish files from rc directory
for rcfile in (find $HOME/.powerrc -maxdepth 1 -name "*.fish" -type f | sort)
  source $rcfile
end

# alias load
source $DIR/alias.fish

# autoload
autoload $POWER_PATH/functions/power
autoload $POWER_PATH/functions/dc
autoload $POWER_PATH/functions/hw
autoload $POWER_PATH/functions/tc

# 同步 $PATH 到 bash
# INFO: 还是不要每次都同步了
# power.EnvPath-To-Bash

# autoclear history hook
if not test -z "$autoclear_history"; and test $autoclear_history -gt 0
  function _hook_autoclear_history --on-process-exit %self
      builtin history clear
      echo Session history scrubbed.  Goodbye
  end
end

# update sub command completions
