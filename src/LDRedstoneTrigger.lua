os.loadAPI( 'dataStore.lua' )

local prevInput = false

while true do
    term.setBackgroundColor(colours.black)  -- Set the background colour to black.
    term.clear()                            -- Paint the entire display with the current background colour.
    term.setCursorPos(1,1)                  -- Move the cursor to the top left position.

    print( '                LD REDSTONE TRIGGER                ' )
    print( '===================================================' )

    local ldVariation = false
    local loadedConfig = dataStore.get('ldConfig')
    local config = {}

    local defaultConfig = {
        triggerOnURL = "",
        triggerOffURL = ""
    }

    print( '' )
    print( 'config:' )
    for configKey, configValue in pairs(defaultConfig) do
        print( '  ' .. configKey .. ': "' .. tostring(loadedConfig[configKey]) .. '"')
        if loadedConfig[configKey] ~= nil then
            config[configKey] = loadedConfig[configKey]
        else
            config[configKey] = defaultConfig[configKey]
        end
    end

    local input = false
    for key, side in pairs(redstone.getSides()) do
        input = input or redstone.getInput(side)
    end

    if prevInput ~= input then
        local url = config.triggerOnURL
        if not input then
            url = config.triggerOffURL
        end
        if url ~= nil then
            local request = http.post(url, "")
            if request then
                local response = request.readAll()
            end
        end
    end

    prevInput = input

    sleep(0)
end
