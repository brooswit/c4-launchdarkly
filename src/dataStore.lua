os.loadAPI('json.lua')

local function buildStoreFileName(storeName)
    return storeName .. '.json'
end

local function buildStorePathList(storeName)
    return { 'disk/' .. storeFileName, storeFileName }
end

local function load(storeName)
    local storeFileName = buildStoreFileName(storeName)
    local storePaths = buildStorePathList(storeName)

    for storePath in storePaths do
        local storeExists = fs.exists(storePath)
        if storeExists then
            local file = fs.open(storePath, "r")
            if file ~= nil then
                local storeContents = file.readAll()
                file.close()
                local store = pcall(json.decode, storeContents)
                if store ~= nil then
                    return store
                end
            end
        end
    end

    return {}
end

local function save(storeName, store)
    local storeText, jsonError = pcall(json.encode, store)
    if jsonError then storeText = "{}" end

    local storeFileName = buildStoreFileName(storeName)
    local storePaths = buildStorePathList(storeName)

    for storePath in storePaths do
        fileManager.save(storePath, storeText)
        local file = fs.open(storePath, "w")
        if file ~= nil then
            file.write(storeText)
            file.close()
        end
    end
end

local cache = {}
local ttl = 5

function get(key)
    local now = os.clock()

    if cache[key] == nil or cache[key].time + ttl < now then
        cache[key] = {
            value = load(key),
            time = now
        }
    end

    return cache[key].value
end

function set(key, value)
    cache[key] = {
        value = value,
        time = now
    }

    save(key, value)
end
