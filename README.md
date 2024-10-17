<!--
SPDX-FileCopyrightText: © 2024 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
SPDX-License-Identifier: GFDL-1.3-or-later
-->

# Guix-Formal-Verification

This is a GNU Guix dedicated to provide package definitions related to formal
methods.

Ideally these packages should be in GNU Guix distribution but are here for
now until they are ready to be submitted.  If you see a package here and
want to see it in GNU Guix officially you are encouraged to send patches
there from the code here as the license of this channel is
`GPL-3.0-or-later`.

**Warning:** this channel depends on [Nonguix] for some non-free software
such as CompCert, please check carefully the licenses of the packages you
are using.

Right now there are no public substitutes for this channel, though, I have
a private Cuirass instance for continuous integration but doesn't have
enough resources for public substitutes.

Some packages can take _hours_ to build on _slow_ machines, and may even run
out of memory.  It is recommended to have at least 8 GiB of RAM, although
4 GiB could work if using only a single core to build.

## Categories

This channel has categories for the packages:

- [formal-verification/packages](./formal-verification/packages): Packages
that are fully free (as in freedom) and could be submitted to GNU Guix
upstream if there's a need.

- [formal-verification/nonfree](./formal-verification/nonfree): Equivalent of
[Nonguix] of this channel, be wary of using these packages, some may forbid
commercial usage, check each license specifically.

- [formal-verification/tainted](./formal-verification/tainted): Packages that
have a free (as in freedom) license but depend on nonfree packages.

- [formal-verification/unbootstrappable](./formal-verification/unbootstrappable):
Packages that can't (yet) be compiled from source code due to dependencies or
the package itself being unbootstrappable.  These packages can't be submitted
to GNU Guix unless the bootstrapping issue is solved.

For more information, see: [bootstrappable.org].

[bootstrappable.org]: https://bootstrappable.org/
[Nonguix]: https://gitlab.com/nonguix/nonguix/ 

# License

The license of this channel is `GPL-3.0-or-later` and follows the [REUSE]
copyright notice standard, check each file individually or with the
`reuse` tool.

Each package contains its own license.

[REUSE]: https://reuse.software/
