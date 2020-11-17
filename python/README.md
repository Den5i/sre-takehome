For the Timer-o-botic API application decided to use a Flask framework. Flask aims to keep the core simple but extensible. It is a web framework.
For building and running the application I've used the Pants build system - designed to support monorepo structure with multiple languages. It has the abilities of remote caching, incremental builds and dependency resolution. For more info https://www.pantsbuild.org/

To use Pants build system, run:
`curl -L -O https://pantsbuild.github.io/setup/pants && chmod +x pants`

To run the application on localhost:
`./pants run src/python/timer-o-botic`

To build a pex binary file (python executable) run:
`./pants package src/python/timer-o-botic`

This will create a file dist/timer-o-botic.pex with all the dependencies.
The binary can then be easily moved into a container and deployed elsewhere.
Build system also supports testing and other interesting features.
