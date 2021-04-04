# cc-quarry

A Quarry script for Computer Craft Turtles. Minecraft :shrug:

## Installer

([Link](https://pastebin.com/HUDjPice) if you'd like to read it yourself. This file is checked into this repo as well under `cc-setup.lua`)

```
pastebin get HUDjPice cc-setup
```

The `cc-setup` script will then let you either fetch the latest revision, or if you are developing, a specific branch name. Syntax:

```
cc-setup [<branchName> = main]
```

By running this, you'll download the dependencies of `cc-quarry` as well as install the script `ccq`. This script is your entry point.

## Running

Use the `ccq` command. This will print it's usage if you don't know off the top of your head.

## Dependencies

This library utilizes [rxi/json.lua](https://github.com/rxi/json.lua) for updating (`cc-setup`)