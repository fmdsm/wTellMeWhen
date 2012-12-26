local _,ns = ...
local log = ns.log
local cfg

local _,myclass = UnitClass("player")
if myclass =="WARRIOR" then
	cfg = {}
elseif myclass =="HUNTER" then
	cfg = {}
elseif myclass == "SHAMAN" then
	cfg = {
		[1] = {--元素

		},
		[2] = {--增强
		
		},
		[3] = {--恢复
			[1] = {73680,"cooldown"},
			[2] = {73920,"cooldown"},
			[3] = {5394,"cooldown"},
			[4] = {53390,"buff","player"},
		},
	}
elseif myclass == "PALADIN" then
	cfg = {}
elseif myclass == "PRIEST" then
	cfg = {}
elseif myclass == "WARLOCK" then
	cfg = {
		[1] = {},
		[2] = {},
		[3] = {--毁灭
			[1] = {17877,"usable",},
			[2] = {17962,"cooldown",},
			[3] = {"獻祭","debuff","target"},
			[4] = {117828,"buff","player"},
			[5] = {30283,"cooldown"},
		},
	}
elseif myclass == "ROGUE" then
	cfg = {}
elseif myclass == "MAGE" then
	cfg = {
		[1] = { --奥
			
		},
		[2] = {--火
			[3] = {
				{13,"debuff","target"},
				{14,"debuff","target"},
				{15,"cooldown"},
				mode = "talent",--同一时间只可能存在一种
			},
			[4] = {108853,"cooldown"},
			[5] = {11129,"cooldown"},
		},
		[3] = {--冰
			[3] = {112948,"cooldown"},
			[2] = {84714,"cooldown"},
			[5] = {33395,"cooldown"},
		},
	}
elseif myclass == "DRUID" then
	cfg = {}
elseif myclass == "DEATHKNIGHT" then
	cfg = {}
elseif myclass == "MONK" then
	cfg = {}
else
	log("未知职业:"..myclass)
end

ns.cfg = cfg or {}