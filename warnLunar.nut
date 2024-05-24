// Script for "warning" players about modifiers.

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
    ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x03" + "Warning! These are 'Lunar Modifiers', enable them for a higher score, at your own risk.")
}

function activateModifier(index)
{
    switch (modifiers[index]["enabled"])
    {
        case false:
            //
            modifiers[index]["enabled"] <- true
            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x03" + "[DEBUG] " + modifiers[index]["name"] + " is now enabled.")
            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "[DESC] " + modifiers[index]["desc"])
            break;

            case true:
            modifiers[index]["enabled"] <- false
            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x03" + "[DEBUG] " + modifiers[index]["name"] + " is now disabled.")
            break;
    }

    local score = 0
    foreach (page in modifiers)
    {
        if (page.enabled == true && page.intName != "W" && page.intName != "OLT")
        {
            score = score + 1
        }
    }

    if (score > 5)
    {
        DoEntFire("waterButtonSpawner", "ForceSpawn", "", 0, null, null)
    }
    else
    {
        DoEntFire("waterButton", "Kill", "", 0, null, null)
        modifiers[7]["enabled"] <- false
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
        if (page.entity == player)
        {
            return (page.maxHP)
        }
    }
}

//// DISORDERLY COMBAT FUNCTIONS ////

function changeWeapons()
{
    local valid = [ // Weapons *to* delete & give the player (primaries)
        "weapon_smg_silenced",
        "weapon_smg",
        "weapon_pumpshotgun",
        "weapon_shotgun_chrome",
        "weapon_smg_mp5",
        "weapon_hunting_rifle",
        "weapon_autoshotgun",
        "weapon_rifle",
        "weapon_sniper_scout",
        "weapon_rifle_desert",
        "weapon_shotgun_spas",
        "weapon_sniper_military",
        "weapon_rifle_m60",
        "weapon_grenade_launcher",
        "weapon_rifle_sg552",
        "weapon_sniper_awp",
    ];

    for ( local ent =  null; ent = Entities.FindByClassname(ent, "weapon_*"); )
    {
        print(ent.GetClassname() + " ")

        if (valid.find(ent.GetClassname()) >= 0)
        {
            local owner = ent.GetOwnerEntity()
            if (owner != null)
            {
                local i = 0
                local secondaries = ["weapon_melee", "weapon_pistol", "weapon_magnum", "weapon_chainsaw", "weapon_first_aid_kit", "weapon_pain_pills", "weapon_adrenaline", "weapon_molotov", "weapon_pipe_bomb", "weapon_vomitjar"]
                while ( owner.SwitchToItem(secondaries[i]) == false)
                {
                    if (i >= secondaries.len() - 1)
                    { // Panic, give an item to the user, trigger the change *and then* fire it off.
                        foreach (page in survivors)
                        {
                            if (page.entity == owner && owner.IsDominatedBySpecialInfected() == false)
                            {
                                page.panicked <- true
                                owner.GiveItem("pain_pills")
                            }
                        }
                        break;
                    }
                    i++
                }
            }
            ent.Kill()
        }
    }

    foreach (page in survivors)
    {
        local toGive = valid[RandomInt(0, valid.len() - 1)]
        local prefix = "weapon_"
        local toGive = toGive.slice(prefix.len())
        local owner = page.entity

        owner.GiveItem(toGive)
        local roll = RandomInt(1, 10)
        if (roll > 6)
        {
            owner.GiveUpgrade(3)
        }
        roll = RandomInt(1, 20)
        if (roll > 15)
        {
            local upgradetype = RandomInt(1, 2)
            owner.GiveUpgrade(upgradetype)
        }

        if (page.panicked)
        {
            for ( local toRemove = null; toRemove = Entities.FindByClassname(toRemove, "weapon_pain_pills"); )
            {
                if (toRemove.GetOwnerEntity() == owner)
                {
                    toRemove.Kill()
                }
            }
        }
    }

    for ( local ent = null; ent = Entities.FindByClassname(ent, "weapon_*"); )
    {
        if (valid.find(ent.GetClassname()) >= 0 && ent.GetOwnerEntity() == null)
        {
            ent.Kill()
        }
    }

}

//// BATTLESHIP FUNCTIONS ////

function teleportShip()
{
    local shipEnts = [ ["ship1", "shipGun1", "shipLights1", "shipZoey1"], ["ship2", "shipGun2", "shipLights2", "shipZoey2"] ]
    local ver = shipEnts[shipSpot]

    foreach (page in ver)
    {
        DoEntFire(page, "Kill", "", 0, null, null)
    }

    switch (shipSpot)
    {
        case 0:
            // teleport spawn-side
            shipSpot <- 1
            DoEntFire("templateShip2", "ForceSpawn", "", 0, null, null)
            break;

        case 1:
            // teleport shop-side
            shipSpot <- 0
            DoEntFire("templateShip1", "ForceSpawn", "", 0, null, null)
    }
}

function destroyShip(type)
{
    switch (type)
    {
        case true:
            //reward players and remove ship from the array
            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x04" + "** THE BATTLESHIP HAS BEEN DESTROYED! SUPPLIES & CASH GIVEN **")
            if (waveType == "ship")
            {
                waveType <- "none"
            }
            break;
        case false:
            //don't do anything other than remove the ship and stop all associated functions :/
            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "// The ship has left... For now. //")
    }

    local ent = null;
    local toRemove = ["ship1", "shipGun1", "shipLights1", "shipZoey1", "ship2", "shipGun2", "shipLights2", "shipZoey2"]
    foreach (page in toRemove)
    {
        DoEntFire(page, "Kill", "", 0, null, null)
    }

    shipActive <- false
}

