--[[
    author: https://github.com/sheldarr
    license: MIT
    name: ETL XpSave
    repository: https://github.com/sheldarr/etl-xpsave
    version: 1.0
]]--

local json = require('json')

local MOD_NAME = "etl-xpsave"

local CONNECTIONS_STATUS = {
    disconnected = 0,
    connecting = 1,
    connected = 2
}

local SKILLS = {
    BATTLESENSE = 0,
    ENGINEERING = 1,
    MEDIC = 2,
    FIELDOPS = 3,
    LIGHTWEAPONS = 4,
    HEAVYWEAPONS = 5,
    COVERTOPS = 6
}

function getServerOptions()
    return {
        maxPlayers = tonumber(et.trap_Cvar_Get("sv_maxclients")),
        basePath = string.gsub(et.trap_Cvar_Get("fs_basepath") .. "/" .. et.trap_Cvar_Get("fs_game") .. "/","\\","/"),
        homePath = string.gsub(et.trap_Cvar_Get("fs_homepath") .. "/" .. et.trap_Cvar_Get("fs_game") .. "/","\\","/"),
        xpSaveFileName = "xpsave.json"
    }
end

function getPlayer(clientNumber)
    return {
        connectionStatus = et.gentity_get(clientNumber, "pers.connected"),
        guid = et.Info_ValueForKey(et.trap_GetUserinfo(clientNumber), "cl_guid"),
        name = et.Info_ValueForKey(et.trap_GetUserinfo(clientNumber), "name"),
        number = clientNumber,
        skills = {
            battlesense = et.gentity_get(clientNumber, "sess.skillpoints", SKILLS.BATTLESENSE),
            engineering = et.gentity_get(clientNumber, "sess.skillpoints", SKILLS.ENGINEERING),
            medic = et.gentity_get(clientNumber, "sess.skillpoints", SKILLS.MEDIC),
            fieldOps = et.gentity_get(clientNumber, "sess.skillpoints", SKILLS.FIELDOPS),
            lightWeapons = et.gentity_get(clientNumber, "sess.skillpoints", SKILLS.LIGHTWEAPONS),
            heavyWeapons = et.gentity_get(clientNumber, "sess.skillpoints", SKILLS.HEAVYWEAPONS),
            covertOps = et.gentity_get(clientNumber, "sess.skillpoints", SKILLS.COVERTOPS)
        }
    }
end

function saveXpForAllPlayers()
    local serverOptions = getServerOptions()

    for clientNumber = 0, serverOptions.maxPlayers - 1 do
        local player = getPlayer(clientNumber);

        if player.connectionStatus  == CONNECTIONS_STATUS.connected then
            saveXpForPlayer(player)
        end
    end
end

function loadXpFromFile()
    local serverOptions = getServerOptions()
    local filePath = serverOptions.basePath .. serverOptions.xpSaveFileName

    local xpSaveFile = io.open(filePath, "r")

    local encodedXp = xpSaveFile:read("*all")
    xpSaveFile:close()

    return json.decode(encodedXp)
end

function saveXpToFile(xp)
    local serverOptions = getServerOptions()
    local filePath = serverOptions.basePath .. serverOptions.xpSaveFileName
    local encodedXp = json.encode(xp)

    local xpSaveFile = io.open(filePath, "w")

    xpSaveFile:write(encodedXp)
    xpSaveFile:close()
end

function saveXpForPlayer(player)
    local xp = loadXpFromFile()

    xp[player.guid] = player.skills

    saveXpToFile(xp)
end

function loadXpForPlayer(player)
    local xp = loadXpFromFile()
    local playerXp = xp[player.guid]

    et.G_Printf("Loading for: %s %s\n", player.name, player.guid)

    if playerXp then
        et.G_Printf("XP FOUND\n")

        et.G_XP_Set (player.number, playerXp.battlesense, SKILLS.BATTLESENSE, 0)
        et.G_XP_Set (player.number, playerXp.engineering, SKILLS.ENGINEERING, 0)
        et.G_XP_Set (player.number, playerXp.medic, SKILLS.MEDIC, 0)
        et.G_XP_Set (player.number, playerXp.fieldOps, SKILLS.FIELDOPS, 0)
        et.G_XP_Set (player.number, playerXp.lightWeapons, SKILLS.LIGHTWEAPONS, 0)
        et.G_XP_Set (player.number, playerXp.heavyWeapons, SKILLS.HEAVYWEAPONS, 0)
        et.G_XP_Set (player.number, playerXp.covertOps, SKILLS.COVERTOPS, 0)
    end
end

function et.G_Printf(...)
    et.G_Print(string.format(...))
end

function sendMessageToPlayer(player, message, ...)
    et.trap_SendServerCommand(player.number, "cpm\"" .. string.format(message, ...) .. "\n\"")
end

function et_InitGame(levelTime, randomSeed, restart)
    et.G_Printf("et_InitGame [%d] [%d] [%d]\n", levelTime, randomSeed, restart)
    et.RegisterModname(MOD_NAME)
end

function et_ShutdownGame(restart)
    et.G_Printf("et_ShutdownGame [%s]\n", restart)

    saveXpForAllPlayers()
end

function et_RunFrame(levelTime)
    if levelTime % 1000 == 0 then
        et.G_Printf("et_RunFrame [%d]\n", levelTime)
        saveXpForAllPlayers()
    end
end

-- return 1 if intercepted, 0 if passthrough
function et_ClientCommand(clientNumber, command)
    et.G_Printf("et_ClientCommand: [%d] [%d] [%s]\n", clientNumber, et.trap_Argc(), command)
    return 0
end

-- return 1 if intercepted, 0 if passthrough
function et_ConsoleCommand()
    et.G_Printf("et_ConsoleCommand: [%s] [%s]\n", et.trap_Argc(), et.trap_Argv(0))
    return 0
 end

function et_ClientConnect(clientNumber, firstTime, isBot)
    et.G_Printf( "et_ClientConnect: [%d] [%d] [%d]\n", clientNumber, firstTime, isBot)

    return nil
end

function et_ClientDisconnect(clientNumber)
    et.G_Printf( "et_ClientDisconnect: [%d]\n", clientNumber)

    local player = getPlayer(clientNumber)

    saveXpForPlayer(player)
end

function et_ClientBegin(clientNumber)
    local player = getPlayer(clientNumber)

    et.G_Printf( "et_ClientBegin: [%d] %s\n", clientNumber, player.name)
    sendMessageToPlayer(player, "Welcome %s \n", player.name)

    loadXpForPlayer(player)
end

function et_ClientUserinfoChanged(clientNumber)
       et.G_Printf( "et_ClientUserinfoChanged: [%d] = [%s]\n", clientNumber, et.trap_GetUserinfo(clientNumber))
end
