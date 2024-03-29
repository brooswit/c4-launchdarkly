os.loadAPI( 'c4' )
c4.loadAPI( 'localStorage' )

while true do
    term.setBackgroundColor(colours.black)  -- Set the background colour to black.
    term.clear()                            -- Paint the entire display with the current background colour.
    term.setCursorPos(1,1)                  -- Move the cursor to the top left position.

    print( '            LD CONFIGURATION INTERFACE             ' )
    print( '===================================================' )

    local loadedConfig = localStorage.get('ldConfig')
    local config = {}

    local defaultConfig = {
        clientSideID = "",
        flagKey = "",
        userKey = "",
        triggerOnURL = "",
        triggerOffURL = "",
        eventName = "",
        baseUrl = "",
        eventsUrl = "",
        pollInterval = "",
        flushInterval = ""
    }

    print( '' )
    print( 'config:' )
    local index = 0
    for configKey, configValue in pairs(defaultConfig) do
        index = index + 1
        print( index .. ' ) Change ' .. configKey .. ' - ["' .. tostring(loadedConfig[configKey]) .. '"]')
        if loadedConfig[configKey] ~= nil then
            config[configKey] = loadedConfig[configKey]
        else
            config[configKey] = defaultConfig[configKey]
        end
    end

    print( '' )
    print( 'Choose an option:' )
    local choice = read()

    local option
    index = 0
    for configKey, configValue in pairs(defaultConfig) do
        index = index + 1
        if tonumber(choice) == index then
            option = configKey
        end
    end

    if option == nil then
        print( '-- invalid option --' )
    else
        print( 'OK!' )
        print( '' )
        print( 'Enter new value for ' .. option .. ':')
        local value = read()

        print( 'OK!' )
        print( '' )
        print( 'Will change ' .. option .. ' from "' ..  config[option] .. '" to "' .. value .. '".')
        local confirm = nil
        while confirm ~= 'yes' and confirm ~= 'no' do
            print( 'Confirm change (yes/no): ')
            confirm = read()
            if confirm ~= 'yes' and confirm ~= 'no' then
                print('-- invalid response --')
                sleep(1)
                print( '' )
            end
        end

        if confirm == 'yes' then
            config[option] = value
            localStorage.set('ldConfig', config)
            print( 'Changed ' .. option .. ' to "' .. value .. '".')
        else
            print( 'Change canceled.')
        end
    end
    sleep(5)
end
