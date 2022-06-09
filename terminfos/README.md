terminfo
========

These terminfo files update the default definitions to add support for italic
and bold ("standout") so I can use those features in vim both inside and
outside of tmux.

You interact with the terminfo database with the `tic` and `infocmp` commands.
To see the current terminfo definitions you can do something like:
`infocmp -I xterm-256color`

To write that to a file: `infocmp -I xterm-256color > ~/old_terminfos/xterm-256color.orig.terminfo`
To read a terminfo file try: `tic -I screen.terminfo`
To compare two terminal entries in the database: `infocmp -d screen screen-256color` (`-d` is show differences)
To compare two terminfo files: `infocmp -d -F screen.terminfo ~/old_terminfos/screen.terminfo` (this will compare the new version agains the installed version.

All three of these include a `use=` line at the end that imports the existing
version of the terminal definition, meaning that when we install these
definitions they overwrite the existing ones, overriding a few specific entries
(which makes this a destructive operation; it's probably more sane to create a
new definition that inherits from the existing one and change the shell to
report that kind of terminal or something, but this is all still magic to me)
so it's a good idea to use `infocmp` to write out the existing definiton before
clobbering it just in case.

Once you're ready to go, use `tic screeninfo.terminfo` to install the update.
