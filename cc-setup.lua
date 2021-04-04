local GIST_ID = "d72ae5868a87adeb6345dbe6f041138d"

function download(uri, scriptName) 
  print("Downloading "..scriptName)
  local file = fs.open(scriptName, "w")
  local str = http.get(uri).readAll()
  file.write(str)
  file.close()
  write("done!")
end

download("https://raw.githubusercontent.com/rxi/json.lua/master/json.lua", "json")
os.loadAPI("json")

local gist_string = http.get("https://api.github.com/gists/"..GIST_ID, {["Accept"]="application/vnd.github.v3+json"}).readAll()
local gist = json.decode(gist_string)
for filename, data in pairs(gist.files) do
  print(filename, data.content)
  download(data.raw_url, filename)
end

print("")
print("Setup complete! Run 'ccq'")