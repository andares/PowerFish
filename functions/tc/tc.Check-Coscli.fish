# 执行 config init 时：
# - Input Your Mode: 时可以输入 AK/SK
# - Input Your Session Token: 可以直接回车留空
function tc.Check-Coscli -d "检查并安装 coscli 工具"
  set -l coscli_cmd "coscli"

  if not command -q coscli
    if test -x "$HOME/.local/bin/coscli"
      set coscli_cmd "$HOME/.local/bin/coscli"
    else
      echo "coscli not found. Installing..."

      set -l arch (uname -m)
      set -l binary_suffix ""

      switch $arch
        case x86_64 amd64
          set binary_suffix "linux-amd64"
        case i386 i686
          set binary_suffix "linux-386"
        case aarch64 arm64
          set binary_suffix "linux-arm64"
        case armv7l armv6l
          set binary_suffix "linux-arm"
        case '*'
          echo "Unsupported architecture for auto-install: $arch"
          return 1
      end

      set -l download_url "https://cosbrowser.cloud.tencent.com/software/coscli/coscli-$binary_suffix"
      set -l tmp_file "/tmp/coscli-$binary_suffix-"(random)

      if command -q wget
        wget -q -O "$tmp_file" "$download_url"
      else if command -q curl
        curl -fsSL -o "$tmp_file" "$download_url"
      else
        echo "Neither wget nor curl found. Please install one of them first."
        return 1
      end

      if test $status -ne 0; or not test -s "$tmp_file"
        echo "Failed to download coscli from: $download_url"
        return 1
      end

      chmod 755 "$tmp_file"
      mkdir -p "$HOME/.local/bin"
      mv -f "$tmp_file" "$HOME/.local/bin/coscli"
      set coscli_cmd "$HOME/.local/bin/coscli"
    end
  end

  if command -q coscli
    set coscli_cmd "coscli"
  else if not test -x "$coscli_cmd"
    echo "coscli installation failed."
    return 1
  end

  if not test -f "$HOME/.cos.yaml"
    echo "~/.cos.yaml not found, running coscli config init..."
    $coscli_cmd config init
    if test $status -ne 0
      echo "coscli config init failed."
      return 1
    end
  end

  return 0
end
