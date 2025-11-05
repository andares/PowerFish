# 这里配合`Set-RCVar DC_ENV "UID=$(id -u) GID=$(id -g)"`指令
function Docker-Compose
    if set -q DC_ENV
        env (string split " " $DC_ENV) docker compose $argv
    else
        env docker compose $argv
    end
end