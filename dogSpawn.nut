// Functions for spawning specfic 'special' enemies such as dogs.

function spawnDog()
{
    local dog = null
    local spawnpoint = null
    local spawner = null
    while ( spawner = Entities.FindByName(spawner, "dogSpawn") )
    {
        spawnpoint = spawner.GetOrigin()
        while ( dog = Entities.FindByClassnameWithin(dog, "player", spawnpoint, 100) )
        {
            {
                printl("DOG FOUND! CRIPPLING.")
                dog.SetHealth(600)
                NetProps.SetPropInt(dog, "m_clrRender", 80)
            }
        }

    }
}

function superSpitter()
{
    printl("SPAWNING SPITTERS")
    if (waveType != null)
    {
        local i = 1
        while (i < 7)
        {
            ZSpawn( {type = 4 } )
            i++
        }
    }
    else
    {
        local i = 1
        while (i < 4)
        {
            ZSpawn( {type = 4} )
            i++
        }
    }
}

function spawnCat()
{
    // TODO: Create cats.
    // Aka, wandering witches (in blue)


    local cat = null
    local spawnpoint = null
    local spawner = null
    while ( spawner = Entities.FindByName(spawner, "catSpawn" ) )
    {
        spawnpoint = spawner.GetOrigin()
        cat = Entities.FindByClassnameNearest("witch", spawnpoint, 100);
        cat.SetHealth(700)
    }
}
