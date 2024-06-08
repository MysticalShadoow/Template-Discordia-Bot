-- Define the command properties
local sayCommand = {
    usage = "!say <message>",
    aliases = {"repeat", "sayoutloud"}
}

-- Define the command function
function sayCommand.run(client, message, args)
    message.channel:send(args)
end

return sayCommand
