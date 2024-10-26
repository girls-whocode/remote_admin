# ARROW v(2.0)
## File Structure

The main opening file is located in the root of the application's directory structure called 'arrow.sh'. Upon opening this file, a few beginning tasks start.

1. Check for existence of an already running arrow.sh file.
2. Gather default variables.
3. Test for the existing directory structure in Arrow's _self path. If the directories do not exists create them.
4. Check if the daily log file for Arrow has been created, if not, then create it.
5. Open the {arrow_home}/bin folder and source all files that start with ra_.
6. Open the {arrow_hone}/mods folder and source all files that start with ramod_.

Once all of the files have been sourced, functions will be available throughout the rest of the code.

Read more about each file in the Bin and Mod Files Documents.
