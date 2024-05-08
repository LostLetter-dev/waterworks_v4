// Script for "warning" players about modifiers.
// TODO: add ability to switch off modifiers and switch them on before round starts.

// PLANNED MODIFIERS:

/// Cat rounds (Wandering witches)

/// Disorderly Combat (ammo piles disabled -- NEED TO DESTROY *ALL* WEAPONS upon round start)
//// WARNING: Guns created with ent_create have NO reserve ammo.
//// Can use events item_pickup to remedy this - Use it to destroy dropped weapons *and* replenish ammo near user.
//// weapon_pickup doesn't work because it's not networked

/// SUPER SPITTERS (Of course)

/// SLAM JAM (of course)

/// (rare) OVERPOWER WAVES (of course)

/// One Last Thrill (maybe? Probably won't.)

/// MULTIWAVES

printl("Lunar Script init")

function firstWarning()
{
    printl("Something happened!")

    ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x03" + "Warning! These are 'Lunar Modifiers', enable them for a higher score, at your own risk.")
}

function activateModifier(index)
{
    switch (modifiers[index]["enabled"])
    {
        case false:
            //
            modifiers[index]["enabled"] <- true
            printl(modifiers[index]["enabled"])
            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x03" + "[DEBUG] " + modifiers[index]["name"] + " are now enabled.")
            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "[DESC] " + modifiers[index]["desc"])
            break;
        
            case true:
            modifiers[index]["enabled"] <- false
            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x03" + "[DEBUG] " + modifiers[index]["name"] + " are now disabled.")
            break;
            
    }
}

//// ONE LAST THRILL FUNCTIONS ////

function changeSurvivorMaxHP(player, hp)
{
    local realHP = 0
    if (hp > 100)
    {
        realHP = 100
    } else if (hp < 0) {
        realHP = 1
    } else {
        realHP = hp
    }

    local index = 0
    foreach (page in survivors)
    {
        if (page.entity == player)
        {
            survivors[index]["maxHP"] <- realHP
        } else {
            index++
        }
    }
}

function getSurvivorMaxHP(player)
{
    local index = 0
    local name = player.GetPlayerName()
    foreach (page in survivors)
    {
        printl("going through" + page.name)
        if (page.name == name)
        {
            return (page.maxHP)
        }
    }
}

/// HOOKS ///
// Move to 'globals' if hook is accessed by something outside of warnLunar script.

// OTHER STUFF (TESTING)


// On fresh infected spawns (likely only used by Double Or Nothing)
function OnGameEvent_player_first_spawn( params )
{
    local uid = params.userid
    local player = GetPlayerFromUserID(uid)

    printl(player.GetPlayerName() + " Is respawning")
    if ( modifiers[4]["enabled"] )
    {
        if (DONSpawn)
        {
            // Do nothing.
        }
        else if (DONSpawn == false)
        {
            DONSpawn <- false
            local z = player.GetZombieType()
            if (z != 8 && z != 9)
            {
                printl("SPAWNING EXTRA")
                if ( ZSpawn( {type = z} ) != true)
                {
                    printl("what is this SHIT")
                }
            }
            DONSpawn <- false
        }
    }
    
}


// ONE LAST THRILL related hooks

function OnGameEvent_player_hurt_concise( params )
{
    if (modifiers[5]["enabled"] && gameON) // One Last Thrill
    {
        local userid = params.userid

        local player = GetPlayerFromUserID(userid)
        local damage = params.dmg_health
    
        local index = 0
        local isSurvivor = false
        local prevmax = getSurvivorMaxHP(player)
        foreach (page in survivors)
        {
            if (player.GetPlayerName() == page.name)
            {
                if (page.entity != player)
                {
                    survivors[index]["entity"] <- player
                }
                isSurvivor = true
                break;
            } 
            else
            {
                index++
            }
        }
    
        if (damage != null)
        {
            if (damage > 1)
            {
                changeSurvivorMaxHP(player, (prevmax - (damage * 2)).tointeger())
            }
        }
        else
        {
            // Shouldn't fire because this line never printed in OLT's mutation.
            // Slightly different logic handling *might* fire it.
            printl("OH FIDDLESTICKS, WHAT NOW?")
        }
    
        local max = getSurvivorMaxHP(player)
    
        if (player.GetHealth() > max)
        {
            player.SetHealth(max)
        }
        if (player.GetHealthBuffer() > max )
        {
            player.SetHealthBuffer(max)
        }
    }
}

function OnGameEvent_pills_used( params )
{
    if (modifiers[5]["enabled"] && gameON) // One Last Thrill
    {
        local userid = params.userid
        local player = GetPlayerFromUserID(userid)
        local hp = getSurvivorMaxHP(player)

        local hp = hp + 35
        changeSurvivorMaxHP(player, hp)

        if (player.GetHealthBuffer() > getSurvivorMaxHP(player))
        {
            player.setHealthBuffer(getSurvivorMaxHP(player))
        }
        say(player, "My max HP is now "+ getSurvivorMaxHP(player), true)
    }
}

function OnGameEvent_adrenaline_used( params )
{
    if (modifiers[5]["enabled"] && gameON) // One Last Thrill
    {
        local userid = params.userid
        local player = GetPlayerFromUserID(userid)
        local hp = getSurvivorMaxHP(player)

        local hp = hp + 20
        changeSurvivorMaxHP(player, hp)

        if (player.GetHealthBuffer() > getSurvivorMaxHP(player))
        {
            player.setHealthBuffer(getSurvivorMaxHP(player))
        }
        say(player, "My max HP is now "+ getSurvivorMaxHP(player), true)
    }
}

function OnGameEvent_player_incapacitated( params )
{
    if (modifiers[5]["enabled"] && gameON) // One Last Thrill
    {
        local userid = params.userid
        local player = GetPlayerFromUserID(userid)

        player.SetReviveCount(3)
    }
}

function OnGameEvent_revive_success( params )
{
    if (modifiers[5]["enabled"] && gameON) // One Last Thrill
    {
        local victim = params.subject
        local player = GetPlayerFromUserID(victim)
    
        ChangeSurvivorMaxHP(player, 50)
        player.SetHealthBuffer(50)
    }
}

function OnGameEvent_heal_success( params ) // Called by medkits. Players shouldn't have this, but I say 'fuck it' and keep it in as easter egg.
{
    
    if (modifiers[5]["enabled"] && gameON)
    {
        local victim = params.subject
        local player = GetPlayerFromUserID(victim)

        local hp = getSurvivorMaxHP(player)

        local hp = hp + 50
        changeSurvivorMaxHP(player, hp)

        if (player.GetHealthBuffer() > getSurvivorMaxHP(player))
        {
            player.setHealthBuffer(getSurvivorMaxHP(player))
        }
        if (player.GetHealth() > getSurvivorMaxHP(player))
        {
            player.SetHealth(getSurvivorMaxHP(player))
        }
        Say(player, "My max HP is now "+ getSurvivorMaxHP(player), true)
    }
}
