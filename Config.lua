local DB = Aki.DB
local soundList = Aki.soundList
local panel = Aki.panel
local scrollFrame = Aki.scrollFrame
--设置面板初始化
panel:SetSize(500, 1000)
scrollFrame.ScrollBar:ClearAllPoints()
scrollFrame.ScrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", -20, -20)
scrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", -20, 20)
scrollFrame:SetScrollChild(panel)
scrollFrame.name = 'AkiTools'
InterfaceOptions_AddCategory(scrollFrame)
--标题
local title = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLargeLeft')
title:SetPoint('TOPLEFT', 16, -16)
title:SetText("AkiTools v"..Aki.version)
--所有组件表
panel.controls = {}
--创建唯一命名函数
local UniqueName
do
	local controlID = 1

	function UniqueName(name)
		controlID = controlID + 1
		return string.format('AkiTools_%s_%02d', name, controlID)
	end
end
--设置面板确定函数
function scrollFrame:ConfigOkay()
	for _, control in pairs(panel.controls) do
		control.SaveValue(control.currentValue)
	end
end
--设置面板回到默认设置函数
function scrollFrame:ConfigDefault()
	for _, control in pairs(panel.controls) do
		control.currentValue = control.defaultValue
		control.SaveValue(control.currentValue)
	end
end
--设置面板刷新函数
function scrollFrame:ConfigRefresh()
	for _, control in pairs(panel.controls) do
		control.currentValue = control.LoadValue()
		control:UpdateValue()
	end
end
--创建标题函数
function panel:CreateHeading(text)
	local title = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLeft')
	title:SetText(text)
	return title
end
--创建文本函数
function panel:CreateText(text)
	local blob = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmallLeft')
	blob:SetText(text)
	return blob
end
--创建选择框函数
function panel:CreateCheckBox(text, LoadValue, SaveValue, defaultValue)
	local checkBox = CreateFrame('CheckButton', UniqueName('CheckButton'), self, 'InterfaceOptionsCheckButtonTemplate')

	checkBox.LoadValue = LoadValue
	checkBox.SaveValue = SaveValue
	checkBox.defaultValue = defaultValue
	checkBox.UpdateValue = function(self) self:SetChecked(self.currentValue) end
	getglobal(checkBox:GetName() .. 'Text'):SetText(text)
	checkBox:SetScript('OnClick', function(self) self.currentValue = self:GetChecked() end)

	self.controls[checkBox:GetName()] = checkBox
	return checkBox
end
--下拉菜单点击函数
local function DropDownOnClick(_, dropDown, selectedValue)
	dropDown.currentValue = selectedValue
	UIDropDownMenu_SetText(dropDown, dropDown.valueTexts[selectedValue])
	if type(selectedValue) == 'number' then
		PlaySoundFile(selectedValue, 'MASTER')
	end
end
--下拉菜单初始化函数
local function DropDownInitialize(frame)
	local info = UIDropDownMenu_CreateInfo()

	for i=1,#frame.valueList,2 do
		local k, v = frame.valueList[i], frame.valueList[i + 1]
		info.text = v
		info.value = k
		info.checked = frame.currentValue == k
		info.func = DropDownOnClick
		info.arg1, info.arg2 = frame, k
		UIDropDownMenu_AddButton(info)
	end
end
--创建下拉菜单函数
function panel:CreateDropDown(text, valueList, LoadValue, SaveValue, defaultValue)
	local title = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmallLeft')
	title:SetText(text)
	local dropDown = CreateFrame('Frame', UniqueName('DropDown'), self, 'UIDropDownMenuTemplate')
	dropDown:SetPoint('CENTER', title, 'CENTER', 120, 0)

	dropDown.LoadValue = LoadValue
	dropDown.SaveValue = SaveValue
	dropDown.defaultValue = defaultValue
	dropDown.UpdateValue = function(self)
		UIDropDownMenu_SetText(self, self.valueTexts[self.currentValue])
	end

	dropDown.valueList = valueList
	dropDown.valueTexts = {}
	for i=1,#valueList,2 do
		local k, v = valueList[i], valueList[i + 1]
		dropDown.valueTexts[k] = v
	end

	dropDown:SetScript('OnShow', function(self)
		UIDropDownMenu_Initialize(self, DropDownInitialize)
	end)

	UIDropDownMenu_JustifyText(dropDown, 'LEFT')
	UIDropDownMenu_SetWidth(dropDown, 120)
	UIDropDownMenu_SetButtonWidth(dropDown, 144)

	self.controls[dropDown:GetName()] = dropDown
	return title
