local DB = Aki.DB
local frame = Aki.frame
local blackList = Aki.blackList

-- 事件处理统一模版
frame:SetScript('OnEvent', function(self, event, ...)
	local a = self[event]
	if a then
		a(self, ...)
	end
end)

-- 插件加载
frame:RegisterEvent('ADDON_LOADED')
function frame:ADDON_LOADED(name)
	if name ~= 'AkiTools' then return end
	self:UnregisterEvent('ADDON_LOADED')
	if not AkiDB then AkiDB = {} end
	Aki:UpdateDB(DB, AkiDB)
end

-- 玩家登出
frame:RegisterEvent('PLAYER_LOGOUT')
function frame:PLAYER_LOGOUT()
	Aki:UpdateDB(AkiDB, DB)
end

-- 打开商店
frame:RegisterEvent('MERCHANT_SHOW')
function frame:MERCHANT_SHOW( ) 
	local num = 0
	local price = 0
	if DB.autoSell then
		for bag = 0, NUM_BAG_FRAMES do
			for slot = 1, GetContainerNumSlots(bag) do
				local itemId = GetContainerItemID(bag,slot)
				if itemId then 
					local _, _, itemRarity, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(itemId)
					if itemRarity == 0 then
						price = price + itemSellPrice
						UseContainerItem(bag,slot)
						num = num +1
					end 
				end 
			end
		end
		if (num > 0) then
			print('Aki已为您自动售卖['..num..']件灰色物品，获得['..GetCoinTextureString(price)..']')
		end
	end
	
	if DB.autoRepair then
		if CanMerchantRepair() then	
			repairAllCost, canRepair = GetRepairAllCost();
			if (canRepair and repairAllCost > 0) then
				if CanGuildBankRepair() then
					RepairAllItems(true)
					print('Aki已为您自动修理所有装备，工会修理费['..GetCoinTextureString(repairAllCost)..']')
				elseif repairAllCost <= GetMoney() then
					RepairAllItems(false)
					print('Aki已为您自动修理所有装备，修理费['..GetCoinTextureString(repairAllCost)..']')
				elseif repairAllCost > GetMoney() then
					print('Aki想为您自动使用修理，但您太穷了，连修理费都付不起。')
				end
			end
		end
	end
end


-- 战斗日志
frame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
function frame:COMBAT_LOG_EVENT_UNFILTERED( ...) 	
	-- 读取事件返回值
	local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
	local prefix, suffix = eventType:match('^(%u*)_(%S*)$')
	
	-- 战斗事件通报
	if prefix == 'SPELL' then
		local spellId, spellName, spellSchool = select(12, CombatLogGetCurrentEventInfo())
		if suffix == 'INTERRUPT' then
			local extraSpellId, extraSpellName, extraSchool = select(15, CombatLogGetCurrentEventInfo())
			if sourceName == UnitName('player')  or sourceName == UnitName('pet')then
				local c, s = Aki:GetConfig('ownInterrupt')
				Aki:Announce(c, '断 → '..GetSpellLink(extraSpellId), s)
			elseif Aki:IsInMyGroup(sourceFlags) then
				local name = Aki:ShortName(sourceName)
				local c, s = Aki:GetConfig('otherInterrupt')
				if c == 'self' and Aki:IsPlayer(sourceFlags) then
					name = Aki:ClassColor(name)
				end
				Aki:Announce(c, '['..name..']断 → '..GetSpellLink(extraSpellId), s)
			end

		elseif suffix == 'DISPEL' then
			local extraSpellId, extraSpellName, extraSchool, auraType = select(15, CombatLogGetCurrentEventInfo())
			if not blackList[extraSpellId] then
				if sourceName == UnitName('player')  or sourceName == UnitName('pet')then
					local c, s = Aki:GetConfig('ownDispel')
					Aki:Announce(c, '驱 → '..GetSpellLink(extraSpellId), s)
				elseif Aki:IsInMyGroup(sourceFlags) then
					local name = Aki:ShortName(sourceName)
					local c, s = Aki:GetConfig('otherDispel')
					if c == 'self' and Aki:IsPlayer(sourceFlags) then
						name = Aki:ClassColor(name)
					end
					Aki:Announce(c, '['..name..']驱 → '..GetSpellLink(extraSpellId), s)
				end
			end

		elseif suffix == 'STOLEN' then
			local extraSpellId, extraSpellName, extraSchool, auraType = select(15, CombatLogGetCurrentEventInfo())
			if sourceName == UnitName('player') then
				local c, s = Aki:GetConfig('ownStolen')
				Aki:Announce(c, '偷 → '..GetSpellLink(extraSpellId), s)
			elseif Aki:IsInMyGroup(sourceFlags) then
				local name = Aki:ShortName(sourceName)
				local c, s = Aki:GetConfig('otherStolen')
				if c == 'self' and Aki:IsPlayer(sourceFlags) then
					name = Aki:ClassColor(name)
				end
				Aki:Announce(c, '['..name..']偷 → '..GetSpellLink(extraSpellId), s)
			end

		elseif suffix == 'MISSED' then
			local missType, isOffHand, amountMissed = select(15, CombatLogGetCurrentEventInfo())
			if missType == 'REFLECT' and destName == UnitName('player') then 
				local c, s = Aki:GetConfig('ownReflect')
				Aki:Announce(c, '反 → '..GetSpellLink(spellId), s)
			elseif missType == 'REFLECT' and Aki:IsInMyGroup(sourceFlags) then
				local name = Aki:ShortName(destName)
				local c, s = Aki:GetConfig('otherReflect')
				if c == 'self' and Aki:IsPlayer(destFlags) then
					name = Aki:ClassColor(name)
				end
				Aki:Announce(c, '['..name..']反 → '..GetSpellLink(spellId), s)
			end
		end
	end
end