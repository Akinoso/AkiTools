local DB = Aki.DB

SLASH_AKI1 = '/aki'
SLASH_AKI2 = '/AKI'
SlashCmdList['AKI'] = function(msg)
    local command, rest = msg:lower():match('^(%S*)%s*(.-)$')

	if command=="test" then
		print('test')
	else
		InterfaceOptionsFrame_OpenToCategory('AkiTools_S')
		InterfaceOptionsFrame_OpenToCategory('AkiTools_S')

	end
end

SLASH_RL1 = '/rl'
SLASH_RL2 = '/RL'
SlashCmdList['RL'] = function(msg)
	ReloadUI()
end