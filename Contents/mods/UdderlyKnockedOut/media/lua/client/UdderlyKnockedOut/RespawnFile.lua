Respawn.SaveFile = "respawn_player_%s.json";

local json = require("json");

function Respawn.SaveRecoverables()
    local path = Respawn.GetSaveName();
    local file = getFileWriter(path, true, false);

    local save = {};
    for i, recoverable in ipairs(Respawn.Recoverables) do
        save[recoverable.Type] = recoverable.Content;
    end
    
    file:write(json.stringify(save, false));
    file:close();
end

function Respawn.LoadRecoverables()
    local path = Respawn.GetSaveName();
    local file = getFileReader(path, false);

    if file == nil then
        return false;
    end

    local line = file:readLine();
    
    if line == nil or line == "" then
        return false;
    end

    local success, save = pcall(json.parse, line);

    if not success then
        return false;
    end

    for i, recoverable in ipairs(Respawn.Recoverables) do
        recoverable.Content = save[recoverable.Type];
    end

    return true;
end

function Respawn.GetSaveName()
    local world = getWorld():getWorld();

    if world == nil or world == "" then
        return nil;
    end

    return string.format(Respawn.SaveFile, world);
end