local Console = require(script.Parent.Parent.Packages.Console)

local ExampleService = { }

ExampleService.Priority = 0
ExampleService.Reporter = Console.new(`⚪ {script.Name}`)

function ExampleService.OnStart(self: ExampleService)
	self.Reporter:Debug(`Hello from '{script.Name}::OnStart'`)
end

function ExampleService.OnInit(self: ExampleService)
	self.Reporter:Debug(`Hello from '{script.Name}::OnInit'`)
end

export type ExampleService = typeof(ExampleService)

return ExampleService