// Script that handles everything that happens during the rounds.

printl("roundManager init")

// functions

mercy <- 0 // used by Waterworks director to judge if it should give the players downtime.
SP <- 0 // Director's "special points", goes up by 1 every wave (multiplied by total anger) to summon a 'super special wave' (Double or nothing & dog round, for example) / Generally unused now.
dogStage <- 0 // Used to determine the Dog's 'pack status' (how many spawn during the regular waves / intervals)
shipStage <- 3 // Used to determine Ship's 'aggressiveness' with spawns / artillery.
OLTActive <- false // Temporarily activate One Last Thrill's extra damage
markVictim <- null // Mark player to recieve extra damage while OLT persists.

function givePlayerItem(x, item)
{
    // Use a delay to make this work (I think)
    // Can't just give an item a second after deleting it because fuck you
    x = x.tointeger()
    local player = GetPlayerFromUserID(x)
    player.GiveItem(item)
}

function shipArtillery() // Fired off by timer entity using the same name every 15~45 seconds
{
    // Stage-based artillery calling. Happens independently from wave and is reliant on stage.
    // pick random spawn(s) based on shipStage.
    local i = 0 // Iterator
    local shells = ["fireArtillerySpawn", "fireArtillerySpawn2", "fireArtillerySpawn3", "fireArtillerySpawn4", "fireArtillerySpawn5", "fireArtillerySpawn6", "fireArtillerySpawn7" ] // teleport destination entities - spawnpoints for fire
    local shell = null
    local potential = null
    local validTargets = []
    local roll = 0

    while (i <= shipStage)
    {
        potential = shells[RandomInt(0, shells.len() - 1)]

        if (validTargets.find(potential) >= 0)
        {
            // Do nothing - make sure ship can't fire twice on the same position... as funny as that may be.
        }
        else
        {
            validTargets.append(potential)
        }
        i++
    }

    foreach (target in validTargets)
    {
        shell = Entities.FindByName(null, target)
        roll = RandomInt(0, 30)
        switch (true)
        {
            case (roll <= 10):
                DropSpit(shell.GetOrigin())
                break;
            case (roll > 10 && roll <= 20):
                DropFire(shell.GetOrigin())
                break;
            case (roll > 20 && roll <= 30):
                ZSpawn({ type = 2, pos = shell.GetOrigin() })
                break;
        }
    }
}

function packSpawn()
{
    // Dogs that spawn independently.
    // Since they are based on timer, there can only be two dogs that spawn at once.
    local spawners = ["packSpawn", "packSpawn2"]
    local dog = null
    local spawnpoint = null
    local actual = spawners[RandomInt(0, 1)]
    DoEntFire(actual, "SpawnZombie", "", 0, null, null)
    for (local spawner = null; spawner = Entities.FindByName(spawner, actual); )
    {
        spawnpoint = spawner.GetOrigin()
        while (dog = Entities.FindByClassnameWithin(dog, "player", spawnpoint, 100))
        {
            if (dog != null)
            {
                dog.SetHealth(350)
                NetProps.SetPropInt(dog, "m_clrRender", 70)
            }
        }
    }
}

function MarkForDeath()
{
    switch (OLTActive)
    {
        case true:
            // Disable associated timer
            // Doesn't do anything while in testing.
            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "** ONE LAST THRILL'S CURSE HAS BEEN LIFTED! **")
            OLTActive <- false
            for (local ent = null; ent = Entities.FindByClassname(ent, "player"); )
            {
                if (ent.GetZombieType() == 9)
                {
                    ent.SetHealth(ent.GetHealth() + 40)
                }
            }
        break;

        case false:
            // Activate One Last Thrill
            OLTActive <- true
            local times = [60, 80, 120]
            local actual = times[RandomInt(0, 2)]
            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "?? Increased damage & Mark will clear in " + actual +  " seconds! ??")
            DoEntFire("warnLunar", "RunScriptCode", "MarkForDeath()", actual, null, null)
            // Enable associated timer
        break;

    }
}