end

--- 设置面板初始化 ---
function panel:Initialize()
	local attention = self:CreateHeading('注：根据暴雪在魔兽版本8.2.5对API的修改，说和喊在户外无法通过插件调用。')
	attention:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -20)

-- 独自一人时
	local solo = self:CreateHeading('独自一人')
	solo:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -50)

	-- 自己打断
	local soloOwnInterrupt = self:CreateDropDown(
		'自己打断',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'self', '自己可见' },
		function() return DB.solo.ownInterrupt end,
		function(v) DB.solo.ownInterrupt = v end,
		'self'
	)
	soloOwnInterrupt:SetPoint('TOPLEFT', solo, 'BOTTOMLEFT', 0, -10)
	-- 音效
	local soloOwnInterruptSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.solo.ownInterruptSound end,
		function(v) DB.solo.ownInterruptSound = v end,
		'')
	soloOwnInterruptSound:SetPoint('CENTER', soloOwnInterrupt, 'CENTER', 250, 0)

	-- 自己驱散
	local soloOwnDispel = self:CreateDropDown(
		'自己驱散',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'self', '自己可见' },
		function() return DB.solo.ownDispel end,
		function(v) DB.solo.ownDispel= v end,
		'self'
	)
	soloOwnDispel:SetPoint('TOPLEFT', solo, 'BOTTOMLEFT', 0, -30)
	-- 音效
	local soloOwnDispelSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.solo.ownDispelSound end,
		function(v) DB.solo.ownDispelSound = v end,
		'')
	soloOwnDispelSound:SetPoint('CENTER', soloOwnDispel, 'CENTER', 250, 0)
	
	-- 自己偷取
	local soloOwnStolen = self:CreateDropDown(
		'自己偷取',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'self', '自己可见' },
		function() return DB.solo.ownStolen end,
		function(v) DB.solo.ownStolen= v end,
		'self'
	)
	soloOwnStolen:SetPoint('TOPLEFT', solo, 'BOTTOMLEFT', 0, -50)
	-- 音效
	local soloOwnStolenSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.solo.ownStolenSound end,
		function(v) DB.solo.ownStolenSound = v end,
		'')
	soloOwnStolenSound:SetPoint('CENTER', soloOwnStolen, 'CENTER', 250, 0)

	-- 自己反射
	local soloOwnReflect = self:CreateDropDown(
		'自己反射',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'self', '自己可见' },
		function() return DB.solo.ownReflect end,
		function(v) DB.solo.ownReflect= v end,
		'self'
	)
	soloOwnReflect:SetPoint('TOPLEFT', solo, 'BOTTOMLEFT', 0, -70)
	-- 音效
	local soloOwnReflectSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.solo.ownReflectSound end,
		function(v) DB.solo.ownReflectSound = v end,
		'')
	soloOwnReflectSound:SetPoint('CENTER', soloOwnReflect, 'CENTER', 250, 0)
	
