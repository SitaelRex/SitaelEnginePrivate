local pathManager= {}

pathManager.rootPath = ""
pathManager.projectPath = "projects/first/"
pathManager.GetProjectPath = function()
    return pathManager.projectPath
end;

pathManager.SetProject = function(projectName)
    pathManager.projectPath = "projects/"..projectName.."/"
end;


return pathManager