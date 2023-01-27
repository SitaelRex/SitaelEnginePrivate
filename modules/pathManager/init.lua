local pathManager= {}

pathManager.rootPath = ""
pathManager.projectName = "aa"
pathManager.projectPath = "projects"


pathManager.GetProjectPath = function()
    local result = pathManager.projectPath.."/"..pathManager.projectName .. "/" 
    return result
end;

pathManager.GetProjectName = function()
    local result = pathManager.projectName 
    print(69,result)
    return result
end;

pathManager.SetProject = function(projectName)
  --  print(33,projectName)
 --   print(11,pathManager)
    pathManager.projectName = projectName
  --  pathManager.projectPath = "projects/"..projectName.."/"
end;


return pathManager