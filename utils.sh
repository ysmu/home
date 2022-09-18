function add_to_bashrc {
  marker="# $1"
  addition="$2"

  if ! grep -qxF "$marker" ~/.bashrc; then
    echo >> ~/.bashrc
    echo "$marker" >> ~/.bashrc
    echo "${addition/\\n/}" >> ~/.bashrc
  fi
}
