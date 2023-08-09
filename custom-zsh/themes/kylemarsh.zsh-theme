#http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
PROMPT='$(virtualenv_prompt_info)%{$fg[cyan]%}%m %{$fg[yellow]%}%1~ $(git_prompt_info)%{$fg[white]%}$%{$reset_color%} '
PROMPT2='%{$fg[white]%}%_>%{$reset_color%} '
