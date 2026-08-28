# Roblox Engine LuaU Wrapper

**This LuaU sandbox allows you to run code just like in the Roblox Engine**

*Author: @iriskxyz/sourcefundings

**Recent Changes**
- Added support for external modules using require
- Added support for HttpService
- Added support for Player service (If game.Players.Player is ever called it will create a fake player)
- Added DataModel Support

**TO-DO**
Finish bin to make the sandbox usable by other programs (Python, Node,...)

**IMPORTANT**
External module support only works with authorization. If you have the need to use require(assetid) please make sure to set your cookie in the config.json file.
This project is still Work In Progress so please be aware of bugs and issues. Feel free to report them.

**How to use**
- Make sure you have (lune)[https://github.com/lune-org/lune] installed
- Install Node.js (Needed for external require)
- Extract the source code
- Open ./src/sandbox.luau
- Change the code you wish to test/use at the very bottom
- Run using ```lune run src/sandbox.luau```