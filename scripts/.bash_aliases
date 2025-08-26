# ~/.dotfiles/.bash_aliases

# ssh shortcuts
alias ssh="kitty ssh"

# nixos rebuild command
alias nix-reb="~/.dotfiles/scripts/nix-rebuild-nice.sh"

# misc
alias ls="ls -a"


# firefox shortcut script is tricky
ff() {
   
	# run script
   	~/.dotfiles/scripts/firefox_shortcuts.sh "$1"

	# case on script exit code to decide whether to kill terminal
	if [ $? -eq 0 ]; then
		exit
	else 
		echo "firefox shortcut script failed."
	fi
		
}
# export -f ff

