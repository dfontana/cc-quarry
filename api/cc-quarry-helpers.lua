-- Helpers actually alter the quarry state through reference, and may be very
-- specific to the quarry behavior. An item in here pretty much has to 
-- consume a reference; if it's not maybe it belongs as a primitive or util?

-- Digs the 3 blocks in front of the turtle and moves forward
-- Returns the number of items it was able to pick up
-- If the turtle returns 0 enough its suggestive there's nothing left for it to fit
function digForward(locRef) 
  local itemsPickedUp = 0
  local didDig = false
  if turtle.detect() then
    didDig = true
    local success, data = turtle.inspect()
    if success and ccqPrim.canFitItem(data.name) then
      turtle.dig()
      itemsPickedUp = itemsPickedUp + 1
    end
  end
  forward(locRef)
  if turtle.detectUp() then
    didDig = true
    local successUp, dataUp = turtle.inspectUp()
    if successUp and ccqPrim.canFitItem(dataUp.name) then
      turtle.digUp()
      itemsPickedUp = itemsPickedUp + 1
    end
  end
  if turtle.detectDown() then
    didDig = true
    local successDn, dataDn = turtle.inspectDown()
    if successDn and ccqPrim.canFitItem(dataDn.name) then
      turtle.digDown()
      itemsPickedUp = itemsPickedUp + 1
    end
  end
  if didDig == false then
    -- Nothing was dug up so we should skip the item check
    return -1
  end
  print("[DigForward] Picked up items: " .. itemsPickedUp)
  return itemsPickedUp
end

-- Move the turtle down {times}. If there are blocks in the way it will
-- dig itself out. If it can't dig or move through, then return false
function digDown(times, locRef)
  for i=1,times do
    if turtle.detectDown() then
      if turtle.digDown() == false then
        return false
      end
    end
    if turtle.down() == false then
      return false
    end
    locRef.y = locRef.y - 1
  end
  return true
end

-- Move the Bot Forward, updating the locRef with the result
function forward(locRef) 
  if turtle.forward() then
    if currentDir == 'N' then
      locRef.z = locRef.z + 1
    elseif currentDir == 'S' then
      locRef.z = locRef.z - 1
    elseif currentDir == 'E' then
      locRef.x = locRef.x + 1
    else
      locRef.x = locRef.x - 1
    end
    return true
  end
  return false
end
