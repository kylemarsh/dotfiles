#!/bin/bash
## Install custom ohmyzsh themes/plugins

dir=~/dotfiles                    # dotfiles directory
rm -r $dir/ohmyzsh/custom
ln -s $dir/custom-zsh ohmyzsh/custom
ls -l $dir/ohmyzsh/custom
