-- Quarry
--
-- Utilizes a static grid system of relative coordinates to an origin (0,0,0) and directions.
-- In this case, the cardinal directions map to the positive domain; eg: N is positive z, E is
-- positive X.
--
-- The turtle should stay within the positive x,y,z directions. This is just to simplify the 
-- general turtle handling overall, albeit much of the code functions without this assumption
-- 
-- The turtle assumes the following setup ([] = Block or Air, T = Turtle, C = Chest)
-- the turtle should be placed facing Up (in this diagram; eg away from the chests)
--
-- [][][][][][]
-- [][][][][][]
-- [][][][][][]
-- T [][][][][]
--   C C C C C 
--
-- Note: Be sure to label your turtles (`label set foo`) so you don't lose fuel or programs

os.loadAPI("ccqArg")
os.loadAPI("ccqPrim")
os.loadAPI("ccqUtil")

-- Constants used to reset the turtle
local ORIGIN_LOC = {x=0,y=0,z=0}
local ORIGIN_DIR = 'N'

-- Offset coordinates from the turtle's current location. This means
-- the turtle uses relative location. If the program reboots the turtle
-- will be lost
local currentLoc = {x=0,y=0,z=0}
local currentDir = 'N'

-- Stores where the turtle stopped when it goes to return home. Is used to
-- help the turtle bee-line back to where it was efficiently
local leftOffAtLoc = {x=0,y=0,z=0}
local leftOffAtDir = 'N'

local tArgs = {...}

-- ===========================================================================
-- =================        MAIN LOOP        =================================
-- ===========================================================================

function mainLoop() 
  -- Parse args and unpack to globals
  local args = ccqArg.parseArgs(tArgs)
  if args == false then
    return
  end
  END_LOC = args.loc

  -- DEFECTS
  -- 1. Turtle digs one too many columns, can we do better?
  print("[Main] Going to "..ccqUtil.locString(END_LOC))
  while currentLoc.y >= END_LOC.y do
    layerRoutine()
    local originShaft = {x=ORIGIN_LOC.x,z=ORIGIN_LOC.z,y=currentLoc.y}
    goToLoc(originShaft, ORIGIN_DIR)
    if digDown(3) == false then
      goToLoc(ORIGIN_LOC, ORIGIN_DIR)
      print("Something blocked moving down!")
      return
    end
  end
  dumpInventory()
end

function layerRoutine()
  while currentLoc.x < END_LOC.x do
    local isEvn = currentLoc.x % 2 == 0
    local rowRotation = isEvn and 'S' or 'N'
    while rowCheck(isEvn) do
      print("[Main] "..ccqUtil.locString(currentLoc))
      if digRoutine() == 1 then
        return
      end
    end
    currentDir = ccqPrim.rotate(currentDir, 'E')
    if digRoutine() == 1 then
      return
    end
    currentDir = ccqPrim.rotate(currentDir, rowRotation)
  end
end

function rowCheck(isEvn) 
  if isEvn then 
    return currentLoc.z < END_LOC.z 
  else 
    return currentLoc.z > 0 
  end
end

function digRoutine() 
  if ccqPrim.hasFuelToMove(ccqUtil.costToDest(currentLoc, ORIGIN_LOC)) == false then
    print("[Dig] Cannot move without stranding, returning home")
    goToLoc(ORIGIN_LOC, ORIGIN_DIR)
    return 1
  end
  if digForward() == 0 then
    print("[Dig] Inventory Full, Need to Empty")
    ccqUtil.copyLocToLoc(leftOffAtLoc, currentLoc)
    leftOffAtDir = currentDir
    dumpInventory()
    resume()
  end
  return 0
end

-- ===========================================================================
-- =================    HIGH LEVEL APIS    ===================================
-- ===========================================================================

