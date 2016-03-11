--[[
    author: https://github.com/sheldarr
    license: MIT
    name: ETL XpSave
    repository: https://github.com/sheldarr/etl-xpsave
    version: 1.0
]]--

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
        homePath = string.gsub(et.trap_Cvar_Get("fs_homepath") .. "/" .. et.trap_Cvar_Get("fs_game") .. "/","\\","/")
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

    et.G_Printf("MaxPlayers: %d\n", serverOptions.maxPlayers)
    et.G_Printf("BasePath: %s\n", serverOptions.basePath)
    et.G_Printf("HomePath: %s\n", serverOptions.homePath)

    for clientNumber = 0, serverOptions.maxPlayers - 1 do
        local player = getPlayer(clientNumber);

        if player.connectionStatus  == CONNECTIONS_STATUS.connected then
            saveXpForPlayer(player)
        end
    end
end

function saveXpForPlayer(player)
    et.G_Printf("Saving XP for %d %s\n", player.number, player.name)
    et.G_Printf("Battlesense: %d\n", player.skills.battlesense)
    et.G_Printf("Engineering: %d\n", player.skills.engineering)
    et.G_Printf("Medic: %d\n", player.skills.medic)
    et.G_Printf("FieldOps: %d\n", player.skills.fieldOps)
    et.G_Printf("LightWeapons: %d\n", player.skills.lightWeapons)
    et.G_Printf("HeavyWeapons: %d\n", player.skills.heavyWeapons)
    et.G_Printf("CovertOps: %d\n", player.skills.covertOps)
end

function loadXpForPlayer(player)
    et.G_XP_Set (player.number, 10.0, SKILLS.BATTLESENSE, 0)
    et.G_XP_Set (player.number, 20.0, SKILLS.ENGINEERING, 0)
    et.G_XP_Set (player.number, 30.0, SKILLS.MEDIC, 0)
    et.G_XP_Set (player.number, 40.0, SKILLS.FIELDOPS, 0)
    et.G_XP_Set (player.number, 50.0, SKILLS.LIGHTWEAPONS, 0)
    et.G_XP_Set (player.number, 60.0, SKILLS.HEAVYWEAPONS, 0)
    et.G_XP_Set (player.number, 70.0, SKILLS.COVERTOPS, 0)
end

function et.G_Printf(...)
    et.G_Print(string.format(...))
end

function sendMessageToPlayer(player, message, ...)
    et.trap_SendServerCommand(player.number, 'cpm\"' .. string.format(message, ...) .. '\n\"')
end

function et_InitGame(levelTime, randomSeed, restart)
    et.G_Printf('et_InitGame [%d] [%d] [%d]\n', levelTime, randomSeed, restart)
    et.RegisterModname(MOD_NAME)
end

function et_ShutdownGame(restart)
    et.G_Printf('et_ShutdownGame [%s]\n', restart)

    saveXpForAllPlayers()
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

    local player = getPlayer(clientNumber)

    saveXpForPlayer(player)
end

function et_ClientBegin(clientNumber)
    local player = getPlayer(clientNumber)

    et.G_Printf( 'et_ClientBegin: [%d] %s\n', clientNumber, player.name)
    sendMessageToPlayer(player, 'Welcome %s \n', player.name)

    loadXpForPlayer(player)
end

function et_ClientUserinfoChanged(clientNumber)
       et.G_Printf( 'et_ClientUserinfoChanged: [%d] = [%s]\n', clientNumber, et.trap_GetUserinfo(clientNumber))
end
