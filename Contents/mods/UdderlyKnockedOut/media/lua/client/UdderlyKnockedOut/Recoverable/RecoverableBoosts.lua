RecoverableBoosts = Recoverable:Derive("Boosts");

function RecoverableBoosts:Update(player)
    self.Content = {};

    local perks = PerkFactory.PerkList;
    local xp = player:getXp();

    for i = 0, perks:size() - 1 do
        local perk = perks:get(i);
        local boost = xp:getPerkBoost(perk);

        if boost > 0 then
            self.Content[perk:getName()] = boost;
        end
    end
end

function RecoverableBoosts:Recover(player)
    local prof = ProfessionFactory.getProfession(Respawn.Id);

    for perkName, boost in pairs(self.Content) do
        prof:addXPBoost(PerkFactory.getPerkFromName(perkName), boost);
    end

    player:getDescriptor():setProfessionSkills(prof);
end