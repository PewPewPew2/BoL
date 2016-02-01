if myHero.charName ~= 'Caitlyn' then return end

--~~~~~~ General Localizations
local pi, pi2, sin, cos, huge, sqrt, ceil = math.pi, 2*math.pi, math.sin, math.cos, math.huge, math.sqrt, math.floor
local clock = os.clock
local pairs, ipairs = pairs, ipairs
local insert, remove = table.insert, table.remove
local TEAM_ALLY, TEAM_ENEMY

local function Normalize(x,z)
    local length  = sqrt(x * x + z * z)
	return { ['x'] = x / length, ['z'] = z / length, }
end

local function NormalizeX(v1, v2, length)
	x, z = v1.x - v2.x, v1.z - v2.z
    local nLength  = sqrt(x * x + z * z)
	return { ['x'] = v2.x + ((x / nLength) * length), ['z'] = v2.z + ((z / nLength) * length)} 
end

local function Print(text, isError)
	if isError then
		print('<font color=\'#0099FF\'>[PewCaitlyn] </font> <font color=\'#FF0000\'>'..text..'</font>')
		return
	end
	print('<font color=\'#0099FF\'>[PewCaitlyn] </font> <font color=\'#FF6600\'>'..text..'</font>')
end

--~~~~~~End Localizations

AddLoadCallback(function()
	if not FileExist(LIB_PATH..'/HPrediction.lua') then
		ScriptUpdate(
			0,
			true,
			'raw.githubusercontent.com', 
			'/BolHTTF/BoL/master/HTTF/Version/HPrediction.version', 
			'/BolHTTF/BoL/master/HTTF/Common/HPrediction.lua',
			LIB_PATH..'/HPrediction.lua',
			function() Print('HPrediction Download Complete. Please reload.') end, 
			function() return end, 
			function() Print('HPrediction cannot be found, downloading now...') end,
			function() Print('There was an error downloading HPrediction.') end
		)
		return
	end	
	if not FileExist(LIB_PATH..'/PewPacketLib.lua') then
		ScriptUpdate(
			0,
			true,
			'raw.githubusercontent.com', 
			'/PewPewPew2/BoL/master/Versions/PewPacketLib.version', 
			'/PewPewPew2/BoL/master/PewPacketLib.lua',
			LIB_PATH..'/PewPacketLib.lua',
			function() Print('PewPacketLib Download Complete. Please reload.') end, 
			function() return end, 
			function() Print('PewPacketLib cannot be found, downloading now...') end,
			function() Print('There was an error downloading PewPacketLib.') end
		)
		return
	end
	require 'PewPacketLib'
	require 'HPrediction'
	local isLoaded, loadTime = false, clock()
	AddTickCallback(function() 
		if _Pewalk and not isLoaded then
			TEAM_ALLY, TEAM_ENEMY = myHero.team, 300 - myHero.team
			Caitlyn()
			isLoaded = true
		elseif loadTime + 5 < clock() and not isLoaded then
			Print('Standalone Pewalk is now required, check forum!!', true)
			isLoaded = true
		end
	end)
end)

class 'Caitlyn'
 
