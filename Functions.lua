local DB = Aki.DB

function Aki:UpdateDB(dst, src)
	for k, v in pairs(src) do
		if type(v) == 'table' then
			if type(dst[k]) == 'table' then
				self:UpdateDB(dst[k], v)
			else
				dst[k] = self:UpdateDB({}, v)
			end
		elseif type(dst[k]) ~= 'table' then
			dst[k] = v
		end
	end
	return dst
end

function Aki:CopyTable(targetTable)
    if targetTable == nil then
        return nil
    end
    if type(targetTable) ~= "table" then
        return targetTable
    end
    local newTable = {}
    local mt = getmetatable(targetTable)
    if mt ~= nil then
        setmetatable(newTable, mt)
    end
    for i, v in pairs(targetTable) do
        if type(v) == "table" then
            newTable[i] = TableDeepCopy(v)
        else
            newTable[i] = v
        end
    end
    return newTable
end

function Aki:Announce(mode, msg, sound)
	if sound ~= '' then
		PlaySoundFile(sound, 'MASTER')
	end
	if mode == 'off' then
		return
	elseif mode == 'self' or mode == '' then
		print(msg)
		return
	elseif mode == 'instance' or mod == 'i' then
		mode = 'INSTANCE_CHAT'
	elseif mode == 's'then
		mode = 'say'
	elseif mode == 'g' then
		mode = 'guild'
	elseif mode == 'p' then
		mode = 'party'
	elseif mode == 'r' then
		mode = 'raid'
	elseif mode == 'y' then
		mode = 'yell'
	end
	SendChatMessage(msg, mode:upper())
end

function Aki:ShortName(name)
	local shortName = name:match('^(%S*)%-') or name or '?'
	return shortName
end

function Aki:IsInMyGroup(flag)
	local inParty = IsInGroup()
	local inRaid = IsInRaid()
	local result = (inRaid and bit.band(flag, COMBATLOG_OBJECT_AFFILIATION_RAID) ~= 0) or (inParty and bit.band(flag, COMBATLOG_OBJECT_AFFILIATION_PARTY) ~= 0)
	return result
end

function Aki:IsPlayer(flag)
	local result = bit.band(flag, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0
	return result
end

function Aki:ClassColor(name)
	local _, classFileName = UnitClass(name)
	name = '|c' .. RAID_CLASS_COLORS[classFileName or 'PRIEST'].colorStr .. name .. '|r'
	return name
end

-- 获取当前状态对应的频道
function Aki:GetConfig(k)
	local inInstance = IsInGroup(LE_PARTY_CATEGORY_INSTANCE)
	local inParty = IsInGroup()
	local inRaid = IsInRaid()
	local cfg
	if inInstance then
		cfg = Aki:CopyTable(DB.instance)
	elseif inRaid then
		cfg = Aki:CopyTable(DB.raid)
	elseif inParty and not inRaid  then
		cfg = Aki:CopyTable(DB.party)
	else
		cfg = Aki:CopyTable(DB.solo)
	end
	local channel = cfg[k]
	if IsOutdoors() and (channel == 'say' or channel == 'yell') then
		channel = 'self'
	end
	local sound = cfg[k..'Sound']
	return channel, sound
end