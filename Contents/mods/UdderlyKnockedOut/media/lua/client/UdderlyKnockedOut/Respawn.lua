print("UKO: Initializing")
Respawn = {};

Respawn.Id = "respawn";
Respawn.Name = "I was only knocked out, I'm waking up now..";
Respawn.Message = ""

Respawn.Recoverables = {};

function Respawn.AddRecoverable(recoverable)
    table.insert(Respawn.Recoverables, recoverable);
end

Respawn.AddRecoverable(RecoverableBoosts);
Respawn.AddRecoverable(RecoverableLevels);
Respawn.AddRecoverable(RecoverableTraits);
Respawn.AddRecoverable(RecoverableRecipes);
Respawn.AddRecoverable(RecoverableOccupation);
Respawn.AddRecoverable(RecoverableWeight);