function Caitlyn:__init()
	local version = 2.8
	ScriptUpdate(
		version,
		true,
		'raw.githubusercontent.com', 
		'/PewPewPew2/BoL/master/Versions/PewCaitlyn.version', 
		'/PewPewPew2/BoL/master/PewCaitlyn.lua',
		SCRIPT_PATH.._ENV.FILE_NAME, 
		function() Print('Update Complete, please reload.') end, 
		function() Print('Latest version loaded v'..('%.1f'):format(version)..'.') end, 
		function() Print('Update availabe, please wait..') end,
		function() Print('There was an error during update.') end
	)

	self.OnSpells = {
		['Crowstorm'] = function(endPos)
				if self.Menu.W.Crowstorm then
					self.W.Active[#self.W.Active + 1] = {
						['pos']     = { ['x'] = endPos.x, ['z'] = endPos.z, },
						['endTime'] = clock() + 1.5,
					}
				end
			end,
		['PantheonRJump'] = function(endPos)
				if self.Menu.W.Skyfall then
					self.W.Active[#self.W.Active + 1] = {
						['pos']     = { ['x'] = endPos.x, ['z'] = endPos.z, },
						['endTime'] = clock() + 2.5,
					}
				end
			end,
		['gate'] = function(endPos)
				if self.Menu.W.Gate then
					self.W.Active[#self.W.Active + 1] = {
						['pos']     = { ['x'] = endPos.x, ['z'] = endPos.z, },
						['endTime'] = clock() + 1.5,
					}
				end
			end,
		}
	self.OnBuff = {
		['Channels'] = {
			['aatroxpassivedeath'] = true,
			['rebirth'] = true,
			['bardrstasis'] = true,
			['lissandrarself'] = true,
			['pantheonesound'] = true,
			['PantheonRJump'] = true,
			['summonerteleport'] = true,
			['zhonyasringshield'] = true,
			['galioidolofdurand'] = true,
			['missfortunebulletsound'] = true,
			['alzaharnethergraspsound'] = true,
			['infiniteduresssound'] = true,
			['VelkozR'] = true,
			['ReapTheWhirlwind'] = true,
			['katarinarsound'] = true,
			['fearmonger_marker'] = true,
			['AbsoluteZero'] = true,
			['Meditate'] = true,
			['ShenStandUnited'] = true,
		},
		['Shields'] = {
			['vipassivebuff'] = true,
			['summonerbarrier'] = true,
			['ironstylusbuff'] = true,
			['itemseraphsembrace'] = true,
			['srturretsecondaryshielde'] = true,
			['azireshield'] = true,
			['evelynnrshield'] = true,
			['jarvanivgoldenaegis'] = true,
			['eyeofthestorm'] = true,
			['lulufaerieshield'] = true,
			['karmasolkimshield'] = true,
			['luxprismaticwaveshield'] = true,
			['udyrturtleactivation'] = true,
			['shenfeint'] = true,
			['skarnerexoskeleton'] = true,
			['orianaghost'] = true,
			['rumbleshieldbuff'] = true,
			['threshwshield'] = true,
			['dianashield'] = true,
			['viktorpowertransfer'] = true,
			['rivenfeint'] = true,
			['sonawshield'] = true,
			['sionwshieldstacks'] = true,
			['urgotterrorcapacitoractive2'] = true,
			['nautiluspiercinggazeshield'] = true,
			['blindmonkwoneshield'] = true,
			['shenstandunitedshield'] = true,
			['yasuopassivemsshieldon'] = true,
		},
		['DamageMods'] = {
			['ferocioushowl'] = function(source) return 0.3 end,
			['garenw'] = function(source) return 0.7 end,
			['katarinaereduction'] = function(source) return 0.85 end,
			['maokaidrain3defense'] = function(source) return 0.8 end,
			['galioidolofdurand'] = function(source) return 0.5 end,
			['vladimirhemoplaguedebuff'] = function(source) return 1.12 end,
			['gragaswself'] = function(source) return 0.92 - (source:GetSpellData(1).level * 0.02) end,
			['meditate'] = function(source) return 0.55 - (source:GetSpellData(1).level * 0.05) end,
			['braumshieldbuff'] = function(source) return 0.725 - (source:GetSpellData(2).level * 0.025) end,
		},
		['CrowdControl'] = { [5] = 'Stun', [11] = 'Snare', [24] = 'Suppresion', [29] = 'KnockUp', },		
	}
	self.OnObject = {
		['Cupcake Trap'] = function(o)
			if o.team == myHero.team then
				self.W.Timers[#self.W.Timers + 1] = {
					['obj'] = o,
					['endTime'] = clock() + 90,
				}
			end
		end,
		['LifeAura.troy'] = function(o)
			if self.Menu.W.Revive then
				for i, hero in ipairs(Enemies) do
					if GetDistanceSqr(hero, o) == 0 then
						self.W.Active[#self.W.Active + 1] = {
							['pos']     = { ['x'] = hero.x, ['z'] = hero.z, },
							['endTime'] = clock() + 4,
						}
						return
					end
				end
			end
		end,
		['GateMarker_red.troy'] = function(o)
			if self.Menu.W.bGate then
				self.W.Active[#self.W.Active + 1] = {
					['pos']     = { ['x'] = o.x, ['z'] = o.z, },
					['endTime'] = clock() + 1.5,
				}
				return
			end
		end,
		['global_ss_teleport_target_red.troy'] = function(o)
			if self.Menu.W.Teleport then
				self.W.Active[#self.W.Active + 1] = {
					['pos']     = { ['x'] = o.x, ['z'] = o.z, },
					['endTime'] = clock() + 1.5,
				}
				return
			end
		end,
	}	
	self.W = {
		['Timers'] = {},
		['Active'] = {},
	}
	self.Enemies = {}
	self.LastCtrl = 0
	self.DT = 0
	for i=1, objManager.maxObjects do
		local o = objManager:getObject(i)
		if o and o.type == 'obj_SpawnPoint' and o.team == myHero.team then
			self.SpawnPos = o
			break
		end
	end	
	for i=1, heroManager.iCount do
		local h = heroManager:getHero(i)
		if h.team ~= TEAM_ALLY then
			self.Enemies[#self.Enemies + 1] = h
		end
	end	
	
	self:CreateMenu()
	
	self.Packets = GetLoseVisionPacketData()
	self.HPrediction = HPrediction()
	self.Spell_Q = HPSkillshot({type = 'DelayLine', delay = 0.625, range = 1300, width = 180, speed = 2200})
	
	AddTickCallback(function() self:Tick() end)
	AddCreateObjCallback(function(o) self:CreateObj(o) end)
	AddDrawCallback(function() self:Draw() end)
	AddApplyBuffCallback(function(...) self:ApplyBuff(...) end)
	AddProcessSpellCallback(function(...) self:ProcessSpell(...) end)
	AddCastSpellCallback(function(...) self:CastSpell(...) end)
	if self.Packets then AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)	end
