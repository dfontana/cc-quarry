-- Primitives are actions a turtle might take, that don't alter a global state
-- or reference. They can occur on their own accord and have no side effects
-- on the overall state. They can, however, alter something about the bot:
-- position, rotation, etc.

-- Attempts to consume anything from the inventory to increase fuel level.
-- Since it's not plausible to detect how much something is worth in fuel
-- this method instead naively tries to increase fuel level one by one until
-- the level is unchanged or maxed out, meaning there's no more fuel to be consumed.
-- 
-- To be conservative this will only run when fuel is at 75%
function refuel() 
  local currentLevel = turtle.getFuelLevel()
  local fuelLimit = turtle.getFuelLimit()
  if currentLevel > 1000 then
    return
  end
  print("[Refuel] Fuel Level: "..currentLevel.." / "..fuelLimit)
  repeat 
    local consumedSomething = false
    for i = 1, 16 do
      turtle.select(i)
      if turtle.refuel(0) then
        turtle.refuel(1)
        consumedSomething = true
        break
      end
    end
    turtle.select(1)
    if consumedSomething == false then
      print("[Refuel] No more fuel to consume")
      break
    end
    newLevel = turtle.getFuelLevel()
    print("[Refuel] Fuel Level: " .. newLevel)
  until newLevel > fuelLimit * 0.75
end

-- Travel the given number of units in the given direction
-- units maybe positive or negative, it doesn't matter
function travel(units, direction)
  if units ~= 0 then
    if direction ~= 'U' and direction ~= 'D' then
      -- Rotate when on cartesian plane
      currentDir = rotate(currentDir, direction)
    end
    for i = 1, math.abs(units) do
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

-- Checks inventory fullness against the given item for space
-- Returning true if the item could be fit
function canFitItem(itemName) 
  for i = 1, 16 do
    turtle.select(i)
    local slot = turtle.getItemDetail(i)
    if slot == nil or (slot and slot.name == itemName and turtle.getItemSpace(i) ~= 0) then
      turtle.select(1)
      return true
    end
  end
  turtle.select(1)
  print("[Fit] Cannot fit Item")
  return false
end

-- Rotate the turtle until it faces the given Dir
-- Must provide the direction it is currently facing
-- Will return the final direction its facing for ease of setting vars.
local LEFT_DIR = {N='W',W='S',S='E',E='N'}
function rotate(facing, direction)
  if targetDir == direction then
    return targetDir
  end
  turtle.turnLeft()
  return rotate(LEFT_DIR[targetDir], direction)
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