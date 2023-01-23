--local utils = EngineCore.modules.utils
-- Private methods
local compress = true
local exDiv = 1--512--1-- 2^9
local maxConstantsInChunk = 65536/ exDiv
local write, writeIndent, writers, refCount, createStringChunk;

local persistence = {}

function string:cut(reference) --сокращенный вырезатель gsub
    return self:gsub(reference, "")
end;

local function GetTableLenght(t)
    local result = 0
    for _,_ in pairs(t) do
        result = result + 1 
    end;
    return result
end;


local function recursivelyDelete( item ) --вылет, если находишься в удаляемой папке во время удаления
    if love.filesystem.getInfo( item , "directory" ) then
        for _, child in ipairs( love.filesystem.getDirectoryItems( item )) do
            recursivelyDelete( item .. '/' .. child )
            love.filesystem.remove( item .. '/' .. child )
        end
    elseif love.filesystem.getInfo( item ) then
        love.filesystem.remove( item )
    end
    love.filesystem.remove( item )
end
    

local function createStringChunk()
    return setmetatable({}, {__call = function(self,str) table.insert(self,str) end;})
end;

local function createRefObjectsChunk(path,...)
    local refObjectsChunk = createStringChunk()
    local n = select("#", ...);
    local objRefCount = {}; 
    for i = 1, n do
        refCount(objRefCount, (select(i,...))); -- args from i to #...
    end;
    
    local objRefNames = {};
    local objRefIdx = 0;
    refObjectsChunk("local multiRefObjects = {\n")
    
     for obj, count in pairs(objRefCount) do
        if count > 1 then
            objRefIdx = objRefIdx + 1;
            objRefNames[obj] = objRefIdx;
            refObjectsChunk("{};")
        end;
    end;
    refObjectsChunk("\n} -- multiRefObjects\n")

    for obj, idx in pairs(objRefNames) do
        for k, v in pairs(obj) do 
            refObjectsChunk("multiRefObjects["..idx.."][")
            write(refObjectsChunk, k, 0, objRefNames);
            refObjectsChunk("] = ")
            write(refObjectsChunk, v, 0, objRefNames);
            refObjectsChunk(";\n")
        end;
    end;
    
    if n > 0 then
        refObjectsChunk("return multiRefObjects")
        for i = 2, n do
            refObjectsChunk(" ,obj"..i)
        end;
        refObjectsChunk("\n")
    else
        refObjectsChunk("return\n")

    end;

    local saveString = table.concat(refObjectsChunk)

    local compressedData = compress and love.data.compress( "string" , "gzip", saveString, 9 ) or saveString
    
    local info = love.filesystem.getInfo( path)
    if not info then  
        love.filesystem.createDirectory( "save" ) 
        love.filesystem.createDirectory( path )
    else
        local isSaveFolder = info.type == "directory"
      --  print(42,info.type)
        if not isSaveFolder then
            love.filesystem.createDirectory( path )
        end
    end;
    
    local file,e = love.filesystem.newFile( path.."/refObjects.lua","w" )
    file:write(compressedData)
    file:close();
    
    return objRefCount
end;

local function getChunkIdx(chunksCount,int)
    local numbersCount = #tostring(chunksCount)
    local result = string.format("%0"..tostring(numbersCount).."d", int)
    return result
end;

persistence.store = function (path, ...) --path as a string
    love.thread.getChannel( 'persistenceInfo' ):push( 0 )
    local path = path:cut(".lua")
    local refObjectsChunk = createStringChunk()
    local n = select("#", ...);
    local objRefCount = {}; 
    for i = 1, n do
        refCount(objRefCount, (select(i,...))); -- args from i to #...
    end; 
    local objRefNames = {};
    local objRefIdx = 0;
    refObjectsChunk("local multiRefObjects = {\n") 
     for obj, count in pairs(objRefCount) do
        if count > 1 then
            objRefIdx = objRefIdx + 1;
            objRefNames[obj] = objRefIdx;
            refObjectsChunk("{};")
        end;
    end;
    refObjectsChunk("\n} -- multiRefObjects\n")
    for obj, idx in pairs(objRefNames) do
        for k, v in pairs(obj) do 
            refObjectsChunk("multiRefObjects["..idx.."][")
            write(refObjectsChunk, k, 0, objRefNames);
            refObjectsChunk("] = ")
            write(refObjectsChunk, v, 0, objRefNames);
            refObjectsChunk(";\n")
        end;
    end; 
    if n > 0 then
        refObjectsChunk("return multiRefObjects")
        for i = 2, n do
            refObjectsChunk(" ,obj"..i)
        end;
        refObjectsChunk("\n")
    else
        refObjectsChunk("return\n")
    end;
    local saveString = table.concat(refObjectsChunk)

    local compressedData = compress and love.data.compress( "string" , "gzip", saveString, 9 ) or saveString
    
    local info = love.filesystem.getInfo( path)
    if not info then  
        love.filesystem.createDirectory( "save" ) 
    end;
    recursivelyDelete( path )
    love.filesystem.createDirectory( path )

    local file,e = love.filesystem.newFile( path.."/refObjects.lua","w" )
    file:write(compressedData)
    file:close();
    compressedData = nil

    local constantCount = GetTableLenght(objRefCount)
    local chunksCount = math.ceil( constantCount / maxConstantsInChunk )
    local constsInChunk = constantCount/chunksCount

    local rawTable = ...
    local splittedTable = {}
    
    for i = 1, chunksCount do
        splittedTable[i] = {}
    end;

    local constCounter = 0
    local splittedIdx = 1
    for key, object in pairs(rawTable) do
        local rc = {}
        refCount(rc, object); 
        local consts =  GetTableLenght(rc)
        constCounter = constCounter + consts
        
        if constCounter > maxConstantsInChunk then --начинаем новый чанк
            constCounter = 0
            splittedIdx = splittedIdx+1
        else -- продолжаем текущий чанк
            
        end;
        splittedTable[splittedIdx] = splittedTable[splittedIdx] or {}
        table.insert( splittedTable[splittedIdx],object)-- = object
    end;

    for i = 1, chunksCount do
        local dataChunk = createStringChunk()
        local n = select("#", ...)
        for j = 1, n do
            dataChunk("local ".."chunk"..j.." = function(multiRefObjects) \n local result = ")
            write(dataChunk, splittedTable[i], 0, objRefNames); --splittedTable[i]
            
            dataChunk(";\nreturn result;\n")
            dataChunk("end;\n")
        end
        
        if n > 0 then
            dataChunk("return chunk1(...)\n")
            for i = 2, n do
                dataChunk(" ,chunk"..i)
            end;
            dataChunk("\n")
        else
            dataChunk("return\n")
        end;

        local saveString = table.concat(dataChunk)
        local compressedData = compress and love.data.compress( "string" , "gzip", saveString, 9 ) or saveString
        
    
        local info = love.filesystem.getInfo( path)
        if not info then  
            love.filesystem.createDirectory( "save" ) 
            love.filesystem.createDirectory( path )
        else
            local isSaveFolder = info.type == "directory"
        --  print(42,info.type)
            if not isSaveFolder then
                love.filesystem.createDirectory( path )
            end
        end;

        local file,e = love.filesystem.newFile( path.."/".. getChunkIdx(chunksCount,i)..".lua","w" )
        file:write(compressedData)
        file:close();
        compressedData = nil
    end;
    
    collectgarbage()
    love.thread.getChannel( 'persistenceInfo' ):push( 100 )
   -- coroutine.yield(100,true)
