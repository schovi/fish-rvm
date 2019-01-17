rvm current 1>/dev/null 2>&1

set -g -x __rvm_current "default"

function __check_rvm --on-variable PWD -d 'Setup rvm on directory change'
  status --is-command-substitution
  and return
  set -l cwd $PWD

  while true
    if contains $cwd "" $HOME "/"
      if test "$__rvm_current" != "default"
        rvm default 1>/dev/null 2>&1 &
        set -g -x __rvm_current "default"
      end

      break
    else
      set -l ruby_version (__get_rvm_version $cwd)

      if test -n "$ruby_version"
         and test "$ruby_version" != "$__rvm_current"

        # Seems not necessary
        # rvm reload 1> /dev/null 2>&1
        rvm rvmrc load 1>/dev/null 2>&1 &
        set -g -x __rvm_current $ruby_version

        break
      else
        set cwd (dirname "$cwd")
      end
    end
  end

  set -e cwd
end

function __get_rvm_version
  set -l cwd $argv[1]

  # TODO
  if test -s "$cwd/.versions.conf"
    echo ".versions.conf is not supported"
    return 1
  end

  if test -s "$cwd/.rvmrc"
    echo (cat $cwd/.rvmrc)
    return
  end

  if test -s "$cwd/.ruby-version"
    set -l ruby_version (cat $cwd/.ruby-version)

    if test -s "$cwd/.ruby-gemset"
      echo $ruby_version"@"(cat $cwd/.ruby-gemset)
    else
      echo $ruby_version
    end

    return
  end

  # TODO: just naive. Ignoring engine and other stuffs
  # Works with `ruby '2.5.1' *` or `ruby "2.5.1" *`
  if test -s "Gemfile"
    echo (grep "^ruby\s[\"\'].*[\"\']" Gemfile | awk -F'[\'\"]' '{print $2}')
    return
  end
end

# Check on open new session
__check_rvm
