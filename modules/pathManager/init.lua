local pathManager= {}

pathManager.rootPath = ""
pathManager.projectPath = "projects/first/"
pathManager.GetProjectPath = function()
    return pathManager.projectPath
end;


return pathManager