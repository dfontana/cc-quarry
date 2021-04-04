-- Utils are functions that aren't specific to quarrying; they just assist
-- the programmer. Think toString, mathematics, or data movement.
-- They do not mutate any global state

-- Computes the cost to travel from current location to the given loc tuple
-- using manhattan distance: |x2-x1| + |y2-y1| + |z2-z1|
function costToDest(locA, locB) 
  return math.abs(locA.x - locB.x) + math.abs(locA.y - locB.y) + math.abs(locA.z - locB.z)
end

-- Copies loc b into loc a, to prevent reference mutation
-- (assigning a = b would move the reference).
function copyLocToLoc(a, b)
  a.x = b.x
  a.y = b.y
  a.z = b.z
end

-- Convert a Loc tuple into a String for easy printing
function locString(loc) 
  return "Loc{"..loc.x..","..loc.z..","..loc.y.."}"
end
