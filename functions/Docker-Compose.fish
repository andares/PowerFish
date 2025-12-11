# 这里配合`Set-RCVar DC_ENV "UID=$(id -u) GID=$(id -g)"`指令
function Docker-Compose -d "带 UID/GID 环境执行 docker compose"
    if set -q DC_ENV
        env (string split " " $DC_ENV) docker compose $argv
    else
        env docker compose $argv
    end
end