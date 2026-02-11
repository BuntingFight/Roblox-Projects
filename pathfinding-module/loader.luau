local pathfind_module = loadstring(game:HttpGet("https://raw.githubusercontent.com/BuntingFight/Roblox-Projects/refs/heads/main/pathfinding-module/script.luau"))()()

local MODEL_ = pathfind_module.MODEL_
local PART_ = pathfind_module.PART_

getgenv().pathfind_ignore = {}

pathfind_module.pathfind(Vector3.new(), getgenv().pathfind_ignore)

--[[

Example macros usage for ignore list:

Ignore list - these are the objects that are ignored by the code; it will not search for bypasses through them

Macros "MODEL_":

1. ignore all models in the workspace

getgenv().pathfind_ignore = {
    MODEL_(),
}

2. ignore a specific model

getgenv().pathfind_ignore = {
    MODEL_(workspace.model_here),
}

3. ignore multiple specific models

getgenv().pathfind_ignore = {
    MODEL_(workspace.Model1),
    MODEL_(workspace.Model2),
    MODEL_(workspace.Model3),
}

4. ignore model inside folder

getgenv().pathfind_ignore = {
    MODEL_(workspace.YOUR_FOLDER_HERE.Model),
}

Macros "PART_":

1. ignore a specific part

getgenv().pathfind_ignore = {
    PART_(workspace.Part),
}

2. ignore all parts with a specific name

getgenv().pathfind_ignore = {
    PART_()("Part"),
}

3. ignore multiple parts types by name

getgenv().pathfind_ignore = {
    PART_()("Part1"),
    PART_()("Part2"),
    PART_()("Part3"),
}

4. ignore specific parts

getgenv().pathfind_ignore = {
    PART_(workspace.Part1),
    PART_(workspace.Folder.Part2),
    PART_(workspace.Model.MainPart),
}

COMBINED EXAMPLES:

1. ignore all models + parts with specific name

getgenv().pathfind_ignore = {
    MODEL_(),
    PART_()("Door"),
}

2. ignore a specific model + a specific part

getgenv().pathfind_ignore = {
    MODEL_(workspace.Model),
    PART_(workspace.Part),
}

3. ignore all models + several types of parts

getgenv().pathfind_ignore = {
    MODEL_(),
    PART_()("Part1"),
    PART_()("Part2"),
    PART_()("Part3"),
}

To remove a specific object, simply delete the line
If you don't want to use the ignore list, just leave it blank: {}

To add something to it, add it as it corresponds to the example, 
the main thing is to change the names to your own (except for workspace), 
otherwise nothing will work for you

]]
