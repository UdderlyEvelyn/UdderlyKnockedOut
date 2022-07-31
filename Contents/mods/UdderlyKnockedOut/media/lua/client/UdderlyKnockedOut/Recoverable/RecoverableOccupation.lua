RecoverableOccupation = Recoverable:Derive("Occupation");

function RecoverableOccupation:Update(player)
    self.Content = player:getDescriptor():getProfession();
end

function RecoverableOccupation:Recover(player)
    player:getDescriptor():setProfession(self.Content);
end