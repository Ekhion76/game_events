EventMonitor = {}

function EventMonitor:new(cEvents)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    obj.enable = true
    obj.gameTime = 0
    obj.registeredEvents = {}
    obj.displayedEvents = {}
    obj.lastEvent = nil
    obj.cEvents = cEvents or {}
    obj:addEventHandlers()
    obj:run()
    obj:drawEvents()
    return obj
end

function EventMonitor:addEventHandlers()
    for event in pairs(self.cEvents) do
        AddEventHandler(event, function(...)
            self:registerEventToEntity(event, { ... })
        end)
    end
end

function EventMonitor:translateKeys(t)
    local keys = {}
    for k in pairs(t) do
        keys[#keys + 1] = self.cEvents[k]
    end
    return keys
end

function EventMonitor:concatKeys(t)
    return table.concat(self:translateKeys(t), '~n~')
end

function EventMonitor:drawText3D(coords, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z + 1.5)
    local dist = #(GetGameplayCamCoords() - coords)

    local scale = (1 / dist) * 15
    local fov = (1 / GetGameplayCamFov()) * 10
    scale = scale * fov

    if onScreen then
        SetTextScale(1.5 * scale, 1.5 * scale)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function EventMonitor:registerEventToEntity(event, args)
    entities = args[1] or {}
    for i = 1, #entities do
        self.registeredEvents[entities[i]] = self.registeredEvents[entities[i]] or {}
        self.registeredEvents[entities[i]][event] = GetGameTimer() + 10000
    end
end

function EventMonitor:checkEventExpired(eventList)
    for event, expireTime in pairs(eventList) do
        if expireTime < self.gameTime then
            eventList[event] = nil
        end
    end
end

function EventMonitor:run()
    CreateThread(function()
        local sleep = 500
        local validEvents = {}
        while self.enable do
            Wait(sleep)

            validEvents = {}
            self.gameTime = GetGameTimer()

            if next(self.registeredEvents) then
                sleep = 500
                for entity, eventList in pairs(self.registeredEvents) do
                    self:checkEventExpired(eventList)
                    if DoesEntityExist(entity) and next(eventList) then
                        validEvents[#validEvents + 1] = {
                            entity = entity, text = self:concatKeys(eventList)
                        }
                    else
                        self.registeredEvents[entity] = nil
                    end
                end
            else
                sleep = 1000
            end
            self.displayedEvents = validEvents;
        end
    end)
end

function EventMonitor:drawEvents()
    CreateThread(function()
        local sleep = 0
        while self.enable do
            Wait(sleep)
            if self.displayedEvents[1] then
                sleep = 0
                for i = 1, #self.displayedEvents do
                    self:drawText3D(GetEntityCoords(self.displayedEvents[i].entity), self.displayedEvents[i].text)
                end
            else
                sleep = 1000
            end
        end
    end)
end

function EventMonitor:destroy()
    self.enable = false
end
