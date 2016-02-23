if myHero.charName ~= 'Zyra' then return end
--~~~~~~ General Localizations
local pi, pi2, sin, cos, atan, atan2, acos, huge, sqrt, max, ceil, abs = math.pi, 2*math.pi, math.sin, math.cos, math.atan, math.atan2, math.acos, math.huge, math.sqrt, math.max, math.floor, math.abs
local lshift, rshift, band, bxor, DwordToFloat = bit32.lshift, bit32.rshift, bit32.band, bit32.bxor, DwordToFloat
local clock = os.clock
local pairs, ipairs = pairs, ipairs
local insert, remove = table.insert, table.remove
local TEAM_ALLY, TEAM_ENEMY, SAVE_FILE, DPExist

local function Normalize(x,z)
    local length  = sqrt(x * x + z * z)
	return { ['x'] = x / length, ['z'] = z / length, }
end

local function NormalizeX(v1, v2, length)
	x, z = v1.x - v2.x, v1.z - v2.z
    local nLength  = sqrt(x * x + z * z)
	return { ['x'] = v2.x + ((x / nLength) * length), ['z'] = v2.z + ((z / nLength) * length)} 
end

local CircleDraw = {
	[1] = function(pos, range, color)
		local c = WorldToScreen(D3DXVECTOR3(pos.x, pos.y or 0, pos.z))
		if c.x < WINDOW_W+200 and c.y < WINDOW_H+200 and c.x > -200 and c.y > -200 then
			local points = {}
			for theta = 0, (pi2+(pi/16)), (pi/16) do
				local tS = WorldToScreen(D3DXVECTOR3(pos.x+(range*cos(theta)), pos.y or 0, pos.z-(range*sin(theta))))
				points[#points + 1] = D3DXVECTOR2(tS.x, tS.y)
			end
			DrawLines2(points, 2, bit32.bor(color, 0xAA000000))
		end
	end,
	[2] = function(pos, range, color)
		DrawCircle(pos.x, pos.y or 0, pos.z, range + 70, color)
	end,
	[3] = function() return end,
}	

function Print(text, isError)
	if isError then
		print('<font color=\'#0099FF\'>[Pew Zyra] </font> <font color=\'#FF0000\'>'..text..'</font>')	
		return
	end
	print('<font color=\'#0099FF\'>[Pew Zyra] </font> <font color=\'#FF6600\'>'..text..'</font>')
end

--~~~~~~End Localizations

AddLoadCallback(function()	
	SAVE_FILE = { ['Prediction'] = 'HPred', }
	if FileExist(LIB_PATH..'/Saves/PewZyra.save') then
		local file = io.open(LIB_PATH..'/Saves/PewZyra.save', 'r')
		local content = file:read('*all')
		if content then 
			SAVE_FILE = JSON:decode(content)		
		end
		file:close()
	end
	DPExist = FileExist(LIB_PATH..'DivinePred.lua')
	if DPExist then require('DivinePred') end
	if FileExist(LIB_PATH..'HPrediction.lua') then require('HPrediction') end
	
	TEAM_ALLY, TEAM_ENEMY = myHero.team, 300 - myHero.team
	
	local isLoaded, loadTime = false, clock()
	AddTickCallback(function() 
		if _Pewalk and not isLoaded then
			isLoaded = true
			Print('Load Completed')
			Zyra()
		elseif loadTime + 5 < clock() and not isLoaded then
			Print('Standalone Pewalk is now required, check forum!!', true)
			isLoaded = true
		end
	end)	
end)

class 'Zyra'

function Zyra:__init()

	-----------------------
	--Update
	-----------------------
	local version = 2.2 --0.1 increments
	local Downloads = {
		[1] = {
			version = version,
			useHttps = true,
			host = 'raw.githubusercontent.com',
			onlineVersion = '/PewPewPew2/BoL/master/Versions/PewZyra.version',
			onlinePath = '/PewPewPew2/BoL/master/PewZyra.lua',
			localPath = SCRIPT_PATH.._ENV.FILE_NAME,
			onUpdateComplete = function() Print('Update Complete. Please reload. (F9 F9)') end,
			onLoad = function() Print('Loaded latest version. v'..version..'.') end,
			onNewVersion = function() Print('New version found, downloading now...') end,
			onError = function() Print('There was an error during update.') end,
			checkExist = false,
			endScript = false,
		},
		[2] = {
			version = 0,
			useHttps = true,
			host = 'raw.githubusercontent.com',
			onlineVersion = '/BolHTTF/BoL/master/HTTF/Version/HPrediction.version',
			onlinePath = '/BolHTTF/BoL/master/HTTF/Common/HPrediction.lua',
			localPath = LIB_PATH..'/HPrediction.lua',
			onUpdateComplete = function() Print('HPrediction Download Complete. Please reload.') end,
			onLoad = function() return end,
			onNewVersion = function() Print('HPrediction cannot be found, downloading now...') end,
			onError = function() Print('There was an error downloading HPrediction.') end,
			checkExist = true,
			endScript = true,
		},
		[3] = {
			version = 0,
			useHttps = true,
			host = 'raw.githubusercontent.com',
			onlineVersion = '/PewPewPew2/BoL/master/Versions/PewPacketLib.version',
			onlinePath = '/PewPewPew2/BoL/master/PewPacketLib.lua',
			localPath = LIB_PATH..'/PewPacketLib.lua',
			onUpdateComplete = function() Print('PewPacketLib Download Complete. Please reload.') end,
			onLoad = function() return end,
			onNewVersion = function() Print('PewPacketLib cannot be found, downloading now...') end,
			onError = function() Print('There was an error downloading PewPacketLib.') end,
			checkExist = true,
			endScript = true,
		},
	}
	local criticalDownload = false
	for _, dl in ipairs(Downloads) do
		if not dl.checkExist or not FileExist(dl.localPath) then
			ScriptUpdate(
				dl.version,
				dl.useHttps, 
				dl.host, 
				dl.onlineVersion, 
				dl.onlinePath, 
				dl.localPath, 
				dl.onUpdateComplete, 
				dl.onLoad, 
				dl.onNewVersion,
				dl.onError
			)
			if dl.endScript then criticalDownload = true end
		end
	end
	if criticalDownload then return end

	require 'PewPacketLib'

	-----------------------
	--General Init
	-----------------------	

	self.Dashing = {}
	self.LastPaths = {}
	self.Enemies = {}
	for i=1, heroManager.iCount do
		local h = heroManager:getHero(i)
		if h and h.team == TEAM_ENEMY then
			self.Enemies[#self.Enemies + 1] = h
			self.Dashing[h.networkID] = {}
			self.LastPaths[h.networkID] = {pos=Vector(0,0,0), time=0}
		end
	end
	self:CreateMenu()
		
	-----------------------
	--Spells Init
	-----------------------
	
	self.Spells = {
		[_Q] = {
			['bReady']	   = false,
			['range'] 	   = 800,
			['rangeSqr']   = 640000,
			['radius'] 	   = 261,
			['speed'] 	   = huge,
			['delay'] 	   = 0.95,
			['damage']     = function() return (35 * myHero:GetSpellData(_Q).level) + 35 + (myHero.ap * 0.65) end,
			['mana']	   = function() return 70 + (myHero:GetSpellData(_Q).level * 5) end,
		},
		[_W] = {
			['bReady']	   = false,
			['range'] 	   = 850,
			['rangeSqr']   = 722500,
			['speed'] 	   = huge,
			['delay'] 	   = 0.00,
			['Active']	   = {},
		},
		[_E] = {
			['bReady']	   = false,
			['range'] 	   = 1100,
			['rangeSqr']   = 1690000,
			['speed'] 	   = 1150,
			['delay'] 	   = 0.25,
			['width'] 	   = 70,
			['damage']     = function() return 25 + (35 * myHero:GetSpellData(_E).level) + (myHero.ap * 0.5) end,
			['mana']	   = function() return 70 + (myHero:GetSpellData(_E).level * 5) end,			
		},
		[_R] = {
			['bReady']	   = false,
			['range'] 	   = 700,
			['rangeSqr']   = 490000,
			['delay']      = 0.25,
			['radius'] 	   = 560,
			['damage'] 	   = function() return 95 + (myHero:GetSpellData(_R).level * 85) + (myHero.ap * 0.7) end,
			['mana']	   = function() return 80 + (myHero:GetSpellData(_R).level * 20) end,
		},
		['P'] = {
			['range'] 	   = 1450,
			['rangeSqr']   = 2102500,
			['speed']      = 1900,
			['delay']      = 0.5,
			['width'] 	   = 70,
			['damage'] 	   = function() return 80 + (20 * myHero.level) end,
		},
	}
	self.JungleW = {
		['SRU_Red']  = true,
		['SRU_RedMini']  = true,
		['SRU_Dragon']  = true,
		['SRU_Baron']  = true,
		['SRU_Blue']  = true,		
		['SRU_BlueMini']  = true,		
		['SRU_BlueMini2']  = true,		
	}		
	self.Ignite = myHero:GetSpellData(SUMMONER_1).name == 'summonerdot' and SUMMONER_1 or myHero:GetSpellData(SUMMONER_2).name == 'summonerdot' and SUMMONER_2 or nil
	self.ePolygon = CreatePolygon({['x'] = 0, ['z'] = 0,},{['x'] = 0, ['z'] = 0,},{['x'] = 0, ['z'] = 0,},{['x'] = 0, ['z'] = 0,})
	self.wZones = {}
	self.wCount = 0
	self.xOffsets = {
		['AniviaEgg'] = -0.1,
		['Darius'] = -0.05,
		['Renekton'] = -0.05,
		['Sion'] = -0.05,
		['Thresh'] = -0.03,
	}
	_Pewalk.DisableSkillFarm(_Q)
	_Pewalk.DisableSkillFarm(_E)
	
	-----------------------
	--Predictions
	-----------------------	

	self.HP = HPrediction()
	local SQ, SE, SP = self.Spells[_Q], self.Spells[_E], self.Spells.P
	self.HP_Q = HPSkillshot({type = 'PromptCircle', delay = SQ.delay, range = SQ.range, radius = SQ.radius})
	self.HP_E = HPSkillshot({type  = 'DelayLine', delay = SE.delay, range = SE.range, width = SE.width*2, speed = SE.speed, IsLowAccuracy = true}) 
	self.HP_P = HPSkillshot({type  = 'DelayLine', delay = SP.delay, range = SP.range, width = SP.width*2, speed = SP.speed, IsLowAccuracy = true})
	if FHPrediction then
		self.FH_Q = {range = SQ.range, speed = huge, delay = SQ.delay, radius = SQ.radius, type = SkillShotType.SkillshotCircle,}
		self.FH_E = {range = SE.range, speed = SE.speed, delay = SE.delay, radius = SE.width, type = SkillShotType.SkillshotMissileLine,}
		self.FH_P = {range = SP.range, speed = SP.speed, delay = SP.delay, radius = SP.width, type = SkillShotType.SkillshotMissileLine,}		
	end
	if DPExist then
		AddTickCallback(function()
			if not self.DivineInitialized and DivinePred.isAuthed() then
				self.DP = DivinePred()
				self.DP_Q = CircleSS(huge, SQ.range, SQ.radius, SQ.delay, huge)
				self.DP_E = LineSS(SE.speed, SE.range, SE.width, SE.delay, huge)
				self.DP_P = LineSS(SP.speed, SP.range, SP.width, SP.delay, huge)
				self.DP:bindSS('Q',self.DP_Q,50,50)
				self.DP:bindSS('E',self.DP_E,50,50)
				self.DP:bindSS("Zyra's Passive",self.DP_P,50,50)
				self.DivineInitialized = true
			end		
		end)
	end
	self.CrowdControl = { 
		[5] = 'Stun', 
		[8] = 'Taunt', 
		[9] = 'Polymorph', 
		[11] = 'Snare',
		[22] = 'Charm',
		[24] = 'Suppresion', 
		[29] = 'KnockUp', 
	}
	self.DrawPrediction = {['Time'] = 0,}
	self.PredictionDrawing = {}
	for i=1, 7 do self.PredictionDrawing[i] = {x=0, y=0, z=0} end	
	
	-----------------------
	--Callbacks
	-----------------------		

	self.Packets = GetLoseVisionPacketData()	
	if self.Packets then AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)	end
	AddNewPathCallback(function(...) self:NewPath(...) end)
	AddTickCallback(function() self:Tick() end)
	AddCastSpellCallback(function(...) self:CastSpell(...) end)
	AddDrawCallback(function() self:Draw() end)
	AddCreateObjCallback(function(o) self:CreateObj(o) end)
	AddExitCallback(function() self:Save() end)
	AddUnloadCallback(function() self:Save() end)
end

function Zyra:CarryE()
	local target = _Pewalk.GetTarget(self.Spells[_E].range)
	if target then
		local CastPos, HitChance = self:GetPrediction(target, 'E', true)
		if CastPos and HitChance > (self.Menu.E.HitChance / 33.4) then
			self:SetWZone(CastPos, _E, 0.22 + (GetDistance(CastPos) / self.Spells[_E].speed), target)
			CastSpell(_E, CastPos.x, CastPos.z)
		end
	end
end

function Zyra:CarryQ()
	local target = _Pewalk.GetTarget(self.Spells[_Q].range + self.Spells[_Q].radius)
	if target then
		local CastPos, HitChance = self:GetPrediction(target, 'Q', false)
		if CastPos and HitChance > (self.Menu.Q.HitChance / 33.4) then
			self:SetWZone(CastPos, _Q, 0.9, target)
			CastSpell(_Q, CastPos.x, CastPos.z)
		end
	end
end

function Zyra:CastSpell(iSlot,startPos,endPos,target)
	if iSlot == _Q or iSlot == _E then
		for i=#self.wZones, 1, -1 do
			local zone = self.wZones[i]
			if zone and zone.time > clock() and GetDistanceSqr(zone.pos, endPos) < (iSlot == _Q and 40000 or 3600) then
				self.wZones[i].valid = true
			else
				remove(self.wZones, i)
			end
		end
	end
end

function Zyra:Compute(minimum, enemies, validRange, radius, delay, mTeam)
	local Targets = {}
	for i, e in ipairs(enemies) do
		if _Pewalk.ValidTarget(e, validRange) and (mTeam==nil or mTeam==e.team) then
			insert(Targets, e)
		end
	end
	for i, e in ipairs(Targets) do
		local ppos = self:Position(e, 0.3)
		local crcl = {[1] = e, cntr = {x=ppos.x, z=ppos.z}, cntrsm = {x=e.x, z=e.z}, pred = {[1] = ppos},}
		for k, e2 in ipairs(Targets) do
			if e~=e2 and GetDistanceSqr(crcl.cntr, e2) < radius * radius then
				insert(crcl, e2)
				local ppos = self:Position(e2, 0.3)
				insert(crcl.pred, ppos)
				crcl.cntrsm.x = crcl.cntrsm.x + ppos.x
				crcl.cntrsm.z = crcl.cntrsm.z + ppos.z
				crcl.cntr.x = crcl.cntrsm.x / #crcl
				crcl.cntr.z = crcl.cntrsm.z / #crcl
			end
		end
		for k=#crcl, 1, -1 do
			local e2= crcl[k]
			local escpDst = (delay + (GetLatency() * 0.001)) * e2.ms
			if GetDistance(e2, crcl.cntr) > radius-escpDst then
				remove(crcl, k)
				crcl.cntrsm.x = crcl.cntrsm.x - crcl.pred[k].x
				crcl.cntrsm.z = crcl.cntrsm.z - crcl.pred[k].z
				crcl.cntr.x = crcl.cntrsm.x / #crcl
				crcl.cntr.z = crcl.cntrsm.z / #crcl
				remove(crcl.pred, k)
			end
		end
		if #crcl >= minimum and GetDistance(crcl.cntr) < validRange - radius then
			return crcl.cntr, crcl
		end
	end
end

function Zyra:CreateMenu()
	self.Menu = scriptConfig('Pew Zyra', 'Zyra')
	self.Menu.load = function() return end
	self.Menu:addSubMenu('Keys', 'Keys')
		self.Menu.Keys:addSubMenu('-Skills-', 'SkillsInfo')
		self.Menu.Keys:addKey('Jungle', 'Jungle Clear', 17, false)
		self.Menu.Keys:setValue('Jungle', false)
		self.Menu.Keys:addKey('LaneClear', 'Lane Clear', ('G'):byte(), false)
		self.Menu.Keys:setValue('LaneClear', false)
		self.Menu.Keys:addKey('Combo', 'Advanced Kill Secure', ('T'):byte(), true)
	self.Menu:addSubMenu('Advanced Kill Secure', 'Combo')
		self.Menu.Combo:addParam('DrawDC', 'Draw Damage Calcuations', SCRIPT_PARAM_LIST, 1, {'When A.K.S. Active', 'Always', 'Off'})
		self.Menu.Combo:addParam('DrawKN', 'Draw Kill Notifcation', SCRIPT_PARAM_LIST, 1, {'Above HP Bar', 'Below HP Bar', 'Off',})
	self.Menu:addSubMenu('Deadly Bloom (Q)', 'Q')
		self.Menu.Q:addParam('info', '-Farming-', SCRIPT_PARAM_INFO, '')
		self.Menu.Q:addParam('Jungle', 'Use in Jungle Clear', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Q:addParam('Clear', 'Use in Lane Clear', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Q:addParam('Farm', 'Use to Last Hit', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Q:addParam('space', '', SCRIPT_PARAM_INFO, '')
		self.Menu.Q:addParam('info', '-Combat-', SCRIPT_PARAM_INFO, '')
		self.Menu.Q:addParam('HarassLaneClear', 'Harass in Lane Clear', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Q:addParam('HarassMixed', 'Harass in Mixed Mode', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Q:addParam('CombatCarry', 'Use in Carry Mode', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Q:addParam('CombatKS', 'Use to Killsteal', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Q:addParam('HitChance', 'Hit Probability (%)', SCRIPT_PARAM_SLICE, 70, 20, 100)
		self.Menu.Q:addParam('space', '', SCRIPT_PARAM_INFO, '')
		self.Menu.Q:addParam('info', '-Miscellaneous-', SCRIPT_PARAM_INFO, '')
		self.Menu.Q:addParam('Draw', 'Draw Range', SCRIPT_PARAM_LIST, 3, { 'Low FPS', 'Normal', 'None', })
	self.Menu:addSubMenu('Rampant Growth (W)', 'W')
		self.Menu.W:addParam('info', '-Combat-', SCRIPT_PARAM_INFO, '')
		self.Menu.W:addParam('CombatCarry', 'Use in Carry Mode', SCRIPT_PARAM_ONOFF, true)
		self.Menu.W:addParam('Vision', 'Use On Lose Vision (Grass)', SCRIPT_PARAM_ONOFF, true)
		self.Menu.W:addParam('Vision2', 'Lose Vision Min. Seed Count', SCRIPT_PARAM_SLICE, 2, 1, 2)
		self.Menu.W:addParam('LaneClear', 'Use in Lane Clear', SCRIPT_PARAM_ONOFF, true)
		self.Menu.W:addParam('LaneClear2', 'Lane Clear Min. Seed Count', SCRIPT_PARAM_SLICE, 2, 1, 2)
		self.Menu.W:addParam('space', '', SCRIPT_PARAM_INFO, '')
		self.Menu.W:addParam('info', '-Miscellaneous-', SCRIPT_PARAM_INFO, '')
		self.Menu.W:addParam('Draw', 'Draw Range', SCRIPT_PARAM_LIST, 3, { 'Low FPS', 'Normal', 'None', })
	self.Menu:addSubMenu('Grasping Roots (E)', 'E')
		self.Menu.E:addParam('info', '-Farming-', SCRIPT_PARAM_INFO, '')
		self.Menu.E:addParam('Jungle', 'Use in Jungle Clear', SCRIPT_PARAM_ONOFF, true)
		self.Menu.E:addParam('Clear', 'Use in Lane Clear', SCRIPT_PARAM_ONOFF, true)
		self.Menu.E:addParam('Farm', 'Use to Last Hit', SCRIPT_PARAM_ONOFF, false)
		self.Menu.E:addParam('space', '', SCRIPT_PARAM_INFO, '')
		self.Menu.E:addParam('info', '-Combat-', SCRIPT_PARAM_INFO, '')
		self.Menu.E:addParam('HarassLaneClear', 'Harass in Lane Clear', SCRIPT_PARAM_ONOFF, true)
		self.Menu.E:addParam('HarassMixed', 'Harass in Mixed Mode', SCRIPT_PARAM_ONOFF, true)
		self.Menu.E:addParam('CombatCarry', 'Use in Carry Mode', SCRIPT_PARAM_ONOFF, true)
		self.Menu.E:addParam('CombatKS', 'Use to Killsteal', SCRIPT_PARAM_ONOFF, true)
		self.Menu.E:addParam('HitChance', 'Hit Probability (%)', SCRIPT_PARAM_SLICE, 70, 20, 100)
		self.Menu.E:addParam('space', '', SCRIPT_PARAM_INFO, '')
		self.Menu.E:addParam('info', '-Miscellaneous-', SCRIPT_PARAM_INFO, '')
		self.Menu.E:addParam('Draw', 'Draw Range', SCRIPT_PARAM_LIST, 3, { 'Low FPS', 'Normal', 'None', })
		self.Menu.E:addParam('DrawPrediction', 'Draw Prediction', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addSubMenu('Stranglethorns (R)', 'R')
		self.Menu.R:addParam('info', '-Combat-', SCRIPT_PARAM_INFO, '')
		self.Menu.R:addParam('CombatKS', 'Use in Combo', SCRIPT_PARAM_ONOFF, true)
		self.Menu.R:addParam('AutoAlways', 'Auto Use if Can Hit (Anytime)', SCRIPT_PARAM_SLICE, 3, 2, 5)
		self.Menu.R:addParam('AutoCarry', 'Auto Use if Can Hit (Carry Mode)', SCRIPT_PARAM_SLICE, 2, 2, 5)
		self.Menu.R:addParam('space', '', SCRIPT_PARAM_INFO, '')
		self.Menu.R:addParam('3', '-Miscellaneous-', SCRIPT_PARAM_INFO, '')
		self.Menu.R:addParam('Draw', 'Draw Range', SCRIPT_PARAM_LIST, 3, { 'Low FPS', 'Normal', 'None', })

	self.Menu:addParam('Passive', 'Cast Passive', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('Prediction', 'Prediction Selection', SCRIPT_PARAM_LIST, 1, { 'HPrediction', DPExist and 'Divine Prediction' or 'Divine Prediction Not Found!', FHPrediction and 'Fun House Prediction' or 'Fun House Prediction Not Found!', })

	self:Load()
end

function Zyra:CreateObj(o)
	if o.valid then
		if o.type == 'MissileClient' and o.spellOwner then
			if o.spellOwner.charName == 'Yasuo' and o.spellOwner.team == TEAM_ENEMY then
				if o.spellName == 'yasuowmovingwallmisl' then
					self.WindWallLeft = o
				elseif o.spellName == 'yasuowmovingwallmisr' then
					self.WindWallRight = o
				end
			end
		end
	end
end

function Zyra:Draw()
	if myHero.dead then return end
	CircleDraw[self.Menu.Q.Draw](myHero, self.Spells[_Q].range, 0xFF0000)
	CircleDraw[self.Menu.W.Draw](myHero, self.Spells[_W].range, 0x0000FF)
	CircleDraw[self.Menu.E.Draw](myHero, self.Spells[_E].range, 0x00FF00)
	CircleDraw[self.Menu.R.Draw](myHero, self.Spells[_R].range, 0xFF9900)
	if self.Menu.E.DrawPrediction then
		if self.DrawPrediction.Time > clock() and self.DrawPrediction.EndPos then
			local EndPos = NormalizeX(self.DrawPrediction.EndPos, self.DrawPrediction.StartPos, self.Spells[_E].range)
			local EndArrow = NormalizeX(self.DrawPrediction.EndPos, self.DrawPrediction.StartPos, self.Spells[_E].range-50)
			local Perpindicular = Normalize(
				EndArrow.x-(EndArrow.x-(self.DrawPrediction.StartPos.z-EndArrow.z)), 
				EndArrow.z-(EndArrow.z+(self.DrawPrediction.StartPos.x-EndArrow.x))
			)			
			local StartArrow = NormalizeX(self.DrawPrediction.EndPos, self.DrawPrediction.StartPos, 50)
			self.PredictionDrawing[1].x = EndArrow.x + (Perpindicular.x*40)
			self.PredictionDrawing[1].y = myHero.y	
			self.PredictionDrawing[1].z = EndArrow.z + (Perpindicular.z*40)
			self.PredictionDrawing[2].x = self.DrawPrediction.StartPos.x + (Perpindicular.x*40)
			self.PredictionDrawing[2].y = myHero.y	
			self.PredictionDrawing[2].z = self.DrawPrediction.StartPos.z + (Perpindicular.z*40)
			self.PredictionDrawing[3].x = StartArrow.x	
			self.PredictionDrawing[3].y = myHero.y	
			self.PredictionDrawing[3].z = StartArrow.z
			self.PredictionDrawing[4].x = self.DrawPrediction.StartPos.x + (Perpindicular.x*(-40))
			self.PredictionDrawing[4].y = myHero.y	
			self.PredictionDrawing[4].z = self.DrawPrediction.StartPos.z + (Perpindicular.z*(-40))
			self.PredictionDrawing[5].x = EndArrow.x + (Perpindicular.x*(-40))
			self.PredictionDrawing[5].y = myHero.y	
			self.PredictionDrawing[5].z = EndArrow.z + (Perpindicular.z*(-40))
			self.PredictionDrawing[6].x = EndPos.x
			self.PredictionDrawing[6].y = myHero.y	
			self.PredictionDrawing[6].z = EndPos.z	
			self.PredictionDrawing[7] = self.PredictionDrawing[1]
			local EndIndicator = NormalizeX(EndPos, StartArrow, (self.Spells[_E].range-102) * self.DrawPrediction.Ratio)
			local HitChanceIndicator = NormalizeX(EndPos, StartArrow, (self.Spells[_E].range-102) * (self.Menu.E.HitChance * 0.01))
			DrawLine3D(
				HitChanceIndicator.x + (Perpindicular.x*(-30)),
				myHero.y,
				HitChanceIndicator.z + (Perpindicular.z*(-30)),
				HitChanceIndicator.x + (Perpindicular.x*(30)),
				myHero.y,
				HitChanceIndicator.z + (Perpindicular.z*(30)),
				3,
				0x78FFFFFF
			)
			for i=-2, 2, 1 do
				DrawLine3D(
					self.PredictionDrawing[3].x + (Perpindicular.x*(10*i)),
					myHero.y,
					self.PredictionDrawing[3].z + (Perpindicular.z*(10*i)),
					EndIndicator.x + (Perpindicular.x*(10*i)),
					myHero.y,
					EndIndicator.z + (Perpindicular.z*(10*i)),
					2,
					self.DrawPrediction.Color
				)			
			end
			DrawLines3D(self.PredictionDrawing,2,0x78FFFFFF)			
		end
	end
	
	self:GetCombo()
	
	local bar = GetUnitHPBarPos(myHero)
	local x, y = bar.x - 68, bar.y - 16 + ((GetUnitHPBarOffset(myHero).y + 0.4) * 44)
	DrawLine(x,y,x-30,y,23,0x64000000)
	DrawLines2({D3DXVECTOR2(x,y-11),D3DXVECTOR2(x-30,y-11),D3DXVECTOR2(x-30,y+12),D3DXVECTOR2(x,y+12),},2,0xFF474D49)
	local mode = _Pewalk.GetActiveMode()
	local text1 = mode.Farm and 'FARM' or mode.LaneClear and 'CLEAR' or mode.Mixed and 'MIXED' or mode.Carry and 'CARRY' or self.Menu.Keys.Escape and 'ECP.' or '-----'
	DrawText(text1,9,x-14-(GetTextArea(text1, 9).x / 2),y-8,0xFFFFFFFF)
	local text2, color = 'OFF', 0xFFFFFFFF
	if self.Menu.Keys.Combo then
		text2, color = 'ACTIVE', 0xFF00FF00
	end
	DrawText(text2,9,x-14-(GetTextArea(text2, 9).x / 2),y+2,color)		
end

function Zyra:FarmQ()
	if self.Menu.Q.Farm then
		local target = _Pewalk.GetSkillFarmTarget(self.Spells[_Q].delay, self.Spells[_Q].damage, self.Spells[_Q].speed, self.Spells[_Q].range, false)
		if target then
			CastSpell(_Q, target.x, target.z)
		end
	end
end

function Zyra:FarmE()
	if self.Menu.E.Farm then
		local target = _Pewalk.GetSkillFarmTarget(self.Spells[_E].delay, self.Spells[_E].damage(), self.Spells[_E].speed, self.Spells[_E].range, false)
		if target then
			CastSpell(_E, target.x, target.z)
		end
	end
end

function Zyra:GetCombo()
	if self.ActiveCombo and self.Menu.Keys.Combo then
		if self.ActiveCombo.endTime < clock() or not _Pewalk.ValidTarget(self.ActiveCombo.target) then
			self.ActiveCombo = nil
		else
			for i, slot in ipairs(self.ActiveCombo) do
				if myHero:CanUseSpell(slot) == READY then
					if slot == self.Ignite and _Pewalk.ValidTarget(self.ActiveCombo.target) then
						CastSpell(slot, self.ActiveCombo.target)
					else
						if slot == _Q or slot == _E then
							local slotToString = slot == _Q and 'Q' or slot == _E and 'E'
							local CP, HC = self:GetPrediction(self.ActiveCombo.target, slotToString, false, true)
							if CP then
								CastSpell(slot, CP.x, CP.z)
							end
						elseif slot == _R then
							CastSpell(slot, self.ActiveCombo.target.x, self.ActiveCombo.target.z)
						end
					end
				end
			end
		end
	end
	for i, enemy in ipairs(self.Enemies) do
		if _Pewalk.ValidTarget(enemy) then
			local qDamage, wDamage, eDamage, rDamage, iDamage, tDamage = 0, 0, 0, 0, 0, 0
			local magicReduction = 100 / (100 + ((enemy.magicArmor * myHero.magicPenPercent) - myHero.magicPen))
			local RemainingMana = myHero.mana
			local finalCombo = {}
			local distance = GetDistanceSqr(enemy)
			if self.qReady then
				qDamage = self.Spells[_Q].damage() * magicReduction
				if distance < 640000 then
					local CP, HC = self:GetPrediction(enemy, 'Q', false, true)
					if HC > .5 then
						tDamage = qDamage
						finalCombo[1] = {slot=_Q, pos=CP}
						RemainingMana = RemainingMana - self.Spells[_Q].mana()
					end
				end				
			end
			if self.eReady then				
				eDamage = self.Spells[_E].damage() * magicReduction
				if distance < 640000 then
					local CP, HC = self:GetPrediction(enemy, 'E', false, true)
					if HC > .5 and tDamage < enemy.health then
						finalCombo[#finalCombo + 1] = {slot=_E, pos=CP}
						tDamage = tDamage + eDamage
						RemainingMana = RemainingMana - self.Spells[_E].mana()
					end				
				end
			end
			if self.wReady then
				if qDamage~=0 or eDamage~=0 then
					wDamage = (46 + (13 * myHero.level) + (.4 * myHero.ap)) * magicReduction
					if finalCombo[1] and tDamage < enemy.health then
						finalCombo[#finalCombo + 1] = {slot=_W, pos=finalCombo[1].pos}
						tDamage = tDamage + wDamage
					end
				end
			end
			if self.rReady then
				rDamage = self.Spells[_R].damage() * magicReduction
				if distance < 490000 and tDamage < enemy.health then
					finalCombo[#finalCombo + 1] = {slot=_R, pos=CP}
					tDamage = tDamage + rDamage
					RemainingMana = RemainingMana - self.Spells[_R].mana()
				end
			end
			if self.iReady and tDamage < enemy.health then
				iDamage = 50 + (myHero.level * 20)
				if distance < 302500 then
					finalCombo[#finalCombo + 1] = {slot=self.Ignite, target=enemy}
					tDamage = tDamage + iDamage
				end
			end
			if self.Menu.Combo.DrawDC == 2 or (self.Menu.Combo.DrawDC == 1 and self.Menu.Keys.Combo) then
				local Center = GetUnitHPBarPos(enemy)
				if Center.x > -100 and Center.x < WINDOW_W+100 and Center.y > -100 and Center.y < WINDOW_H+100 then
					local Offset = GetUnitHPBarOffset(enemy)
					local y = Center.y + (Offset.y * 53) + 2
					local x = Center.x + ((self.xOffsets[enemy.charName] or 0) * 140) - 66
					local xo = x + ((enemy.health / enemy.maxHealth) * 104)
					if qDamage > 0 and xo > x then
						local ax = (qDamage / enemy.maxHealth) * 104
						local bx = xo - ax
						DrawLine(bx>x and bx or x,y,xo,y,9,0xAAFFAABB)
						DrawText('Q',11,xo+2,y-4,0xFFFFFFFF)
						xo = bx
						if xo < x then return end
					end
					if wDamage > 0 and xo > x then
						local ax = (wDamage / enemy.maxHealth) * 104
						local bx = xo - ax
						DrawLine(bx>x and bx or x,y,xo,y,9,0xAA99AA00)
						DrawText('W',11,xo+2,y-4,0xFFFFFFFF)
						xo = bx
						if xo < x then return end
					end
					if eDamage > 0 and xo > x then
						local ax = (eDamage / enemy.maxHealth) * 104
						local bx = xo - ax					
						DrawLine(bx>x and bx or x,y,xo,y,9,0xAA0099BB)
						DrawText('E',11,xo+2,y-4,0xFFFFFFFF)
						xo = bx
						if xo < x then return end
					end
					if rDamage > 0 and xo > x then
						local ax = (rDamage / enemy.maxHealth) * 104
						local bx = xo - ax
						DrawLine(bx>x and bx or x,y,xo,y,9,0xAA336644)
						DrawText('R',11,xo+2,y-4,0xFFFFFFFF)
						xo = bx			
					end
					if iDamage > 0 and xo > x then
						local ax = (iDamage / enemy.maxHealth) * 104
						local bx = xo - ax
						DrawLine(bx>x and bx or x,y,xo,y,9,0xAA22BB94)
						DrawText('I',11,xo+2,y-4,0xFFFFFFFF)
						xo = bx			
					end
					if self.Menu.Combo.DrawKN < 3 and tDamage > enemy.health then
						DrawText(
							RemainingMana > 0 and 'Can Kill!' or 'Need More Mana!!',
							16,
							x,
							y + (self.Menu.Combo.DrawKN == 1 and -22 or 14),
							0xFFFFFFFF
						)
					end
				end
			end
			if tDamage > enemy.health and (not self.ActiveCombo or self.ActiveCombo.endTime < clock()) then
				self.ActiveCombo = {
					endTime = clock() + 2,
					target = enemy,
				}
				for _, info in ipairs(finalCombo) do
					self.ActiveCombo[#self.ActiveCombo+1] = info.slot
				end
			end
		end
	end
end

function Zyra:GetPrediction(target, spell, draw, hpOnly)		
	local buffTable = _Pewalk.GetBuffs(target)
	if buffTable then
		for i, buff in pairs(buffTable) do
			if self.CrowdControl[buff.type] then
				return target, 3
			end
		end
	end
	if self.Menu.Prediction == 3 and FHPrediction and not hpOnly then
		local CastPos, HitChance = FHPrediction.GetPrediction(self['FH_'..spell], target, myHero)
		if draw and CastPos then
			self.DrawPrediction.EndPos = CastPos
			self.DrawPrediction.StartPos = myHero
			self.DrawPrediction.Time = clock() + 1
			self.DrawPrediction.Ratio = HitChance * 0.5
			self.DrawPrediction.Color = ARGB(185, (1.25-self.DrawPrediction.Ratio) * 255, self.DrawPrediction.Ratio * 200, 0)
		end
		return CastPos, HitChance * 1.5		
	elseif self.Menu.Prediciton == 2 and self.DivineInitialized and not hpOnly then
		local Status, CastPos, Percent = self.DP:predict(spell,target)
		if draw and Percent and CastPos then
			self.DrawPrediction.EndPos = CastPos
			self.DrawPrediction.StartPos = {x=myHero.x, y=myHero.y, z=myHero.z}
			self.DrawPrediction.Time = clock() + 1
			self.DrawPrediction.Ratio = self.Menu.E.HitChance < Percent and 1 or Percent / self.Menu.E.HitChance
			self.DrawPrediction.Color = ARGB(255, (1-self.DrawPrediction.Ratio) * 255, self.DrawPrediction.Ratio * 255, 0)
		end
		if Status == SkillShot.STATUS.SUCCESS_HIT then
			return CastPos, (Percent / 100) * 3
		end
		return CastPos, 0	
	else
		local CastPos, HitChance = self.HP:GetPredict(self['HP_'..spell], target, myHero)
		if draw then
			self.DrawPrediction.EndPos = CastPos
			self.DrawPrediction.StartPos = {x=myHero.x, y=myHero.y, z=myHero.z}
			self.DrawPrediction.Time = clock() + 1
			self.DrawPrediction.Ratio = self.Menu.E.HitChance < HitChance * 33.4 and 1 or  (HitChance * 33.4) / self.Menu.E.HitChance
			self.DrawPrediction.Color = ARGB(255, (1-self.DrawPrediction.Ratio) * 255, self.DrawPrediction.Ratio * 255, 0)
			self.DrawPrediction.Chance = HitChance
		end
		return CastPos, HitChance + 1
	end
end

function Zyra:JungleE()
	local eMinions = {}
	for i, minion in ipairs(_Pewalk.GetMinions()) do
		if _Pewalk.ValidTarget(minion, self.Spells[_E].range + 100, true) and minion.team == 300 then
			eMinions[#eMinions + 1] = minion.hasMovePath and NormalizeX(minion.endPath, minion, 150) or minion
		end
	end
	local nMinions = #eMinions
	if nMinions > 1 then
		local highHit = {['count'] = 0,}
		for i, iMin in ipairs(eMinions) do
			if GetDistanceSqr(iMin) < self.Spells[_E].rangeSqr then
				local ePos = NormalizeX(iMin, myHero, self.Spells[_E].range)
				local d1 = Normalize(myHero.x-(myHero.x-(myHero.z-ePos.z)), myHero.z-(myHero.z+(myHero.x-ePos.x)))
				self.ePolygon.points[1].x, self.ePolygon.points[1].z = myHero.x + d1.x*-128, myHero.z + (d1.z*(-128))
				self.ePolygon.points[2].x, self.ePolygon.points[2].z = myHero.x + d1.x*128, myHero.z + (d1.z*128)
				self.ePolygon.points[3].x, self.ePolygon.points[3].z = ePos.x + d1.x*128, ePos.z + (d1.z*128)
				self.ePolygon.points[4].x, self.ePolygon.points[4].z = ePos.x + d1.x*-128, ePos.z + (d1.z*(-128))
				local count = 1
				for f, eMin in ipairs(eMinions) do
					if i~=f and self.ePolygon:contains(eMin.x, eMin.z) then
						count = count+1				
					end
				end
				if highHit.count < count then
					highHit.count = count
					highHit.minion = iMin
				end	
			end
		end
		if highHit.count >= nMinions - 1 then
			CastSpell(_E, highHit.minion.x, highHit.minion.z)
		end
	elseif nMinions == 1 then
		CastSpell(_E, eMinions[1].x, eMinions[1].z)		
	end
end

function Zyra:JungleQ()
	if  _Pewalk.CanMove() then
		local CP, Hits = self:Compute(1, _Pewalk.GetMinions(), 1060, 260, 0.1, 300)
		if CP then
			for _, unit in ipairs(Hits) do
				if self.JungleW[unit.charName] then
					self:SetWZone(CP, _Q, 0.85, unit)
				end
			end
			CastSpell(_Q, CP.x, CP.z)
			return
		end
	end
end

function Zyra:LaneE()
	local eMinions = {}
	for i, minion in ipairs(_Pewalk.GetMinions()) do
		if _Pewalk.ValidTarget(minion, self.Spells[_E].range + 100, true) and minion.team == TEAM_ENEMY then
			eMinions[#eMinions + 1] = minion.hasMovePath and NormalizeX(minion.endPath, minion, 150) or minion
		end
	end
	local nMinions = #eMinions
	if nMinions > 1 then
		local highHit = {['count'] = 0,}
		for i, iMin in ipairs(eMinions) do
			if GetDistanceSqr(iMin) < self.Spells[_E].rangeSqr then
				local ePos = NormalizeX(iMin, myHero, self.Spells[_E].range)
				local d1 = Normalize(myHero.x-(myHero.x-(myHero.z-ePos.z)), myHero.z-(myHero.z+(myHero.x-ePos.x)))
				self.ePolygon.points[1].x, self.ePolygon.points[1].z = myHero.x + (d1.x*(-128)), myHero.z + (d1.z*(-128))
				self.ePolygon.points[2].x, self.ePolygon.points[2].z = myHero.x + (d1.x*128), myHero.z + (d1.z*128)
				self.ePolygon.points[3].x, self.ePolygon.points[3].z = ePos.x + (d1.x*128), ePos.z + (d1.z*128)
				self.ePolygon.points[4].x, self.ePolygon.points[4].z = ePos.x + (d1.x*(-128)), ePos.z + (d1.z*(-128))
				local count = 1
				for f, eMin in ipairs(eMinions) do
					if i~=f and self.ePolygon:contains(eMin.x, eMin.z) then
						count = count+1				
					end
				end
				if highHit.count < count then
					highHit.count = count
					highHit.minion = iMin
				end	
			end
		end
		if highHit.count >= nMinions * 0.67 or highHit.count > 6 and self:WindWalkCheck(myHero,	highHit.minion) then
			CastSpell(_E, highHit.minion.x, highHit.minion.z)
			if self.Menu.W.LaneClear and self.wCount > self.Menu.W.LaneClear2-1 then
				self:SetWZone(highHit.minion, _E, 0.85, nil, true)
			end			
		end
	end	
end

function Zyra:LaneQ()
	if _Pewalk.CanMove() then
		local CP = self:Compute(3, _Pewalk.GetMinions(), 1060, 260, 0.1, TEAM_ENEMY)
		if CP then
			CastSpell(_Q, CP.x, CP.z)
			if self.Menu.W.LaneClear and self.wCount > self.Menu.W.LaneClear2-1 then
				self:SetWZone(CP, _Q, 0.85, nil, true)
			end
			return
		end
	end
end

function Zyra:Load()
	if SAVE_FILE.Menu then
		for i, entry in ipairs(self.Menu._param) do
			for k, v in pairs(SAVE_FILE.Menu[entry.var]) do
				if k=='key' then entry[k] = v end
			end
			self.Menu[entry.var] = SAVE_FILE.Menu[entry.var].Value
		end
		local function iterateMenu(m)
			for i, subMenu in ipairs(m._subInstances) do
				iterateMenu(subMenu)
				for _, entry in ipairs(subMenu._param) do
					if entry.var:find('Target') == nil and SAVE_FILE.Menu[subMenu.name] and SAVE_FILE.Menu[subMenu.name][entry.var] then
						for k, v in pairs(SAVE_FILE.Menu[subMenu.name][entry.var]) do
							if k=='key' then entry[k] = v end
						end
						subMenu[entry.var] = SAVE_FILE.Menu[subMenu.name][entry.var].Value
					end
				end
			end
		end
		iterateMenu(self.Menu)
	end
end

function Zyra:NewPath(unit,startPos,endPos,isDash,dashSpeed,dashGravity,dashDistance)
	if unit.valid and unit.type == 'AIHeroClient' and unit.team == TEAM_ENEMY then
		if isDash then
			if GetDistanceSqr(endPos, startPos) > 62500 then
				self.Dashing[unit.networkID].time = clock() + (GetDistance(startPos, endPos) / dashSpeed)
				self.Dashing[unit.networkID].endPos = {x=endPos.x, z=endPos.z,}
				self.Dashing[unit.networkID].startPos = {x=startPos.x, z=startPos.z,}
			end
		elseif endPos.x~=self.LastPaths[unit.networkID].pos.x then
			self.LastPaths[unit.networkID].pos = Vector(endPos)
			self.LastPaths[unit.networkID].time = clock()
		end
	end
end

function Zyra:Position(unit, delay)
	local Waypoints = {[1] = { ['x'] = unit.x, ['z'] = unit.z, },}
	local pathPotential = unit.ms * delay
	if unit.hasMovePath then
		for i = unit.pathIndex, unit.pathCount do
			local p = unit:GetPath(i)
			Waypoints[#Waypoints+1] = { ['x'] = p.x, ['z'] = p.z, }
		end
	else
		return Waypoints[1]
	end	
	for i = 1, #Waypoints - 1 do
		local CurrentDistance = GetDistance(Waypoints[i], Waypoints[i + 1])
		if pathPotential < CurrentDistance then
			return NormalizeX(Waypoints[i + 1], Waypoints[i], pathPotential)
		elseif i == (#Waypoints - 1) then
			return Waypoints[i + 1]
		end
		pathPotential = pathPotential - CurrentDistance
	end	
	return Waypoints[1]
end

function Zyra:RecvPacket(p)			
	if p.header == self.Packets.Header then
		p.pos=self.Packets.Pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			local CastPos = self:Position(o, 0.75)
			if IsWallOfGrass(D3DXVECTOR3(CastPos.x,myHero.y,CastPos.z)) then
				self.Spells[_W].Active[#self.Spells[_W].Active+1] = {
					['unit'] = o,
					['startTime'] = clock(),
					['endTime'] = clock() + 0.5,
					['pos'] = CastPos,
				}
			end
		end
	end
end

function Zyra:Save()
	if not SAVE_FILE.Menu then SAVE_FILE.Menu = {} end
	for i, entry in ipairs(self.Menu._param) do
		SAVE_FILE.Menu[entry.var] = entry
		SAVE_FILE.Menu[entry.var].Value = self.Menu[entry.var]
	end
	local function iterateMenu(m)
		for i, subMenu in ipairs(m._subInstances) do
			iterateMenu(subMenu)
			for _, entry in ipairs(subMenu._param) do
				if not SAVE_FILE.Menu[subMenu.name] then SAVE_FILE.Menu[subMenu.name] = {} end
				SAVE_FILE.Menu[subMenu.name][entry.var] = entry
				SAVE_FILE.Menu[subMenu.name][entry.var].Value = subMenu[entry.var]
			end
		end
	end
	iterateMenu(self.Menu)
	local file = io.open(LIB_PATH..'/Saves/PewZyra.save', 'w')
	file:write(JSON:encode(SAVE_FILE))
	file:close()
end

function Zyra:SetWZone(pos, spell, time, target, removeAfterCast)
	self.wZones[#self.wZones + 1] = {
		['pos'] = {['x'] = pos.x, ['y'] = pos.y or myHero.y, ['z'] = pos.z,},
		['spell'] = spell,
		['time'] = clock() + time,
		['valid'] = false,
		['target'] = target,
		['removeAfterCast'] = removeAfterCast,
	}
end

function Zyra:Tick()
	self.qReady = myHero:CanUseSpell(_Q) == READY
	self.wReady = myHero:CanUseSpell(_W) == READY
	self.eReady = myHero:CanUseSpell(_E) == READY
	self.rReady = myHero:CanUseSpell(_R) == READY
	self.iReady = self.Ignite and myHero:CanUseSpell(self.Ignite) == READY
	self.wCount = self.wReady and ReadDWORD(GetPtrS(myHero:GetSpellData(_W))+0x18) or 0
	local MB = _Pewalk.GetBuffs(myHero)
	if MB['zyrapqueenofthorns'] and MB['zyrapqueenofthorns'].endT > GetGameTimer() then
		if self.Menu.Passive then	
			if self.qReady and myHero:GetSpellData(_Q).name == 'zyrapassivedeathmanager'then
				local Target = _Pewalk.GetTarget(self.Spells.P.range)
				if Target then
					local CastPos, HitChance = self:GetPrediction(Target, 'P')
					if CastPos then
						CastSpell(_Q, CastPos.x, CastPos.z)
					end
				end
			end
		end
		return
	end
	if self.wReady then
		if self.Menu.W.Vision and self.wCount > self.Menu.W.Vision2-1 then
			for i=#self.Spells[_W].Active, 1, -1 do
				local active = self.Spells[_W].Active[i]
				if not active.unit.visible and active.endTime > clock() then
					if active.startTime < clock() and GetDistanceSqr(active.pos) < self.Spells[_W].rangeSqr then
						CastSpell(_W, active.pos.x, active.pos.z)
						table.remove(self.Spells[_W].Active, i)
					end
				else
					table.remove(self.Spells[_W].Active, i)
				end			
			end
		end
		for i=#self.wZones, 1, -1 do
			local zone = self.wZones[i]
			if zone and zone.time > clock() then
				if zone.valid and GetDistanceSqr(zone.pos) < self.Spells[_W].rangeSqr then
					-- if zone.spell == _Q and zone.target then
						-- local CP = NormalizeX(zone.target, zone.pos, 225)
						-- CastSpell(_W, CP.x, CP.z)
					-- else
						CastSpell(_W, zone.pos.x, zone.pos.z)
					-- end
					if zone.spell == _E or zone.removeAfterCast then
						remove(self.wZones, i)
					end
				end
			else
				remove(self.wZones, i)
			end
		end
	end
	if Evade or not _Pewalk.CanMove() then return end
	if self.Menu.Keys.LaneClear then
		if self.qReady then
			if self.Menu.Q.Clear then
				self:LaneQ()
				self.LastLaneQ = clock() + 1.1
			end
		elseif self.eReady and self.Menu.E.Clear then
			if not self.LastLaneQ or self.LastLaneQ < clock() then
				self:LaneE()
			end
		end
	end
	if self.Menu.Keys.Jungle then
		if self.qReady and self.Menu.Q.Jungle then
			self:JungleQ()
		end
		if self.eReady and self.Menu.E.Jungle then
			self:JungleE()
		end
	end
	local OM = _Pewalk.GetActiveMode()
	if OM.Carry then
		if self.Menu.Q.CombatCarry and self.qReady then
			self:CarryQ()
		end
		if self.eReady and self.Menu.E.CombatCarry then
			self:CarryE()
		end
	elseif OM.LaneClear then
		if self.qReady then
			self:FarmQ()
			if self.Menu.Q.HarassLaneClear and not _Pewalk.WaitForMinion() and not self.Menu.Keys.LaneClear then
				self:CarryQ()
			end
		end
		if self.eReady then
			self:FarmE()
			if self.Menu.E.HarassLaneClear and not _Pewalk.WaitForMinion() and not self.Menu.Keys.LaneClear then	
				self:CarryE()
			end
		end
	elseif OM.Mixed then
		if self.qReady and self.Menu.Q.HarassMixed and not _Pewalk.WaitForMinion() then
			self:CarryQ()
		end
		if self.eReady and self.Menu.E.HarassMixed then
			self:CarryE()
		end
	elseif OM.Farm then
		if self.qReady then
			self:FarmQ()
		end
		if self.eReady then
			self:FarmE()
		end
	end	
	if self.rReady then
		local CP = self:Compute(OM.Carry and self.Menu.R.AutoCarry or self.Menu.R.AutoAlways, self.Enemies, 1260, 560, 0.3)
		if CP then
			CastSpell(_R, CP.x, CP.z)
		end
	end
end

function Zyra:WindWalkCheck(S, E)
	if self.WindWallLeft and self.WindWallLeft.valid and self.WindWallRight and self.WindWallRight.valid then
		local WL, WR = self.WindWallLeft.pos, self.WindWallRight.pos
		local p = Normalize(WL.x-(WL.x-(WL.z-WR.z)), WL.z-(WL.z+(WL.x-WR.x)))
		local p = CreatePolygon(
			{['x'] = WL.x + p.x*-70, ['z'] = WL.z + p.z*-70},  
			{['x'] = WL.x + p.x*70,  ['z'] = WL.z + p.z*70 }, 
			{['x'] = WR.x + p.x*70,  ['z'] = WR.z + p.z*70 }, 
			{['x'] = WR.x + p.x*-70, ['z'] = WR.z + p.z*-70}
		)		
		local d = Normalize(S.x-(S.x-(S.z-E.z)), S.z-(S.z+(S.x-E.x)))
		local c1 = p:intersects(S.x + d.x*-80, S.z + d.z*-80, E.x + d.x*-80, E.z + d.z*-80)
		local c2 = p:intersects(S.x + d.x*80, S.z + d.z*80, E.x + d.x*80, E.z + d.z*80)
		if c1 or c2 then
			return false
		end
	end
	return true
end

class 'CreatePolygon'

function CreatePolygon:__init(...)
	self.points = {...}
end

function CreatePolygon:contains(px, pz)
	if #self.points == 3 then
		local p1, p2, p3 = self.points[1], self.points[2], self.points[3]
		local VERTEX_A = ((pz - p1.z) * (p2.x - p1.x)) - ((px - p1.x) * (p2.z - p1.z))
		local VERTEX_B = ((pz - p2.z) * (p3.x - p2.x)) - ((px - p2.x) * (p3.z - p2.z))
		local VERTEX_C = ((pz - p3.z) * (p1.x - p3.x)) - ((px - p3.x) * (p1.z - p3.z))
		return (VERTEX_A * VERTEX_B >= 0 and VERTEX_B * VERTEX_C >= 0)
	else
		for j, triangle in ipairs(self:triangulate()) do
			if triangle:contains(px, pz) then
				return true
			end
		end
		return false
	end
end

function CreatePolygon:triangulate()
	if not self.triangles then
		self.triangles = {}
		local nVertices = #self.points
		if nVertices > 3 then			
			if nVertices == 4 then
				insert(self.triangles, CreatePolygon(self.points[1], self.points[2], self.points[3]))
				insert(self.triangles, CreatePolygon(self.points[1], self.points[3], self.points[4]))
			end
		elseif #self.points == 3 then
			insert(self.triangles, self)
		end
	end
	return self.triangles
end

function CreatePolygon:intersects(x1, z1, x2, z2)
	for i=1, #self.points-1 do
		local lx1, lz1, lx2, lz2 = self.points[i].x, self.points[i].z, self.points[i+1].x, self.points[i+1].z
		if ((z2 - lz1) * (x1 - lx1) - (z1 - lz1) * (x2 - lx1) <= 0) ~= ((z2 - lz2) * (x1 - lx2) - (z1 - lz2) * (x2 - lx2) <= 0) then
			if ((z1 - lz1) * (lx2 - lx1) - (lz2 - lz1) * (x1 - lx1) <= 0) ~= ((z2 - lz1) * (lx2 - lx1) - (lz2 - lz1) * (x2 - lx1) <= 0) then
				return true
			end
		end
	end
	local lx1, lz1, lx2, lz2 = self.points[1].x, self.points[1].z, self.points[#self.points].x, self.points[#self.points].z
    if ((z2 - lz1) * (x1 - lx1) - (z1 - lz1) * (x2 - lx1) <= 0) ~= ((z2 - lz2) * (x1 - lx2) - (z1 - lz2) * (x2 - lx2) <= 0) then
		if ((z1 - lz1) * (lx2 - lx1) - (lz2 - lz1) * (x1 - lx1) <= 0) ~= ((z2 - lz1) * (lx2 - lx1) - (lz2 - lz1) * (x2 - lx1) <= 0) then
			return true
		end
	end
	return false
end

function scriptConfig:addKey(var, name, key, defaultToggle)
	local sub = scriptConfig(name, var, self)
	sub:addParam(var, 'Key', defaultToggle and SCRIPT_PARAM_ONKEYTOGGLE or SCRIPT_PARAM_ONKEYDOWN, false, key)
	sub:addParam(var..'Toggle', 'Toggle', SCRIPT_PARAM_ONOFF, defaultToggle)
	AddTickCallback(function()
		self[var] = sub[var]
		self[var..'_param'] = sub._param[1]
		self[var..'_param'].isToggle = sub[var..'Toggle']
		if sub.lastToggle ~= sub[var..'Toggle'] then
			sub.lastToggle = sub[var..'Toggle']
			sub._param[1].pType = sub[var..'Toggle'] and SCRIPT_PARAM_ONKEYTOGGLE or SCRIPT_PARAM_ONKEYDOWN
		end
	end)
	AddMsgCallback(function(m,k)
		if m==256 and self[var..'_param'] and k==self[var..'_param'].key then
			self[var] = true
		end
	end)	
end

local o_OnDraw = scriptConfig.OnDraw
function scriptConfig:OnDraw()
	if #self._subInstances > 0 or #self._param > 0 then
		o_OnDraw(self)
	end
end

function scriptConfig:setValue(var, value)
	for i, instance in ipairs(self._subInstances) do
		if instance.name == var then
			for k, param in ipairs(instance._param) do
				if param.var == var then
					instance[var] = value
				end
			end
		end
	end
end

class "ScriptUpdate"
function ScriptUpdate:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
    self.ScriptPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
    self.SavePath = SavePath
    self.CallbackUpdate = CallbackUpdate
    self.CallbackNoUpdate = CallbackNoUpdate
    self.CallbackNewVersion = CallbackNewVersion
    self.CallbackError = CallbackError
    AddDrawCallback(function() self:OnDraw() end)
    self:CreateSocket(self.VersionPath)
    self.DownloadStatus = 'Connect to Server for VersionInfo'
    AddTickCallback(function() self:GetOnlineVersion() end)
end

function ScriptUpdate:print(str)
    print('<font color="#FFFFFF">'..os.clock()..': '..str)
end

function ScriptUpdate:OnDraw()
    if self.DownloadStatus ~= 'Downloading Script (100%)' and self.DownloadStatus ~= 'Downloading VersionInfo (100%)'then
        DrawText('Download Status: '..(self.DownloadStatus or 'Unknown'),50,10,50,ARGB(0xFF,0xFF,0xFF,0xFF))
    end
end

function ScriptUpdate:CreateSocket(url)
    if not self.LuaSocket then
        self.LuaSocket = require("socket")
    else
        self.Socket:close()
        self.Socket = nil
        self.Size = nil
        self.RecvStarted = false
    end
    self.LuaSocket = require("socket")
    self.Socket = self.LuaSocket.tcp()
    self.Socket:settimeout(0, 'b')
    self.Socket:settimeout(99999999, 't')
    self.Socket:connect('sx-bol.eu', 80)
    self.Url = url
    self.Started = false
    self.LastPrint = ""
    self.File = ""
end

function ScriptUpdate:Base64Encode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function ScriptUpdate:GetOnlineVersion()
    if self.GotScriptVersion then return end

    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        self.DownloadStatus = 'Downloading VersionInfo (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</s'..'ize>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<scr'..'ipt>') then
            local _,ScriptFind = self.File:find('<scr'..'ipt>')
            local ScriptEnd = self.File:find('</scr'..'ipt>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading VersionInfo ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</scr'..'ipt>') then
        self.DownloadStatus = 'Downloading VersionInfo (100%)'
        local a,b = self.File:find('\r\n\r\n')
        self.File = self.File:sub(a,-1)
        self.NewFile = ''
        for line,content in ipairs(self.File:split('\n')) do
            if content:len() > 5 then
                self.NewFile = self.NewFile .. content
            end
        end
        local HeaderEnd, ContentStart = self.File:find('<scr'..'ipt>')
        local ContentEnd, _ = self.File:find('</sc'..'ript>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            self.OnlineVersion = (Base64Decode(self.File:sub(ContentStart + 1,ContentEnd-1)))
            self.OnlineVersion = tonumber(self.OnlineVersion)
            if self.OnlineVersion > self.LocalVersion then
                if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
                    self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
                end
                self:CreateSocket(self.ScriptPath)
                self.DownloadStatus = 'Connect to Server for ScriptDownload'
                AddTickCallback(function() self:DownloadUpdate() end)
            else
                if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
                    self.CallbackNoUpdate(self.LocalVersion)
                end
            end
        end
        self.GotScriptVersion = true
    end
end

function ScriptUpdate:DownloadUpdate()
    if self.GotScriptUpdate then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        self.DownloadStatus = 'Downloading Script (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</si'..'ze>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<scr'..'ipt>') then
            local _,ScriptFind = self.File:find('<scr'..'ipt>')
            local ScriptEnd = self.File:find('</scr'..'ipt>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading Script ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</scr'..'ipt>') then
        self.DownloadStatus = 'Downloading Script (100%)'
        local a,b = self.File:find('\r\n\r\n')
        self.File = self.File:sub(a,-1)
        self.NewFile = ''
        for line,content in ipairs(self.File:split('\n')) do
            if content:len() > 5 then
                self.NewFile = self.NewFile .. content
            end
        end
        local HeaderEnd, ContentStart = self.NewFile:find('<sc'..'ript>')
        local ContentEnd, _ = self.NewFile:find('</scr'..'ipt>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            local newf = self.NewFile:sub(ContentStart+1,ContentEnd-1)
            local newf = newf:gsub('\r','')
            if newf:len() ~= self.Size then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
                return
            end
            local newf = Base64Decode(newf)
            if type(load(newf)) ~= 'function' then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
            else
                local f = io.open(self.SavePath,"w+b")
                f:write(newf)
                f:close()
                if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
                    self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
                end
            end
        end
        self.GotScriptUpdate = true
    end
end
