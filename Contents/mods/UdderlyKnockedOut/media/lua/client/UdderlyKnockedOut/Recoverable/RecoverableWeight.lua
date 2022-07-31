RecoverableWeight = Recoverable:Derive("Weight");

function RecoverableWeight:Update(player)
    self.Content = player:getNutrition():getWeight();
end

function RecoverableWeight:Recover(player)
    player:getNutrition():setWeight(self.Content);
end