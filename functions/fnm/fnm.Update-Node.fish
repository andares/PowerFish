function fnm.Update-Node -d "升级 Node 到指定大版本" -a major
  # 检查 fnm 是否存在
  if not command -q fnm
    echo (set_color red)"Error: fnm not found"(set_color normal)
    echo ""
    echo (set_color yellow)"Please install fnm first:"(set_color normal)
    echo (set_color cyan)"curl -o- https://fnm.vercel.app/install | bash"(set_color normal)
    echo ""
    echo "Then restart your shell and try again."
    return 1
  end

  # 参数验证
  if test -z "$major"
    echo "Usage: fnm.Update-Node <major_version>" >&2
    echo "Example: fnm.Update-Node 24" >&2
    return 1
  end

  # 检查是否为有效的大版本号
  if not string match -rq '^[0-9]+$' -- $major
    echo (set_color red)"Error: Invalid major version: $major"(set_color normal)
    echo "Major version must be a positive integer."
    return 1
  end

  echo "Installing Node v$major latest..."
  fnm install $major
  if test $status -ne 0
    echo (set_color red)"Failed to install Node v$major"(set_color normal)
    return 1
  end

  # 获取刚安装的版本号（最新版本）
  set -l installed_versions (fnm list | string match -r -a "v$major\.[0-9]+\.[0-9]+")
  set -l latest_version ""
  if test (count $installed_versions) -gt 0
    set -l latest_version (printf "%s\n" $installed_versions | sort -V | tail -n 1)
  end

  if test -z "$latest_version"
    echo (set_color red)"Failed to find installed Node v$major version"(set_color normal)
    return 1
  end

  echo "Setting v$latest_version as default..."
  fnm default $latest_version

  echo "Switching to Node v$latest_version..."
  fnm use $latest_version

  # 卸载该大版本的旧版本（如果存在）
  set -l old_versions
  for ver in $installed_versions
    if test "$ver" != "$latest_version"
      set -a old_versions $ver
    end
  end
  if test (count $old_versions) -gt 0
    echo "Removing old Node v$major versions..."
    for old_ver in $old_versions
      fnm uninstall (string replace -r '^v' '' -- $old_ver)
    end
  end

  # 升级 pnpm（如果存在）
  if command -q pnpm
    echo "Upgrading pnpm..."
    pnpm add -g pnpm@latest
  end

  echo (set_color green)"Node upgrade complete!"(set_color normal)
  fnm list
end
