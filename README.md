# ComputerCraft-Projects
ComputerCraft is a Minecraft mod that uses Lua for scripting computers and robots (turtles). This repository contains some work that I've done.

## Quick start
Start a computer and run `wget run https://raw.githubusercontent.com/asampley/ComputerCraft-Projects/master/bootstrap.lua`. This will run a bootstrap program that will download a library and executable for fetching programs and their dependencies called `wequire`.

If you run `wequire bin/routem` for example, it will download bin/routem from this repository (if it does not yet exist), as well as replace all calls of require, loadfile, and os.run with versions that also download form this repository (if they do not yet exist). The caveat is it will not attempt to download all files, just ones pulled in with those functions. Configuration files may be missing.
