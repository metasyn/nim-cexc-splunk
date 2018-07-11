# nim-cexc
This repo contains an implementation of a custom search command for [Splunk](https://www.splunk.com) Enterprise. It is written in [Nim](https://www.nim-lang.org) - an efficient and expressive programming language. It is a statically typed language, and compiled. See [this page](https://nim-lang.org/features.html) to learn more about why Nim is great.

# Using
See src/cexc/handler for the basis of a new search command. Namely, you'll need to override the various handler methods, e.g. what to do during getinfo exchange, and what to do during the execute chunks. The foo example included with this repo simply reflects the input data back to original process.

See the super simple `build.sh` script to build your application - you'll need to change some file names in app.conf and commands.conf appropriately if you change the names of the files. After that, you can tar ball your app folder andinstall it as a Splunk app. Remember that since Nim is a compiled language, it will only work on the architecture that you compiled the command on - see [this page](https://nim-lang.org/docs/nimc.html#cross-compilation) for information on cross compiling for other architectures.

# CEXC - Chunked EXternal Command
See [this presentation](https://conf.splunk.com/files/2016/slides/extending-spl-with-custom-search-commands-and-the-splunk-sdk-for-python.pdf) for more information on the chunked protocol and custom search commands.

# License
Apache2

# Authors
Xander Johnson