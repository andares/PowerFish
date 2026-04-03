function power.EnvPath-To-Bash
	set -l bashrc "$HOME/.bashrc"

	if not test -f "$bashrc"
		touch "$bashrc"
		if test $status -ne 0
			echo "Error: 无法创建 $bashrc" >&2
			return 1
		end
	end

	set -l bash_paths

	while read -l line
		set -l trimmed_line (string trim -- "$line")

		if not string match -qr '^(export[[:space:]]+)?PATH[[:space:]]*=' -- "$trimmed_line"
			continue
		end

		set -l path_value (string replace -r '^(export[[:space:]]+)?PATH[[:space:]]*=[[:space:]]*' '' -- "$trimmed_line")

		if string match -qr '^".*"$' -- "$path_value"
			set path_value (string sub -s 2 -l (math (string length -- "$path_value") - 2) -- "$path_value")
		else if string match -qr "^'.*'\$" -- "$path_value"
			set path_value (string sub -s 2 -l (math (string length -- "$path_value") - 2) -- "$path_value")
		end

		for entry in (string split ':' -- "$path_value")
			set entry (string trim -- "$entry")

			if test -z "$entry"
				continue
			end

			if test "$entry" = '$PATH'; or test "$entry" = '${PATH}'
				continue
			end

			set -a bash_paths "$entry"
		end
	end < "$bashrc"

	set -l merged_paths

	for entry in $PATH $bash_paths
		if test -z "$entry"
			continue
		end

		if not contains -- "$entry" $merged_paths
			set -a merged_paths "$entry"
		end
	end

	set -l merged_joined (string join ':' -- $merged_paths)
	set -l managed_marker '# [power.EnvPath-To-Bash] managed'
	set -l export_line "export PATH=\"$merged_joined:\$PATH\""

	set -l tmpfile (mktemp)
	if test $status -ne 0; or test -z "$tmpfile"
		echo "Error: 无法创建临时文件" >&2
		return 1
	end

	set -l skip_managed_export 0

	while read -l line
		set -l trimmed_line (string trim -- "$line")

		if test $skip_managed_export -eq 1
			set skip_managed_export 0
			if string match -qr '^export[[:space:]]+PATH[[:space:]]*=' -- "$trimmed_line"
				continue
			end
		end

		if string match -q -- "$managed_marker" "$trimmed_line"
			set skip_managed_export 1
			continue
		end

		if string match -qr '^# \[power.EnvPath-To-Bash\][[:space:]]+export[[:space:]]+PATH[[:space:]]*=' -- "$trimmed_line"
			continue
		end

		if string match -qr '^export[[:space:]]+PATH[[:space:]]*=' -- "$trimmed_line"
			if test "$trimmed_line" = "$export_line"
				continue
			end

			echo "# [power.EnvPath-To-Bash] $line" >> "$tmpfile"
			continue
		end

		echo "$line" >> "$tmpfile"
	end < "$bashrc"

	echo "$managed_marker" >> "$tmpfile"
	echo "$export_line" >> "$tmpfile"

	mv "$tmpfile" "$bashrc"
	if test $status -ne 0
		echo "Error: 写入 $bashrc 失败" >&2
		rm -f "$tmpfile"
		return 1
	end

	echo "PATH 已同步到 $bashrc"
end
