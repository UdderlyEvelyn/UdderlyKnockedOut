function Respawn.UpdatePlayer(player)
    for i, recoverable in ipairs(Respawn.Recoverables) do
        recoverable:Update(player);
    end

    Respawn.SaveRecoverables();
    print("UKO: Character data saved.")
end

Events.OnPlayerDeath.Add(Respawn.UpdatePlayer);