-- Will return the turtle home, followed by moving to each chest dumping its 
-- inventory until its empty or theres no more chest room, which ever comes first.
-- It will then return home again.
--
-- In the event it's inventory isn't empty after this the function will return 
-- false, otherwise true
function dumpInventory()
  print("[Dump] Emptying Inventory")
  goToLoc(ORIGIN_LOC, ORIGIN_DIR)
  currentDir = ccqPrim.rotate(currentDir, 'E')
  local notChest = false
  repeat
    print("[Dump] Current "..ccqUtil.locString(currentLoc))
    forward()
    currentDir = ccqPrim.rotate(currentDir, 'S')
    -- are we looking at a chest?
    local success, data = turtle.inspect()
    if success == false or data.name ~= 'minecraft:chest' then
      print("[Dump] No more chests, stopping")
      break
    end
    -- Dump inventory
    for i = 1, 16 do
      turtle.select(i)
      -- Skip fuel items && empty slots
      if turtle.getItemCount() ~= 0 and turtle.refuel(0) == false then
        if turtle.drop() == false then
          -- inventory is full, go to next
          break
        end
      end
    end
    turtle.select(1)
    currentDir = ccqPrim.rotate(currentDir,'E')
  until notChest
  print("[Dump] Stopped at "..ccqUtil.locString(currentLoc))
  goToLoc(ORIGIN_LOC, ORIGIN_DIR)
end

-- Returns the turtle to where it left off, but only if it has at least 
-- (2 * Fuel-for-Trip) + 1 (to ensure it can get home).
-- This will return false if it could not do this as a result.
function resume()
  if ccqPrim.hasFuelToMove(2 * ccqUtil.costToDest(currentLoc, leftOffAtLoc)) == false then
    print("[Resume] Cannot resume, not enough fuel")
    return false
  end
  print("[Resume] Returning to left off loc")
  goToLoc(leftOffAtLoc, leftOffAtDir)
end

-- Sends the turtle to the given loc and direction
function goToLoc(loc, direction)
  local xDiff = currentLoc.x - loc.x
  local xDir = xDiff > 0 and 'W' or 'E'
  travel(xDiff, xDir)
  local zDiff = currentLoc.z - loc.z
  local zDir = zDiff > 0 and 'S' or 'N'
  travel(zDiff, zDir)
  local yDiff = currentLoc.y - loc.y
  local yDir = yDiff > 0 and 'D' or 'U'
  travel(yDiff, yDir)
  currentDir = ccqPrim.rotate(currentDir, direction)
  ccqUtil.copyLocToLoc(currentLoc, loc)
  currentDir = direction
end

-- Travel the given number of units in the given direction
-- units maybe positive or negative, it doesn't matter
function travel(units, direction)
  if units ~= 0 then
    if direction ~= 'U' and direction ~= 'D' then
      -- Rotate when on cartesian plane
      currentDir = ccqPrim.rotate(currentDir, direction)
    end
    for i = 1, math.abs(units) do
      if direction == 'U' then
        if turtle.detectUp() then
          turtle.digUp()
        end
        turtle.up()
      elseif direction == 'D' then
        if turtle.detectDown() then
          turtle.digDown()
        end
        turtle.down()
      else
        if turtle.detect() then
          turtle.dig()
        end
        turtle.forward()
      end
    end
  end
end

-- Digs the 3 blocks in front of the turtle and moves forward
-- Returns the number of items it was able to pick up
-- If the turtle returns 0 enough its suggestive there's nothing left for it to fit
function digForward() 
  if turtle.detectUp() then
    local successUp, dataUp = turtle.inspectUp()
    if successUp and ccqPrim.canFitItem(dataUp.name) then
      turtle.digUp()
    else
      return 0
    end
  end
  if turtle.detectDown() then
    local successDn, dataDn = turtle.inspectDown()
    if successDn and ccqPrim.canFitItem(dataDn.name) then
      turtle.digDown()
    else
      return 0
    end
  end
  if turtle.detect() then
    local success, data = turtle.inspect()
    if success and ccqPrim.canFitItem(data.name) then
      turtle.dig()
    else 
      return 0
    end
  end
  forward()
  return -1
end

-- Move the turtle down {times}. If there are blocks in the way it will
-- dig itself out. If it can't dig or move through, then return false
function digDown(times)
  for i=1,times do
    if turtle.detectDown() then
      if turtle.digDown() == false then
        return false
      end
    end
    if turtle.down() == false then
      return false
    end
    currentLoc.y = currentLoc.y - 1
  end
  return true
end

-- Move the Bot Forward, updating the locRef with the result
function forward() 
  if turtle.forward() then
    if currentDir == 'N' then
      currentLoc.z = currentLoc.z + 1
    elseif currentDir == 'S' then
      currentLoc.z = currentLoc.z - 1
    elseif currentDir == 'E' then
      currentLoc.x = currentLoc.x + 1
    else
      currentLoc.x = currentLoc.x - 1
    end
    return true
  end
  return false
end

mainLoop()