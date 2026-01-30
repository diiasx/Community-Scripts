-- ======================================================
-- Smart Lure Control
-- Autor: Yago
-- ======================================================

if _G.smartLureLoaded then return end
_G.smartLureLoaded = true

-- ================= CONFIG =================
local MAX_MOBS   = 2
local CHECK_TIME = 200
local DISTANCE   = 2

-- ================= IGNORE =================
local IGNORE_SUMMONS = {
  ["raiton hearth"] = true,
  ["fuuton hearth"] = true,
  ["suiton hearth"] = true,
  ["katon hearth"]  = true,
  ["kugutsu"]       = true
}

-- ================= STORAGE =================
storage.smartLure = storage.smartLure or { fighting = false }

-- ================= HUD =================
local hud = setupUI([[
UIWidget
  background-color: black
  opacity: 0.8
  padding: 3 8
  draggable: true
]], g_ui.getRootWidget())

local label = g_ui.createWidget("Label", hud)
label:setText("Lure: 0/" .. MAX_MOBS)
label:setColor("green")

hud:setPosition({ x = 50, y = 50 })

-- ================= MACRO =================
macro(CHECK_TIME, "Smart Lure Control", function()
  local mobs = 0
  local p = player:getPosition()

  for _, c in pairs(getSpectators()) do
    if c:isMonster() then
      local name = c:getName():lower()
      if not IGNORE_SUMMONS[name] then
        local pos = c:getPosition()
        if pos.z == p.z
        and math.abs(pos.x - p.x) <= DISTANCE
        and math.abs(pos.y - p.y) <= DISTANCE then
          mobs = mobs + 1
        end
      end
    end
  end

  label:setText("Lure: " .. mobs .. "/" .. MAX_MOBS)

  if mobs >= MAX_MOBS then
    label:setColor("red")
  elseif mobs > 0 then
    label:setColor("yellow")
  else
    label:setColor("green")
  end

  if mobs >= MAX_MOBS and not storage.smartLure.fighting then
    storage.smartLure.fighting = true
    CaveBot.setOff()
  end

  if storage.smartLure.fighting and mobs == 0 then
    storage.smartLure.fighting = false
    CaveBot.setOn()
  end
end)
