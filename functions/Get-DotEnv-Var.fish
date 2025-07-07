function Get-DotEnv-Var -a name -d "Get variable from .env file" --argument-names path
    # Set default path to current directory if not provided
    if test -z "$path"
        set path "."
    end

    # Check if .env file exists
    set -l env_file "$path/.env"
    if not test -f "$env_file"
        echo "Error: .env file not found in $path" >&2
        return 1
    end

    # Extract the variable value
    set -l value (grep -E "^$name=" "$env_file" | cut -d= -f2-)

    if test -z "$value"
        echo "Error: Variable '$name' not found in $env_file" >&2
        return 1
    end

    echo -n "$value"  # Output without newline
end