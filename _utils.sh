has_displayed_title=false

title () {
  if $has_displayed_title; then echo; fi
  echo "$@" | sed s/./=/g
  echo "$@"
  echo "$@" | sed s/./=/g
  has_displayed_title=true
}

now=$(date "+%Y%m%d-%H%M%S")