function waterworks()
{
    // True waterworks handling
    local directorAnger = 0
    local riskofreference = "HAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHA"

    ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x04" + riskofreference + riskofreference)

    foreach (page in survivors)
    {
        directorAnger = directorAnger + (page.entity.GetHealth() / 15)
    }
    directorAnger = directorAnger + wavesPassed

    SP <- SP + (1 * directorAnger)

    // cycle through each mutation's threat level judged on anger
    // EVERY mutation is applicable, fire off special "wave types" depending on what happens.

    local copycat = []

    foreach (page in modifiers)
    {
        if (page.threat < (directorAnger - mercy))
        {
            copycat.append(page)
        }
    }

    local roll = {type = "dummy", name = "", score = 0, desc = "", threat = 0, enabled = false, alternateNames = [], intName = "", cmod = 0, waveName = ""}

    if (copycat.len() > 0)
    {
        roll = copycat[RandomInt(0, copycat.len() - 1)]
        mercy <- roll.threat
    }
    else
    {
        mercy <- 0
    }

    switch (roll.intName)
    {
        case "dog": // expand upon this later
            DoEntFire("dogSpawn", "SpawnZombie", "", 0, null, null)
            // Pack tactics: Dogs will start to spawn amongst the normal infected based on a timer instead of hordes.
            // Use dogStage to justify how many.
            DoEntFire("catSpawn", "SpawnZombie", "", 0, null, null)

            if (dogStage < 3)
            {
                dogStage <- dogStage + 1
            }
            else
            {
                DoEntFire("packSpawnTimer", "Enable", "", 0, null, null)
            }
            break;

        case "cat": // expand upon this later
            // Shouldn't be called thanks to its insane threat value.
            break;

        case "ship":
            if (shipActive == false)
            {
                DoEntFire(shipTemplates[1], "ForceSpawn", "", 0, null, null)
                DoEntFire(shipTemplates[0], "ForceSpawn", "", 0, null, null)
                ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "// The air is getting saltier around you... //")
                ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "// Tonight's storm will leave us in crimson mist... //")
                shipActive <- true
                shipHealth <- 9999999999999999 // I'd be amazed if someone actually destroyed the ship with this value

                // Todo: Make cannons fire off (potentially) while ship is active.
                // I would, but True Waterworks is meant to be FUN.
                DoEntFire("shipArtillery", "Enable", "", 0, null, null)
            }
            else
            {
                local phase = 2
                    if (phase == 2)
                    {
                        ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "/!! SHIP HAS SUMMONED ITS SUNKEN SOLDIERS /!!")
                        local targets = ["catSpawn", "dogSpawn"]
                        local target = targets[RandomInt(0, targets.len() - 1)]

                        DoEntFire(target, "SpawnZombie", "", 0, null, null)
                    }

                    local artillery = cannons[RandomInt(0, cannons.len() - 1)]
                    DoEntFire(artillery, "SpawnZombie", "", 0, null, null)

                if (shipStage < 3)
                {
                    shipStage <- shipStage + 1
                }

            }

            if (shipStage != 3 && shipStage < 3)
            {
                shipStage <- shipStage + 1
            }
            break;

        case "DC": // Disorderly combat

            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "// Our vision was lost in the fog - we didn't even know what we had. //")

            local limit = directorAnger + 1
            local attacks = [
                {type = "medkit", threat = 12, SPREQ = 0, items = ["weapon_first_aid_kit", "weapon_defibrillator"]},
                {type = "throw", threat = 9, SPREQ = 0, items = ["weapon_molotov", "weapon_pipe_bomb", "weapon_vomitjar"]},
                {type = "pills", threat = 9, SPREQ = 0, items = ["weapon_pain_pills", "weapon_adrenaline"]}
            ]

            local scope = []

            foreach (target in attacks)
            {
                if (target.threat < limit && target.SPREQ <= SP)
                {
                    scope.append(target)
                }
            }

            local target = null

            foreach (target in scope)
            {
                for ( local ent; ent = Entities.FindByClassname(ent, "weapon_*"); )
                {
                    if (target == "nah")
                    {
                        break;
                    }
                    if (ent.GetOwnerEntity() != null && target.items.find(ent.GetClassname()) >= 0)
                    {
                        local player = ent.GetOwnerEntity()

                        local secondaries = ["weapon_melee", "weapon_pistol", "weapon_magnum", "weapon_chainsaw"]
                        local i = 0
                        while ( player.SwitchToItem(secondaries[i]) == false)
                        {
                            if (i >= secondaries.len() - 1)
                            { // Panic, give an item to the user, trigger the change *and then* fire it off.
                                break;
                            }
                            i++
                        }
                        ent.Kill()
                        local prefix = "weapon_"
                        local toGive = target.items[RandomInt(0, target.items.len() - 1)].slice(prefix.len())

                        player.GiveItem(toGive)

                        DoEntFire("warnLunar", "RunScriptCode", "givePlayerItem(\"" + player.GetPlayerUserId() + "\", \"" + toGive + "\")", 0, null, null)

                    }
                }
            }


            // replace item with random, valid item equivilent (if possible)
            // outright steal weapon if targeted
            // do not give items to players that don't already have an item
            break;

        case "DoN": // Double or Nothing
            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "// This is what you call a truly uncontrollable situation. //")
            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "// Flip the coin of fate. //")

            local roll = RandomInt(1, 20)

            local wheel = [
                // Health Effects
                {type = "Health", effect = "35", min = 0, max = 5, threat = 12, SPGain = -10} //0
                {type = "Health", effect = "50", min = 0, max = 10, threat = 8, SPGain = 0} //1
                {type = "Health", effect = "75", min = 17, max = 20, threat = 5, SPGain = 0} //2
                {type = "Health", effect = "100", min = 19, max = 20, threat = 0, SPGain = 20} //3
                {type = "Health", effect = "200", min = 20, max = 20, threat = 0, SPGain = 50} //4
                // General Effects
                {type = "General", effect = "fireWave", min = 0, max = 20, threat = 5, SPGain = 0} //5
                // Item Effects (Giving)
                {type = "Item", effect = "pipe_bomb", min = 0, max = 12, SPGain = 5} //9
                {type = "Item", effect = "molotov", min = 15, max = 20, SPGain = 10}
                {type = "Item", effect = "first_aid_kit", min = 12, max = 20, SPGain = 5}
                {type = "Item", effect = "pain_pills", min = 12, max = 20, SPGain = 10}
                {type = "Item", effect = "adrenaline", min = 10, max = 20, SPGain = 5}
                {type = "Item", effect = "vomitjar", min = 0, max = 15, SPGain = 5} //14
                // Wave Effects
                {type = "Wave", effect = "Dogs", min = 0, max = 20, SPGain = 0}
                {type = "Wave", effect = "Cat", min = 0, max = 20, SPGain = 0}
                {type = "Wave", effect = "Ship", min = 0, max = 20, SPGain = 0}
            ];

            local target = wheel[RandomInt(0, wheel.len() - 1)]
            target = wheel[RandomInt(9, 14)]

            switch (target.type)
            {
                case "Health":
                    // Give players health
                    ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "** Rolled health, and its effect: " + target.effect + "**")
                    for (local ent = null; ent = Entities.FindByClassname(ent, "player"); )
                    {
                        if (ent.GetZombieType() == 9)
                        {
                            // improve this to account for One Last Thrill being enabled.
                            ent.SetHealth(target.effect.tointeger())
                        }
                    }
                    break;
                case "General":
                    // Exec general stuff
                    switch (target.effect)
                    {
                        case "fireWave":
                            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "!! DIRECTOR ACTIVATED EARLY. !!")
                            fireWave()
                            break;
                    }
                    break;
                case "Item":
                    ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "** Merry Christmas. **")
                    for (local ent = null; ent = Entities.FindByClassname(ent, "player"); )
                    {
                        if (ent.GetZombieType() == 9)
                        {
                            DoEntFire("warnLunar", "RunScriptCode", "givePlayerItem(\"" + ent.GetPlayerUserId() + "\", \"" + target.effect + "\")", 0, null, null)
                        }
                    }
                    // Give all players the item
                    break;
                case "Wave":
                    ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "!! WAVE SUMMONED. !!")
                    switch (target.effect)
                    {
                        case "Dogs":
                            DoEntFire("dogSpawn", "SpawnZombie", "", 0, null, null)
                            break;
                        case "Cats":
                            DoEntFire(catSpawn, "SpawnZombie", "", 0, null, null)
                            break;
                        case "Ship":
                            shipArtillery()
                            break;
                    }
                    // Fire specified wave
                    break;
            }

            SP <- SP + target.SPGain
            break;

        case "OLT": // One last thrill
            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "// Our skin held together by threads. //")

            // No idea what to put here... yet.
            // Make sure that this function can't fire off MarkForDeath if it isn't already on.

            local victim = survivors[RandomInt(0, 3)]
            markVictim <- victim.entity
            printl("Victim is: " + markVictim)
            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x03" + "WARNING: MARK VICTIM IS " + markVictim.GetPlayerName())

            if (OLTActive != true)
            {
                MarkForDeath()
            }
            break;

        case "spit":
            printl("Director tried to call Spit-tastic")
            // threat value is too high for this to ever be called but maybe something can happen.
            break;

        case "W":
            printl("Director called true waterworks")
            fireWave() // Should never happen, but whatever honestly
            break;

        default: // only called by dummy variable
            break;
    }
}

