num=$(i3-msg -t get_workspaces | jq '.[] | select(.focused == true).num' | tr -d '\n')

i3-msg "append_layout /etc/nixos/i3-layouts/${num}.json"
