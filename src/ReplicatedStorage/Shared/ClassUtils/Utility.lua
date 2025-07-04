local Utility = {}
local RunService = game:GetService("RunService")

function Utility:eventListener(bindableEvent, method)
    bindableEvent:Connect(function(...)
        self[method](self, ...)
    end)
end

function Utility:remoteListener(remoteEvent, method)
    if RunService:IsServer() then
        remoteEvent.OnServerEvent:Connect(function(...)
            self[method](self, ...)
        end)
    elseif RunService:IsClient() then
        remoteEvent.OnClientEvent:Connect(function(...)
            self[method](self, ...)
        end)
    end
end

function Utility:bindToCLose(method)
    game:BindToClose(function()
        self[method](self)
    end)
end

return Utility