function initSpecial()
{
    // Function for initialising "special" things such as One Last Thrill (if it's enabled).
    // One Last Thrill works differently compared to its mutation; it does not disable medkits.

    survivors[0]["entity"] <- Entities.FindByModel(null, "models/survivors/survivor_mechanic.mdl")
    survivors[1]["entity"] <- Entities.FindByModel(null, "models/survivors/survivor_gambler.mdl")
    survivors[2]["entity"] <- Entities.FindByModel(null, "models/survivors/survivor_coach.mdl")
    survivors[3]["entity"] <- Entities.FindByModel(null, "models/survivors/survivor_producer.mdl")

    foreach (page in survivors)
    {
        page.name <- page.entity.GetPlayerName()
    }

    gameON <- true
}

function initWaveTypes()
{
    // Initialise wavetypes on finale start.
    // Happens after cleanOnStart.

    local copycat = null
    local index = 0
    foreach (page in modifiers)
    {
        if (page.enabled == true)
        {
            lunarScore <- lunarScore + page.score
            if (page.type == "wave")
            {
                cMod.append(page)
                validWaves.append(page.intName)
            }
            Currencymod <- Currencymod + page.cmod
        }
    }

    switch (true)
    {
        case (modifiers[0]["enabled"] && modifiers[1]["enabled"]):
            printl("Cats & Dogs are now enabled")
            cMod.append(extras[0])
            validWaves.append(extras[0]["intName"])
    }

    initMusicType()
}