-- 副本队伍中
	local instance = self:CreateHeading('副本队伍中')
	instance:SetPoint('TOPLEFT', solo, 'BOTTOMLEFT', 0, -110)

	-- 自己打断
	local instanceOwnInterrupt = self:CreateDropDown(
		'自己打断',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'instance', '副本频道', 'self', '自己可见' },
		function() return DB.instance.ownInterrupt end,
		function(v) DB.instance.ownInterrupt = v end,
		'self'
	)
	instanceOwnInterrupt:SetPoint('TOPLEFT', instance, 'BOTTOMLEFT', 0, -10)
	-- 音效
	local instanceOwnInterruptSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.instance.ownInterruptSound end,
		function(v) DB.instance.ownInterruptSound = v end,
		'')
	instanceOwnInterruptSound:SetPoint('CENTER', instanceOwnInterrupt, 'CENTER', 250, 0)

	-- 自己驱散
	local instanceOwnDispel = self:CreateDropDown(
		'自己驱散',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'instance', '副本频道', 'self', '自己可见' },
		function() return DB.instance.ownDispel end,
		function(v) DB.instance.ownDispel= v end,
		'self'
	)
	instanceOwnDispel:SetPoint('TOPLEFT', instance, 'BOTTOMLEFT', 0, -30)
	-- 音效
	local instanceOwnDispelSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.instance.ownDispelSound end,
		function(v) DB.instance.ownDispelSound = v end,
		'')
	instanceOwnDispelSound:SetPoint('CENTER', instanceOwnDispel, 'CENTER', 250, 0)
	
	-- 自己偷取
	local instanceOwnStolen = self:CreateDropDown(
		'自己偷取',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'instance', '副本频道', 'self', '自己可见' },
		function() return DB.instance.ownStolen end,
		function(v) DB.instance.ownStolen= v end,
		'self'
	)
	instanceOwnStolen:SetPoint('TOPLEFT', instance, 'BOTTOMLEFT', 0, -50)
	-- 音效
	local instanceOwnStolenSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.instance.ownStolenSound end,
		function(v) DB.instance.ownStolenSound = v end,
		'')
	instanceOwnStolenSound:SetPoint('CENTER', instanceOwnStolen, 'CENTER', 250, 0)
	
	-- 自己反射
	local instanceOwnReflect = self:CreateDropDown(
		'自己反射',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'instance', '副本频道', 'self', '自己可见' },
		function() return DB.instance.ownReflect end,
		function(v) DB.instance.ownReflect= v end,
		'self'
	)
	instanceOwnReflect:SetPoint('TOPLEFT', instance, 'BOTTOMLEFT', 0, -70)
	-- 音效
	local instanceOwnReflectSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.instance.ownReflectSound end,
		function(v) DB.instance.ownReflectSound = v end,
		'')
	instanceOwnReflectSound:SetPoint('CENTER', instanceOwnReflect, 'CENTER', 250, 0)
	
	-- 他人打断
	local instanceOtherInterrupt = self:CreateDropDown(
		'他人打断',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'instance', '副本频道', 'self', '自己可见' },
		function() return DB.instance.otherInterrupt end,
		function(v) DB.instance.otherInterrupt = v end,
		'self'
	)
	instanceOtherInterrupt:SetPoint('TOPLEFT', instance, 'BOTTOMLEFT', 0, -90)
	-- 音效
	local instanceOtherInterruptSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.instance.otherInterruptSound end,
		function(v) DB.instance.otherInterruptSound = v end,
		'')
	instanceOtherInterruptSound:SetPoint('CENTER', instanceOtherInterrupt, 'CENTER', 250, 0)

	-- 他人驱散
	local instanceOtherDispel = self:CreateDropDown(
		'他人驱散',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'instance', '副本频道', 'self', '自己可见' },
		function() return DB.instance.otherDispel end,
		function(v) DB.instance.otherDispel= v end,
		'self'
	)
	instanceOtherDispel:SetPoint('TOPLEFT', instance, 'BOTTOMLEFT', 0, -110)
	-- 音效
	local instanceOtherDispelSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.instance.otherDispelSound end,
		function(v) DB.instance.otherDispelSound = v end,
		'')
	instanceOtherDispelSound:SetPoint('CENTER', instanceOtherDispel, 'CENTER', 250, 0)
	
	-- 他人偷取
	local instanceOtherStolen = self:CreateDropDown(
		'他人偷取',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'instance', '副本频道', 'self', '自己可见' },
		function() return DB.instance.otherStolen end,
		function(v) DB.instance.otherStolen= v end,
		'self'
	)
	instanceOtherStolen:SetPoint('TOPLEFT', instance, 'BOTTOMLEFT', 0, -130)
	-- 音效
	local instanceOtherStolenSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.instance.otherStolenSound end,
		function(v) DB.instance.otherStolenSound = v end,
		'')
	instanceOtherStolenSound:SetPoint('CENTER', instanceOtherStolen, 'CENTER', 250, 0)
	
	-- 他人反射
	local instanceOtherReflect = self:CreateDropDown(
		'他人反射',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'instance', '副本频道', 'self', '自己可见' },
		function() return DB.instance.otherReflect end,
		function(v) DB.instance.otherReflect= v end,
		'self'
	)
	instanceOtherReflect:SetPoint('TOPLEFT', instance, 'BOTTOMLEFT', 0, -150)
	-- 音效
	local instanceOtherReflectSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.instance.otherReflectSound end,
		function(v) DB.instance.otherReflectSound = v end,
		'')
	instanceOtherReflectSound:SetPoint('CENTER', instanceOtherReflect, 'CENTER', 250, 0)
	
