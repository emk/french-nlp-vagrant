# Override various environment variables which are normally set up by ssh,
# so that we run everything in a known-consistent environment.  We use an
# English UTF-8 locale for now, but we reserve the right to change if
# something else would work better.
export LANG=en_US.UTF-8
unset LANGUAGE
unset `env | egrep '^LC_' | sed 's/=.*//'`
