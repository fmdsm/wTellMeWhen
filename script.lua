local _,ns = ...
local log = ns.log

local GetSpellCooldown,UnitAura,GetSpellCharges,IsUsableSpell = GetSpellCooldown,UnitAura,GetSpellCharges,IsUsableSpell

local unpack = unpack
local Color = {
	["RED"] = {1,0,0},--缺少光环
	["BLUE"] = {1,0,1},--缺少资源无法使用
	["YELLOW"] = {1,1,0},--可以使用
}
function ns.Show(btn,bordercolor)
	btn:Show()
	if bordercolor then
		btn.shadow:SetBackdropBorderColor(unpack(Color[bordercolor]))
		btn.shadow:Show()
	else
		btn.shadow:Hide()
	end
end

function ns.Hide(btn)
	btn:Hide()
end

local gcdid = 5019 --射击 83968群体复活
function ns.Cooldown(btn)
	local start,duration,enable = GetSpellCooldown(btn.id)
	local _,gcdduration = GetSpellCooldown(gcdid)
	if start >0 and enable ==1  then --正在冷却
		if gcdduration >= duration then return end
		btn.cd:SetCooldown(start,duration)
		ns.Show(btn)
	else
		btn.cd:SetCooldown(0,0)
		ns.Show(btn,"YELLOW")
	end
end

ns.Hook = function() end

function ns.Charges(btn)
	local count,maxcount,start,duration = GetSpellCharges(btn.id)
	btn.br:SetText(count)
	if count ~= maxcount then
		btn.cd:SetCooldown(start,duration)
		ns.Show(btn)
	else --全部冷却
		btn.cd:SetCooldown(0,0)
		ns.Show(btn,"YELLOW")
	end
end

function ns.Usable(btn)
	local isUsable, notEnoughMana = IsUsableSpell(btn.id)
	if isUsable then
		ns.Show(btn,"YELLOW")
	elseif notEnoughMana then
		ns.Show(btn,"BLUE")
	else
		ns.Hide(btn)
	end
end

function ns.UnitChange(btn)--只能遍历所有aura,用name只能判定是否存在但是无法判定是否是我施放的
	for i = 1,40 do
		local name, _, icon, count, _, duration, expires, _, _, _, id = UnitAura(btn.unit,i,btn.filter)
		--	local name, rank, icon, count, debuffType, duration, expires, caster, isStealable, shouldConsolidate, id = UnitAura(btn.unit,i,btn.filter)
		if not name then break end
		if id == btn.id or name == btn.id then
			--log("id相同,设置显示时间")
			btn:SetNormalTexture(icon)
			btn.br:SetText(count>1 and count)
			btn.cd:SetCooldown(expires-duration,duration)
			ns.Show(btn)
			return
		end
	end
	ns.Show(btn,"RED")
	btn.cd:SetCooldown(0,0)
	btn.br:SetText()
end

function ns.Aura(btn,unit)
	if unit and unit ~= btn.unit then return end
	btn:func()
end

-- do
	-- tinsert(functionList,{ns.TargetChange,"targetChange"})
	-- tinsert(functionList,{ns.Cooldown,"cooldown"})
-- end