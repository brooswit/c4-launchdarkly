os.loadAPI('json.lua')

local function buildStoreFileName(storeName)
    return storeName .. '.json'
end

local function buildStorePathList(storeFileName)
    local disks = { 'disk', 'disk2', 'disk3', 'disk4', 'disk5' }
    local pathList = {}
    for k, disk in pairs(disks) do
        if fs.exists(disk .. '/') then
            table.insert(pathList, disk .. '/' .. storeFileName)
        end
    end
    table.insert(pathList, storeFileName)
    return pathList
end

local function load(storeName)
    local storeFileName = buildStoreFileName(storeName)
    local storePaths = buildStorePathList(storeFileName)
    local store = {}
    for k, storePath in pairs(storePaths) do
        local storeExists = fs.exists(storePath)
        if storeExists then
            local file = fs.open(storePath, "r")
            if file ~= nil then
                local storeContents = file.readAll()
                file.close()
                local ran
                ran, decodedStore = pcall(json.decode, storeContents)
                if ran and type(decodedStore) == 'table' then
                    store = decodedStore
                end
            end
        end
    end

    save(storeName, store)

    return store
end

local function save(storeName, store)
    local ran, storeText = pcall(json.encode, store)
    if not ran then
        storeText = "{}"
    end

    local storeFileName = buildStoreFileName(storeName)
    local storePaths = buildStorePathList(storeFileName)

    for k, storePath in pairs(storePaths) do
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
    local now = os.clock()

    cache[key] = {
        value = value,
        time = now
    }

    save(key, value)
end
