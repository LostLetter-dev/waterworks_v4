// Francis' shop handling and all related functions.

// TODO: Shop (buying, selling) [ IN PROGRESS ]
// TODO: Visual indicator for currency
// TODO: Teleporter Functionality [ METHOD KNOWN ]
// TODO: Louis functionality (aka, guntower louis) [ METHOD KNOWN ]
// TODO: COD-Zombies styled traps
// TODO: The ability to sell rochelle

// We want the players to gain points every wave that passes. Potentially can be scaled on the Lunar score, but that'll get unbalanced quickly.
// Might add a lunar option that disables / severely reduces shop functionality.
// Team currency is shared.

// Basic balancing scheme

/// ITEMS (Ranked on value)
// Ammo kits (Top tier, highest value)
// Medkits -- Limited or disabled with OLT modifier
//// SAME VALUE ITEMS
// Adrenaline
// Molotovs
// Pills
//// Low value items
// Pipe bombs
// Bile jars
// etc..
//// Random / Trash items
// Weapons
// Melee weapons

/// POWERUPS / UPGRADES (ranked on value)

// Tower Louis (may be disabled on 'hard mode')
// Laser Sights
// Teleporters (Needs cooldown) (May be disabled on 'hard mode')
// Traps (Needs cooldown)
// Etc...

///// MORE PLANS ADDED LATER(?)

// Global vars ref (DELETE LATER) -- MOVE TO globals.nut

///// Functions /////

// Upgrades (Permanent, most important so they stay at top)

// Traps

function restoreTrap()
{
    printl("a")
    local index = 0
    local callTime = Time()
    foreach (trap in traps)
    {
        local timeElapsed = callTime - trap.currentTime
        printl(timeElapsed)
        if (timeElapsed >= trap.cooldownTime && trap.cooldown == true)
        {
            // ok
            traps[index]["cooldown"] <- false
            traps[index]["currentTime"] <- 0

            DoEntFire(traps[index]["light"], "TurnOn", "", 0, null, null)
        }
        index++
    }
}

function activateTrap(index)
{
    // Change to global variable later because it won't persist otherwise


    local trapSpawn = Entities.FindByName(null, traps[index]["itemSpawn"])
    switch (traps[index]["cooldown"])
    {
        case true:
            printl("FUCKING WAIT")
            //Do nothing :)
        case false:
            if (teamCurrency >= 4 && traps[index]["cooldown"] != true)
            {
                DropFire(trapSpawn.GetOrigin())
                DoEntFire(traps[index]["light"], "TurnOff", "", 0, null, null)
                traps[index]["cooldown"] <- true
                traps[index]["currentTime"] <- Time()

                DoEntFire("warnLunar", "RunScriptCode", "restoreTrap()", traps[index]["cooldownTime"], null, null)
                teamCurrency <- teamCurrency - 4
            }
    }

}

// Buttons (Aka, francis' shop)
/// NOTE: Minimise as much as possible. Use lists for efficiency and less clutter if possible
/// Change notes to use as guide

function listCurrency()
{
    // Give player the reading of the team's current cash.
    // TODO: Make it specific to the player that calls the script.
    ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x03" + "Team currently has: $" + teamCurrency)
}

