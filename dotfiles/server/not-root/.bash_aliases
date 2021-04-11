# Aliases
# alias alias_name="command_to_run"

alias la='LS_COLORS="mh=1;37" ls -A'
alias l='LS_COLORS="mh=1;37" ls -CF'
alias ll='LC_COLLATE=C LS_COLORS="mh=1;37" ls -la --si --group-directories-first'

# Nginx aliases
alias nt='sudo nginx -t'
alias nr='sudo service nginx reload'

# Custom aliases
alias temp='vcgencmd measure_temp'
#alias update='sudo apt update & sudo apt upgrade -y'
alias lss='ls -la --block-size=M'

# Listening ports
alias ports='sudo netstat -tulpn | grep LISTEN'
alias ports2='sudo ss -lptn'

# Others
alias nextcloud='sudo -u www-data php7.4 /srv/http/drive.federicociro.com/nextcloud/occ'
alias nano='nano -lS'
