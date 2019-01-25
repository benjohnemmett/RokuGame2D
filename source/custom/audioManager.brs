'
'
'
'

function audioManager() as object

  am = {}

  am.audioPlayer = CreateObject("roAudioPlayer")
  am.audioPort = CreateObject("roMessagePort")
  am.audioPlayer.SetMessagePort(am.audioPort)
  am.audioPlayerPlaying = false
  am.loadTimeout = 3000 ' Time out to wait for song to load before going to the backup
  am.defaultBackupURL = invalid

  am.stop = function() as void
    m.audioPlayer.stop()
    m.audioPlayerPlaying = false
  end function

  am.pause = function() as void
    m.audioplayer.pause()
  end function

  am.play = function() as void
    m.audioplayer.play()
    m.audioPlayerPlaying = true
  end function

  am.resume = function() as void
    m.audioplayer.resume()
  end function

  am.playDefaultSong = function() as void
    m.playSong(m.defaultBackupURL)
  end function

  am.playSong = function(primeURL as string)
    m.playSongWithBackup(primeURL, m.defaultBackupURL)
  end function

  ' Play a song from the given URL, provide a backup URL (typically local) in case the primary fails to load.'
  am.playSongWithBackup = function(primeURL as string, backupURL)
    g = GetGlobalAA()
    if(g.settings.music = "On") then
      if m.audioPlayerPlaying = false then

        m.audioplayer.setContentList([{url:primeURL}])
        m.audioplayer.setloop(true)
        m.audioPlayer.play()

        clock = CreateObject("roTimespan")

        while clock.TotalMilliseconds() < m.loadTimeout
          event = m.audioPort.GetMessage()

          if (type(event) = "roAudioPlayerEvent") then
                    ''?"Got event "; event
              if event.isStatusMessage() then
                msg = event.getMessage()
                ''?"AudioPLayerEvent "; msg
                if (msg = "start of play") then
                  ?"Playing!";msg
                end if

              else if event.isRequestFailed() then ' Play local'
                msg = event.getMessage()
                ?"AudioPLayerEvent "; msg
                ?"Backup plan"
                m.audioplayer.setContentList([{url:"pkg:/components/audio/MakeMyDay.mp3"}])
                m.audioplayer.setloop(true)
                m.audioPlayer.play()

                exit while
              end if

          end if

        end while ' 3 second timeout'
        ?"Done waiting"
      end if ' if Not playing'

      m.audioPlayerPlaying = true
    else ' If music set to off '
      m.Stop()
    end if

  end function

  return am

end function
