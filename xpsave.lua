--[[
    author: https://github.com/sheldarr
    license: MIT
    name: ETL XpSave
    repository: https://github.com/sheldarr/etl-xpsave
    version: 1.0
]]--

local connectionStatus = {
    disconnected = 0,
    connecting = 1,
    connected = 2
}

local skills = {
    battlesense = 0,
    engineering = 1,
    medic = 2,
    fieldOps = 3,
    lightWeapons = 4,
    heavyWeapons = 5,
    covertOps = 6
}

function getPlayer(clientNumber)
    return {
        connectionStatus = et.gentity_get(clientNumber, "pers.connected"),
        name = et.Info_ValueForKey(et.trap_GetUserinfo(clientNumber), "name"),
        number = clientNumber
    }
end

function saveXpForAllPlayers()
    for clientNumber = 0, tonumber(et.trap_Cvar_Get("sv_maxclients")) - 1 do
        local player = getPlayer(clientNumber);

        if player.connectionStatus  == connectionStatus.connected then
            saveXpForPlayer(player)
        end
    end
end


function saveXpForPlayer(player)
    et.G_Printf("Saving XP for [%d] %s", player.number, player.name)
end

function et.G_Printf(...)
    et.G_Print(string.format(...))
end

function sendMessageToClient(clientNumber, message, ...)
    et.trap_SendServerCommand(tonumber(clientNumber), 'cpm\"' .. string.format(message, ...) .. '\n\"')
end

function et_InitGame(levelTime, randomSeed, restart)
    et.G_Printf('et_InitGame [%d] [%d] [%d]\n', levelTime, randomSeed, restart)
    et.RegisterModname(MOD_NAME)
end

function et_RunFrame(levelTime)
    if levelTime % 1000 == 0 then
        et.G_Printf('et_RunFrame [%d]\n', levelTime)
        saveXpForAllPlayers()
    end
end

-- return 1 if intercepted, 0 if passthrough
function et_ClientCommand(clientNumber, command)
    et.G_Printf('et_ClientCommand: [%d] [%d] [%s]\n', clientNumber, et.trap_Argc(), command)
    return 0
end

-- return 1 if intercepted, 0 if passthrough
function et_ConsoleCommand()
    et.G_Printf('et_ConsoleCommand: [%s] [%s]\n', et.trap_Argc(), et.trap_Argv(0))
    return 0
 end

function et_ClientConnect(clientNumber, firstTime, isBot)
    et.G_Printf( 'et_ClientConnect: [%d] [%d] [%d]\n', clientNumber, firstTime, isBot)

    return nil
end

function et_ClientDisconnect(clientNumber)
    et.G_Printf( 'et_ClientDisconnect: [%d]\n', clientNumber)
end

function et_ClientBegin(clientNumber)
    local clientName = et.Info_ValueForKey(et.trap_GetUserinfo(clientNumber), "name")

    et.G_Printf( 'et_ClientBegin: [%d] %s\n', clientNumber, clientName)
    sendMessageToClient(clientNumber, 'Welcome %s \nXpSave: ON', clientName)
end

function et_ClientUserinfoChanged(clientNumber)
       et.G_Printf( 'et_ClientUserinfoChanged: [%d] = [%s]\n', clientNumber, et.trap_GetUserinfo(clientNumber))
end
