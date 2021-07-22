os.loadAPI("json.lua")
os.loadAPI("base64.lua")

local inf = (1/0)

local function printError(msg)
    print("[LDClient Error]: " .. msg)
end

local LDClientInstance = {
    __clientsideId = "",
    __currentUser = {},
    __flagSettings = {},
    __config = {},
    __lastPoll = -inf,
    __lastFlush = -inf
}

function LDClientInstance:__init__(baseClass, clientsideId, currentUser, config)
    clientsideId = clientsideId or ""
    currentUser  = currentUser  or {}
    config       = config       or {}

    self.__clientsideId = clientsideId

    self.__currentUser  = currentUser

    self.__config = {}
    self.__config.pollInterval  = config.pollInterval  or 5
    self.__config.flushInterval = config.flushInterval or 30
    self.__config.baseUrl       = config.baseUrl       or "https://app.launchdarkly.com/"
    self.__config.eventsUrl     = config.eventsUrl     or "https://events.launchdarkly.com/"

    self.__lastPoll  = -inf
    self.__lastFlush = -inf

    setmetatable ( self, {__index=LDClientInstance})

    return self
end

function LDClientInstance:identify(user)
    self.__currentUser = user
    self:__enqueueIdentifyEvent()
    self:__fetchAllFlags()
    self:__maybeFlushAllEvents()
end

function LDClientInstance:variationDetails(flagKey, fallbackValue)
    local details = self:allFlagDetails()[flagKey] or { value = fallbackValue }
    self:__enqueueVariationEvent(details, fallbackValue)
    self:__maybeFlushAllEvents()
    return details
end

function LDClientInstance:variation(flagKey, fallbackValue)
    local details = self:variationDetails(flagKey, fallbackValue)
    local value = fallbackValue
    if details then
        value = details.value
    end
    return value
end

function LDClientInstance:allFlagDetails()
    self:__maybeFetchAllFlags()
    return self.__flagSettings
end

function LDClientInstance:allFlags()
    local allFlags = {}
    local allFlagDetails = self:allFlagDetails()
    
    for flagKey, flagDetails in pairs(allFlagDetails) do
        allFlags[flagKey] = flagDetails.value
    end

    return allFlags
end

function LDClientInstance:track(metric)
    self:__enqueueTrackEvent(metric)
    self:__maybeFlushAllEvents()
end

function LDClientInstance:flush()
    self:__flushAllEvents()
end

function close()
    self:flush()

    -- TODO
    -- ¯\_(ツ)_/¯
end
-- private methods

function LDClientInstance:__enqueueIdentifyEvent()
    -- TODO
    -- ¯\_(ツ)_/¯
end

function LDClientInstance:__enqueueVariationEvent()
    -- TODO
    -- ¯\_(ツ)_/¯
end

function LDClientInstance:__enqueueTrackEvent()
    -- TODO
    -- ¯\_(ツ)_/¯
end

function LDClientInstance:__maybeFetchAllFlags(force)
    if force or (self.__lastPoll + self.__config.pollInterval < os.clock()) then
        self.allFlags = self:__fetchAllFlags()
    end
end

function LDClientInstance:__maybeFlushAllEvents(force)
    if force or (self.__lastFlush + self.__config.flushInterval < os.clock()) then
        self:__flushAllEvents()
    end
end

function LDClientInstance:__fetchAllFlags()
    self.__lastPoll = os.clock()

    local user = self:__buildUserObject()
    local userString = json.encode(user)
    local userBase64 = base64.encode(userString)
    local url = self.__config.baseUrl .. "sdk/evalx/" .. clientsideId .. "/users/" .. userBase64
    
    local request = http.get(url)
    if not request then
        printError("Fetching flags failed: (" .. url .. ")")
        return
    end
    local response = request.readAll()

    return json.decode(response)
end

function LDClientInstance:__flushAllEvents()
    self.__lastFlush = os.clock()

    local url = self.__config.eventsUrl .. "events/bulk/" .. self.clientsideId
    local headers = { [ "Content-Type" ] = "application/json" }
    local event = json.encode({
        kind = "index",
        user = self:__buildUser()
    })
    -- TODO: Summary events

    local request = http.post(url, event, headers)
    if not request then
        printError("Flushing events failed: (" .. url .. ")")
        return
    end
    local response = request.readAll()
end

function LDClientInstance:__buildUserObject()
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

setmetatable (LDClientInstance, {__call=LDClientInstance.__init__})

function init(clientsideId, currentUser)
    return LDClientInstance (clientsideId, currentUser)
end
