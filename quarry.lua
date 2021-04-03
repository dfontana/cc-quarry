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

-- Defines a left transform on direction of 1
local LEFT_DIR = {
  'N': 'W',
  'W': 'S',
  'S': 'E',
  'E': 'N'
}

-- Constants used to reset the turtle
local ORIGIN = {'x': 0, 'y': 0, 'z': 0}
local ORIGIN_DIR = 'N'

-- Offset coordinates from the turtle's current location. This means
-- the turtle uses relative location. If the program reboots the turtle
-- will be lost
local currentLoc = {'x': 0, 'y': 0, 'z': 0}
local currentDir = 'N'

-- Stores where the turtle stopped when it goes to return home. Is used to
-- help the turtle bee-line back to where it was efficiently
local leftOffAtLoc = {'x': 0, 'y': 0, 'z': 0}
local leftOffAtDir = 'N'

-- ===========================================================================
-- =================        MAIN LOOP        =================================
-- ===========================================================================

function mainLoop() 
  -- TODO
  -- General idea
  -- 1. Start are Origin
  -- 2. While currentLoc.x < max x
  --   3. While currentLoc < max z, detect forward:
  --      a digRoutine
  --   4. rotate E
  --      a digRoutine
  --   5. rotate S
  --   6. While currentLoc.z != 0, detect forward:
  --      a digRoutine
  --   7. rotate E
  --      a digRoutine
  --   8. rotate N
  -- 9. return home
  --
  --
  -- digRoutine:
  --   a if not hasFuelToMove(costToDest(ORIGIN_LOC))
  --     b go home
  --     c exit routine
  --   b if not block: forward
  --     d return early
  --   a if block: digForward
  --     a if no items were picked up, dumpInventory()
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
  leftOffAtLoc = currentLoc
  leftOffAtDir = currentDir
  goToLoc(ORIGIN, ORIGIN_DIR)
  rotate('E')
  local invEmpty = false
  local notChest = false
  repeat
    forward()
    rotate('S')
    -- are we looking at a chest?
    local success, data = turtle.inspect()
    if success == false or data.name ~= 'minecraft:chest' then
      break
    end
    -- Dump inventory
    for i = 1, 16 do
      turtle.select(i)
      -- Skip fuel items
      if turtle.refuel(0) == false then
        if turtle.drop() then
          -- inventory is full, go to next
          break
        end
      end
    end
    -- Check if inv is cleared of non-fueld items
    for i = 1, 16 do
      turtle.select(i)
      -- Skip fuel items
      if turtle.refuel(0) == false then
        invEmpty = turtle.getItemCount() > 0 && invEmpty
      end
    end
    rotate('E')
  until invEmpty or notChest
  goToLoc(ORIGIN, ORIGIN_DIR)
end

-- Returns the turtle to where it left off, but only if it has at least 
-- (2 * Fuel-for-Trip) + 1 (to ensure it can get home).
-- This will return false if it could not do this as a result.
function resume()
  if hasFuelToMove(2 * costToDest(leftOffAtLoc)) == false then
    return false
  end
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
  rotate(direction)
  currentLoc = loc
  currentDir = direction
end

-- ===========================================================================
-- =================    INNER API (don't call from MainLoop ideally)    ======
-- ===========================================================================

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

-- Digs the 3 blocks in front of the turtle and moves forward, if there is a block in front.
-- Returns the number of items it was able to pick up or -1 if nothing happened
-- If the turtle returns 0 enough its suggestive there's nothing left for it to fit
function digForward() 
  if turtle.detect() then
    local itemsPickedUp = 0
    local success, data = turtle.inspect()
    if success and canFitItem(data.name) then
      turtle.dig()
      itemsPickedUp = itemsPickedUp + 1
    end
    forward()
    local successUp, dataUp = turtle.inspectUp()
    if successUp and canFitItem(dataUp.name) then
      turtle.digUp()
      itemsPickedUp = itemsPickedUp + 1
    end
    local successDn, dataDn = turtle.inspectDown()
    if successDn and canFitItem(dataDn.name) then
      turtle.digUp()
      itemsPickedUp = itemsPickedUp + 1
    end
    return itemsPickedUp
  end
  return -1
end

-- Travel the given number of units in the given direction
-- units maybe positive or negative, it doesn't matter
function travel(units, direction) 
  if units ~= 0 then
    if direction == 'U' or direction == 'D' then
      -- Ensure travel is correct given sign
      direction = units > 0 and 'U' or 'D'
    else
      -- Rotate when on cartesian plane
      rotate(direction)
    end
    for i = 1, math.abs(units) then
      if direction == 'U' then
        turtle.up()
      elseif direction == 'D' then
        turtle.down()
      else
        turtle.forward()
      end
    end
  end
end

-- Rotate the turtle until it faces the given Dir
function rotate(direction)
  while currentDir ~= direction then
    turtle.turnLeft()
    currentDir = LEFT_DIR[direction]
  end 
end

-- Computes the cost to travel from current location to the given loc tuple
function costToDest(loc) 
  -- manhattan distance: |x2-x1| + |y2-y1| + |z2-z1|
  return math.abs(currentLoc.x - loc.x) + math.abs(currentLoc.y - loc.y) + math.abs(currentLoc.z - loc.z)
end

-- Checks inventory fullness against the given item for space
-- Returning true if the item could be fit
function canFitItem(itemName) 
  for i = 1, 16 do
    turtle.select(i)
    local slot = turtle.getItemDetail(i)
    if slot and slot.name == itemName and turtle.getItemSpace(i) ~= 0 then
      return true
    end
  end
  return false
end

-- Determine if there is enough fuel left to execute an action that consumes one fuel (eg move forward)
-- after arriving at the destionation (the given cost). This will implicitly refuel the turtle as 
-- much as it can before computing the boolean
--
-- Consumes: costToDest -- the cost to move to the destination (see costToDest function)
--
-- return true if so, false if not
function hasFuelToMove(costToDest) 
  refuel()
  return turtle.getFuelLevel() - costToDest >= 1
end


-- Attempts to consume anything from the inventory to increase fuel level.
-- Since it's not plausible to detect how much something is worth in fuel
-- this method instead naively tries to increase fuel level one by one until
-- the level is unchanged or maxed out, meaning there's no more fuel to be consumed.
-- 
-- To be conservative this will only run when fuel is at 75%
function refuel() 
  local currentLevel = turtle.getFuelLevel()
  local fuelLimit = turtle.getFuelLimit()
  if fuelLimit * 0.75 < currentLevel then
    return
  end
  repeat 
    for i = 1, 16 do
      turtle.select(i)
      if turtle.refuel(0) then
        turtle.refuel(1)
        break
      end
    end
    newLevel = turtle.getFuelLevel()
  until fuelLimit == newLevel or newLevel == currentLevel
end