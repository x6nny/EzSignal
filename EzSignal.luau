local EzSignal = { }
local StoredSignals = { } :: StoredSignals
local links = { } :: { signal }

type link = {
	isLink : boolean,
	signals : { signal }
}
type StoredSignals = {
	[string] : signal
}
type signal = { 
	Connections : { (...any) -> () },
	Enabled : boolean,
}
type EzSignal = {
	new : () -> signal,
	store : (name : string, signal : signal, override : boolean?) -> (),
	get : (name : string) -> signal,
	list : () -> StoredSignals,
	remove : (name : string) -> (),
	newLink : () -> { signal? },
	addLink : (link : link, signal : signal) -> () -> (),
	clearLink : (link : link) -> (),
	Connect : (signal : signal, callBack : (...any) -> ()) -> () -> (),
	Fire : (signal : signal | link, ...any) -> (),
	fireList : (list : { [any] : signal }, ...any) -> (),
	Enable : (signal : signal, enabled : boolean) -> (),
	DisconnectAll : (signal : signal) -> (),
}

function EzSignal.new() : signal
	return {
		Connections = { },
		Enabled = true,
	}
end

function EzSignal.store(name : string, signal : signal, override : boolean?)
	if StoredSignals[name] ~= nil and (override == nil or override == false) then
		warn(`Unable to store '{name}', '{name}' is already a stored signal!`)
		return
	end
	StoredSignals[name] = signal
end

function EzSignal.get(name : string) : signal
	return StoredSignals[name]
end

function EzSignal.list()
	return StoredSignals
end

function EzSignal.remove(name : string)
	if StoredSignals[name] then
		StoredSignals[name] = nil
	end
end

function EzSignal.newLink()
	return {
		isLink = true,
		signals = { }
	}
end

function EzSignal.addLink(link : link, signal : signal) : () -> ()
	assert(table.find(link.signals, signal) == nil, `Cannot add signal to link, signal is already inside the link!`)
	table.insert(link.signals, signal)
	
	return function()
		local index = table.find(link.signals, signal)
		if index then
			table.remove(link.signals, index)
		end
	end
end

function EzSignal.clearLink(link : link)
	table.clear(link.signals)
end

function EzSignal.Connect(signal : signal, callBack : (...any) -> ()) : () -> ()
	assert(signal.Connections, `Passed signal is not a valid signal object!`)
	table.insert(signal.Connections, callBack)
	
	return function()
		local index = table.find(signal.Connections, callBack)
		
		if index then
			table.remove(signal.Connections, index)
		end
	end
end

function EzSignal.Fire(signal : signal | link, ...)
	if signal.isLink == nil then
		if signal.Enabled == false then
			return
		end

		for i = 1, #signal.Connections do
			local conn = signal.Connections[i]
			task.spawn(conn, ...)
		end
	elseif signal.isLink then
		for i, signal : signal in pairs(signal.signals) do
			if signal.Enabled == false then
				continue
			end

			for i = 1, #signal.Connections do
				local conn = signal.Connections[i]
				task.spawn(conn, ...)
			end
		end
	end
end

function EzSignal.fireList(list : {[any] : signal}, ...)
	for _, signal in pairs(list) do
		EzSignal.Fire(signal, ...)
	end
end

function EzSignal.Enable(signal : signal, enabled : boolean)
	assert(signal.Connections, `Passed signal is not a valid signal object!`)
	
	signal.Enabled = enabled
end

function EzSignal.DisconnectAll(signal : signal)
	assert(signal.Connections, `Passed signal is not a valid signal object!`)
	
	signal.Connections = { }
end

return EzSignal :: EzSignal