end

function Caitlyn:ApplyBuff(source, unit, buff)
	if unit and unit.valid and unit.type == 'AIHeroClient' and unit.team == TEAM_ENEMY then
		if self.OnBuff.CrowdControl[buff.type] and self.Menu.W.CrowdControl then
			self.W.Active[#self.W.Active + 1] = {
				['pos']     = { ['x'] = unit.x, ['z'] = unit.z, },
				['endTime'] = buff.endTime + (clock() - GetGameTimer()),
			}
		end
		if self.OnBuff.Channels[buff.name] and self.Menu.W.Channel then
			self.W.Active[#self.W.Active + 1] = {
				['pos']     = { ['x'] = unit.x, ['z'] = unit.z, },
				['endTime'] = buff.endTime + (clock() - GetGameTimer()),
			}		
		end
	end
end

function Caitlyn:CastSpell(iSlot,startPos,endPos,target)
	if iSlot == _E and self.Menu.E.Mouse and GetDistanceSqr(mousePos, endPos) < 10000 then
		BlockSpell()
	end
end

function Caitlyn:CheckDamage()
	local qData = myHero:GetSpellData(_Q)
	local critChance, totalDamage, qCd, critDamage = myHero.critChance, myHero.totalDamage, qData.cd, 2 --HaveItem(3031) and 2.5 or 2
	local aaAttackCount, qAttackCount = (myHero.attackSpeed * 0.625) * (qCd + 1), ((myHero.attackSpeed * 0.625)) * qCd
	local function aaDamage(speed)
		local passiveChance = speed / ceil(7.13 - (myHero.level/6))
		local damageSum = ((speed - passiveChance) * totalDamage) + (passiveChance * (totalDamage * 1.5))
		return ((1 - critChance) * damageSum) + (critChance * (damageSum * critDamage))
	end
	return aaDamage(aaAttackCount) < aaDamage(qAttackCount) + ((qData.level * 40) - 20) + (1.3 * totalDamage)
end

