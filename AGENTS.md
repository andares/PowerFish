# PowerFish Agent Notes

## 项目定位

- `PowerFish` 是 Oh My Fish（OMF）插件，主能力在 `functions/*.fish`。
- `Land` 是通过 `functions/Land.fish` 调用的 Deno 子命令系统，入口在 `land/main.ts`。
- 本仓库以 Linux 环境（尤其 apt 生态）为默认目标，多个函数会直接调用 `sudo apt`。

## 关键目录

```text
PowerFish/
├─ init.fish                 # OMF 初始化入口：环境变量、PATH、rc 加载、autoload
├─ alias.fish                # 别名文件（当前为空）
├─ functions/
│  ├─ PowerFish.fish         # 命令列表与分组展示
│  ├─ Land.fish              # Land 命令桥接（deno run land/main.ts ...）
│  ├─ power/                 # 依赖检查、工具函数
│  ├─ tc/                    # 腾讯云证书相关子命令
│  └─ *.fish                 # 其他业务函数
├─ completions/              # fish 补全脚本
└─ land/
    ├─ main.ts               # Land 命令路由入口
    ├─ install_php.ts        # 示例子命令（install-php）
    ├─ main_test.ts          # Deno 测试
    └─ deno.json             # Deno tasks/imports
```

## 开发前置（建议）

- fish shell（>=3）与 OMF。
- Deno（`Land` 与 `land/*` 测试依赖）。
- 若改动 secrets/cert 相关函数，需确认本机具备：`age`、`certbot`、`python3`、`pip3`、`pipx`。
- 若函数涉及容器能力，需本地可用 Docker / docker compose。

## 本地开发与调试规范（必须遵守）

### Fish function 的测试方法（必须遵守）

- 这是 OMF 库：本地修改后的正确测试方式是在终端会话中先 `source` 本地函数文件，覆盖系统已加载版本，再执行函数测试。
- 不要通过把文件软链到插件安装目录（受 git 管控的同名文件）来做测试。

### 推荐调试步骤

1. 在仓库根目录启动 fish 会话。
2. 先加载插件入口：`source ./init.fish`。
3. 修改某个函数后，单独覆盖加载该函数文件，例如：`source ./functions/Make-SecretFile.fish`。
4. 直接执行对应命令做回归，例如：`Make-SecretFile ...` / `Land help`。

## Land 子项目开发说明

- 命令入口：`functions/Land.fish`，实际执行 `deno run "$POWER_PATH/land/main.ts" ...`。
- 本地开发可在 `land/` 下使用：
   - `deno task dev`（watch 模式运行）
   - `deno task test`（运行 Deno 测试）
- 新增 Land 子命令时：
   1. 在 `land/main.ts` 注册 `router.register("cmd", "desc", handler)`；
   2. 实现 handler 文件；
   3. 为命令路由补测试（`land/main_test.ts` 或新增测试文件）。

## 改动约束与提交前检查

- 优先做最小改动，避免顺手重构无关函数。
- 涉及系统命令（`apt` / `sudo` / 文件写入）时，先保持与现有风格一致，再补错误处理。
- 修改 `land/*.ts` 后至少执行一次 Deno 测试。
- 修改 `functions/*.fish` 后至少进行一次 `source` 覆盖加载 + 手工命令验证。

## 当前已知现状（2026-02）

- `land/main_test.ts` 在当前仓库状态下存在失败用例（与彩色输出文本、退出码断言相关），属于存量问题，不是文档改动引入。
