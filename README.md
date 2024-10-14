# perl cpan index legacy

This repository contains CPAN index files for old perls.

For some reasons, you might have to use old perls, such as v5.8 or v5.10.
Then you'll have difficulty installing CPAN modules because a lot of CPAN modules requires a more recent perl.

In cases like this, the index files in this repository might help.

# Usage

Let's say you use perl v5.10.1, and want to install Plack. Plack now requires perl v5.12, so it cannot be install as is:

```
❯ perl -v
This is perl, v5.10.1 (*) built for darwin-2level

❯ cpm install Plack
...
FAIL install Plack-1.0051
```

However, if you specify the index file [5.10.1.txt](5.10.1.txt), you should be able to install Plack on perl 5.10.1:

```
❯ cpm install --resolver 02packages,https://raw.githubusercontent.com/skaji/perl-cpan-index-legacy/main/5.10.1.txt,https://cpan.metacpan.org Plack
...
DONE install Plack-1.0050
53 distributions installed.
```

# See also

https://www.nntp.perl.org/group/perl.perl5.porters/2023/04/msg266308.html
