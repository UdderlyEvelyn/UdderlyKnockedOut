Recoverable = {};

Recoverable.Type = "Recoverable";
Recoverable.Content = {};

function Recoverable:Update(player)
    error("Not implemented");
end

function Recoverable:Recover(player)
    error("Not implemented");
end

function Recoverable:Derive(type)
    local obj = {};
    
    setmetatable({}, self);
    self.__index = self;

    obj.Type = type;
    return obj;
end