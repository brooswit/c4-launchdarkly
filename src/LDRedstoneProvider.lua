os.loadAPI( 'launchDarkly.lua' )
os.loadAPI( 'dataStore.lua' )

ldClient = nil
prevClientSideID = nil
prevUserKey = nil

while true do
    term.setBackgroundColor(colours.black)  -- Set the background colour to black.
    term.clear()                            -- Paint the entire display with the current background colour.
    term.setCursorPos(1,1)                  -- Move the cursor to the top left position.

    print( '                LD REDSTONE PROVIDER               ' )
    print( '===================================================' )

    local ldVariation = false
    local loadedConfig = dataStore.get('ldConfig')
    local config = {}

    local defaultConfig = {
        clientSideID = "",
        apiKey = "",
        flagKey = "",
        userKey = ""
    }

    print( '' )
    print( 'config:' )
    for configKey, configValue in pairs(defaultConfig) do
        print( '  ' .. configKey .. ': ' .. configValue )
        if loadedConfig[configKey] ~= nil then
            config[configKey] = loadedConfig[configKey]
        else
            config[configKey] = defaultConfig[configKey]
        end
    end

-- handle config changes
    
    if config.clientSideID ~= prevClientSideID then
        prevClientSideID = config.clientSideID
        if ldClient ~= nil then
            ldClient:close()
            ldClient = nil
        end
        if config.clientSideID ~= "" then
            ldClient = launchDarkly.init( config.clientSideID, { key = config.userKey } )
        end
    else
        if config.userKey ~= prevUserKey then
            prevUserKey = config.userKey
            if ldClient ~= nil then
                ldClient:identify( { key = config.userKey } )
            end
        end
    end

    if ldClient ~= nil then
        if config.flagKey ~= "" and config.userKey ~= ""  then
            ldVariation = ldClient:variation(config.flagKey)
        end
    end

    print( '' )
    print( 'state:' )
    print( '  ldVariation: ' .. ldVariation )

    for key, side in pairs(redstone.getSides()) do
        redstone.setOutput(side, ldVariation)
    end

    sleep(0)
end
