// File for holding global variables.
// This is because scripts can access global vars from anywhere (so long as it's loaded) because VScript is based.

// General
wavesPassed <- -1 // Used more by roundManager, updates every horde event.
gameON <- false // used to determine if OLT hooks should fire
DONSpawn <- false // Redundancy.

shipHealth <- 4000 // Used by the battleship
cannons <- ["boomTillery1", "boomTillery1"] // used to spawn falling boomers while the Battleship is active
shipTemplates <- ["templateShip1", "templateShip2"]
shipSpot <- 0 // What side of the map the Battleship is currently at.
shipWaves <- 0 // How long the battleship has lived.
shipActive <- false // Turn this to true while ship is 'alive'. Ship can be killed before wave ends.

// Used by OLT and potentially Disorderly Combat

survivors <- [
    {name = "Ellis", maxHP = 100, entity = null, panicked = false}
    {name = "Nick", maxHP = 100, entity = null, panicked = false}
    {name = "Coach", maxHP = 100, entity = null, panicked = false}
    {name = "Rochelle", maxHP = 100, entity = null, panicked = false}
];

// warnLunar.nut (Lunar Modifiers)

modifiers <- [
    {type = "wave", name = "Dog Rounds", score = 2, desc = "Tanks with low health spawn during special waves.", threat = 15, enabled = false, alternateNames = ["butterian"], intName = "dog", cmod = 0, waveName = "dog"} // 0
    {type = "wave", name = "Cat Rounds", score = 2, desc = "Spawn wandering witches during special waves.", threat = 99, enabled = false, alternateNames = ["witches and whores"], intName = "cat", cmod = 0, waveName = "Cats"} // 1
    {type = "wave", name = "The Battleship", score = 4, desc = "Map's dedicated boss fight.", threat = 9, enabled = false, alternateNames = ["Valenguardian Intervention"], intName = "ship", cmod = 0, waveName = "The Battleship"} // 2
    {type = "general", name = "Disorderly Combat", score = 2, desc = "No permanent guns and no gurantee of items - Utter chaos.", threat = 8, enabled = false, alternateNames = [], intName = "DC", cmod = 0, waveName = ""} //3
    {type = "general", name = "Double or Nothing", score = 3, desc = "Some things doubled, some things halved.", threat = 0, enabled = false, alternateNames = [], intName = "DoN", cmod = 1, waveName = ""} // 4
    {type = "general", name = "One Last Thrill", score = 4, desc = "(BUGGY - OPTIONAL) Max health decreases every hit you take.", threat = 0, enabled = false, alternateNames = [], intName = "OLT", cmod = 0, waveName = ""} // 5
    {type = "special", name = "Spit-tastic!", score = 3, desc = "Spitters. Lots of them.", threat = 99, enabled = false, alternateNames = ["7 Spitters"], intName = "spit", cmod = 0, waveName = ""} // 6
    {type = "wave", name = "The True Waterworks", score = 7, desc = "All modifiers combined into one.", threat = 99, enabled = false, alternateNames = ["The True Waterworks"], intName = "W", cmod = -1.25, waveName = "The True Waterworks"} // 7 (Keep this at bottom)
];

traps <- [
    {name = "shopTrap", cooldown = false, cooldownTime = 55, itemSpawn = "shopTrapSpawn", light = "shopTrapLight", currentTime = 0}
    {name = "platformTrap", cooldown = false, cooldownTime = 55, itemSpawn = "platformTrapSpawn", light = "platformTrapLight", currentTime = 0}
];

// Extra waves that are automatically appended to cMod when specfic criteria are true

extras <- [
    {type = "wave", name = "Raining Cats & Dogs", score = null, desc = null, threat = 8, enabled = null, alternateNames = [""], intName = "C&D"}
];

// cMod lists all of the currently active wave-based modifiers.
// Might be redundant?

cMod <- [

];

lunarScore <- 0

// dogSpawn.nut
//// Shouldn't have any.

// roundManager.nut
waveNext <- RandomInt(2, 4)
waveType <- "none" // Current wave.
validWaves <- ["none"]

// musicManager.nut

baseMus <- ["phase1mus", "phase2mus", "phase3mus"] // Base audio entities..
baseMusLEN <- [3, 4, 3] // Base audio wave length 1m == 1 wave (ROUND DOWN WAVES)

rareMus <- []

RORMus <- ["ror1mus", "ror2mus", "ror3mus"] // Risk of Rain audio entities. UNUSED RIGHT NOW
RORMusLEN <- [3, 4, 3] // read baseMusLEN
mustype <- 0

specialMus <- [] // Rare music. Only to be played in certain events. UNUSED RIGHT NOW

// shop.nut

louisReal <- false
teamCurrency <- 30 // Set to testing value. (Lower later)
Currencymod <- 1 // Multiplicator for currency gained each wave.

// End of init

printl("Global variables init")

// HOOKS

function OnGameEvent_round_end( params )
{
    // Kill louis.
    ClientPrint(null, DirectorScript.HUD_PRINTTALK, "\x04" + "WAVES SURVIVED: " + wavesPassed + ", LUNAR SCORE: " + lunarScore + ", TOTAL: " + (wavesPassed * lunarScore))

    local louis = Entities.FindByModel(null, "models/survivors/survivor_manager.mdl")
    if (louis != null)
    {
        louis.Kill()
    }
}
