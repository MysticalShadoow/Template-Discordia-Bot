-- Define the command properties
local sayCommand = {
    usage = "!say <message>",
    aliases = {"repeat", "sayoutloud"}
}

-- Define the command function
function sayCommand.run(client, message, args)
    -- Create the embed table
    local embed = {
        description = args-- Green color for the embed
    }

    -- Send the embed
    message.channel:send({
        embed = embed
    })
end

return sayCommand