function purchaseItem(index)
{
    local shopPlate = Entities.FindByName(null, "shopSpawn")
    local shopSpawn = shopPlate.GetOrigin()
    // TYPE: Type of item. Aka, Health, Throw, Upgrade, etc.
    // INDEX: Index of item. Aka, TYPE = Health INDEX: Medkit
    local items = [
        {type = "Health", name = "Medkit", price = 10, itemID = "weapon_first_aid_kit"}, // I: 0
        {type = "Health", name = "Pills", price = 4, itemID = "weapon_pain_pills"}, // I: 1
        {type = "Health", name = "Adrenaline", price = 4, itemID = "weapon_adrenaline"} // I: 2
        {type = "Throw", name = "Molotov", price = 8, itemID = "weapon_molotov"} // I: 3
        {type = "Health", name = "Defib", price = 2, itemID = "weapon_defibrillator"} // Moved to avoid indexing issues // I: 4
        {type = "Throw", name = "Bile", price = 8, itemID = "weapon_vomitjar"} // I: 5
        {type = "Throw" name = "Pipe Bomb", price = 4, itemID = "weapon_pipe_bomb"} // I: 6
    ];

    printl(items[1]["name"]) // tested: returns name of item
    // DEBUGGING LINE ABOVE: REMOVE LATER

    if (teamCurrency >= items[index]["price"])
    {
        // TODO: ADD LIMITATIONS (such as removing medkits because of OLT)
        ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x03" + "Buying Item " + items[index]["name"])
        SpawnEntityFromTable(items[index]["itemID"], {
            origin = shopSpawn
        })
        teamCurrency <- teamCurrency - items[index]["price"]
    }
    else
    {
        ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x03" + "Don't have enough.")
    }
}

function purchaseConsumable(type, index)
{
    // Add functionality for consumable items (Gascans, etc.)
    // TODO: This.

    local tpDes = ["ammoSpawn", "shopSpawn"]
    local types = ["Ammo", "Consumable"]

    local items = [
        {type = "Ammo", name = "Explosive Ammopack", price = 6, itemID = "weapon_upgradepack_explosive"} // 0
        {type = "Ammo", name = "Incendiary Ammopack", price = 6, itemID = "weapon_upgradepack_incendiary"} // 1
        {type = "Consumable", name = "Jerry Can", price = 3, itemID = "weapon_gascan"} // 0
        {type = "Consumable", name = "Firework Crate", price = 3, itemID = "weapon_fireworkcrate"} // 1
        {type = "Consumable", name = "Oxygen Tank", price = 3, itemID = "weapon_oxygentank"} // 2
        {type = "Consumable", name = "Propane Tank", price = 3, itemID = "weapon_propanetank"} // 3
    ];

    local shopPlate = Entities.FindByName(null, tpDes[type])
    local shopSpawn = shopPlate.GetOrigin()

    local copycat = [];

    foreach (item in items)
    {
        if (item.type == types[type])
        {
            copycat.append(item)
        }
    }

    if ( teamCurrency >= copycat[index]["price"] )
    {
        ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x03" + "Buying Item " + copycat[index]["name"])
        SpawnEntityFromTable(copycat[index]["itemID"], {
            origin = shopSpawn
        })
        teamCurrency <- teamCurrency - copycat[index]["price"]
    }
    else
    {
        ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x03" + "Don't have enough.")
    }


}