end;

persistence.load = function (path)
   -- print("__________")
    local path = path:cut(".lua")
    local savedData = {}
    local compressedRefObjects = love.filesystem.read(path.."/refObjects.lua")
    if compressedRefObjects then
        local decompressedData = compress and love.data.decompress( "string","gzip" ,compressedRefObjects ) or compressedRefObjects
        local f,e = loadstring(decompressedData)
        savedData.refObjects  = f()
    else
        return nil, e;
    end;
    
    local chunks = love.filesystem.getDirectoryItems( path )
    local objectsCount = 0
    for i = 1,#chunks-1 do
        local compressedData = love.filesystem.read( path.."/"..chunks[i] )
        if compressedData then
            local decompressedData = compress and love.data.decompress( "string","gzip" ,compressedData ) or compressedData
            local f,e = loadstring(decompressedData)
            local chunk = f(savedData.refObjects)
            for j = 1,#chunk do
                local objIdx= j+(i-1)+objectsCount
                local object = chunk[j]
                savedData[objIdx] = object
            end
            objectsCount = objectsCount + (#chunk-1)
        else
            return nil, e;
        end;
    end;
    savedData.refObjects  = nil
    collectgarbage()
    return  savedData
end;

write = function (t, item, level, objRefNames)
	writers[type(item)](t, item, level, objRefNames);
end;

writeIndent = function (t, level)
	for i = 1, level do
        t("\t")
	end;
end;

-- recursively count references
refCount = function (objRefCount, item)
	-- only count reference types (tables)
	if type(item) == "table" then
		-- Increase ref count
		if objRefCount[item] then
			objRefCount[item] = objRefCount[item] + 1;
		else
			objRefCount[item] = 1;
			-- If first encounter, traverse
			for k, v in pairs(item) do
				refCount(objRefCount, k);
				refCount(objRefCount, v);
			end;
		end;
    
	end;
end;

-- Format items for the purpose of restoring
writers = {
	["nil"] = function (t, item)
        t("nil")
		end;
	["number"] = function (t, item)
            t(tostring(item))
		end;
	["string"] = function (t, item)
        t(string.format("%q", item))
		end;
	["boolean"] = function (t, item)
			if item then
                t("true")
			else
                t("false")
			end
		end;
	["table"] = function (t, item, level, objRefNames)
			local refIdx = objRefNames[item];
			if refIdx then
				-- Table with multiple references
                t("multiRefObjects["..refIdx.."]")
			else
				-- Single use table
                t("{\n")
				for k, v in pairs(item) do
                    writeIndent(t, level+1);
                    t("[")
                    write(t, k, level+1, objRefNames);
                    t("] = ")
                    write(t, v, level+1, objRefNames);
                    t(";\n")
				end
                writeIndent(t, level);
                t("}")
			end;
		end;
	["function"] = function (t, item)
			-- Does only work for "normal" functions, not those
			-- with upvalues or c functions
			local dInfo = debug.getinfo(item, "uS");
			if dInfo.nups > 0 then
                t("nil --[[functions with upvalue not supported]]")
			elseif dInfo.what ~= "Lua" then
                t("nil --[[non-lua function not supported]]")
			else
				local r, s = pcall(string.dump,item);
				if r then
                    t(string.format("loadstring(%q)", s))
				else
                    t("nil --[[function could not be dumped]]")
				end
			end
           -- return str
		end;
	["thread"] = function (t, item)
        t("nil --[[thread]]\n")
		end;
	["userdata"] = function (t, item)
        t("nil --[[userdata]]\n")
		end;
}
return persistence