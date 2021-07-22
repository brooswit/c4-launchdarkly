os.loadAPI("json.lua")
os.loadAPI("base64.lua")

local inf = (1/0)

local function printError(msg)
    print("[LDClient Error]: " .. msg)
end


local LDClient = {
    __clientsideId = "",
    __config = {},
    __currentUser = {},
    __flagSettings = {},
    __lastPoll = -inf,
    __lastFlush = -inf,
    __closed = false
}
LDClient.__index = LDClient

function LDClient:create(clientsideId, currentUser, config)
    clientsideId = clientsideId or ""
    currentUser  = currentUser  or {}
    config       = config       or {}

    local ldClient = {}
    setmetatable(ldClient, LDClient)

    ldClient.__clientsideId = clientsideId

    ldClient.__currentUser  = currentUser

    ldClient.__config = {}
        ldClient.__config.pollInterval  = config.pollInterval  or 5
        ldClient.__config.flushInterval = config.flushInterval or 30
        ldClient.__config.baseUrl       = config.baseUrl       or "https://app.launchdarkly.com/"
        ldClient.__config.eventsUrl     = config.eventsUrl     or "https://events.launchdarkly.com/"

    ldClient.__lastPoll  = -inf
    ldClient.__lastFlush = -inf

    return ldClient
end

function LDClient:identify(user)
    self.__currentUser = user
    self:__enqueueIdentifyEvent()
    self:__fetchAllFlags()
    self:__maybeFlushAllEvents()
end

function LDClient:variationDetails(flagKey, fallbackValue)
    local details = self:allFlagDetails()[flagKey] or { value = fallbackValue }
    self:__enqueueVariationEvent(details, fallbackValue)
    self:__maybeFlushAllEvents()
    return details
end

function LDClient:variation(flagKey, fallbackValue)
    local details = self:variationDetails(flagKey, fallbackValue)
    local value = fallbackValue
    if details then
        value = details.value
    end
    return value
end

function LDClient:allFlagDetails()
    self:__maybeFetchAllFlags()
    return self.__flagSettings
end

function LDClient:allFlags()
    local allFlags = {}
    local allFlagDetails = self:allFlagDetails()
    
    for flagKey, flagDetails in pairs(allFlagDetails) do
        allFlags[flagKey] = flagDetails.value
    end

    return allFlags
end

function LDClient:track(metric)
    self:__enqueueTrackEvent(metric)
    self:__maybeFlushAllEvents()
end

function LDClient:flush()
    self:__flushAllEvents()
end

function LDClient:close()
    self:flush()
    self.__flagSettings = {}
    self.__closed = true
end
-- private methods

function LDClient:__enqueueIdentifyEvent()
    -- TODO
    -- ¯\_(ツ)_/¯
end

function LDClient:__enqueueVariationEvent()
    -- TODO
    -- ¯\_(ツ)_/¯
end

function LDClient:__enqueueTrackEvent()
    -- TODO
    -- ¯\_(ツ)_/¯
end

function LDClient:__maybeFetchAllFlags(force)
    if force or (self.__lastPoll + self.__config.pollInterval < os.clock()) then
        self.allFlags = self:__fetchAllFlags()
    end
end

function LDClient:__maybeFlushAllEvents(force)
    if force or (self.__lastFlush + self.__config.flushInterval < os.clock()) then
        self:__flushAllEvents()
    end
end

function LDClient:__fetchAllFlags()
    if self.__closed then return end
    self.__lastPoll = os.clock()

    local user = self:__buildUserObject()
    local userString = json.encode(user)
    local userBase64 = base64.encode(userString)
    local url = self.__config.baseUrl .. "sdk/evalx/" .. self.__clientsideId .. "/users/" .. userBase64
    print(url)

    local request = http.get(url)
    if not request then
        printError("Fetching flags failed: (" .. url .. ")")
        sleep(1)
        return
    end
    local response = request.readAll()
    print(response)
    sleep(1)

    return json.decode(response)
end

function LDClient:__flushAllEvents()
    if self.__closed then return end
    self.__lastFlush = os.clock()

    local url = self.__config.eventsUrl .. "events/bulk/" .. self.__clientsideId
    local headers = { [ "Content-Type" ] = "application/json" }
    local event = json.encode({
        kind = "index",
        user = self:__buildUserObject()
    })
    -- TODO: Summary events

    local request = http.post(url, event, headers)
    if not request then
        printError("Flushing events failed: (" .. url .. ")")
        return
    end
    local response = request.readAll()
end

function LDClient:__buildUserObject()
    local user = {}
    user.key = "" .. (self.__currentUser.key or os.getComputerID())

    user.custom = {}
    if self.__currentUser.custom ~= nil then
        for key, value in pairs(self.__currentUser.custom) do
            user.custom[key] = value
        end
    end

    -- overrides
    user.custom.millis = os.day() * 60*60*24*1000 + os.time()*1000
    user.custom.secondOfMinute = math.floor(os.time()*60*60) % 60
    user.custom.minuteOfHour = math.floor(os.time()*60) % 60
    user.custom.hourOfDay = math.floor(os.time())
    user.custom.dayOfMonth = os.day() % 30
    user.custom.monthOfYear = math.floor(os.day() / 30) % 12
    user.custom.year = math.floor(os.day() / 360)

    user.custom.clock = os.clock()

    for key, side in pairs(redstone.getSides()) do
        user.custom["redstone_" .. side] = redstone.getInput(side)
    end

    return user
end

setmetatable (LDClient, {__call=LDClient.__init__})

function init(clientsideId, currentUser)
    return LDClient:create(clientsideId, currentUser)
end
