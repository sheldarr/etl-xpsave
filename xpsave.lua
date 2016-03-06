--[[
author: https://github.com/sheldarr
name: ETL XpSave
version: 1.0
]]--

local MOD_NAME      = "ETL XpSave"
local MOD_VERSON    = "1.0"
local MOD_SHORTNAME = "ETLXPSAVE"

-- printf wrapper
function et.G_Printf(...)
       et.G_Print(string.format(unpack(arg)))
end

-- test some of the supported etpro lua functions
function test_lua_functions()
       et.trap_Cvar_Set( "bla1", "bla2" )
       et.G_Printf( "sv_hostname [%s]\n", et.trap_Cvar_Get( "sv_hostname" ) )
       et.G_Printf( "configstring 1 [%s] \n", et.trap_GetConfigstring( 1 ) )
       et.trap_SetConfigstring( 4, "yadda test" )
       et.G_Printf( "configstring 4 [%s]\n", et.trap_GetConfigstring( 4 ) )
       et.trap_SendConsoleCommand( et.EXEC_APPEND, "cvarlist *charge*\n" )
       et.trap_SendServerCommand( -1, "print \"Yadda yadda\"" )
       et.G_Printf( "gentity[1022].classname = [%s]", et.gentity_get( 1022, "classname" ) )
end

-- called when game inits
function et_InitGame( levelTime, randomSeed, restart )
       et.G_Printf( "et_InitGame [%d] [%d] [%d]\n", levelTime, randomSeed, restart )
       et.RegisterModname( "bani qagame " .. et.FindSelf() )
--     test_lua_functions()
end

-- called every server frame
function et_RunFrame( levelTime )
       if math.mod( levelTime, 1000 ) == 0 then
--             et.G_Printf( et_RunFrame [%d]\n", levelTime )
       end
end

-- called for every clientcommand
-- return 1 if intercepted, 0 if passthrough
function et_ClientCommand( clientNum, cmd )
       et.G_Printf( "et_ClientCommand: [%d] [%s]\n", et.trap_Argc(), cmd )
       return 0
end

-- called for every consolecommand
-- return 1 if intercepted, 0 if passthrough
function et_ConsoleCommand()
       et.G_Printf( "et_ConsoleCommand: [%s] [%s]\n", et.trap_Argc(), et.trap_Argv(0) )
       if et.trap_Argv(0) == "listmods" then
               i = 1
               repeat
                       modname, signature = et.FindMod( i )
                       if modname and signature then
                               et.G_Printf( "vm slot [%d] name [%s] signature [%s]\n", i, modname, signature )
                               et.IPCSend( i, "hello" )
                       end
                       i = i + 1
               until modname == nil or signature == nil
               return 1
       end
       return 0
 end

-- called when we receive an IPC from another VM
function et_IPCReceive( vmnumber, message )
       et.G_Printf( "IPCReceive [%d] from [%d] message [%s]\n", et.FindSelf(), vmnumber, message )
end

-- called for every ClientConnect
function et_ClientConnect( clientNum, firstTime, isBot )
       et.G_Printf( "et_ClientConnect: [%d] [%d] [%d]\n", clientNum, firstTime, isBot )
--     return "go away"
       return nil
end

-- called for every ClientDisconnect
function et_ClientDisconnect( clientNum )
       et.G_Printf( "et_ClientDisconnect: [%d]\n", clientNum )
end

-- called for every ClientBegin
function et_ClientBegin( clientNum )
       et.G_Printf( "et_ClientBegin: [%d]\n", clientNum )
end

-- called for every ClientUserinfoChanged
function et_ClientUserinfoChanged( clientNum )
       et.G_Printf( "et_ClientUserinfoChanged: [%d] = [%s]\n", clientNum, et.trap_GetUserinfo( clientNum ) )
end

-- called for every trap_Printf
function et_Print( text )
--     et.G_Printf( "et_Print [%s]", text )
end
