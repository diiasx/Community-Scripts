script_bot = {}

-- ================= CONFIG BÁSICA =================
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

-- ================= LIBRARIES (SOMENTE SEU REPO) =================
local libraryList = {
    BASE_REPO .. "library.lua",
    BASE_REPO .. "script_list.lua"
}

-- ================= LOAD =================
for _, library in ipairs(libraryList) do
    modules.corelib.HTTP.get(library, function(content)
        if content then
            assert(loadstring(content))()
        end
    end)
end

-- ================= UI / MANAGER =================
macro(1000, function()
    if not script_manager or script_bot.loaded then return end
    script_bot.loaded = true

    local g_resources = modules._G.g_resources

    if not g_resources.fileExists(script_path) then
        g_resources.makeDir(script_path)
    end

    function script_bot.readScripts()
        if g_resources.fileExists(script_path_json) then
            local content = g_resources.readFileContents(script_path_json)
            local ok, data = pcall(json.decode, content)
            if ok then
                script_manager._cache = data
            end
        else
            script_bot.saveScripts()
        end
    end

    function script_bot.saveScripts()
        local content = json.encode(script_manager._cache, 4)
        g_resources.writeFileContents(script_path_json, content)
    end

    -- ================= WINDOW =================
    script_bot.window = setupUI([[
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

    script_bot.window:hide()

    script_bot.button = UI.Button("Script Manager", function()
        script_bot.window:setVisible(not script_bot.window:isVisible())
    end, tabName)

    -- ================= LIST =================
    function script_bot.update(tab)
        script_bot.window.list:destroyChildren()
        local list = script_manager._cache[tab]
        if not list then return end

        for name, data in pairs(list) do
            local label = UI.Label(name, script_bot.window.list)
            label:setColor(data.enabled and "green" or "white")

            label.onClick = function()
                data.enabled = not data.enabled
                script_bot.saveScripts()
                label:setColor(data.enabled and "green" or "white")

                if data.enabled then
                    modules.corelib.HTTP.get(data.url, function(code)
                        if code then
                            assert(loadstring(code))()
                        end
                    end)
                end
            end
        end
    end

    -- ================= TABS =================
    for category, _ in pairs(script_manager._cache) do
        local tab = script_bot.window.tabs:addTab(category)
        tab.onClick = function()
            script_bot.update(category)
        end
    end

    script_bot.readScripts()

    local firstTab = script_bot.window.tabs:getCurrentTab()
    if firstTab then
        script_bot.update(firstTab:getText())
    end
end)
