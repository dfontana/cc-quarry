local tArgs = {...}
if #tArgs > 1 then
  print("Usage: ccs [<gistId>]")
  return
end

local GIST_ID = "d72ae5868a87adeb6345dbe6f041138d"
if #tArgs == 1 then
  GIST_ID = tostring(tArgs[1])
end

function download(uri, scriptName) 
  print("Downloading "..scriptName)
  local file = fs.open(scriptName, "w")
  local str = http.get(uri).readAll()
  file.write(str)
  file.close()
  write("done!")
end

function stripLuaSuffix(s)
  return s:gsub("%.lua", "")
end


download("https://raw.githubusercontent.com/rxi/json.lua/master/json.lua", "json")
local json = require("json")

local gist_string = http.get("https://api.github.com/gists/"..GIST_ID, {["Accept"]="application/vnd.github.v3+json"}).readAll()
local gist = json.decode(gist_string)
for filename, data in pairs(gist.files) do
  download(data.raw_url, stripLuaSuffix(filename))
end

print("")
print("Setup complete! Run 'ccq'")