function damageShip()
{
    shipHealth <- shipHealth - 1
    if (shipHealth <= 0)
    {
        destroyShip(true)
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

    if ( modifiers[4]["enabled"] )
    {
        if (DONSpawn)
        {
            // Do nothing.
        }
        else if (DONSpawn == false)
        {
            local z = player.GetZombieType()
            if (z != 8 && z != 9)
            {
                if ( ZSpawn( {type = z} ) != true)
                {
                    printl("Can't spawn extra zombie... Why?")
                }
            }
        }
    }

}


// ONE LAST THRILL related hooks

function OnGameEvent_player_hurt_concise( params )
{
    local userid = params.userid

    local player = GetPlayerFromUserID(userid)
    local damage = params.dmg_health

    if (modifiers[5]["enabled"] && gameON) // One Last Thrill
    {


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
            if (damage > 1 && isSurvivor && player.IsIncapacitated() !=  true)
            {
                changeSurvivorMaxHP(player, (prevmax - (damage * 1.5)).tointeger())
            }
        }
        else
        {
            // Shouldn't fire because this line never printed in OLT's mutation.
            // Slightly different logic handling *might* fire it.
            printl("OH FIDDLESTICKS, WHAT NOW?")
        }

        if (player.IsIncapacitated() != true && player.IsDominatedBySpecialInfected() !=  true)
        {
            if (player.GetHealth() > getSurvivorMaxHP(player))
            {
                player.SetHealth(getSurvivorMaxHP(player))
            }
            if (player.GetHealthBuffer() > getSurvivorMaxHP(player) )
            {
                player.SetHealthBuffer(getSurvivorMaxHP(player))
            }
        }
    }
    if (OLTActive)
    {
        local mark = 0.25
        local prev = 0
        // Independant of previous statement - players take more damage
        if (modifiers[5]["enabled"])
        {
            // Seperate handling for the case that One Last Thrill is on.
            mark = 0.5
            if (player == markVictim)
            {
                mark = 0.5
            }
            prev = player.GetHealth()
            changeSurvivorMaxHP(player, (prev - (damage * mark)))

            if (player.IsIncapacitated() != true && player.IsDominatedBySpecialInfected() !=  true)
            {
                if (player.GetHealth() > getSurvivorMaxHP(player))
                {
                    player.SetHealth(getSurvivorMaxHP(player))
                }
                if (player.GetHealthBuffer() > getSurvivorMaxHP(player) )
                {
                    player.SetHealthBuffer(getSurvivorMaxHP(player))
                }
            }

        }
        else
        {
            local type = "health"
            if (player.GetHealthBuffer() > 1)
            {
                type = "pain"
            }

            if (player == markVictim)
            {
                mark = 0.75

                // Should result in 1.75x damage taken.
                // This attacks health directly so *be careful*
            }

            switch (type)
            {
                case "health":
                    prev = player.GetHealth()

                    if (prev - (damage * mark) > 1)
                    {
                        player.SetHealth(prev - (damage * mark))
                    }
                    else
                    {
                        if (player.GetHealth > 1)
                        {
                            player.SetHealth(1)
                        }
                    }

                    break;
                case "pain":
                    prev = player.GetHealthBuffer()

                    local total = damage * mark
                    if (player.GetHealthBuffer() - total > 1)
                    {
                        // Take away health accordingly
                    }
                    else
                    {
                        player.SetHealth(prev - ((damage * mark) - player.GetHealthBuffer()))
                        player.SetHealthBuffer(0)
                    }

                    break;
            }
                prev = player.GetHealth()

            if (prev - (damage * mark) > 1)
            {
                player.SetHealth(prev - (damage * mark))
            }
            else
            {
                player.SetHealth(1)
            }
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
            player.SetHealthBuffer(getSurvivorMaxHP(player))
        }
        Say(player, "My max HP is now "+ getSurvivorMaxHP(player), true)
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
            player.SetHealthBuffer(getSurvivorMaxHP(player))
        }
        Say(player, "My max HP is now "+ getSurvivorMaxHP(player), true)
    }
}

function OnGameEvent_player_incapacitated( params )
{
    if (modifiers[5]["enabled"] && gameON) // One Last Thrill
    {
        local userid = params.userid
        local player = GetPlayerFromUserID(userid)

        changeSurvivorMaxHP(player, 300)
        player.SetReviveCount(3)
    }
}

function OnGameEvent_revive_success( params ) // Called when reviving from incap
{
    if (modifiers[5]["enabled"] && gameON) // One Last Thrill
    {
        local victim = params.subject
        local player = GetPlayerFromUserID(victim)

        changeSurvivorMaxHP(player, 50)
        player.SetHealthBuffer(50)
    }
}

function OnGameEvent_heal_success( params ) // Called by medkits.
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
            player.SetHealthBuffer(getSurvivorMaxHP(player))
        }
        if (player.GetHealth() > getSurvivorMaxHP(player))
        {
            player.SetHealth(getSurvivorMaxHP(player))
        }
        Say(player, "My max HP is now "+ getSurvivorMaxHP(player), true)
    }
}

function OnGameEvent_defibrillator_used( params )
{
    local subject = params.subject
    if (modifiers[5]["enabled"] && gameON) // One Last Thrill
    {
        local victim = params.subject
        local player = GetPlayerFromUserID(victim)

        changeSurvivorMaxHP(player, 50)
        player.SetHealth(50)
    }
}

function OnGameEvent_tank_spawn( params )
{
    // Spawn seven spitters.
    if (modifiers[6]["enabled"] == true && waveType !=  "none")
    {
        local spawnedSpitters = 0
        while (spawnedSpitters < 7)
        {
            ZSpawn( {type = 4} )
            spawnedSpitters++
        }
    }
}
