generate_config() {
  regex="^( *)([a-z0-9\-]+): *(.+)$"
  cond="if"
  lastcmd=""
  find_config

  echo "# This file was automatically generated by alf"
  echo "# https://github.com/dannyben/alf"

  while IFS= read -r line || [ -n "$line" ]; do
    if [[ $line =~ $regex ]]; then
      indent="${BASH_REMATCH[1]}"
      
      if [[ -z $indent ]]; then
        ali1="${BASH_REMATCH[2]}"
        cmd1="${BASH_REMATCH[3]}"
        local_regex="^$ali1( +|$)"
        if [[ $cmd1 =~ $local_regex ]]; then
          cmd1="command $cmd1"
        fi
        unset ali2 cmd2
        generate_last_cmd
        lastcmd=$cmd1
      else
        ali2="${BASH_REMATCH[2]}"
        cmd2="${BASH_REMATCH[3]}"
      fi

      if [[ -n $ali2 ]]; then
        echo "  $cond [[ \$1 = \"$ali2\" ]]; then"
        echo "    shift"
        
        if [[ $cmd2 =~ ^! ]]; then
          cmd=${cmd2:1}
        elif [[ $cmd1 =~ ^! ]]; then
          cmd="$cmd2"
        else
          cmd="$cmd1 $cmd2"
        fi

        if [[ $cmd2 =~ \$ ]]; then
          echo "    $cmd"
        else
          echo "    $cmd \"\$@\""
        fi
        cond="elif"
      else
        echo ""
        echo "unalias $ali1 1>/dev/null 2>&1"
        echo "$ali1() {"
      fi
    fi
  done < "$config_file"
  generate_last_cmd
}

