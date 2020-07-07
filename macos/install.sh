if test ! "$(uname)" = "Darwin"
  then
  exit 0
fi

# The Brewfile handles Homebrew-based app and library installs
# This CLI handles updates and installables from the Mac App Store.

echo "> sudo softwareupdate -i -a"
sudo softwareupdate -i -a