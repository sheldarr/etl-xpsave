# etl-xpsave

[ET: Legacy](https://github.com/etlegacy/etlegacy) script for xpsave.

### Description

- xp is saved in json file which is created in ./legacy folder next to the etl-xpsave lua script
- xp is automatically saved each minute for all players (including bots)
- xp is automatically loaded when player joins the server
- xp is automacially saved when user disconnects the server

### How To Use

1. Download etl-xpsave script and put it in the ./legacy folder which is inside the main [ET: Legacy](https://github.com/etlegacy/etlegacy) directory.
2. Download [dkjson](http://dkolf.de/src/dkjson-lua.fsl/home) script and put it next to etl-xpsave script.
3. Update lua_modules variable in your server configuration file e.g.

    ```bash
    set lua_modules "etl-xpsave.lua"
    ```

4. Start your server and enjoy the game :)

#### License [MIT](LICENSE.md)
