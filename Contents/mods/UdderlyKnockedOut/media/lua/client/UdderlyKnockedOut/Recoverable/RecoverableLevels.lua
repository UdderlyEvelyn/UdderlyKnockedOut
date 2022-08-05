RecoverableLevels = Recoverable:Derive("Levels");

function RecoverableLevels:Update(player)
    self.Content = {};

    local perks = PerkFactory.PerkList;

    for i = 0, perks:size() - 1 do
        local perk = perks:get(i)
	local level =  player:getPerkLevel(perk)
	if level < 10 then		
		local totalXpForLevel = perk:getTotalXpForLevel(level)
		local xpForPerk = player:getXp():getXP(perk)
		local xpForNextLevel = perk:getTotalXpForLevel(level + 1) - totalXpForLevel
		local currentXP = xpForPerk - totalXpForLevel --xp for level minus current xp to get any overflow to store
		level = 0.0 + level + currentXP / xpForNextLevel --level with fraction based on xp over the minimum
		--print("UKO: For \""..perk:getName()..": Level "..player:getPerkLevel(perk)..", Total XP For Level: "..totalXpForLevel..", XP For Perk: "..xpForPerk..", XP For Next Level: "..xpForNextLevel..", Current XP: "..currentXP..", Progress "..currentXP.."/"..xpForNextLevel.." ("..(currentXP/xpForNextLevel * 100).."%), Storing "..level)
	else
		--print("UKO: For \""..perk:getName()..": Level "..level..", No Progress (0%), Storing "..level)
	end
        self.Content[perk:getName()] = level
    end
end

local function split(s, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(s, "([^"..sep.."]+)") do
       table.insert(t, str)
    end
    return t
end

local function getDataForSkill(skillConfig, skill)
	for i,config in ipairs(skillConfig) do
		if config[1] == skill then
			return { config[2], config[3] }
		end
	end
	return { nil, nil }
end
	
local function random(pctChanceInteger)
	local input = 0.0 + pctChanceInteger
	--print ("UKO: Random For "..tostring(input))
	local rand = 1.0 + ZombRand(100) + (ZombRand(1000) / 1000)
	--print("UKO: Rolled "..tostring(rand))
	return rand <= input
end

local function randomDecimal(max)
	local input = 0.0 + max
	--print ("UKO: Random Decimal For "..tostring(input))
	local rand = ZombRand(max) + (ZombRand(1000) / 1000)
	--print ("UKO: Rolled "..tostring(rand))
	return rand
end

function RecoverableLevels:Recover(player)
    local skillConfiguration = SandboxVars.UdderlyKnockedOut.SkillConfiguration or "Carpentry;Electrical;Metalworking;Mechanics;Cooking=40:15;Farming=40:15;First Aid=40:15;Tailoring=40:15;Fishing=40:15;Trapping=40:15;Foraging=40:15;Maintenance=20:10;Aiming=20:10;Reloading=20:10;Sprinting=20:10;Sneaking=20:10;Lightfooted=20:10;Nimble=20:10;Axe=40:15;Long Blunt=40:15;Short Blunt=40:15;Long Blade=40:15;Short Blade=40:15;Spear=40:15;Strength=20:10;Fitness=20:10"
    local skillConfig = {}
    for i,item in ipairs(split(skillConfiguration, ";")) do
	if string.find(item, "=") then --if it has config data, parse and use it
		local pair = split(item, "=")
		local subPair = split(pair[2], ":")
		skillConfig[i] = { pair[1], subPair[1], subPair[2] }
		--print("UKO: Config data found for \""..pair[1].."\", \""..tostring(subPair[1])..", "..tostring(subPair[2]))
	else --it has no config data but is present, so use the global defaults
		skillConfig[i] = { item, SandboxVars.UdderlyKnockedOut.ChanceToLose or 60, SandboxVars.UdderlyKnockedOut.MaxLossPercentage or 30 }
		--print("UKO: Config data missing for \""..item.."\", using defaults: \""..tostring(SandboxVars.UdderlyKnockedOut.ChanceToLose).."\", \""..tostring(SandboxVars.UdderlyKnockedOut.MaxLossPercentage).."\"")
	end
    end
    local affectedPerks = ""
    --print("UKO: Looping through skills..")
    for perkName, targetLevel in pairs(self.Content) do
	--print("UKO: For "..perkName..", at "..targetLevel.."..")
        local perk = PerkFactory.getPerkFromName(perkName);
	
	local config = getDataForSkill(skillConfig, perkName)
	local hasConfig = config ~= nil and config[1] ~= nil and config[2] ~= nil
	local chanceToLose = 0
	local maxToLose = 0
	if hasConfig then
		chanceToLose = config[1]
		maxToLose = config[2]
	end
	
	--print("UKO: Has Config: "..tostring(hasConfig)..", Chance To Lose: "..tostring(chanceToLose)..", Max To Lose: "..tostring(maxToLose))
	
	if hasConfig then
		local oldTargetLevel = 0.0 + targetLevel
		if chanceToLose ~= 0 and random(chanceToLose) then --we rolled to lose something
			--randomly modify targetLevel up to configured amount for this skill
			targetLevel = 0.0 + targetLevel - ((randomDecimal(maxToLose / 10)) / 10 * targetLevel)
			if targetLevel == oldTargetLevel and oldTargetLevel ~= 0 then --if we somehow rolled no change, not even a fractional loss, and we're not at zero..
				targetLevel = targetLevel - randomDecimal(1) --you're not getting away that easily..
			end
			--print("UKO: Randomized loss has left the new target at "..targetLevel)
			if (oldTargetLevel - targetLevel > 0) then
				if affectedPerks ~= "" then
					affectedPerks = affectedPerks..", "
				end
				affectedPerks = affectedPerks..perkName
			end
		--elseif chanceToLose == 0 then
		--	print("UKO: Skill configured to zero chance, so we don't affect it..")
		--else
		--	print("UKO: Got lucky, rolled to not affect this skill.")
		end
	else
		print("UKO: Skipped unconfigured skill \""..perkName.."\".")
	end
	
	local flooredTargetLevel = 0.0 + math.floor(targetLevel)
	local targetLevelFraction = targetLevel - flooredTargetLevel
	
        while player:getPerkLevel(perk) < flooredTargetLevel do
            player:LevelPerk(perk, false);
        end

        while player:getPerkLevel(perk) > flooredTargetLevel do
            player:LoseLevel(perk);
        end

        local xp = player:getXp()
	xp:setXPToLevel(perk, flooredTargetLevel);
	local nextLevel = flooredTargetLevel + 1
	if nextLevel ~= 11 then
		local xpForLevel = 0.0 + perk:getXpForLevel(nextLevel)
		xp:AddXP(perk, xpForLevel * targetLevelFraction)
	end
	--print("UKO: Done with "..perkName)
    end
    --print("UKO: Done looping through skills.")
    if affectedPerks ~= "" then
        Respawn.Message = "I feel like that knock on the head made me forget something about "..affectedPerks
    else
	Respawn.Message = "I'm lucky I don't have memory loss from that bonk to the skull.."
    end
    --print ("UKO: Set Respawn.Message to \""..Respawn.Message.."\".")
end