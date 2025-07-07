function Call-ComposeMysql -a database
    # Step 0: Check for jq dependency
    if not command -v jq >/dev/null
        echo "Error: jq is required but not installed. Please install it with:" >&2
        echo "  macOS: brew install jq" >&2
        echo "  Linux: sudo apt-get install jq" >&2
        echo "  Windows: choco install jq" >&2
        return 1
    end

    # Step 1: Check for required files
    if not test -f docker-compose.yml
        echo "Error: docker-compose.yml not found in current directory" >&2
        return 1
    end

    # Step 2: Check compose services status
    set -l compose_status (Docker-Compose ps --status running -q 2>/dev/null)
    if test -z "$compose_status"
        echo "Error: Docker compose services are not running" >&2
        return 1
    end

    # Step 3: Find MySQL service name (修复：处理行分隔的 JSON 对象)
    set -l mysql_service (
        Docker-Compose ps --format json |
        jq -r 'select(.Image | test("mysql|mariadb"; "i")) | .Service' |
        head -1
    )

    if test -z "$mysql_service"
        echo "Error: MySQL/MariaDB service not found in running compose services" >&2
        echo "Hint: Check service image contains 'mysql' or 'mariadb'" >&2
        return 1
    end

    # Step 4: Get database name
    if test -z "$database"
        set -l env_db (Get-DotEnv-Var "MYSQL_DATABASE" . 2>/dev/null)
        if test -z "$env_db"
            echo "Error: Database name not provided and MYSQL_DATABASE not set in .env" >&2
            return 1
        end
        set database "$env_db"
    end

    # Step 5: Get credentials
    set -l user
    set -l password

    set -l env_user (Get-DotEnv-Var "MYSQL_USER" . 2>/dev/null)
    set -l env_password (Get-DotEnv-Var "MYSQL_PASSWORD" . 2>/dev/null)
    set -l root_password (Get-DotEnv-Var "MYSQL_ROOT_PASSWORD" . 2>/dev/null)

    if test -n "$env_user" -a -n "$env_password"
        set user "$env_user"
        set password "$env_password"
    else if test -n "$root_password"
        set user "root"
        set password "$root_password"
    else
        echo "Error: No valid credentials found in .env (MYSQL_USER/MYSQL_PASSWORD or MYSQL_ROOT_PASSWORD required)" >&2
        return 1
    end

    # Step 6: Execute with input redirection handling
    if isatty stdin
        Docker-Compose exec "$mysql_service" mysql -u "$user" -p"$password" "$database"
    else
        Docker-Compose exec -T "$mysql_service" mysql -u "$user" -p"$password" "$database" <&0
    end
end