-- 小队中
	local party = self:CreateHeading('小队中')
	party:SetPoint('TOPLEFT', instance, 'BOTTOMLEFT', 0, -190)
	
	-- 自己打断
	local partyOwnInterrupt = self:CreateDropDown(
		'自己打断',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'party', '小队频道', 'self', '自己可见' },
		function() return DB.party.ownInterrupt end,
		function(v) DB.party.ownInterrupt = v end,
		'self'
	)
	partyOwnInterrupt:SetPoint('TOPLEFT', party, 'BOTTOMLEFT', 0, -10)
	-- 音效
	local partyOwnInterruptSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.party.ownInterruptSound end,
		function(v) DB.party.ownInterruptSound = v end,
		'')
	partyOwnInterruptSound:SetPoint('CENTER', partyOwnInterrupt, 'CENTER', 250, 0)

	-- 自己驱散
	local partyOwnDispel = self:CreateDropDown(
		'自己驱散',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'party', '小队频道', 'self', '自己可见' },
		function() return DB.party.ownDispel end,
		function(v) DB.party.ownDispel= v end,
		'self'
	)
	partyOwnDispel:SetPoint('TOPLEFT', party, 'BOTTOMLEFT', 0, -30)
	-- 音效
	local partyOwnDispelSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.party.ownDispelSound end,
		function(v) DB.party.ownDispelSound = v end,
		'')
	partyOwnDispelSound:SetPoint('CENTER', partyOwnDispel, 'CENTER', 250, 0)
	
	-- 自己偷取
	local partyOwnStolen = self:CreateDropDown(
		'自己偷取',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'party', '小队频道', 'self', '自己可见' },
		function() return DB.party.ownStolen end,
		function(v) DB.party.ownStolen= v end,
		'self'
	)
	partyOwnStolen:SetPoint('TOPLEFT', party, 'BOTTOMLEFT', 0, -50)
	-- 音效
	local partyOwnStolenSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.party.ownStolenSound end,
		function(v) DB.party.ownStolenSound = v end,
		'')
	partyOwnStolenSound:SetPoint('CENTER', partyOwnStolen, 'CENTER', 250, 0)
	
	-- 自己反射
	local partyOwnReflect = self:CreateDropDown(
		'自己反射',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'party', '小队频道', 'self', '自己可见' },
		function() return DB.party.ownReflect end,
		function(v) DB.party.ownReflect= v end,
		'self'
	)
	partyOwnReflect:SetPoint('TOPLEFT', party, 'BOTTOMLEFT', 0, -70)
	-- 音效
	local partyOwnReflectSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.party.ownReflectSound end,
		function(v) DB.party.ownReflectSound = v end,
		'')
	partyOwnReflectSound:SetPoint('CENTER', partyOwnReflect, 'CENTER', 250, 0)
	
	
	-- 他人打断
	local partyOtherInterrupt = self:CreateDropDown(
		'他人打断',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'party', '小队频道', 'self', '自己可见' },
		function() return DB.party.otherInterrupt end,
		function(v) DB.party.otherInterrupt = v end,
		'self'
	)
	partyOtherInterrupt:SetPoint('TOPLEFT', party, 'BOTTOMLEFT', 0, -90)
	-- 音效
	local partyOtherInterruptSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.party.otherInterruptSound end,
		function(v) DB.party.otherInterruptSound = v end,
		'')
	partyOtherInterruptSound:SetPoint('CENTER', partyOtherInterrupt, 'CENTER', 250, 0)

	-- 他人驱散
	local partyOtherDispel = self:CreateDropDown(
		'他人驱散',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'party', '小队频道', 'self', '自己可见' },
		function() return DB.party.otherDispel end,
		function(v) DB.party.otherDispel= v end,
		'self'
	)
	partyOtherDispel:SetPoint('TOPLEFT', party, 'BOTTOMLEFT', 0, -110)
	-- 音效
	local partyOtherDispelSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.party.otherDispelSound end,
		function(v) DB.party.otherDispelSound = v end,
		'')
	partyOtherDispelSound:SetPoint('CENTER', partyOtherDispel, 'CENTER', 250, 0)
	
	-- 他人偷取
	local partyOtherStolen = self:CreateDropDown(
		'他人偷取',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'party', '小队频道', 'self', '自己可见' },
		function() return DB.party.otherStolen end,
		function(v) DB.party.otherStolen= v end,
		'self'
	)
	partyOtherStolen:SetPoint('TOPLEFT', party, 'BOTTOMLEFT', 0, -130)
	-- 音效
	local partyOtherStolenSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.party.otherStolenSound end,
		function(v) DB.party.otherStolenSound = v end,
		'')
	partyOtherStolenSound:SetPoint('CENTER', partyOtherStolen, 'CENTER', 250, 0)
	
	-- 他人反射
	local partyOtherReflect = self:CreateDropDown(
		'他人反射',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'party', '小队频道', 'self', '自己可见' },
		function() return DB.party.otherReflect end,
		function(v) DB.party.otherReflect= v end,
		'self'
	)
	partyOtherReflect:SetPoint('TOPLEFT', party, 'BOTTOMLEFT', 0, -150)
	-- 音效
	local partyOtherReflectSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.party.otherReflectSound end,
		function(v) DB.party.otherReflectSound = v end,
		'')
	partyOtherReflectSound:SetPoint('CENTER', partyOtherReflect, 'CENTER', 250, 0)
	