function cleanOnStart()
{
    // Delete lunar platform & buttons when the map begins.
    local trash = [ "lunarPlatform", "dogButton", "dogButtonEnt", "waterButton"] // Locally set list of every named entity on the lunar platform.
    // Add as more lunar modifiers are made...

    foreach (item in trash)
    {
        DoEntFire(item, "Kill", "", 0, null, null)
    }

    initWaveTypes()
    initSpecial()

    if (modifiers[3]["enabled"])
    {
        // Delete all weapon entities and enables the timer
        // DISORDERLY COMBAT

        DoEntFire("weaponTimer", "Enable", "", 0, null, null)
        // "buyDefibButton", "buyDefib", "buyPipeBomb", "buyPipe", "buyBile", "buyBileButton", "buyMolotovButton", "buyMolotov", "buyAdrenaline", "buyAdrenalineButton", "buyPills", "buyPillsButton", "buyMedkit", "buyMedkitButton",
        trash = ["survival_ammo", "survival_AR", "buyWeapon", "buyWeaponButton"]
        foreach (item in trash)
        {
            DoEntFire(item, "Kill", "", 0, null, null)
        }
    }

    if (modifiers[7]["enabled"])
    {
        // True waterworks handling
        waveNext <- 1
        validWaves <- ["none", "W"]
    }
}

