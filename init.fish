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

# rc file support
if test -f $HOME/.powerrc.fish
  source $HOME/.powerrc.fish
end

# alias load
source $DIR/alias.fish

# autoload
autoload $POWER_PATH/functions/power
autoload $POWER_PATH/functions/hw
autoload $POWER_PATH/functions/tc

# autoclear history hook
if not test -z "$autoclear_history"; and test $autoclear_history -gt 0
  function _hook_autoclear_history --on-process-exit %self
      builtin history clear
      echo Session history scrubbed.  Goodbye
  end
end

# update sub command completions
