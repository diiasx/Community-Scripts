script_bot = {}

-- ================= CONFIG =================
local BASE_REPO = "https://raw.githubusercontent.com/diiasx/Community-Scripts/main/"
local actualVersion = 1.0

local script_path
local script_path_json
local tabName

if ragnarokBot then
    script_path = ragnarokBot.path .. 'scripts_storage/'
    script_path_json = script_path .. player:getName() .. '.json'
    setDefaultTab('HP')
    tabName = getTab('HP') or setDefaultTab('HP')
else
    script_path = '/scripts_storage/'
    script_path_json = script_path .. player:getName() .. '.json'
    setDefaultTab('Main')
    tabName = getTab('Main') or setDefaultTab('Main')
end

-- ================= LOAD LIBRARIES =================
local function loadRemote(url)
    modules.corelib.HTTP.get(url, function(code)
        if code then
            assert(loadstring(code))()
        end
    end)
end

loadRemote(BASE_REPO .. "library.lua")
loadRemote(BASE_REPO .. "script_list.lua")

-- ================= UI =================
local function initUI()
    if script_bot.ui then return end

    script_bot.ui = setupUI([[
MainWindow
  text: Community Scripts
  size: 300 400

  TabBar
    id: tabs
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right

  ScrollablePanel
    id: list
    anchors.fill: parent
    margin-top: 30
    layout:
      type: verticalBox

  Button
    id: close
    text: Close
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    margin: 5
]], g_ui.getRootWidget())

    script_bot.ui:hide()

    script_bot.button = UI.Button("Script Manager", function()
        script_bot.ui:setVisible(not script_bot.ui:isVisible())
    end, tabName)
end

-- ================= INIT =================
macro(500, function()
    if not script_manager then return end

    initUI()

    local g_resources = modules._G.g_resources

    if not g_resources.fileExists(script_path) then
        g_resources.makeDir(script_path)
    end

    function script_bot.read()
        if g_resources.fileExists(script_path_json) then
            local data = g_resources.readFileContents(script_path_json)
            local ok, decoded = pcall(json.decode, data)
            if ok then
                script_manager._cache = decoded
            end
        else
            script_bot.save()
        end
    end

    function script_bot.save()
        local data = json.encode(script_manager._cache, 4)
        g_resources.writeFileContents(script_path_json, data)
    end

    function script_bot.update(tab)
        script_bot.ui.list:destroyChildren()
        local scripts = script_manager._cache[tab]
        if not scripts then return end

        for name, info in pairs(scripts) do
            local label = UI.Label(name, script_bot.ui.list)
            label:setColor(info.enabled and "green" or "white")

            label.onClick = function()
                info.enabled = not info.enabled
                script_bot.save()
                label:setColor(info.enabled and "green" or "white")

                if info.enabled then
                    loadRemote(info.url)
                end
            end
        end
    end

    for category, _ in pairs(script_manager._cache) do
        local tab = script_bot.ui.tabs:addTab(category)
        tab.onClick = function()
            script_bot.update(category)
        end
    end

    script_bot.read()

    local firstTab = script_bot.ui.tabs:getCurrentTab()
    if firstTab then
        script_bot.update(firstTab:getText())
    end

    script_bot.loaded = true
end)
