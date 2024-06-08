-- Require the necessary libraries
local discordia = require('discordia')
local client = discordia.Client()
local fs = require('fs')  -- For reading the commands directory

-- Define the command prefix
local prefix = "!"

-- Table to hold the loaded commands
local commands = {}

-- Function to load all commands from the commands folder
local function loadCommands()
    local path = 'C:/Users/Administrator/Downloads/AstraalMC/commands'

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
