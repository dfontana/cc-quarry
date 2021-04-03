local tArgs = {...}
function parseArgs()
  if #tArgs < 2 or #tArgs > 3 then
    print("Usage: cc <width> <length> [<depth> = 0]")
    return false
  end
  local endLoc = {x=tonumber(tArgs[1]),y=0,z=tonumber(tArgs[2])}
  if tArgs[3] ~= nil then
    endLoc.y = 0 - tonumber(tArgs[3])
  end
  return {loc=endLoc}
end