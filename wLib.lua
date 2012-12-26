local addon,ns = ...

local tinsert,type = tinsert,type
ns.logs = {}
function ns.log(msg)
	tinsert(ns.logs,addon..":"..msg)
end

local log = ns.log

function ns.argcheck(value,...)
	for i = 1,select("#",...) do
		if type(value)==select(i,...) or value == select(i,...) then return true end
	end
	return false
end

function ns.CreateShadow(parent)
	local Shadow = CreateFrame("Frame", nil, parent)
	Shadow:SetFrameStrata("BACKGROUND")
	Shadow:SetPoint("TOPLEFT", -3, 3)
	Shadow:SetPoint("BOTTOMRIGHT", 3, -3)
	Shadow:SetBackdrop({
	BgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\AddOns\\wBar\\media\\glowTex", edgeSize = 3,
	insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	Shadow:SetBackdropColor(1, 1, 1, 1)--阴影颜色
	Shadow:SetBackdropBorderColor(0,1, 1,1)--阴影边框 红 绿 蓝
	return Shadow
end

function ns.CreateText(parent,anchor,size)
	local text = parent:CreateFontString(nil,"ARTWORK")
	text:SetFont("Fonts\\ARIALN.ttf", size,"THINOUTLINE")
	text:SetPoint(unpack(anchor))
	text:SetVertexColor(1, 1, 1)
	return text
end

function ns.CreateIcon(parent,anchor,size,space,num)
	local btn = {}
	for i = 1,num do
		btn[i] = CreateFrame("BUTTON",nil,parent)
		btn[i]:SetSize(size,size)
		if i == 1 then
			btn[i]:SetPoint(unpack(anchor),-(size+space)*(num-1)/2,-30-size/2)
		else
			btn[i]:SetPoint("LEFT",btn[i-1],"RIGHT",space,0)
		end
		btn[i].cd = CreateFrame("COOLDOWN",nil,btn[i])
		btn[i].cd:SetAllPoints(btn[i])
		btn[i].cd:SetFrameLevel(btn[i]:GetFrameLevel()+1)
		btn[i].cd:HookScript("OnHide",function(self) ns.Hook(self) end)
		
		btn[i].cen = ns.CreateText(btn[i],{"CENTER"},size/2)
		btn[i].br = ns.CreateText(btn[i],{"BOTTOMRIGHT",btn[i],"BOTTOMRIGHT"},size*0.4)
		
		btn[i].shadow = ns.CreateShadow(btn[i])
		btn[i].shadow:Hide()
		
		btn[i]:SetID(i)
		btn[i]:Show()
	end
	return btn
end

SLASH_LOG1 = "/log"
SlashCmdList["LOG"] = function(cmd)
	if cmd == "test" then
		ns.test()
	else
		for i,msg in pairs(ns.logs) do
			print(msg)
		end
		print(getn(ns.logs).."条信息已清除")
		wipe(ns.logs)
	end
end