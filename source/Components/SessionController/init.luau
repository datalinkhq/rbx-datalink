local HttpService = game:GetService("HttpService")
local HttpComponent = { }

function HttpComponent:requestAsync()
	
end

function HttpComponent:start()
	
end

function HttpComponent:init()
	self.httpEnabled = HttpService.HttpEnabled
end

return HttpComponent