function nextWave()
{
    // If the current waveType != null, then generate a new wave. Otherwise, set to null for a period of  time.

    if (waveType != "none")
    {
        if (waveType == "ship")
        {
            destroyShip(false)
        }
        waveType <- "none"
        waveNext <- waveNext + RandomInt(3, 6)
        ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x04" + "** SPECIAL WAVE SURVIVED! SUPPLIES & MONEY GIVEN **")

        for (local ent; ent = Entities.FindByClassname(ent, "player"); )
        {
            ent.SetHealth(100)
        }
        teamCurrency <- teamCurrency + 20
    } else {
        local targetWave = RandomInt(0, validWaves.len() - 1)
        if (targetWave == 0 && validWaves.len() > 1)
        { // Increase by 1 to force a wave type.
            targetWave++
        }
        waveType <- validWaves[targetWave]
        if ( waveType != "none" )
        {
            if (waveType == "W")
            {
                startMusic(1)
            }
            else
            {
                startMusic(0)
            }
            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x04" + "!! SPECIAL WAVE: "+ waveType+ "! !!")
            foreach (page in modifiers)
            {
                if (page.intName == waveType)
                {
                    local roll = RandomInt(1, 20)
                    if (roll < 15)
                    {
                        ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x04" + "!! SPECIAL WAVE: "+ page.waveName + "! !!")
                    }
                    else
                    {
                        ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x04" + "!! SPECIAL WAVE: "+ page.alternateNames[RandomInt(0, page.alternateNames.len() - 1)]+ "! !!")
                    }

                }
            }
        }
    }
}

function fireWave()
{
    if (wavesPassed < waveNext)
    {
        switch (waveType)
        {
            case "none":
                // do nothing
                break;

            case "dog":
                DoEntFire("dogSpawn", "SpawnZombie", "", 0, null, null)
                break;

            case "cat":
                DoEntFire("catSpawn", "SpawnZombie", "", 0, null, null)
                break;

            case "C&D":
                DoEntFire("catSpawn", "SpawnZombie", "", 0, null, null)
                DoEntFire("dogSpawn", "SpawnZombie", "", 0, null, null)
                break;

            case "ship":
                if (shipActive == false && shipWaves <= 0)
                {
                    if (modifiers[4]["enabled"] == true)
                    {
                        DoEntFire(shipTemplates[1], "ForceSpawn", "", 0, null, null)
                    }
                    DoEntFire(shipTemplates[0], "ForceSpawn", "", 0, null, null)
                    ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "// The air is getting saltier around you... //")
                    ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "// Tonight is going to be a horrible night. //")
                    shipActive <- true
                }
                if (shipActive)
                {
                    local phase = waveNext - wavesPassed
                    if (shipWaves >= phase / 2)
                    {
                        ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "/!! WAVES WON'T STOP UNTIL DEATH OF SHIP /!!")
                        local targets = ["catSpawn", "dogSpawn"]
                        local target = targets[RandomInt(0, targets.len() - 1)]

                        DoEntFire(target, "SpawnZombie", "", 0, null, null)
                    }

                    local artillery = cannons[RandomInt(0, cannons.len() - 1)]
                    DoEntFire(artillery, "SpawnZombie", "", 0, null, null)
                    if (modifiers[4]["enabled"] == false)
                    {
                        teleportShip()
                    }

                }
                break;

            case "OP":
                // overpower waves
                // Probably not going to be implemented.

                break;

            case "W":
                // True Waterworks. Doesn't end.
                // Need to change this to be handled in a 'special way'.

                waveNext <- 99999 //yeah that'll do it
                waterworks()

                break;

            default:
                nextWave();
                break;
        }
    }
    else
    {
        nextWave()
    }
}

function fireSpecial()
{
    // Handle special events that are always active.
    // Probably will be used ONLY for spit-tastic.

    if (modifiers[6]["enabled"] == true)
    {
        superSpitter()
    }
}

function OnGameEvent_create_panic_event( params ) // Might move this to globals considering that this function is accessed a lot. (LIES)
{
    wavesPassed++

    teamCurrency <- teamCurrency + (8 * Currencymod)
    fireWave()
    initSpecial() // refresh survivors before specials happen
    fireSpecial()
}
