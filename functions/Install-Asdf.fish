# INFO: 做个说明，这个是老的安装方式，安装的是0.15老版本，0.16之后asdf使用go重写并变更了安装方式，安装脚本也不兼容了，后续如果需要安装0.16版本可以再更新这个函数
function Install-Asdf -d "安装 ASDF 版本管理器"
    # 检查sudo权限
    if not power.Has-Sudo
        echo "Error: Need sudo permission" >&2
        return $OMF_UNKNOWN_ERR
    end

    # 检查是否已安装
    if test -d "$HOME/.asdf"
        echo "asdf already installed at $HOME/.asdf"
        if type -q asdf
            echo "Current version: "(asdf --version)
            read -P "Reinstall? [y/N] " -l answer
            if test "$answer" != "y" -a "$answer" != "Y"
                return 0
            end
            echo "Removing existing installation..."
            rm -rf "$HOME/.asdf"
        end
    end

    # 安装依赖包
    echo "Installing dependencies..."
    sudo apt-get update
    sudo apt-get install -y curl git

    # 克隆 asdf 仓库
    echo "Cloning asdf repository..."
    git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf" --branch (curl -s https://api.github.com/repos/asdf-vm/asdf/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

    if test $status -ne 0
        echo "Failed to clone asdf repository" >&2
        return 1
    end

    # 配置 fish shell
    set -l fish_config "$HOME/.config/fish/config.fish"
    set -l asdf_source_line "source ~/.asdf/asdf.fish"

    # 确保 fish 配置目录存在
    mkdir -p (dirname $fish_config)

    # 检查配置文件中是否已经包含 asdf 配置
    if test -f $fish_config
        if grep -q "asdf.fish" $fish_config
            echo "asdf already configured in $fish_config"
        else
            echo "Adding asdf to fish configuration..."
            echo "" >> $fish_config
            echo "# asdf version manager" >> $fish_config
            echo $asdf_source_line >> $fish_config
        end
    else
        echo "Creating fish configuration with asdf..."
        echo "# asdf version manager" > $fish_config
        echo $asdf_source_line >> $fish_config
    end

    # 配置补全
    echo "Configuring fish completions..."
    mkdir -p "$HOME/.config/fish/completions"
    ln -sf "$HOME/.asdf/completions/asdf.fish" "$HOME/.config/fish/completions/asdf.fish"

    echo ""
    echo "✓ asdf installation completed!"
    echo ""
    echo "Please restart your shell or run:"
    echo "  source ~/.config/fish/config.fish"
    echo ""
    echo "Then verify installation with:"
    echo "  asdf --version"
    echo ""
    echo "To get started, you can install plugins like:"
    echo "  asdf plugin add nodejs"
    echo "  asdf install nodejs latest"

    return 0
end
