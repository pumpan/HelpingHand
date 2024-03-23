local MAX_PLAYERS_PER_GROUP = 5
local isFixingGroups = false
local moveDelay = 0.7 -- Delay time in seconds
local lastMoveTime = 0
local moveQueue = {} -- Queue for delayed moves
local currentPhase = 1 -- Phase control variable
local FixGroups

DEFAULT_CHAT_FRAME:AddMessage("Fixgroups |cff00FF00 loaded|cffffffff, /fixgroups |cff00eeee to start. ")

local function QueueMove(player, group, offlineTime)
    table.insert(moveQueue, {player = player, group = group, offlineTime = offlineTime})
end

local function ProcessMoveQueue()
    local currentTime = time()
    local queueLength = 0
    for _, _ in pairs(moveQueue) do
        queueLength = queueLength + 1
    end

    if currentTime >= (lastMoveTime + moveDelay) and queueLength > 0 then
        local nextMove = table.remove(moveQueue, 1)
        local player = nextMove.player
        local group = nextMove.group

        if not player.moved then
            SetRaidSubgroup(player.index, group)
            player.moved = true
            lastMoveTime = currentTime
        end
    end

    if currentPhase == 1 and queueLength == 0 then
        currentPhase = 2
        UIErrorsFrame:AddMessage("Phase 1 complete, starting Phase 2")
        FixGroups()
    end
end

local function FindNextAvailableGroup(groupSizes, isPhase1)
    local startGroup, endGroup, step = 1, 8, 1
    if isPhase1 then
        startGroup, endGroup, step = 8, 1, -1
    end

    for group = startGroup, endGroup, step do
        if groupSizes[group] < MAX_PLAYERS_PER_GROUP then
            return group
        end
    end
    UIErrorsFrame:AddMessage("No available group found")
    return nil
end

FixGroups = function()
    local groupSizes = {}
    local playersByClass = {}
    local classesInOrder = {"SHAMAN", "WARRIOR", "ROGUE", "PRIEST", "WARLOCK", "MAGE", "PALADIN", "DRUID", "HUNTER"}
    local shamanGroups = {} -- Tracks groups with Shamans

    for i = 1, 8 do
        groupSizes[i] = 0
        shamanGroups[i] = false
    end

    for _, class in ipairs(classesInOrder) do
        playersByClass[class] = {}
    end

    for i = 1, GetNumRaidMembers() do
        local name, _, _, _, _, class, _, online = GetRaidRosterInfo(i)
        if class and playersByClass[class] then
            local player = {name = name, index = i, moved = false, online = online}
            if not online then
                player.offlineTime = time() -- Store the time when player went offline
            end
            table.insert(playersByClass[class], player)
        end
    end

    for _, class in ipairs(classesInOrder) do
        for _, player in ipairs(playersByClass[class]) do
            if not player.online then
                local groupToMove = 8
                while groupSizes[groupToMove] >= MAX_PLAYERS_PER_GROUP and groupToMove > 1 do
                    groupToMove = groupToMove - 1
                end
                QueueMove(player, groupToMove, player.offlineTime) -- Pass offline time to QueueMove
                groupSizes[groupToMove] = groupSizes[groupToMove] + 1
            end
        end
    end

    for _, shaman in ipairs(playersByClass["SHAMAN"]) do
        if shaman.online and not shaman.moved then
            for group = 1, 8 do
                if not shamanGroups[group] and groupSizes[group] < MAX_PLAYERS_PER_GROUP then
                    QueueMove(shaman, group)
                    groupSizes[group] = groupSizes[group] + 1
                    shamanGroups[group] = true
                    break
                end
            end
        end
    end

    for _, class in ipairs(classesInOrder) do
        for _, player in ipairs(playersByClass[class]) do
            if class ~= "SHAMAN" and player.online and not player.moved then
                local group = FindNextAvailableGroup(groupSizes, currentPhase == 1)
                if group then
                    QueueMove(player, group)
                    groupSizes[group] = groupSizes[group] + 1
                end
            end
        end
    end

    if currentPhase == 2 and queueLength == 0 then
        UIErrorsFrame:AddMessage("Phase 2 complete, groups organized")
        isFixingGroups = false
    end
end

local frame = CreateFrame("Frame")
frame:SetScript("OnUpdate", function(self, elapsed)
    if not isFixingGroups then
        return
    end
    ProcessMoveQueue()
end)

frame:Show()

function EnableAutoFixGroupsFeatures(enable)
    DEFAULT_CHAT_FRAME:AddMessage("Automatic Fixgroups enabled")
end

function EnableAutoFixGroupsFeatures(enable)
    if enable then
        local function HandleRaidUpdate()
            if isFixingGroups then
                currentPhase = 2
                FixGroups()
            end
        end
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("RAID_ROSTER_UPDATE")
        frame:SetScript("OnEvent", HandleRaidUpdate)
    end
end

SlashCmdList["FIXGROUPS"] = function()
    isFixingGroups = true
    currentPhase = 1
    lastMoveTime = 0
    moveQueue = {}
    FixGroups()
end

SlashCmdList["FIXGROUPS2"] = function()
    isFixingGroups = true
    currentPhase = 2 
    lastMoveTime = 0
    moveQueue = {}
    FixGroups()
end

SLASH_FIXGROUPS1 = "/fixgroups"
SLASH_FIXGROUPS2 = "/fixgroups2"
