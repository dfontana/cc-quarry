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

os.loadAPI("cc-quarry-arguments")
os.loadAPI("cc-quarry-helpers")
os.loadAPI("cc-quarry-primitives")
os.loadAPI("cc-quarry-utils")

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

-- ===========================================================================
-- =================        MAIN LOOP        =================================
-- ===========================================================================

function mainLoop() 
  -- Parse args and unpack to globals
  local args = parseArgs()
  if args == false then
    return
  end
  END_LOC = args.loc

  -- DEFECTS
  -- 1. Turtle digs one too many columns, can we do better?
  -- 1. Updating is a royal PITA. Would be nice to autoupdate on run...
  --    a. optionally from a branch name if we can do github...
  -- 3. need to break up this file
  print("[Main] Going to "..locString(END_LOC))
  while currentLoc.y >= END_LOC.y do
    layerRoutine()
    local originShaft = {x=ORIGIN_LOC.x,z=ORIGIN_LOC.z,y=currentLoc.y}
    goToLoc(originShaft, ORIGIN_DIR)
    if digDown(3, currentLoc) == false then
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
      print("[Main] "..locString(currentLoc))
      if digRoutine() == 1 then
        return
      end
    end
    currentDir = rotate(currentDir, 'E')
    if digRoutine() == 1 then
      return
    end
    currentDir = rotate(currentDir, rowRotation)
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
  if hasFuelToMove(costToDest(currentLoc, ORIGIN_LOC)) == false then
    print("[Dig] Cannot move without stranding, returning home")
    goToLoc(ORIGIN_LOC, ORIGIN_DIR)
    return 1
  end
  if digForward(currentLoc) == 0 then
    print("[Dig] Inventory Full, Need to Empty")
    copyLocToLoc(leftOffAtLoc, currentLoc)
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
  currentDir = rotate(currentDir, 'E')
  local notChest = false
  repeat
    print("[Dump] Current "..locString(currentLoc))
    forward(currentLoc)
    currentDir = rotate(currentDir, 'S')
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
    currentDir = rotate(currentDir,'E')
  until notChest
  print("[Dump] Stopped at "..locString(currentLoc))
  goToLoc(ORIGIN_LOC, ORIGIN_DIR)
end

-- Returns the turtle to where it left off, but only if it has at least 
-- (2 * Fuel-for-Trip) + 1 (to ensure it can get home).
-- This will return false if it could not do this as a result.
function resume()
  if hasFuelToMove(2 * costToDest(currentLoc, leftOffAtLoc)) == false then
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
  currentDir = rotate(currentDir, direction)
  copyLocToLoc(currentLoc, loc)
  currentDir = direction
end

mainLoop()