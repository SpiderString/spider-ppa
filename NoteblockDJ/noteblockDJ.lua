--bind to a key or whatever
local instrumentList="instruments" --path to your list of registered instruments
local songList="songs" --path to your list of registered songs
local defaultInstrument="CivPiano"
local tempoModifier

--Example song format
--instrument is optional, will default to whatever your default instrument is
--instrument name can technically be anything,
--but track title should be the same as a registered instrument on your setup
--to use it properly without it just defaulting

--SongName{
--	{note:0;length:50;instrument:piano}
--	{note:4;length:25;instrument:piano}
--	{note:6;length:25}
--}

local function writeInstrument(instrument)
  local instReg=filesystem.open(instrumentList, "a")
  instReg.write(instrument.name.."{\n")
  for pitch, block in pairs(instrument) do
    if pitch~="name" then
      instReg.write("\t"..pitch..":{x:"..block[1]..";y:"..block[2]..";z:"..block[3].."}\n")
    end
  end
  instReg.write("}\n")
  instReg:close()
end

local function getSongs()
  local songs={}
  local song
  for i, line in pairs(catRel(songList)) do
    if tostring(i):lower()~="lines" then
      if line:match("{$") then
        song={}
        song.notes={}
        song.name=line:sub(1, line:find("{")-1)
      elseif line:match("^}") and song.name~=nil then
        table.insert(songs, song)
        song=nil
      else
        if line:match("^[%s]+{") and song.name~=nil then
          local note, length, instrument, tempo
          local a, b
          if line:match("note:") then
            a, b = line:find("note:")
            a=line:find(";", b)
            if a==nil then
              a=line:find("}")
            end
            note=line:sub(b+1,a-1)
            a=nil; b=nil
          end
          if line:match("length:") then
            a, b = line:find("length:")
            a=line:find(";", b)
            if a==nil then
              a=line:find("}")
            end
            length=line:sub(b+1, a-1)
            a=nil; b=nil
          end
          if line:match("instrument:") then
            a, b = line:find("instrument:")
            a=line:find(";", b)
            if a==nil then
              a=line:find("}")
            end
            instrument=line:sub(b+1, a-1)
            a=nil; b=nil
          end
          if line:match("tempo:") then
            a, b = line:find("tempo:")
            a=line:find(";", b)
            if a==nil then
              a=line:find("}")
            end
            tempo=line:sub(b+1, a-1)
            a=nil; b=nil
          end
          if note~=nil and length~=nil then
            if instrument==nil then
              instrument=defaultInstrument
            end
            table.insert(song.notes, {["tempo"]=tonumber(tempo), ["note"]=tonumber(note), ["length"]=tonumber(length), ["instrument"]=instrument})
            note=nil; length=nil; instrument=nil; tempo=nil
          end
        end
      end
    end
  end
  return songs
end

local function getInstrumentNote(inst, note)
  local instReg=catRel(instrumentList)
  local foundInst=false
  local foundNote=false
  local x, y, z
  for id, line in pairs(instReg) do
    if tostring(id):lower()~="lines" then
      if line:lower():match("^"..inst:lower().."{") then
        foundInst=true
      end
      if foundInst and not foundNote then
        if line:match(tostring(note)..":{") then
          foundNote=true
          local a, b
          a=line:find("{")
          b=line:find("}")
          local strTable=split(line:sub(a+1, b-1), ";")
          x=tonumber(split(strTable[1], ":")[2])
          y=tonumber(split(strTable[2], ":")[2])
          z=tonumber(split(strTable[3], ":")[2])
        end
      end
    end
  end
  return {["x"]=x, ["y"]=y, ["z"]=z}
end

local function playNote(note)
  --look at note,
  --store time,
  --play note,
  --look at next note
  --wait until time
  --play next note
  --repeat
  local noteBlock=getInstrumentNote(note.instrument, note.note)
  if note.tempo~=nil then
    tempoModifier=note.tempo
  end
  --Currently this may cause issues with different noteblock arrangements
  lookAt(noteBlock.x+0.5, noteBlock.y+1, noteBlock.z+0.5)
  sleep(30)
  attack()
  sleep(note.length*tempoModifier)
end

local function playSong(song)
  local notes=song.notes
  tempoModifier=1
  local i=1
  for id, note in pairs(notes) do
    playNote(notes[i])
    i=i+1
  end
  tempoModifier=1
  log("Finished playing \""..song.name.."\"")
end



local notes={
	"F#3/G♭3",
	"G3",
	"G#3/A♭3",
	"A3",
	"A#3/B♭3",
	"B3",
	"C4",
	"C#4/D♭4",
	"D4",
	"D#4/E♭4",
	"E4",
	"F4",
	"F#4/G♭4",
	"G4",
	"G#4/A♭4",
	"A4",
	"A#4/B♭4",
	"B4",
	"C5",
	"C#5/D♭5",
	"D5",
	"D#5/E♭5",
	"E5",
	"F5",
	"F#5/G♭5"
}
local pitches={}
local click=0
for i, note in pairs(notes) do
  pitches[note]=click
  click=click+1
end

run("spiderLib")
local choice=prompt("What would you like to do?", "choice", "Play a song", "Make a song", "Register an instrument", "Delete an instrument")
if choice=="Register an instrument" then
  choice=nil
  choice=prompt("Enter a name for the instrument", "text")
  --TODO: check if the instrument already exists
  if choice then
    local instrument={}
    instrument.name=choice
    log("Punch a noteblock to register it, press enter when finished.")
    local canRegister=true
    while not isKeyDown("RETURN") do
      if not canRegister then
        while isKeyDown("LMB") do end
        canRegister=true
      end
      if isKeyDown("LMB") and getBlock(table.unpack(getPlayer().lookingAt)).name=="Note Block" then
        local noteExists=false
        local lookingAt=getPlayer().lookingAt
        for i, val in pairs(instrument) do
          if val[1]==lookingAt[1] and val[2]==lookingAt[2] and val[3]==lookingAt[3] and val[1]~=nil then
            choice=prompt("This noteblock has already been registered. Delete it?", "choice", "No", "Yes")
            if choice=="Yes" then
              instrument[i]=nil
            end
            noteExists=true
          end
        end
        if not noteExists then
	  choice=prompt("What note is this?", "choice", table.unpack(notes))
          if choice then
            --write noteblock to instrument
            instrument[pitches[choice]]=lookingAt
          end
        end
        canRegister=false
      end
    end
    --write instrument to instrument registry
    writeInstrument(instrument)
    log("Instrument \""..instrument.name.."\" Registered!")
  end
elseif choice=="Delete an instrument" then

elseif choice=="Make a song" then


elseif choice=="Play a song" then
  local songs=getSongs()
  local songNames={}
  for id, song in pairs(songs) do
    table.insert(songNames, song.name)
  end
  choice=nil
  choice=prompt("What song would you like to play?", "choice", table.unpack(songNames))
  if choice then
    local song
    for id, val in pairs(songs) do
      if val.name==choice then
        song=val
      end
    end
    playSong(song)
  end
end
