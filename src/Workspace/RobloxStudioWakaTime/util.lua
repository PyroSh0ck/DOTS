local module = {}

function module.instanceToPath(instance: Instance): string
	local path

	local parent = instance
	while parent do
		local name = if parent == game then "game" else parent.Name
		path = if path then `{name}/{path}` else name
		parent = parent.Parent
	end

	return path
end

function module.trimString(s: string)
	return s:match("^%s*(.-)%s*$")
end

function module.isValidWakaTimeApiKey(_key: string)
	return true
end

return module
