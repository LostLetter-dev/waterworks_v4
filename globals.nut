// File for holding global variables.
// This is because scripts can access global vars from anywhere (so long as it's loaded) because VScript is based.

// General
wavesPassed <- -1 // Used more by roundManager, updates every horde event.
gameON <- false // used to determine if OLT hooks should fire

// Used by OLT and potentially Disorderly Combat

survivors <- [
    {name = "Ellis", maxHP = 100, entity = null}
    {name = "Nick", maxHP = 100, entity = null}
    {name = "Coach", maxHP = 100, entity = null}
    {name = "Rochelle", maxHP = 100, entity = null}
];

DONSpawn <- false // Double or nothing 'something is spawning' check.

// warnLunar.nut (Lunar Modifiers)

modifiers <- [
    {type = "wave", name = "Dog Rounds", score = 2, desc = "Tanks with low health spawn during special waves.", threat = 5, enabled = false, alternateNames = ["butterian"], intName = "dog", cmod = 0, waveName = "dog"} // 0
    {type = "wave", name = "Cat Rounds", score = 2, desc = "Spawn wandering witches during special waves.", threat = 3, enabled = false, alternateNames = ["witches and whores"], intName = "cat", cmod = 0, waveName = "Cats"} // 1
    {type = "special", name = "The Battleship", score = 4, desc = "Map's dedicated boss fight.", threat = 5, enabled = false, alternateNames = ["Valenguardian Intervention"], intName = "ship", cmod = 0, waveName = "The Battleship"} // 2
    {type = "general", name = "Disorderly Combat", score = 2, desc = "No ammo piles or permanent guns - buy weapons to survive.", threat = 0, enabled = false, alternateNames = [], intName = "DC", cmod = 0, waveName = ""} //3
    {type = "general", name = "Double or Nothing", score = 3, desc = "Some things doubled, some things halved.", threat = 0, enabled = false, alternateNames = [], intName = "DoN", cmod = 1, waveName = ""} // 4
    {type = "general", name = "One Last Thrill", score = 4, desc = "Max health decreases every hit you take.", threat = 0, enabled = false, alternateNames = [], intName = "OLT", cmod = 0, waveName = ""} // 5
    {type = "special", name = "Spit-tastic!", score = 3, desc = "Spitters. Lots of them.", threat = 99, enabled = false, alternateNames = ["7 Spitters"], intName = "spit", cmod = 0, waveName = ""} // 6
    {type = "special", name = "The True Waterworks", score = 15, desc = "(IS YOUR TEARS)", threat = 99, enabled = false, alternateNames = [], intName = "WATERWORKS", cmod = -1.25, waveName = ""} // 7 (Keep this at bottom)
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

// cGen lists all of the currently added 'general' or 'special' modifiers.
// Splitting them should increase performance *and* might reduce my confusion later.

cGen <- [

];



lunarScore <- 0

// dogSpawn.nut
//// Shouldn't have any.

// roundManager.nut
waveNext <- 0
waveType <- "none" // Current wave.
validWaves <- ["none"]

specialPassed <- 0 // Counts how many special waves have passed. Might be used for music handling later. (POTENTIAL REDUNDANCY)

// musicManager.nut

baseMus <- ["phase1mus", "phase2mus", "phase3mus"] // Base audio entities..
baseMusLEN <- [3, 4, 3] // Base audio wave length 1m == 1 wave (ROUND DOWN WAVES)

RORMus <- [] // Risk of Rain audio entities. UNUSED RIGHT NOW
RORMusLEN <- [] // read baseMusLEN
mustype <- 0

specialMus <- [] // Rare music. Only to be played in certain events. UNUSED RIGHT NOW

// shop.nut

teamCurrency <- 30 // Set to testing value. (Lower later)
Currencymod <- 1 // Multiplicator for currency gained each wave.

// End of init

printl("Global variables init")

// HOOKS

function OnGameEvent_round_end( params )
{
    // Kill louis.
    printl("h")

    local louis = Entities.FindByModel(null, "models/survivors/survivor_manager.mdl")
    if (louis != null)
    {
        louis.Kill()
    }
}
