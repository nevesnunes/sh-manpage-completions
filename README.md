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

## License

Files in `fish-tools` were taken from fish-shell's source code, which is released under the GNU General Public License, version 2 (see LICENSE.GPL2).

The remaining source code is released under the MIT License (see LICENSE.MIT).