function purchaseWeapon()
{
    // Add functionality for random weapons. (Vending machine, no specific tier)
    // Potentially add chance for tier of weapons?
    // TODO: make multiple vending machines (so players aren't just F***ED)

    if (teamCurrency >= 3)
    {
        teamCurrency <- teamCurrency - 3
        // RARITY, NAME, ITEMID
        local guns = [
            {rarity = "Bullshit", name = "A FUCKING PISTOL", itemID = "weapon_pistol", min = 0, max = 3}
            {rarity = "Common", name = "Silenced SMG", itemID = "weapon_smg_silenced", min = 0, max = 10}
            {rarity = "Common", name = "SMG", itemID = "weapon_smg", min = 0, max = 10}
            {rarity = "Common", name = "Pump Shotgun", itemID = "weapon_pumpshotgun", min = 0, max = 10}
            {rarity = "Uncommon", name = "Chrome Shotgun", itemID = "weapon_shotgun_chrome", min = 5, max = 15}
            {rarity = "Uncommon", name = "MP5", itemID = "weapon_smg_mp5", min = 5, max = 15}
            {rarity = "Uncommon", name = "Hunting Rifle", itemID = "weapon_hunting_rifle", min = 5, max = 15}
            {rarity = "Uncommon", name = "Auto Shotgun", itemID = "weapon_autoshotgun", min = 7, max = 17}
            {rarity = "Rare", name = "M16", itemID = "weapon_rifle", min = 10, max = 20}
            {rarity = "Rare", name = "Scout Sniper", itemID = "weapon_sniper_scout", min = 10, max = 20}
            {rarity = "Rare", name = "Deagle", itemID = "weapon_pistol_magnum", min = 10, max = 20}
            {rarity = "Epic", name = "Desert Rifle", itemID = "weapon_rifle_desert", min = 14, max = 20}
            {rarity = "Epic", name = "SPAS 12", itemID = "weapon_shotgun_spas", min = 14, max = 20}
            {rarity = "Epic", name = "Military Sniper", itemID = "weapon_sniper_military", min = 14, max = 20}
            {rarity = "Legend", name = "LMG", itemID = "weapon_rifle_m60", min = 17, max = 20}
            {rarity = "Legend", name = "Grenade Launcher", itemID = "weapon_grenade_launcher", min = 17, max = 20}
            {rarity = "Legend", name = "SG-552", itemID = "weapon_rifle_sg552", min = 17, max = 20}
            {rarity = "Legend", name = "AWP", itemID = "weapon_sniper_awp", min = 17, max = 20}
            {rarity = "Legend", name = "Chainsaw", itemID = "weapon_chainsaw", min = 17, max = 20}
        ];

        local copycat = guns

        local roll = RandomInt(1, 20)
        roll = roll - RandomInt(1, 3)
        if (roll < 0)
        {
            roll = 1
        }
        local index = 0

        foreach (gun in copycat)
        {
            if (roll < gun.min || roll > gun.max)
            {
                copycat.remove(index)
            }
            index++
        }

        local secondroll = RandomInt(0, copycat.len() - 1)
        printl("You unboxed: " + copycat[secondroll]["name"])

        local shopPlate = Entities.FindByName(null, "weaponSpawn")
        local shopSpawn = shopPlate.GetOrigin()

        for (local ent; ent = Entities.FindByClassnameWithin(ent, "weapon_*", shopSpawn, 100); )
        {
            if (ent.GetOwnerEntity() == null)
            {
                ent.Kill()
            }
        }
        
        local x = QAngle(0.0, 270.0, 0.0)
        x = x.ToKVString()
        SpawnEntityFromTable(copycat[secondroll]["itemID"], {
            origin = shopSpawn
            angles = x
            Ammo = 200
        })

        if ( copycat[secondroll]["rarity"] == "Legend" )
        {
            printl("HOLY SHIT")
            DoEntFire("JosephReact", "PlaySound", "", 0, null, null)
        }
        if ( copycat[secondroll]["rarity"] == "Bullshit" )
        {
            local why = 0
            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x03" + "... Is that a pistol? You might as well kill yourself.")
            ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x03" + "Take these 7 spitters as compensation.")

            while ( why < 7 )
            {
                ZSpawn( { type = 4 })
                why++
            }
        }
    }
    else
    {
        ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x03" + "Not enough cash to roll weapons.")
    }
}

function buyLouis()
{
    local price = 24
    if (teamCurrency >= price)
    {
        teamCurrency <- teamCurrency - price
        DoEntFire("louisTowerSpawn", "SpawnSurvivor", "", 0, null, null)
        ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x01" + "Louis has been spawned.")
    }
    else
    {
        ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x03" + "Not enough cash to buy louis (24).")
    }
}

// Teleporters

MTTeleporter <- true // true == teleporter is ready

function respawnGuns()
{

    local minigun = Entities.FindByName(null, "platformGun")
    local m1pos = minigun.GetOrigin()

    local minigun2 = Entities.FindByClassname(null, "prop_minigun_l4d1")
    local m2pos = minigun2.GetOrigin()

    for (local ent; ent = Entities.FindByClassnameWithin(ent, "player", m1pos, 50); )
    {
        ent.Stagger(Vector(0, 0, 0))
    }
    for (local ent; ent = Entities.FindByClassnameWithin(ent, "player", m2pos, 50); )
    {
        ent.Stagger(Vector(0, 0, 0))
    }
    
}

