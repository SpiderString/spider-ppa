--A simple script which can tune noteblocks for you
--bind to a key, though it can be run by other means if you want.
--Look at a noteblock and, when run, it will prompt you to pick a key and it will tune it to that note
--The noteblock should be tuned to the lowest setting, though, so it may be best to re-place it before running the script.
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
local note=prompt("Pick a note", "choice", table.unpack(notes))

if note then
  for i=0, pitches[note], 1 do
    use()
    sleep(50)
  end
  log("Tuned to "..note)
end
