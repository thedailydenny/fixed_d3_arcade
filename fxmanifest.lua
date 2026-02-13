fx_version 'cerulean'
game 'gta5'
lua54 'yes'

dependencies {
	'ox_target',
	'ox_lib'
}

shared_script '@ox_lib/init.lua'

client_scripts {
	"locale.lua",
	"locales/*.lua",
	"config.lua",

	"client/main.lua",
	"client/class/*.lua",
	"client/events.lua",
}

server_script {
	"locale.lua",
	"locales/*.lua",
	"config.lua",

	"server/server.lua",
}

files {
	"html/css/style.css",
	"html/css/reset.css",

	"html/css/img/monitor.png",

	"html/*.html",
	
	"html/scripts/listener.js",
}

ui_page "html/index.html"