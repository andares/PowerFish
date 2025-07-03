function Docker-Compose
    set -l uid (id -u)
    set -l gid (id -g)
    env UID=$uid GID=$gid docker compose $argv
end