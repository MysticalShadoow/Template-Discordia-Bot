-- Require the necessary libraries
local discordia = require('discordia')
local client = discordia.Client()
local fs = require('fs')  -- For reading the commands directory
local stopwatch = discordia.Stopwatch()  -- For reading the commands directory

-- Define the command prefix
local prefix = "!"

-- Bot creator's user ID
local creatorId = "1261343684859924643"

-- Table to hold the loaded commands
local commands = {}

local function getScriptPath()
    local str = debug.getinfo(1, "S").source
    if str:sub(1, 1) == "@" then
        local scriptPath = str:sub(2)
        local lastSlash = scriptPath:match(".*[\\/]")
        return lastSlash
    else
        return nil, "Cannot determine script path"
    end
end

local function loadCommands()
    local scriptPath, err = getScriptPath()
    if not scriptPath then
        print("Error: " .. (err or "Unknown error"))
        return
    end
    
    local path = scriptPath .. 'commands'

    -- Check if the commands directory exists
    if not fs.existsSync(path, 'directory') then
        print("Error: 'commands' directory does not exist.")
        return
    end

    local success, dir = pcall(fs.readdirSync, path)
    if not success then
        print("Error: Unable to read 'commands' directory. Make sure the 'commands' folder exists and is accessible.")
        return
    end

    for _, file in ipairs(dir) do
        if file:match('%.lua$') then
            local commandName = file:match('^(.-)%.lua$')
            local commandPath = path .. '/' .. file
            local success, command = pcall(dofile, commandPath)
            if success then
                -- Check if the loaded command is a table
                if type(command) == "table" then
                    -- Add the usage and aliases if provided
                    command.usage = command.usage or "Usage not specified"
                    command.aliases = command.aliases or {}

                    commands[commandName] = command
                    print("Loaded command:", commandName)  -- Print the loaded command
                else
                    print("Error: Command from file " .. commandPath .. " is not a table.")
                end
            else
                print("Error: Unable to load command from file " .. commandPath .. ". " .. command)
            end
        end
    end
end

-- Load commands on startup
-- Add the reload command
commands["reload"] = {
    run = function(client, message, args)
        if message.author.id ~= creatorId then
            message.channel:send("You do not have permission to use this command.")
            return
        end

        local startTime = os.clock()  -- Start time measurement

        loadCommands()
        
        local endTime = os.clock()  -- End time measurement

        local timeTaken = endTime - startTime  -- Calculate elapsed time in seconds

        -- Format the elapsed time to 1 significant figure
        local formattedTime = string.format("%.1g", timeTaken)

        -- Create the embed table
        local embed = {
            title = "Commands Reloaded",
            description = "All commands have been reloaded successfully.",
            fields = {
                {
                    name = "Time Taken",
                    value = formattedTime .. " seconds",
                    inline = true
                }
            }, -- Green color
        }

        -- Send the embed
        message.channel:send({
            embed = embed
        })
    end,
    usage = "reload",
    aliases = {"restart"},
    description = "Reloads the bot's commands."
}


loadCommands()


-- Event handler for when the bot is ready
client:on('ready', function()
    print('Logged in as ' .. client.user.username)
end)

-- Event handler for when a message is created
client:on('messageCreate', function(message)
    -- Ignore messages from the bot itself
    if message.author == client.user then return end

    -- Check if the message starts with the command prefix
    if message.content:sub(1, #prefix) == prefix then
        -- Extract the command and arguments from the message
        local commandName, args = message.content:match('^' .. prefix .. '(%S+)%s*(.*)')

        -- Check if the command exists
        local command = commands[commandName]
        if command then
            -- Execute the command
            command.run(client, message, args)
        else
            -- Check if there are any aliases for the command
            for _, cmd in pairs(commands) do
                if cmd.aliases then
                    for _, alias in ipairs(cmd.aliases) do
                        if alias == commandName then
                            -- Execute the alias command
                            cmd.run(client, message, args)
                            return
                        end
                    end
                end
            end

            -- Command not found
            message.channel:send('Command not found!')
        end
    end
end)


-- Log in to Discord with your bot token
client:run('Bot token')
