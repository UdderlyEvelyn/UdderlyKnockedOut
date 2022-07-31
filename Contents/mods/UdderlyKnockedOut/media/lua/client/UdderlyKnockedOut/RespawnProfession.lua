local Original_SetVisible = CharacterCreationProfession.setVisible;

function CharacterCreationProfession:setVisible(visible, joypadData)
    Original_SetVisible(self, visible, joypadData);

    if not visible or not Respawn.RespawnAvailable() or Respawn.CreatedRespawnProfession()  then
        return;
    end
    
    local prof = Respawn.CreateRespawnProfession();

    self.listboxProf:insertItem(0, 0, prof);
    self:onSelectProf(prof);
end

function Respawn.RespawnAvailable()
    return Respawn.LoadRecoverables();
end

function Respawn.CreatedRespawnProfession()
    local profs = ProfessionFactory.getProfessions();

    for i = 0, profs:size() - 1 do
        if profs:get(i):getType() == Respawn.Id then
            return true;
        end
    end

    return false;
end

function Respawn.CreateRespawnProfession()
    local prof = ProfessionFactory.addProfession(Respawn.Id, Respawn.Name, "knockedOutStars", 0);
    
    Respawn.CreateRespawnTrait();
    prof:addFreeTrait(Respawn.Id);

    return prof;
end

function Respawn.CreateRespawnTrait()
    TraitFactory.addTrait(Respawn.Id, Respawn.Name, 0, "Reject zombiehood", true, false);

    local traits = TraitFactory.getTraits();
    for i = 0, traits:size() - 1 do
        TraitFactory.setMutualExclusive(Respawn.Id, traits:get(i):getType());
    end
end

function CharacterCreationProfession:resetBuild()
    local index = 1;

    while self.listboxProf.items[index].item:getType() ~= "unemployed" do
        index = index + 1;
    end

    self.listboxProf.selected = index;
    self:onSelectProf(self.listboxProf.items[self.listboxProf.selected].item);

    while #self.listboxTraitSelected.items > 0 do
        self.listboxTraitSelected.selected = 1;
        self:onOptionMouseDown(self.removeTraitBtn);
    end
end