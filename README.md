# ComputerCraft-Projects
ComputerCraft is a Minecraft mod that uses Lua for scripting computers and robots/[turtles](https://www.computercraft.info/wiki/Turtle) ([API](https://www.computercraft.info/wiki/Turtle_(API))). This repository contains some work that I've done.

## Quick start
Start a computer and run `wget run https://raw.githubusercontent.com/asampley/ComputerCraft-Projects/master/bootstrap.lua https://raw.githubusercontent.com/asampley/ComputerCraft-Projects/master/`. This will run a bootstrap program that will download a library and executable for fetching programs and their dependencies called `wequire`.

If you run `wequire bin/routem` for example, it will download bin/routem from this repository (if it does not yet exist), as well as replace all calls of require, adn loadfile with versions that also download form this repository (if they do not yet exist). The caveat is it will not attempt to download all files, just ones pulled in with those functions. Configuration files may be missing.

## Development

### 1. Start a local server
Any way you want to do it is fine.

(VS Code has an extension "Live Server" you can use to get one going quickly.  Just install, and then in the bottom right, click "Go Live".)

### 2. Modify your Minecraft world config

We need to enable the turtle's access to localhost...

If it is a single player world: `%AppData%\.minecraft\saves\<world>\serverconfig\computercraft-server.toml`

Change `deny` to `allow` in
```
[[http.rules]]
    host = "$private"
    action = "deny"
```

Bonus settings while we are here:
```
[turtle]
	#Set whether Turtles require fuel to move.
	need_fuel = false
```

### 3. Bootstrap to your local server

`wget run http://127.0.0.1:5500/bootstrap.lua http://127.0.0.1:5500/`

With this, wequire requests will be routed to the 2nd url.
