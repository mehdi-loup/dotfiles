# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

# Fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# export FZF_DEFAULT_COMMAND='rg --files --files-with-matches --no-ignore --hidden --follow --exclude .git'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# Aliases
alias vim="nvim"
alias gs='git status'
alias gsh='git show HEAD'
alias grab='git rebase --abort'
alias grim='git rebase -i origin/master'
alias grc='git rebase --continue'
alias gdc='git diff --cached'
alias gss='f() { git stash show stash@{$1} }; f'
alias gbranches='git branch --sort=committerdate'
alias reset-yarn-lock='git reset yarn.lock && git co yarn.lock && yarn && git add yarn.lock'
alias nginx-update="erb .spin/nginx.conf.erb > /etc/nginx/conf.d/nginx.conf"
alias find-tsserver-logs="find /home/spin/.vscode-server/data/logs/ |grep /tsserver\\\.log"
alias lint="node_modules/.bin/eslint --format codeframe --no-cache"
alias fixup="git commit --amend -C HEAD"
alias gpf='git push --force-with-lease --set-upstream origin "$(git-branch-current 2> /dev/null)"'
alias gap='git commit --amend -C HEAD && git push --force --set-upstream origin "$(git-branch-current 2> /dev/null)"'
alias gup='git pull --rebase origin "$(git-branch-current 2> /dev/null)"'
alias gcf="git commit -a --fixup HEAD"
alias gpm="git pull --rebase origin master"
alias gpms="git fetch origin master && git rebase --interactive --autosquash origin/master"
alias wip="git commit -am \"WIP\""
alias delete-old-branches="git branch --merged | grep -v '\*\|master\|develop' | xargs -n 1 git branch -d"

git_recent_branches() {
    git branch --sort=committerdate | tail -n 10
}

git_checkout_recent_branch() {
    local current_branch_name="$(git branch | grep \* | cut -d ' ' -f2)"

    local new_branch_name="${$(git_recent_branches | fzf)//[[:blank:]]/}"

    echo "Switching to \e[36m$new_branch_name\e[0m..."

    {
        git add .
        git stash save "$current_branch_name-AUTOSTASH"

        git co $new_branch_name

        local previous_stash="$new_branch_name-AUTOSTASH"
        local stash_found="$(git stash list | grep $previous_stash | head -n 1 | sed 's/:.*//')"

        if [ ! -z "$stash_found" ]
        then
            git stash apply $stash_found
            git stash drop $stash_found
        fi
    } &> /dev/null
}

clone_repo() {
    local repo_url=$1

    local repo_domain="$(echo "$1" | awk -F/ '{print $3}')"
    local git_user="$(echo "$1" | awk -F/ '{print $4}')"
    local user_path="$HOME/src/$repo_domain/$git_user"

    mkdir -p $user_path
    cd $user_path
    git clone $repo_url

    local repo_name="$(echo "$1" | awk -F/ '{print $5}')"
    local src_dir="$(echo $repo_name | sed -e "s/\.git//g")"

    cd $src_dir
}

alias gcor=git_checkout_recent_branch

alias lastb="git for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'"
git config --global alias.up 'pull --rebase --autostash'
git config --global alias.st 'status'

export EDITOR=nvim
export VISUAL=nvim

export DOTFILES=~/src/github.com/felix-d/dotfiles
alias dotfiles="nvim $DOTFILES"

# Fixes Ctr-A and Ctrl-E because of oh my zsh
bindkey -e

export DEFAULT_USER=$USER
zstyle ':prezto:module:git:info:dirty' format "%%B%F{$secondary_color}]%f%%b %F{yellow}✗%f"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

alias zapper="cd ~/src/github.com/Zapper-fi/zapper-web"

source ~/.secrets
export PATH="/opt/homebrew/opt/postgresql@11/bin:$PATH"
nvm use 16
