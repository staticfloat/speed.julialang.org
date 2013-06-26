This repository contains all configuration and code needed to run a [codespeed](https://github.com/tobami/codespeed/) server for the [Julia project](http://julialang.org)

The `etc/` directory contains configuration files for an ubuntu-based system to run an nginx server connected to a uwsgi process and django installation to listen to travis hooks and serve codespeed pages, respectively

The `www/` directory contains the web code.
`www/codespeed` is a git checkout of the codespeed install, and contains all the files needed to run the codespeed frontend on nginx
`www/posthook.py` is a python uwsgi application that is invoked by nginx to kick off compilation and testing of a new julia commit.  Note that this code can be placed on multiple computers, and if they are properly configured with regards to the location of the codespeed server, they can all report independently

The `recipes/` directory contains the recipes detailing how to build different julia executables
Note that each recipe must start with the `build_` prefix, and the suffix must be a valid directory name

The `benchmarks/` directory contains the suite of julia tests to run.  Each file should contain a function, `runTest()` that returns an array of tests with their resultant metric.
