local ExampleServiceServer = {}

function ExampleServiceServer.init(_self: ExampleServiceServer)
	print("hi from ExampleServiceServer!")
end

export type ExampleServiceServer = typeof(ExampleServiceServer) & {}

return ExampleServiceServer