function Caitlyn:CreateMenu()
	self.Menu = scriptConfig('PewCaitlyn', 'Caitlyn')
	self.Menu:addSubMenu('Piltover Peacemaker', 'Q')
		self.Menu.Q:addParam('Carry', 'Use in Carry Mode', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Q:addParam('Mixed', 'Harass in Mixed Mode', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Q:addParam('Clear', 'Harass in Clear Mode', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Q:addParam('Method', 'Peacemaker Control Method', SCRIPT_PARAM_LIST, 1, { 'Calculated', 'Toggle', })
		self.Menu.Q:addParam('Toggle', 'Manual Control Key', SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte('G'))
		local MenuCheck = 0
		AddTickCallback(function()
			if self.Menu.Q.Method ~= MenuCheck then
				for k, v in ipairs(self.Menu.Q._param) do
					if v.var == 'Toggle' then
						if self.Menu.Q.Method == 1 then
							v.pType, v.text, self.Menu.Q.Toggle = 5, 'Internally Calculating Q Usage', ''
						else
							v.pType, v.text, self.Menu.Q.Toggle = 3, 'Manual Control Key', true
						end
					end
				end
				MenuCheck = self.Menu.Q.Method
			end
		end)
		self.Menu.Q:addParam('HitChance', 'Cast HitChance [3==Highest]', SCRIPT_PARAM_SLICE, 1.25, 0.5, 3, 1)
		self.Menu.Q:addParam('Collision', 'Check for minion Collision', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Q:addParam('LastHit', 'Use for Last Hits', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Q:addParam('Mana', 'Always Save Mana for E', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Q:addParam('Draw', 'Draw Peacemaker Range', SCRIPT_PARAM_LIST, 1, { 'Low FPS', 'Normal', 'None', })
	self.Menu:addSubMenu('Yordle Snap Trap', 'W')
		self.Menu.W:addParam('Path', 'Cast on Target Path', SCRIPT_PARAM_ONOFF, true)
		self.Menu.W:addParam('Channel', 'Trap Channel Spells', SCRIPT_PARAM_ONOFF, true)
		self.Menu.W:addParam('CrowdControl', 'Trap Crowd Control', SCRIPT_PARAM_ONOFF, true)
		self.Menu.W:addParam('Revive', 'Trap Revives (GA / Chronoshift)', SCRIPT_PARAM_ONOFF, true)
		self.Menu.W:addParam('Teleport', 'Trap Teleports', SCRIPT_PARAM_ONOFF, true)
		self.Menu.W:addParam('Vision', 'Trap on Lose Vision (Grass)', SCRIPT_PARAM_ONOFF, true)
		for i=1, heroManager.iCount do
			local h = heroManager:getHero(i)
			if h and h.team == TEAM_ENEMY then
				if h.charName == 'FiddleSticks' then
					self.Menu.W:addParam('Crowstorm', 'Trap Crowstorm', SCRIPT_PARAM_ONOFF, true)
				elseif h.charName == 'Pantheon' then
					self.Menu.W:addParam('Skyfall', 'Trap Grand Skyfall', SCRIPT_PARAM_ONOFF, true)
				elseif h.charName == 'TwistedFate' then
					self.Menu.W:addParam('Gate', 'Trap Destiny', SCRIPT_PARAM_ONOFF, true)
				end
			end
		end
		self.Menu.W:addParam('Mana', 'Always Save Mana for E', SCRIPT_PARAM_ONOFF, true)
		self.Menu.W:addParam('Draw', 'Draw Active Trap Timers', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addSubMenu('90 Caliber Net', 'E')
		self.Menu.E:addParam('Mouse', 'Net To Mouse', SCRIPT_PARAM_ONKEYDOWN, false, ('E'):byte())
		self.Menu.E:addParam('Block', 'Block Failed Wall Jumps', SCRIPT_PARAM_ONOFF, true)
		self.Menu.E:addParam('MinimumBlock', 'Do Not Block if Will Jump This Far', SCRIPT_PARAM_SLICE, 350, 20, 490)
		self.Menu.E:addParam('LastHit', 'Use for Last Hits', SCRIPT_PARAM_ONOFF, false)
	self.Menu:addSubMenu('Ace in the Hole', 'R')
		self.Menu.R:addParam('CrossHair', 'Draw Can Kill Alert', SCRIPT_PARAM_ONOFF, true)
		self.Menu.R:addParam('Line', 'Draw Line to Killable Character', SCRIPT_PARAM_ONOFF, true)
		self.Menu.R:addParam('Indicator', 'Draw Health Remaining Indicator', SCRIPT_PARAM_ONOFF, true)
		self.Menu.R:addParam('Key', 'Kill Key', SCRIPT_PARAM_ONKEYDOWN, false, ('R'):byte())
		self.Menu.R:addParam('Auto', 'Use Automatically', SCRIPT_PARAM_ONOFF, false)
	self.Menu:addParam('Combo', 'E - Q Combo', SCRIPT_PARAM_ONKEYDOWN, false, ('T'):byte())
end

function Caitlyn:CreateObj(o)
	if o.valid then
		if self.OnObject[o.name] then
			self.OnObject[o.name](o)
		elseif o.name:find('Pantheon') and o.name:find('indicator_red.troy') and self.Menu.W.bSkyfall then
			self.W.Active[#self.W.Active + 1] = {
				['pos']     = { ['x'] = o.x, ['z'] = o.z, },
				['endTime'] = clock() + 1.5,
			}
		end
	end
end

function Caitlyn:Draw()
	if self.Menu.Q.Draw == 1 then
		local points = {}
		for theta = 0, (pi2+(pi/24)), (pi/24) do
			local tS = WorldToScreen(D3DXVECTOR3(myHero.x+(1300*cos(theta)), myHero.y, myHero.z-(1300*sin(theta))))
			points[#points + 1] = D3DXVECTOR2(tS.x, tS.y)
		end
		if OnScreen({x = points[1].x, y = points[1].y}, {x = points[16].x, y = points[16].y}) then
			DrawLines2(points, 1, 0xAA646464)
		end	
	elseif self.Menu.Q.Draw == 2 then
		DrawCircle(myHero.x, myHero.y or 0, myHero.z, 1370, 0x646464)
	end
	if self.Menu.W.Draw then
		for i, timer in ipairs(self.W.Timers) do
			if timer.obj and timer.obj.valid and not timer.obj.dead then
				local t = timer.endTime - clock()
				DrawText3D(('%d:%.2d'):format(t / 60, t % 60), timer.obj.x, timer.obj.y + 200, timer.obj.z, 22, 0xFFFF9900, true)
			else
				table.remove(self.W.Timers, i)
				return
			end
		end
	end
	if self.KillDraw then
		if self.Menu.R.CrossHair then
			local tsp = 30 + (225 * (0.5 * sin(self.DT) + 0.5))		
			local x1, y1 = WINDOW_W / 2, WINDOW_H / 2.25
			local color = ARGB(tsp, 255, 125, 0)
			DrawLine(x1+50, y1, x1+200, y1, 10, color)
			DrawLine(x1-50, y1, x1-200, y1, 10, color)
			DrawLine(x1, y1+40, x1, y1+160, 10, color)
			DrawLine(x1, y1-40, x1, y1-160, 10, color)
			DrawLine(x1+5, y1, x1-5, y1, 6, ARGB(tsp, 0, 0, 0))
			self.DT = self.DT+0.03	
		end
		if self.Menu.R.CrossHair then
			DrawLine3D(myHero.x, myHero.y+75, myHero.z, self.KillDraw.x, self.KillDraw.y+75, self.KillDraw.z, 4, 0xFFFF9900)
			DrawLine3D(myHero.x, myHero.y+100, myHero.z, self.KillDraw.x, self.KillDraw.y+100, self.KillDraw.z, 1, 0xFFFF9900)			
		end
	end
	if self.Menu.R.Indicator and self.rReady then
		local range = self:GetUltRange()
		for i, enemy in ipairs(self.Enemies) do
			if _Pewalk.ValidTarget(enemy) then
				local Center = GetUnitHPBarPos(enemy)
				if Center.x > -100 and Center.x < WINDOW_W+100 and Center.y > -100 and Center.y < WINDOW_H+100 then
					local off = GetUnitHPBarOffset(enemy)
					local y=Center.y + (off.y * 53) + 2
					local xOff = ({['AniviaEgg'] = -0.1,['Darius'] = -0.05,['Renekton'] = -0.05,['Sion'] = -0.05,['Thresh'] = -0.03,})[enemy.charName]
					local x = Center.x + ((xOff or 0) * 140) - 66
					local rmn = enemy.health - self:RDamage(enemy)
					DrawLine(x + ((enemy.health / enemy.maxHealth) * 104),y, x+(((rmn > 0 and rmn or 0) / enemy.maxHealth) * 104),y,9, GetDistance(enemy) < range and 0x78FF7D00 or 0x78FFFFFF)
				end
			end
		end
	end
end

function Caitlyn:GetCollision(unit, CastPos)
	if self.Menu.Q.Collision then
		local Collision = self:MinionCollision(myHero, CastPos, 90, unit, 0.625, 2200)
		return Collision==false
	end
	return true
end

function Caitlyn:GetPrediction(unit, hitchance)
	local CastPos, HitChance = self.HPrediction:GetPredict(self.Spell_Q, unit, myHero)
	return CastPos and HitChance >= hitchance * 0.5 and self:GetCollision(unit, CastPos), CastPos
end

function Caitlyn:GetUltRange()
	return (500 * myHero:GetSpellData(_R).level) + 1500
end

function Caitlyn:MinionCollision(sPos, ePos, width, unit, delay, speed)
	width = width + 65
	local range = GetDistanceSqr(sPos, ePos)
	local collision = {}
	local d1 = Normalize(sPos.x-(sPos.x-(sPos.z-ePos.z)), sPos.z-(sPos.z+(sPos.x-ePos.x)))
	local poly = CreatePolygon(
		{['x'] = sPos.x + (d1.x*(-width)), ['z'] = sPos.z + (d1.z*(-width))},  
		{['x'] = sPos.x + (d1.x*width), ['z'] = sPos.z + (d1.z*width)}, 
		{['x'] = ePos.x + (d1.x*width), ['z'] = ePos.z + (d1.z*width)}, 
		{['x'] = ePos.x + (d1.x*(-width)), ['z'] = ePos.z + (d1.z*(-width))})
	for _, minion in ipairs(_Pewalk.GetMinions()) do
		if minion and minion ~= unit and GetDistanceSqr(minion, sPos) < (range*1.15) then
			if poly:contains(minion.x, minion.z) then
				collision[#collision + 1] = minion
			end
			if minion.hasMovePath then
				local pPos = self:MinionPrediction(minion, delay + 1, width, speed, sPos)
				if pPos then
					local real = NormalizeX(pPos, minion, 400)
					local d2 = Normalize(real.x-(real.x-(minion.z-real.z)), real.z-(real.z+(minion.x-real.x)))
					local bR = minion.boundingRadius
					if poly:intersects(minion.x + (d2.x*(-bR)), minion.z + (d2.z*(-bR)), real.x + (d2.x*(-bR)), real.z + (d2.z*(-bR))) 
					or poly:intersects(minion.x + (d2.x*bR), minion.z + (d2.z*bR), real.x + (d2.x*bR), real.z + (d2.z*bR)) then
						collision[#collision + 1] = minion
					end
				end
			end
		end
	end
	return #collision > 0, #collision, collision
end

function Caitlyn:MinionPrediction(unit, delay, width, speed, from)
	local Waypoints = {{ ['x'] = unit.x, ['z'] = unit.z, }}
	local pathPotential = unit.ms * ((GetDistance(from, unit) / speed) + delay)
	if unit.hasMovePath then
		for i = unit.pathIndex, unit.pathCount do
			local p = unit:GetPath(i)
			Waypoints[#Waypoints+1] = { ['x'] = p.x, ['z'] = p.z, }
		end
	else
		return Waypoints[1], Waypoints, 2
	end	
	for i = 1, #Waypoints - 1 do
		local CurrentDistance = GetDistance(Waypoints[i], Waypoints[i + 1])
		if pathPotential < CurrentDistance then
			return NormalizeX(Waypoints[i + 1], Waypoints[i], pathPotential), Waypoints, 2
		elseif i == (#Waypoints - 1) then
			return Waypoints[i + 1], Waypoints, 1
		end
		pathPotential = pathPotential - CurrentDistance
	end
end

function Caitlyn:ProcessSpell(u, s)
	if u.valid and u.type == 'AIHeroClient' and u.team == TEAM_ENEMY and self.OnSpells[s.name] then
		self.OnSpells[s.name](s.endPos)
	end
end

function Caitlyn:RDamage(unit)
	local baseDmg = (((225 * myHero:GetSpellData(_R).level) + (myHero.addDamage * 2)) * (100 / (100 + ((unit.armor * myHero.armorPenPercent) - myHero.armorPen)))) - (unit.hpRegen * (1 + (GetDistance(unit) / 3000)))
	for _, buff in ipairs(_Pewalk.GetBuffs(unit)) do
		if self.OnBuff.DamageMods[buff.name] and buff.endT > GetGameTimer() + 1 then
			baseDmg = baseDmg * self.OnBuff.DamageMods[buff.name]
		end
	end
	return baseDmg --/ baseHP
end

function Caitlyn:RecvPacket(p)
	if p.header == self.Packets.Header and self.Menu.W.Vision then
		p.pos=self.Packets.Pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			if o.endPath and not o.dead and o.health / o.maxHealth < 0.4 and IsWallOfGrass(D3DXVECTOR3(o.endPath.x,o.endPath.y,o.endPath.z)) then
				self.W.Active[#self.W.Active + 1] = {
					['pos']     = { ['x'] = o.endPath.x, ['z'] = o.endPath.z, },
					['endTime'] = clock() + 1,
				}
			end
		end	
	end
end

function Caitlyn:Tick()
	self.KillDraw = nil
	self.qReady = myHero:CanUseSpell(_Q) == READY
	self.wReady = myHero:CanUseSpell(_W) == READY
	self.eReady = myHero:CanUseSpell(_E) == READY
	self.rReady = myHero:CanUseSpell(_R) == READY
	local OM = _Pewalk.GetActiveMode()
	
	if self.qCombo and self.qCombo.Time < clock() then
		local CastPos, HitChance = self.HPrediction:GetPredict(self.Spell_Q, self.qCombo.target, Vector(self.qCombo.x, myHero.y, self.qCombo.z))	
		if CastPos then	
			CastSpell(_Q, CastPos.x, CastPos.z)
			self.qCombo = nil
		end
	end
	
	if Evade then return end
	if self.qReady and self.eReady and self.Menu.Combo and not self.qCombo then
		if 115 + (10 * myHero:GetSpellData(_Q).level) < myHero.mana then
			local target = _Pewalk.GetTarget(1000)
			if target then
				local bCast, CastPos = self:GetPrediction(target, 0.25)
				if CastPos then
					self.qCombo = {['Time'] = clock() + 0.22, ['x'] = myHero.x, ['z'] = myHero.z, ['target'] = target,}
					CastSpell(_E, CastPos.x, CastPos.z)
				end
			end
		end
	end
	if self.qReady then
		if _Pewalk.CanMove() then
			if not self.Menu.Q.Mana or (myHero.mana - ((myHero:GetSpellData(_Q).level * 10) + 40)) > 75 then	
				local c1 = OM.Carry and self.Menu.Q.Carry
				local c2 = OM.Mixed and self.Menu.Q.Mixed and not _Pewalk.WaitForMinion()
				local c3 = OM.Clear and self.Menu.Q.Clear and not _Pewalk.WaitForMinion()
				if c1 or c2 or c3 then
					local c4 = self.Menu.Q.Method == 1 and self:CheckDamage()
					local c5 = self.Menu.Q.Method == 2 and self.Menu.Q.Toggle
					if c4 or c5 then
						local target = _Pewalk.GetTarget(1300)
						if target then
							local bCast, castPos = self:GetPrediction(target, self.Menu.Q.HitChance)
							if bCast then	
								CastSpell(_Q, castPos.x, castPos.z)
								return
							end
						end
					end
				end
				if (OM.Farm or OM.Clear) and self.Menu.Q.LastHit then
					local d = function() 
						local qLvl = myHero:GetSpellData(_Q).level
						return (30.15 * qLvl) - 13.4 + ((0.804 + (qLvl * 0.067)) * myHero.totalDamage)
					end
					local t = _Pewalk.GetSkillFarmTarget(0.625, d, 2200, 1300, false)
					if t then
						local CastPos = self:MinionPrediction(t, 0.625, 90, 2200, myHero)
						if CastPos then
							CastSpell(_Q, CastPos.x, CastPos.z)
						end
					end
				end
			end
		end
	end	
	if self.wReady and myHero.mana - 50 > 75 then
		for i, active in ipairs(self.W.Active) do
			if active.endTime > clock() then
				if GetDistanceSqr(active.pos) < 640000 then
					local cast = true
					for k, v in ipairs(self.W.Timers) do
						if v.obj.valid and GetDistanceSqr(v.obj, active.pos) < 10000 then
							cast = false
						end
					end
					if cast then CastSpell(_W, active.pos.x, active.pos.z) end
				end
			else
				table.remove(self.W.Active, i)
				return
			end
		end
		if self.Menu.W.Path and _Pewalk.CanMove() and not _Pewalk.CanAttack() then
			local target = _Pewalk.GetTarget(700)
			if target and target.hasMovePath then
				if GetDistanceSqr(target, target.endPath) > 160000 then
					local CastPos = NormalizeX(target.endPath, target, 200)
					CastSpell(_W, CastPos.x, CastPos.z)
				elseif GetDistanceSqr(myHero, target.endPath) > 10000 then
					local CastPos = NormalizeX(target.endPath, target, 200)
					CastSpell(_W, CastPos.x, CastPos.z)
				end
			end
		end
	end
	if self.eReady then
		if IsKeyDown(17) then
			self.LastCtrl = clock() + 0.15		
		end
		if self.Menu.E.Mouse and self.LastCtrl < clock() then
			if self.Menu.E.Block then
				local d = Normalize(mousePos.x - myHero.x, mousePos.z - myHero.z)
				local bWall = false
				for i=30, self.Menu.E.MinimumBlock, 20 do
					if IsWall(D3DXVECTOR3(myHero.x + (d.x * i), myHero.y, myHero.z + (d.z * i))) then
						bWall = true
						break
					end
				end
				if bWall and IsWall(D3DXVECTOR3(myHero.x + (d.x * 400), myHero.y, myHero.z + (d.z * 400))) then
					return
				end
			end
			local x, z = mousePos.x - myHero.x, mousePos.z - myHero.z
			local nLength  = sqrt(x * x + z * z)
			CastSpell(_E, myHero.x + ((x / nLength) * (-400)), myHero.z + ((z / nLength) * (-400)))
		end
		if (OM.Farm or OM.Clear) and self.Menu.E.LastHit then
			local d = function() return (50 * myHero:GetSpellData(_E).level) + 30 + (myHero.ap * 0.8) end
			local t = _Pewalk.GetSkillFarmTarget(0.125, d, 2000, 1000, true)
			if t and GetDistanceSqr(t, self.SpawnPos) > GetDistanceSqr(self.SpawnPos)  then
				local CastPos = self:MinionPrediction(t, 0.125, 80, 2000, myHero)
				if CastPos and not self:MinionCollision(myHero, CastPos, 80, t, 0.125, 2000) then
					CastSpell(_E, CastPos.x, CastPos.z)
				end
			end
		end
	end
	if self.rReady then
		local range = self:GetUltRange()
		for i, enemy in ipairs(self.Enemies) do
			if _Pewalk.ValidTarget(enemy, range, true) and self:RDamage(enemy) > enemy.health + enemy.shield then
				self.KillDraw = enemy
				if self.Menu.R.Key or self.Menu.R.Auto then
					CastSpell(_R, enemy)
					return
				end
			end
		end
	end
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
		elseif nVertices == 3 then
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
