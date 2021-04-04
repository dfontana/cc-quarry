# cc-quarry

A Quarry script for Computer Craft Turtles. Minecraft :shrug:

## Installer

([Link](https://pastebin.com/HUDjPice) if you'd like to read it yourself. This file is checked into this repo as well under `cc-setup.lua`)

```
pastebin get HUDjPice ccs
```

The `ccs` script will then let you either fetch the full source code straight from the [Github Gist](https://gist.github.com/dfontana/d72ae5868a87adeb6345dbe6f041138d). By running this, you'll download the dependencies of `cc-quarry` as well as install the script `ccq`. This script is your entry point.

## Running

Use the `ccq` command. This will print it's usage if you don't know off the top of your head.

## Development And Dependencies

This library utilizes [rxi/json.lua](https://github.com/rxi/json.lua) for updating (`cc-setup`) from the Gist. A Gist is used because:

- Fetching from the repository has a 5 minute cache time, making developing extremely burdensome
- The GitHub gist API let's us publish straight to the gist.
- The only downside is that only the owner of the gist can edit it, since the api key is local to them (stored in a `.gh-secret` file).

This method does, however, enable us to quickly iterate on the gist by just calling the `./deploy.sh` script at the root of this repo.

__Working Around This Limitation__

To solve for this problem, the `deploy.sh` and `ccs` scripts are parameterized to take a different Gist ID. As long as you define a gist with the expected filenames already present, you can utilize your own api key (in `.gh-secret`) and call `deploy.sh` and `ccs` with this GistId instead.
