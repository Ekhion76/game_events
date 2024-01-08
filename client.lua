local enable, eventMonitor

RegisterCommand('events', function()
    enable = not enable

    if enable then
        startMonitor()
    else
        stopMonitor()
    end
end)

function startMonitor()
    print('cEvent Monitor Started')
    eventMonitor = EventMonitor:new(cEvents)
end

function stopMonitor()
    print('cEvent Monitor Stopped')
    if eventMonitor then
        eventMonitor:destroy()
        eventMonitor = nil
    end
end