-- 团队中
	local raid = self:CreateHeading('团队中')
	raid:SetPoint('TOPLEFT', party, 'BOTTOMLEFT', 0, -190)
	
	-- 自己打断
	local raidOwnInterrupt = self:CreateDropDown(
		'自己打断',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'party', '小队频道', 'raid', '团队频道', 'self', '自己可见' },
		function() return DB.raid.ownInterrupt end,
		function(v) DB.raid.ownInterrupt = v end,
		'self'
	)
	raidOwnInterrupt:SetPoint('TOPLEFT', raid, 'BOTTOMLEFT', 0, -10)
	-- 音效
	local raidOwnInterruptSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.raid.ownInterruptSound end,
		function(v) DB.raid.ownInterruptSound = v end,
		'')
	raidOwnInterruptSound:SetPoint('CENTER', raidOwnInterrupt, 'CENTER', 250, 0)

	-- 自己驱散
	local raidOwnDispel = self:CreateDropDown(
		'自己驱散',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'party', '小队频道', 'raid', '团队频道', 'self', '自己可见' },
		function() return DB.raid.ownDispel end,
		function(v) DB.raid.ownDispel= v end,
		'self'
	)
	raidOwnDispel:SetPoint('TOPLEFT', raid, 'BOTTOMLEFT', 0, -30)
	-- 音效
	local raidOwnDispelSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.raid.ownDispelSound end,
		function(v) DB.raid.ownDispelSound = v end,
		'')
	raidOwnDispelSound:SetPoint('CENTER', raidOwnDispel, 'CENTER', 250, 0)
	
	-- 自己偷取
	local raidOwnStolen = self:CreateDropDown(
		'自己偷取',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'party', '小队频道', 'raid', '团队频道', 'self', '自己可见' },
		function() return DB.raid.ownStolen end,
		function(v) DB.raid.ownStolen= v end,
		'self'
	)
	raidOwnStolen:SetPoint('TOPLEFT', raid, 'BOTTOMLEFT', 0, -50)
	-- 音效
	local raidOwnStolenSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.raid.ownStolenSound end,
		function(v) DB.raid.ownStolenSound = v end,
		'')
	raidOwnStolenSound:SetPoint('CENTER', raidOwnStolen, 'CENTER', 250, 0)
	
	-- 自己反射
	local raidOwnReflect = self:CreateDropDown(
		'自己反射',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'party', '小队频道', 'raid', '团队频道', 'self', '自己可见' },
		function() return DB.raid.ownReflect end,
		function(v) DB.raid.ownReflect= v end,
		'self'
	)
	raidOwnReflect:SetPoint('TOPLEFT', raid, 'BOTTOMLEFT', 0, -70)
	-- 音效
	local raidOwnReflectSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.raid.ownReflectSound end,
		function(v) DB.raid.ownReflectSound = v end,
		'')
	raidOwnReflectSound:SetPoint('CENTER', raidOwnReflect, 'CENTER', 250, 0)
	
	-- 他人打断
	local raidOtherInterrupt = self:CreateDropDown(
		'他人打断',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'party', '小队频道', 'raid', '团队频道', 'self', '自己可见' },
		function() return DB.raid.otherInterrupt end,
		function(v) DB.raid.otherInterrupt = v end,
		'self'
	)
	raidOtherInterrupt:SetPoint('TOPLEFT', raid, 'BOTTOMLEFT', 0, -90)
	-- 音效
	local raidOtherInterruptSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.raid.otherInterruptSound end,
		function(v) DB.raid.otherInterruptSound = v end,
		'')
	raidOtherInterruptSound:SetPoint('CENTER', raidOtherInterrupt, 'CENTER', 250, 0)

	-- 他人驱散
	local raidOtherDispel = self:CreateDropDown(
		'他人驱散',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'party', '小队频道', 'raid', '团队频道', 'self', '自己可见' },
		function() return DB.raid.otherDispel end,
		function(v) DB.raid.otherDispel= v end,
		'self'
	)
	raidOtherDispel:SetPoint('TOPLEFT', raid, 'BOTTOMLEFT', 0, -110)
	-- 音效
	local raidOtherDispelSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.raid.otherDispelSound end,
		function(v) DB.raid.otherDispelSound = v end,
		'')
	raidOtherDispelSound:SetPoint('CENTER', raidOtherDispel, 'CENTER', 250, 0)
	
	-- 他人偷取
	local raidOtherStolen = self:CreateDropDown(
		'他人偷取',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'party', '小队频道', 'raid', '团队频道', 'self', '自己可见' },
		function() return DB.raid.otherStolen end,
		function(v) DB.raid.otherStolen= v end,
		'self'
	)
	raidOtherStolen:SetPoint('TOPLEFT', raid, 'BOTTOMLEFT', 0, -130)
	-- 音效
	local raidOtherStolenSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.raid.otherStolenSound end,
		function(v) DB.raid.otherStolenSound = v end,
		'')
	raidOtherStolenSound:SetPoint('CENTER', raidOtherStolen, 'CENTER', 250, 0)
	
	-- 他人反射
	local raidOtherReflect = self:CreateDropDown(
		'他人反射',
		{ 'off', '关', 'say', '说', 'yell', '喊', 'party', '小队频道', 'raid', '团队频道', 'self', '自己可见' },
		function() return DB.raid.otherReflect end,
		function(v) DB.raid.otherReflect= v end,
		'self'
	)
	raidOtherReflect:SetPoint('TOPLEFT', raid, 'BOTTOMLEFT', 0, -150)
	-- 音效
	local raidOtherReflectSound = self:CreateDropDown(
		'音效',
		soundList,
		function() return DB.raid.otherReflectSound end,
		function(v) DB.raid.otherReflectSound = v end,
		'')
	raidOtherReflectSound:SetPoint('CENTER', raidOtherReflect, 'CENTER', 250, 0)

-- 是否开启自动售卖
	local autoSellEnabled = self:CreateCheckBox(
		'自动售卖灰色物品',
		function() return DB.autoSell end,
		function(v) DB.autoSell = v end,
		true)
	autoSellEnabled:SetPoint('TOPLEFT', raid, 'BOTTOMLEFT', 0, -190)

-- 是否开启自动修理
	local autoRepairEnabled = self:CreateCheckBox(
		'自动修理',
		function() return DB.autoRepair end,
		function(v) DB.autoRepair = v end,
		true)
	autoRepairEnabled:SetPoint('TOPLEFT', raid, 'BOTTOMLEFT', 0, -210)
end

--面板初始化
panel:Initialize()
panel:Show()
scrollFrame.okay = scrollFrame.ConfigOkay
scrollFrame.default = scrollFrame.ConfigDefault
scrollFrame.refresh = scrollFrame.ConfigRefresh
scrollFrame:ConfigRefresh()
scrollFrame:Show()





