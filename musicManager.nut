// Music manager directs music that plays during waves.
// TODO: all of this

// functions

function initMusicType()
{
    if (lunarScore < 3)
    {
        ValidMus <- baseMus
        mustype <- 0
    } else {
        // set mustype to risk of rain, aka 1
        mustype <- 0
    }
}

function startMusic(type) // Play normal music.
{

    function normMusic() // really didn't want to make a new function but it was the only way I could get thiS POS to work.
    {
        local targetMusic = RandomInt(0, baseMus.len() - 1)
        waveNext <- waveNext + baseMusLEN[targetMusic]
        DoEntFire(baseMus[targetMusic], "PlaySound", "", 0, null, null)
        fireWave()
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
            printl("THIS ISN'T SUPPSOED TO HAPPPEN!! INVALID MUSIC")
        }
    } else if (type == 1) {
        // Play special / overpower music
        printl("Why did you call this? You haven't done anything with this yet.")
    }
}
