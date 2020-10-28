os.loadAPI("LDClient")

local ldClient = LDClient.init("YOUR-CLIENTSIDE-ID")

while true do
    sleep(0)
    local value = ldClient.variation("YOUR-FLAG-KEY", false)
    
    for key, side in pairs(redstone.getSides()) do
        redstone.setOutput(side, value)
    end
end