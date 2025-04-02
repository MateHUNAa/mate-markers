fx_version "cerulean"
game "gta5"
lua54 'yes'


author 'MateHUN [mhScripts]'
description 'Template used mCore.clientOnly'
version '1.0.0'


files {
    "icons/*.png"
}
escrow_ignore {
    "icons",
    "icons/",
    "icons/*.png",
}

dependency {
    'clientloader',
}

shared_script "@clientloader/shared.lua"
clientloader {
    "client/main.lua",
}
