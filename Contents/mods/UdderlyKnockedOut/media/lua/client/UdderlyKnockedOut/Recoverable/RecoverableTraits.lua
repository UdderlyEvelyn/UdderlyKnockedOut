RecoverableTraits = Recoverable:Derive("Traits");

function RecoverableTraits:Update(player)
    self.Content = {};
    local traits = player:getTraits();

    for i = 0, traits:size() - 1 do
        table.insert(self.Content, traits:get(i));
    end
end

function RecoverableTraits:Recover(player)
    player:getTraits():clear();

    for i, trait in ipairs(self.Content) do
        player:getTraits():add(trait);
    end
end