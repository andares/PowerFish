# PowerFish Agent Notes

## 项目定位

- `PowerFish` 是 Oh My Fish（OMF）插件，主能力在 `functions/*.fish`。
- 本仓库以 Linux 环境（尤其 apt 生态）为默认目标，多个函数会直接调用 `sudo apt`。

## 关键目录

```text
PowerFish/
├─ init.fish                 # OMF 初始化入口：环境变量、PATH、rc 加载、autoload
├─ alias.fish                # 别名文件（当前为空）
├─ functions/
│  ├─ PowerFish.fish         # 命令列表与分组展示
│  ├─ power/                 # 依赖检查、工具函数
│  ├─ tc/                    # 腾讯云证书相关子命令
│  └─ *.fish                 # 其他业务函数
├─ completions/              # fish 补全脚本
└─ uninstall.fish            # OMF 卸载钩子
```

## 空目录警告

以下目录存在但为空，init.fish 中有 autoload 引用：

- `functions/dc/` - 空目录
- `functions/hw/` - 空目录  
- `functions/fnm/` - 仅含空文件

## 开发前置

- fish shell（>=3）与 OMF
- `age`、`certbot`、`python3`、`pip3`、`pipx`（secrets/cert 相关函数需要）
- Docker / docker compose（容器相关函数需要）

## 本地开发与调试规范

### Fish function 测试方法

这是 OMF 库：本地修改后的正确测试方式是在终端会话中先 `source` 本地函数文件，覆盖系统已加载版本，再执行函数测试。

**不要**通过把文件软链到插件安装目录（受 git 管控的同名文件）来做测试。

### 推荐调试步骤

1. 在仓库根目录启动 fish 会话
2. 先加载插件入口：`source ./init.fish`
3. 修改某个函数后，单独覆盖加载该函数文件，例如：`source ./functions/Make-SecretFile.fish`
4. 直接执行对应命令做回归测试

## 核心函数说明

| 函数 | 用途 |
|------|------|
| `Make-SecretFile` | 使用 age 加密并保存文件到 `~/.local/.secret/` |
| `Export-SecretFile` | 解密加密文件并导出到 `/dev/shm/.export-secret/` |
| `Clean-ExportedSecret` | 清理导出的临时密钥文件 |
| `tc.Renew-Cert` | 使用腾讯云凭据和 certbot 续期 Let's Encrypt 证书 |
| `Docker-Compose` | 带 UID/GID 环境执行 docker compose |
| `Set-RCVar` / `Delete-RCVar` | 管理 `~/.powerrc.fish` 中的环境变量 |

## 改动约束

- 优先做最小改动，避免顺手重构无关函数
- 涉及系统命令（`apt` / `sudo` / 文件写入）时，先保持与现有风格一致
- 修改 `functions/*.fish` 后至少进行一次 `source` 覆盖加载 + 手工命令验证