function purchaseTeleporter(index)
{
    // Links to other scripts and activates the teleporters.
    // Might want to keep this seperate from the teleport function(?)
    // Assign each survivor to teleported status (probably un-needed)
    // How the fuck does teleporter cooldown wor-- oh. Logic timers and global variables... Right.

    // Entfire, MT-TeleportON MT-TeleportOFF (lights)
    // Inputs: TurnOn, TurnOff
    // MT-TeleportSOUND
    // Inputs: PlaySound

    // TODO: move activation / effect scripts to disable both teleporters when fired
    local chance = 20
    local price = 0
    if (teamCurrency >= price)
    {
        if (MTTeleporter)
        {
            teamCurrency <- teamCurrency - price
            MTTeleporter <- false
            switch (index)
            {
                case 0:
                    // main teleporter
                    DoEntFire("MT-TeleportSOUND", "PlaySound", "", 0, null, null)
                    if (chance > 15)
                    {
                        DoEntFire("MT-TeleportPlatform", "Enable", "", 0, null, null)
                        DoEntFire("MT-TeleportPlatform", "Disable", "", 0.2, null, null) // Teleporter's *actual* activation
                        // Sends to platform
                    }
                case 1:
                    // secondary teleporter (Will I even add this?)
            }
            DoEntFire("MT-TeleportON", "TurnOff", "", 0, null, null)
            DoEntFire("MT-TeleportOFF", "TurnOn", "", 0, null, null) // Teleporter lights. Probably can make this global.

            DoEntFire("warnLunar", "RunScriptCode", "respawnGuns()", 39, null, null)

            
            DoEntFire("PlatformTeleporter", "Enable", "", 40, null, null) // Platform teleporter timer.
            DoEntFire("PlatformTeleporter", "Disable", "", 40.5, null, null) // Platform teleporter disable

            DoEntFire("TeleportTimer", "Enable", "", 40.6, null, null) // Teleporter cooldown activator
            // Can activate these regardless of chance because idk lol
        }
        else
        {
            printl("Teleporter on cooldown.")
        }
    }
    else
    {
        printl("Team doesn't have enough money to use teleporter!")
        ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x03" + "Not enough cash to teleport.")
    }
}

function resetTeleporter() // Resets both teleporters.
{
    MTTeleporter <- true

    DoEntFire("MT-TeleportOFF", "TurnOff", "", 0, null, null)
    DoEntFire("MT-TeleportON", "TurnOn", "", 0, null, null)
    DoEntFire("MT-TeleportSOUND", "PlaySound", "", 0, null, null)
}

// Respawn Point (Technically not Francis' shop?)

function respawnPlayers()
{
    local survivorsRevived = 0
    local price = 5
    // stuff here
    local respawner = Entities.FindByName(null, "respawnPoint")
    local loc = respawner.GetOrigin()
    for ( local ent = null; ent = Entities.FindByClassname(ent, "player"); )
    {
        if ( ent.IsSurvivor() && ent.IsDead() && teamCurrency >= price )
        {
            printl("Target found!")
            
            ent.ReviveByDefib()
            ent.SetOrigin(loc)
            DoEntFire(ent.GetName(), "SetLocalOrigin", loc.tostring(), 0, null, null)
            teamCurrency <- teamCurrency - price
            survivorsRevived++
        }
    }
    if (survivorsRevived == 0)
    {
        printl("No survivors revived -- out of money or nobody's dead.")
    }
}

// Random Item Spawner

///// Hooks /////
// DONT USE MANY.
// *TRUST* ME.
// Hooks will break eachother, can't have more than 1.
