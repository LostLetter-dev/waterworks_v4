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
                if (dog != null)
                {
                    dog.SetHealth(450)
                    NetProps.SetPropInt(dog, "m_clrRender", 80)
                }


            }
        }

    }
}

function superSpitter()
{
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
    // Aka, wandering witches


    local cat = null
    local spawnpoint = null
    local spawner = null
    while ( spawner = Entities.FindByName(spawner, "catSpawn" ) )
    {
        spawnpoint = spawner.GetOrigin()
        cat = Entities.FindByClassnameNearest("witch", spawnpoint, 100);
        if (cat != null)
        {
            cat.SetHealth(350)
        }

    }
}
