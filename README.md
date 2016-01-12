# Clusterator tools

Tools used to build and run Clusterator

## Hacking on the tools

This project uses a standard GNU Autotools build system.  'nough said.

### Bootstrapping the build

`cd` into the project root and run autoreconf and configure

    $ autoreconf --install
    $ ./configure --prefix=$PWD/build # prefix is optional

This will create auto generate all the scripts needed to configure the build.  The `--prefix` will cause all the Makefiles to use the specified *absolute* path for installation--handy for testing the build.

### Using the build

Once you have the build configured, run it is just the normal make stuff e.g.

    $ make
    $ make install

### Distribution

There are a number of ways to distribute projects using Autotools, it's one of the perks.  The easiest is using `dist`

    $ make dist

You should see some archives in the project root, usually a tarball and a zip.  This can be changed in `configure.ac`. Before you really release you should test the distribution.  Again, Autotools makes this really easy.

    $ make distcheck

This will ensure that your distribution passes all the standard checks.  For example, in this project Autotools is configured to ensure all executables provide `--help` and `--version`.

## Autotools to Docker

There are lots of ways to build a Docker image from an Autotools.  For convenience you can use the `distbin` script in this project

    $ distbin
    $ Docker build -t linode-advizex .

