local DebugPrint = {}

local template = "[%s][%s][%s](%s)"

function DebugPrint:Init()
    self.SEVERITY = {
        [self.Enum.SeverityType.Debug] = "DEBUG",
        [self.Enum.SeverityType.Info] = "INFO",
        [self.Enum.SeverityType.Warn] = "WARN",
        [self.Enum.SeverityType.Error] = "ERROR",
        [self.Enum.SeverityType.Fatal] = "FATAL"
    }
end

function DebugPrint:Message(systemName, severityType, scriptName, ...)
	local messages = {...}
	local longString = ""
	for _, m in pairs(messages) do
		longString = longString .. m
	end
	if severityType == self.Enum.SeverityType.Fatal or severityType == self.Enum.SeverityType.Error then
		error(string.format(template, systemName, self.SEVERITY[severityType], scriptName, longString))	
	elseif severityType == self.Enum.SeverityType.Warn then
		warn(string.format(template, systemName, self.SEVERITY[severityType], scriptName, longString))
	else
		print(string.format(template, systemName, self.SEVERITY[severityType], scriptName, longString))	
	end
end

function DebugPrint:Trace(trackback)
	print(trackback)
end

return DebugPrint