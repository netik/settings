#!/bin/sh

# This will make a bunch of links to these files, assuming that you've
# done a git clone as $USER/settings

for F in .profile .bashrc .emacs site-lisp;
do
  ln -s ~/settings/${F} ~/${F}
done


