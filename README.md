# ComputerCraft-Projects
[ComputerCraft](https://tweaked.cc/) is a Minecraft mod that uses Lua for scripting computers and robots ([turtles](https://tweaked.cc/module/turtle.html). This repository contains some work that I've done.

## Quick start
Start a computer and run `wget run https://raw.githubusercontent.com/asampley/ComputerCraft-Projects/master/bootstrap.lua https://raw.githubusercontent.com/asampley/ComputerCraft-Projects/master/`. This will run a bootstrap program that will download a library and executable for fetching programs and their dependencies called `werun`.

If you run `werun bin/routem` for example, it will download bin/routem from this repository (if it does not yet exist), as well as replace all calls of require, and loadfile with versions that also download form this repository (if they do not yet exist). To force re-downloading of all files for the program, use `werun --update bin/routem`.

# Development

## Tips

For single player worlds you can set infinite fule.

`%AppData%\.minecraft\saves\<world>\serverconfig\computercraft-server.toml`

```
[turtle]
	#Set whether Turtles require fuel to move.
	need_fuel = false
```

## Development (recommended) - linked file system to turtle

### 1. Create a computer or turtle
* In your minecraft world, create a computer or turtle, give it a name? `set name hiya`
* If you break and pick up your computer/turtle, in your inventory if you hover over the item you can check the the `ID: <number>`
* disconnect from the server

### 2. Create link between repo and computer/turtle
* clone the repo anywhere
* Windows
  * Navigate to `%AppData%\.minecraft\saves\<world>\computercraft\computer\`
  * Delete the folder that corresponds to `ID: <number>`
  * Open an administrator cmd prompt in the `computercraft\computer\` folder: `mklink /D "<ID number>" "<path to ComputerCraft-Projects repo>"`
* Now if you go into your computer/turtle and run `ls` you will see all the files (they are dynamically linked)

## Development (alternative) - local server

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

### 3. Bootstrap to your local server

`wget run http://127.0.0.1:5500/bootstrap.lua http://127.0.0.1:5500/`

With this, `werun` requests will all be sent to the 2nd url.
