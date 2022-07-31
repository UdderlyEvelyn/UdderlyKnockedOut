RecoverableRecipes = Recoverable:Derive("Recipies");

function RecoverableRecipes:Update(player)
    self.Content = {};
    local recipes = player:getKnownRecipes();

    for i = 0, recipes:size() - 1 do
        table.insert(self.Content, recipes:get(i));
    end
end

function RecoverableRecipes:Recover(player)
    local recipes = player:getKnownRecipes();

    for i, recipe in ipairs(self.Content) do
        recipes:add(recipe);
    end
end