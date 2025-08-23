set -g fish_greeting

# fzf 
if type -q fzf
    fzf --fish | source
end

# example integration with bat : <cltr+f>
# bind -M insert \ce '$EDITOR $(fzf --preview="bat --color=always --plain {}")' 

set fish_pager_color_prefix cyan
set fish_color_autosuggestion brblack

# List Directory
alias l='eza -lh  --icons=auto' # long list
alias ls='eza -1   --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lt='eza --icons=auto --tree' # list folder as tree
alias myip='bash ~/.config/hypr/scripts/iptest.sh'
alias s='sudo find / -name'
alias update='yay -Syu --noconfirm && flatpak update'
alias clearcache='sudo pacman -Rns $(pacman -Qtdq) && sudo pacman -Scc'

# Handy change dir shortcuts
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .3 'cd ../../..'
abbr .4 'cd ../../../..'
abbr .5 'cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
abbr mkdir 'mkdir -p'

fish_add_path /home/whoami/.spicetify
#set -Ux STARSHIP_CONFIG ~/.config/starship.toml
#starship init fish | source
clear && fastfetch --config os
