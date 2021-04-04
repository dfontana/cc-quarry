local tArgs = {...}
if #tArgs > 1 then
  print("Usage: cc-setup [<branchName> = main]")
  return
end

local BRANCH_NAME = "main"
if #tArgs == 1 then
  BRANCH_NAME = tostring(tArgs[1])
end

function download(scriptPath, scriptName) 
  print("Downloading "..scriptName)
  local file = fs.open(scriptName, "w")
  local uri = "https://raw.githubusercontent.com/dfontana/cc-quarry/"..BRANCH_NAME.."/"..scriptPath..".lua"
  print("URI: "..uri)
  local str = http.get(uri).readAll()
  file.write(str)
  file.close()
  write("done!")
end

download('cc-quarry', 'ccq')
download('api/cc-quarry-arguments', 'ccqArg')
download('api/cc-quarry-primitives', 'ccqPrim')
download('api/cc-quarry-utils', 'ccqUtil')

print("")
print("Setup complete! Run 'ccq'")