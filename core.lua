local _,ns = ...

local log = ns.log
local wBar = wBar
local MAXICON = 5
local GetSpellInfo = GetSpellInfo
local unpack,ipairs,select = unpack,ipairs,select

local Event = {}
local _Event = {}

-- _Event = {
	-- ["SPELL_UPDATE_COOLDOWN"] = {[1] = btn[1],[2] = btn[2],name = "SPELL_UPDATE_COOLDOWN"},
	-- ["UNIT_AURA"] = {[1] = btn[3],name = "UNIT_AURA"}
-- }
-- btn = {
	-- func = function() end,
	-- id = ,
	-- unit = ,
	-- filter = ,
	-- ...
-- }

local btn = {}
local addon = CreateFrame("Frame")
local Events = CreateFrame("Frame")

local mt = {
	__newindex = function(t,k,v)
		if not _Event[k] then
			_Event[k] = {name = k}
		end
	end,
	__index = function(t,k)
		if not _Event[k] then
			_Event[k] = {name = k}
		end
		return _Event[k]
	end
}
setmetatable(Event,mt)

function ns.SetIcon(btn,id,icontype,arg1,arg2,arg3)
	if not ns.argcheck(id,"string","number") then log("非法id类型:"..id) return end
	if icontype == "cooldown" then --arg1=func
		btn.id = id
		btn:SetNormalTexture(select(3,GetSpellInfo(id)))
		if  GetSpellCharges(btn.id) then --可累积层数的冷却类型
			btn.func = arg1 or ns.Charges
			tinsert(Event["SPELL_UPDATE_CHARGES"],btn)
		else --普通冷却类型
			btn.func = arg1 or ns.Cooldown
			tinsert(Event["SPELL_UPDATE_COOLDOWN"],btn)
		end
	elseif icontype == "buff" then --arg1=unit arg2=filter arg3=func
		if not ns.argcheck(arg1,"player","target","focus") then log("不支持的unit类型"..(arg1 or "nil")) return end
		btn.id = id
		btn.unit = arg1
		btn.filter = arg2 or "HELPFUL|PLAYER"
		btn.func = ns.Aura
		tinsert(Event["UNIT_AURA"],btn)
		btn.func = arg3 or ns.UnitChange
		if unit == "target" then
			tinsert(Event["PLAYER_TARGET_CHANGED"],btn)
		elseif unit == "focus" then
			tinsert(Event["PLAYER_FOCUS_CHANGED"],btn)
		end
		btn:SetNormalTexture(select(3,GetSpellInfo(id)))
	elseif icontype == "debuff" then --arg1=unit arg2=filter arg3=func
		if not ns.argcheck(arg1,"player","target","focus") then log("不支持的unit类型"..(arg1 or "nil")) return end
		btn.id = id
		btn.unit = arg1
		btn.filter = arg2 or "HARMFUL|PLAYER"
		btn.func =  ns.Aura
		tinsert(Event["UNIT_AURA"],btn)
		btn.func = arg3 or ns.UnitChange
		if unit == "target" then
			tinsert(Event["PLAYER_TARGET_CHANGED"],btn)
		elseif unit == "focus" then
			tinsert(Event["PLAYER_FOCUS_CHANGED"],btn)
		end
		btn:SetNormalTexture(select(3,GetSpellInfo(id)))
	elseif icontype == "usable" then --arg1=func
		btn.id = id
		btn:SetNormalTexture(select(3,GetSpellInfo(id)))
		btn.func = arg1 or ns.Usable
		tinsert(Event["SPELL_UPDATE_USABLE"],btn)
	elseif icontype == "item" then
	
	elseif type(icontype) == "function"then
		icontype(btn,id)
	else
		log("未知监视类型:"..icontype)
	end
end

addon:RegisterEvent("PLAYER_TALENT_UPDATE")
addon:SetScript("OnEvent",function(self,event,...)
	if event == "PLAYER_TALENT_UPDATE" then
		if getn(btn) ~= MAXICON then
			btn = ns.CreateIcon(wBar,{"CENTER",wBar,"CENTER"},36,4,MAXICON)
		else
			Events:UnregisterAllEvents()
			wipe(_Event)
		end
		--载入配置
		local spec = GetSpecialization()
		for i = 1,MAXICON do
			btn[i]:Hide()
			if ns.cfg[spec] and ns.cfg[spec][i] then
				if (ns.cfg[spec][i].mode) then
					local group = ns.cfg[spec][i]
					if group.mode == "talent" then
						for j in ipairs(group) do
							local name,_,_,_,selected = GetTalentInfo(group[j][1])
							if selected then
								ns.SetIcon(btn[i],name,unpack(group[j],2))
								btn[i]:Show()
								--log("选择天赋技能:"..name)
								break
							end
						end
					elseif group.mode == "order" then
						--
					else
						log("未知组模式:"..group.mode)
					end
				else
					ns.SetIcon(btn[i],unpack(ns.cfg[spec][i]))
					btn[i]:Show()
				end
			end
		end
		ns.Hook = function(cd) cd:GetParent():func() end
		--注册事件
		for i,e in pairs(_Event) do
			if getn(e) > 0 then
				Events:RegisterEvent(e.name)
				--log("注册事件"..e.name)
				for i in ipairs(_Event[e.name]) do --强制刷新状态
					_Event[e.name][i]:func()
				end
			end
		end
		log("重载配置")
	end
end)

Events:SetScript("OnEvent",function(self,event,...)
	--if not Event[event] then log(event.." error") end
	for i in ipairs(_Event[event]) do
		_Event[event][i].func(_Event[event][i],...)
	end
end)

function ns.test() --只有core文件有btn
	for i = 1,1000 do
		ns.Usable(btn[1])
		--ns.TargetChange(btn[3])
		--ns.Cooldown(btn[4])
	end
end