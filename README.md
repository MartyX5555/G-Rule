# What's this
The Measurer, rule or simply GRule is a specialized, high grade, measuring tool, with different modes and units to use by the user.

This was done as goal to *actually get a proper rule tool* that can measure in both playerscale and mapscale and not *faking the units massively* as some tools do, besides, considering the point of making the task less tedious.
# Features

This tool, apart of obviously getting the distance between 2 points, also provides:
- A **very ultra wide** list of units to convert from (Want astronomical units or Terameters? go ahead).
- A correct mapscale-playerscale conversion (1 unit = 0.75 inch / 1 unit = 1 inch respectively).
- Different modes for different tasks. Get thickness of a wall or the space between 2 walls in 1-2 clicks. No more tricks.
- InfMap Support. The renders won't break beyond the initial chunk. Feel free to measure and render astronomical units if you want.

# Installation

If you are a normal user and want to use this tool, i recommend you grab this tool on the [Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3335380314&searchtext=) 

However, if you want to use the tool and also contribute, you can either clone this repository or directly download the ZIP (green button) and extract it into addons folder (likely to be located at garrysmod/addons).

# Notes

- When getting distances too large, make sure to increase the decimal count to avoid misconceptions of the values (1 Megameter is 1000 km, but rounding it to 0 decimals means 0.5 Mm becomes 1 Mm)
- In InfMap, certain trace-based modes wont work beyond the chunk where it was performed. If you want to get distance across many chunks, use the Entity to Entity or basic modes.
- The traces can add until 0.625 due to how they work currently, meaning that measures can be *slightly* higher than the real one.
