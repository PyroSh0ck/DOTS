local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local ScriptEditorService = game:GetService("ScriptEditorService")
local Selection = game:GetService("Selection")
local StudioService = game:GetService("StudioService")
local UserInputService = game:GetService("UserInputService")
local storageHandler = require(script.storageHandler)
local uiHandler = require(script.uiHandler)
local wakatime = require(script.wakatime)

if RunService:IsRunning() and RunService:IsClient() then
	return
end

local function activityCallback(force: boolean?)
	wakatime.onActivityCallback(plugin, force)
end

local function getBestProjectName()
	-- If there's already a saved project name we don't need to figure it out.
	if storageHandler.getSavedProjectName(plugin) then
		return
	end
	local ok, gameDetails = pcall(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
	if ok then
		storageHandler.setProjectName(plugin, gameDetails.Name)
	else
		local inferredName = storageHandler.getProjectName(plugin)
		if inferredName then
			storageHandler.setProjectName(plugin, inferredName)
		end
	end
end

do
	-- While the plugin runs in playtest, we can't get the proper game name, so we'll save it in the plugin settings for it to be read later on.
	if not RunService:IsRunning() and not storageHandler.getSavedProjectName(plugin) then
		getBestProjectName()
	end

	uiHandler.init(plugin)

	UserInputService.InputBegan:Connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			return
		end
		activityCallback()
	end)
	StudioService:GetPropertyChangedSignal("ActiveScript"):Connect(activityCallback)
	ScriptEditorService.TextDocumentDidChange:Connect(activityCallback)
	Selection.SelectionChanged:Connect(activityCallback)

	-- While in playtesting, the plugin can't run clientside because we can't access HttpService. However, the server code still runs, and we can mark this playtime.
	if RunService:IsRunning() then
		-- Accurately mark the end segment of the playtest.
		game:BindToClose(function()
			activityCallback(true)
		end)

		-- The possibility that someone pressed play and left the game running in the background, with no focus on the window, or falling asleep, is still there. So we are not doing an indefinite loop, and instead limiting this to 8 iterations. After 16 minutes, playtime would no longer be on autopilot.
		-- Of course, if the developer focuses on the server view (either in play solo or in server mode), then input events would be registered, and the activity would continue even after this loop ends.
		for i = 1, 8 do
			activityCallback()
			task.wait(121)
		end
	end
end
