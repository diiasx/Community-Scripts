-- ======================================================
-- Single + AOE Safe
-- Autor: Yago
-- ======================================================

if _G.singleAoeSafeLoaded then return end
_G.singleAoeSafeLoaded = true

-------------- STORAGE ----------------
storage.lureSafe = storage.lureSafe or {
  singleSpells = "brave sword attack",
  areaSpells   = "brave furie",
  quantityLure = 2,
  range        = 3
}

---------------- BOT UI ----------------
UI.Separator()
UI.Label("SINGLE + AOE SAFE")

UI.Label("Single Spells:")
UI.TextEdit(storage.lureSafe.singleSpells, function(widget, text)
  storage.lureSafe.singleSpells = text
end)

UI.Label("AOE Spells:")
UI.TextEdit(storage.lureSafe.areaSpells, function(widget, text)
  storage.lureSafe.areaSpells = text
end)

UI.Label("Quantidade mínima de mobs:")
UI.TextEdit(tostring(storage.lureSafe.quantityLure), function(widget, text)
  local v = tonumber(text)
  if v then storage.lureSafe.quantityLure = v end
end)

UI.Label("Range:")
UI.TextEdit(tostring(storage.lureSafe.range), function(widget, text)
  local v = tonumber(text)
  if v then storage.lureSafe.range = v end
end)

UI.Separator()

---------------- FUNÇÕES ----------------
local function sayMultipleSpells(spells)
  for _, sp in ipairs(spells:split(',')) do
    say(sp:trim())
  end
end

local function getDistanceFromPlayer(pos)
  local p = player:getPosition()
  if not p or not pos then return 999 end
  return math.max(
    math.abs(p.x - pos.x),
    math.abs(p.y - pos.y),
    math.abs(p.z - pos.z)
  )
end

local function getMonstersInRange(range)
  local count = 0
  for _, spec in ipairs(getSpectators(false)) do
    if spec:isMonster()
    and getDistanceFromPlayer(spec:getPosition()) <= range then
      count = count + 1
    end
  end
  return count
end

local function hasPlayerOnScreen()
  local myPos = player:getPosition()
  for _, spec in ipairs(getSpectators(true)) do
    if spec:isPlayer() and spec ~= player then
      local pos = spec:getPosition()
      if pos.z == myPos.z then
        return true
      end
    end
  end
  return false
end

---------------- MACRO ----------------
macro(100, "Single + AOE Safe", function()
  if not g_game.isAttacking() then return end

  local cfg = storage.lureSafe
  local playerDetected = hasPlayerOnScreen()
  local mobCount = getMonstersInRange(cfg.range)

  if playerDetected then
    sayMultipleSpells(cfg.singleSpells)
    return
  end

  if mobCount >= cfg.quantityLure and player:getSkull() < 3 then
    sayMultipleSpells(cfg.areaSpells)
  else
    sayMultipleSpells(cfg.singleSpells)
  end
end)
