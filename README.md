# sh-manpage-completions

Automatically generate bash and zsh completions from man pages.

Uses [fish-shell](https://github.com/fish-shell/fish-shell)'s `create_manpage_completions.py` to parse the pages, then converts the resulting fish completions.

## Example

```
./run.sh /usr/share/man/man1/tar.1.gz
```

You can then take the files from `completions/$shell/` and use them according to your configuration:

- **Bash**: Source them in an initialization file (e.g. `~/.bashrc`)
- **Zsh**: Add them to a directory in `$fpath`

## Limitations

Bash doesn't support descriptions in completions. There has been some [discussion about workarounds](https://stackoverflow.com/questions/7267185/bash-autocompletion-add-description-for-possible-completions). The strategy that was followed consists on printing the completions with descriptions, before bash displays the completions again. It results in redundancy but doesn't break tab behaviour. Descriptions can be omitted like so:

```
BASH_NO_DESCRIPTIONS=1 ./run.sh /usr/share/man/man1/tar.1.gz
```

## License

Files in `fish-tools` were taken from fish-shell's source code, which is released under the GNU General Public License, version 2 (see LICENSE.GPL2).

The remaining source code is released under the MIT License (see LICENSE.MIT).
