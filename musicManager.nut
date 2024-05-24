// Music manager directs music that plays during waves.
// TODO: all of this

// functions

function initMusicType()
{
    if (lunarScore < 8)
    {
        ValidMus <- baseMus
        mustype <- 0
    } else {
        // set mustype to risk of rain, aka 1
        mustype <- 1
    }
}

function startMusic(type) // Play normal music.
{

    function normMusic() // Should've merged them.
    {
        local targetMusic = RandomInt(0, baseMus.len() - 1)
        waveNext <- waveNext + baseMusLEN[targetMusic]
        DoEntFire(baseMus[targetMusic], "PlaySound", "", 0, null, null)
        fireWave()
    }

    function rorMusic()
    {
        local targetMusic = RandomInt(0, RORMus.len() - 1)
        waveNext <- waveNext + RORMusLEN[targetMusic]
        DoEntFire(RORMus[targetMusic], "PlaySound", "", 0, null, null)
        fireWave()
    }

    function specMusic()
    {
        if (waveType == "W")
        {
            waveNext <- 999999
            fireWave()
        }
    }

    if (type == 0)
    {
        if (mustype == 0)
        {
            //call normal music handling
            normMusic()
        }
        else
        {
            // call risk of rain music handling
            rorMusic()
        }
    } else if (type == 1) {
        // Play special / overpower music
        printl("Why did you call this? You haven't done anything with this yet.")
        specMusic()
    }
}
