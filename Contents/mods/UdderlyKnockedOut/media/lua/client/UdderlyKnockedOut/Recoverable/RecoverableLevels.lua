RecoverableLevels = Recoverable:Derive("Levels");

function RecoverableLevels:Update(player)
    self.Content = {};

    local perks = PerkFactory.PerkList;

    for i = 0, perks:size() - 1 do
        local perk = perks:get(i);
        local level = player:getPerkLevel(perk);

        self.Content[perk:getName()] = level;
    end
end

function RecoverableLevels:Recover(player)
    local affectedPerks = ""
    print("UKO: Looping through skills..")
    for perkName, targetLevel in pairs(self.Content) do
	print("UKO: For "..perkName..", at "..targetLevel.."..")
        local perk = PerkFactory.getPerkFromName(perkName);
	
	if perkName ~= "Fitness" and perkName ~= "Strength" then
		local oldTargetLevel = targetLevel
		--randomly modify targetLevel up to MaxLossPercentage sandbox option
		targetLevel = math.ceil(targetLevel - (ZombRand((SandboxVars.UdderlyKnockedOut.MaxLossPercentage or 30) / 10 + 1) / 10 * targetLevel))
		--math.ceil added to prevent partial levels which are ignored, should turn them into XP in the future instead..
		print("UKO: Randomized loss has left the new target at "..targetLevel)
		if (oldTargetLevel - targetLevel > 0) then
			if affectedPerks ~= "" then
				affectedPerks = affectedPerks..", "
			end
			affectedPerks = affectedPerks..perkName
		end		
	else
		print("UKO: Skipped blacklisted skill \""..perkName.."\".")
	end
	
        while player:getPerkLevel(perk) < targetLevel do
            player:LevelPerk(perk, false);
        end

        while player:getPerkLevel(perk) > targetLevel do
            player:LoseLevel(perk);
        end

        player:getXp():setXPToLevel(perk, targetLevel);
	print("UKO: Done with "..perkName)
    end
    print("UKO: Done looping through skills.")
    if affectedPerks ~= "" then
        Respawn.Message = "I feel like that knock on the head made me forget something about "..affectedPerks
    else
	Respawn.Message = "I'm lucky I don't have memory loss from that bonk to the skull.."
    end
    print ("UKO: Set Respawn.Message to \""..Respawn.Message.."\".")
end