fx_version("cerulean")
game("gta5")
author("Csoki")

shared_script("@es_extended/imports.lua")
shared_script("shared.lua")

client_script("client.lua")
server_script("server.lua")

files({
	"ui/*",
})

ui_page("ui/index.html")
