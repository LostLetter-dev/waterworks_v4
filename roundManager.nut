// Script that handles everything that happens during the rounds.

printl("roundManager init")

// functions

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

    foreach (item in validWaves)
    {
        printl(item)
    }
}

function cleanOnStart()
{
    // Delete lunar platform & buttons when the map begins.
    local trash = [ "lunarPlatform", "dogButton", "dogButtonEnt" ] // Locally set list of every named entity on the lunar platform.
    // Add as more lunar modifiers are made...

    foreach (item in trash)
    {
        DoEntFire(item, "Kill", "", 0, null, null)
    }

    initWaveTypes()
    initSpecial()
}

function nextWave()
{
    
    // TODO: intercept wave generation before it is calculated by implementing a 1/50 random chance (overpower waves)
    // If the current waveType != null, then generate a new wave. Otherwise, set to null for a period of  time.

    if (waveType != "none")
    {
        waveType <- "none"
        waveNext <- waveNext + RandomInt(4, 7)
        printl("DEBUG: NEXT WAVE IN: " +waveNext)
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
            startMusic(0)
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

function OnGameEvent_create_panic_event( params ) // Might move this to globals considering that this function is accessed a lot.
{
    wavesPassed++

    printl("Current wave is: " +wavesPassed)
    teamCurrency <- teamCurrency + (8 * Currencymod)
    fireWave()
    fireSpecial()
}
