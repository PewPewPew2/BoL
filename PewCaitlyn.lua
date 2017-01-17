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
	if FileExist(LIB_PATH..'PewPacketLib.lua') then require('PewPacketLib') end
	if FileExist(LIB_PATH..'FHPrediction.lua') then require('FHPrediction') end
	require 'HPrediction'
	local isLoaded, loadTime = false, clock()
	AddTickCallback(function() 
		if _Pewalk and not isLoaded then
			TEAM_ALLY, TEAM_ENEMY = myHero.team, 300 - myHero.team
			Caitlyn()
			isLoaded = true
		elseif loadTime + 5 < clock() and not isLoaded then
			Print('Pewalk is required!', true)
			isLoaded = true
		end
	end)
end)

class 'Caitlyn'
 
function Caitlyn:__init()
	local version = 3.7
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
				for i, hero in ipairs(self.Enemies) do
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
	self.Dashing = {}
	self.LastCtrl = 0
	self.AllowECast = {x=0,z=0}
	self.PreventSpam = 0
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
	
	if FileExist(LIB_PATH..'PewPacketLib.lua') then self.Packets = GetLoseVisionPacketData() end
	
	self.HP = HPrediction()
	self.HP_Q = HPSkillshot({type = 'DelayLine', delay = 0.625, range = 1300, width = 180, speed = 2200})
	self.HP_E = HPSkillshot({type = 'DelayLine', delay = 0.125, range = 800, width = 140, speed = 1600})
	if FHPrediction then
		self.FH_Q = {range = 1300,speed = 2200,delay = 0.625,radius = 90,type = SkillShotType.SkillshotMissileLine,}
	end	
	
	
	AddTickCallback(function() self:Tick() end)
	AddCreateObjCallback(function(o) self:CreateObj(o) end)
	AddDrawCallback(function() self:Draw() end)
	AddApplyBuffCallback(function(...) self:ApplyBuff(...) end)
	AddProcessSpellCallback(function(...) self:ProcessSpell(...) end)
	AddCastSpellCallback(function(...) self:CastSpell(...) end)
  AddNewPathCallback(function(...) self:NewPath(...) end)
	if self.Packets then AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)	end
end

function Caitlyn:ApplyBuff(source, unit, buff)
	if unit and unit.valid and unit.type == 'AIHeroClient' and unit.team == TEAM_ENEMY then
		if self.OnBuff.CrowdControl[buff.type] and self.Menu.W.CrowdControl then
			self.W.Active[#self.W.Active + 1] = {
				['pos']     = { ['x'] = unit.x, ['z'] = unit.z, },
				['endTime'] = clock() + (buff.endTime - buff.startTime),
			}
		end
		if self.OnBuff.Channels[buff.name] and self.Menu.W.Channel then
			self.W.Active[#self.W.Active + 1] = {
				['pos']     = { ['x'] = unit.x, ['z'] = unit.z, },
				['endTime'] = clock() + (buff.endTime - buff.startTime),
			}		
		end
	end
end

function Caitlyn:AntiGapClose()
	for i=#self.Dashing, 1, -1 do
		local d = self.Dashing[i]
		if d.endTime > clock() then
			if d.unit.valid then
				local isValid = d.unit.bTargetable and d.unit.bInvulnerable == 0
				if self.Menu.E.Dash and self.eReady then
          local point, onLine = self:GetLinePoint(d.startPos.x, d.startPos.z, d.endPos.x, d.endPos.z, myHero.x, myHero.z)          
          local onLine = onLine and GetDistanceSqr(point) < 40000
          if onLine or GetDistanceSqr(d.endPos) < 90000 then
            if GetDistanceSqr(d.startPos, d.endPos) < GetDistanceSqr(d.startPos, myHero) then
              local remainingTime = d.endTime - clock()
              local wTime = .125 + (GetDistance(d.endPos) / 1600) + (GetLatency() * .0005)
              
              local moveTime = wTime - remainingTime
              if moveTime > 0 and (isValid or (d.unit.charName=='Fizz' and d.speed>750 and d.speed<850)) then
                local moveDistance = moveTime * d.unit.ms
                if moveDistance < 70 + d.unit.boundingRadius then
                  self.AllowECast = {x=d.endPos.x, z=d.endPos.z}
                  CastSpell(_E, d.endPos.x, d.endPos.z)
                  local wPos = NormalizeX(d.endPos, myHero, 200)
                  DelayAction(function()
                    CastSpell(_W, wPos.x, wPos.z)
                  end, .2)
                end
              elseif moveTime > -wTime and isValid then
                self.AllowECast = {x=d.endPos.x, z=d.endPos.z}
                CastSpell(_E, d.endPos.x, d.endPos.z)
                local wPos = NormalizeX(d.endPos, myHero, 200)
                DelayAction(function()
                  CastSpell(_W, wPos.x, wPos.z)
                end, .2)
              end
            elseif onLine then
              local remainingTime = (GetDistance(d.startPos) - myHero.boundingRadius) / d.speed
              if remainingTime > .125 + (GetLatency() * .0005) then
                self.AllowECast = {x=d.startPos.x, z=d.startPos.z}
                CastSpell(_E, d.startPos.x, d.startPos.z)
                local wPos = NormalizeX(d.startPos, myHero, 200)
                DelayAction(function()
                  CastSpell(_W, wPos.x, wPos.z)
                end, .2)
              end
            end            
          end
				end
			end
		else
			table.remove(self.Dashing, i)
		end
	end
end

function Caitlyn:CalcArmor(target)
	local baseArmor = target.armor-target.bonusArmor
	return 100 / (100 + (((target.bonusArmor * myHero.bonusArmorPenPercent) + baseArmor) * myHero.armorPenPercent) - ((myHero.lethality * .4) + ((myHero.lethality * .6) * (myHero.level / 18))))
end

function Caitlyn:CastSpell(iSlot,startPos,endPos,target)
	if iSlot == _E and not self.Menu.E.NeverBlock then
		if ceil(self.AllowECast.x)~=ceil(endPos.x) or ceil(self.AllowECast.z)~=ceil(endPos.z) then
			BlockSpell()
		end		
	elseif iSlot == _W then
		self.PreventSpam = clock() + 5
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
		self.Menu.Q:addParam('info', '---Farming---', SCRIPT_PARAM_INFO, '')
		self.Menu.Q:addParam('LastHit', 'Use for Last Hits', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Q:addParam('space', '', SCRIPT_PARAM_INFO, '')
		self.Menu.Q:addParam('info', '---Combat---', SCRIPT_PARAM_INFO, '')
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
		self.Menu.Q:addParam('HitChance2', 'Cast HitChance [3==Highest]', SCRIPT_PARAM_SLICE, 0.4, 0, 3, 1)
		self.Menu.Q:addParam('space', '', SCRIPT_PARAM_INFO, '')
		self.Menu.Q:addParam('info', '---Miscellaneous---', SCRIPT_PARAM_INFO, '')
		self.Menu.Q:addParam('Mana', 'Always Save Mana for E', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Q:addParam('Draw', 'Draw Peacemaker Range', SCRIPT_PARAM_LIST, 1, { 'Low FPS', 'Normal', 'None', })
	self.Menu:addSubMenu('Yordle Snap Trap', 'W')
		self.Menu.W:addParam('info', '---Combat---', SCRIPT_PARAM_INFO, '')
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
		self.Menu.W:addParam('space', '', SCRIPT_PARAM_INFO, '')
		self.Menu.W:addParam('info', '---Miscellaneous---', SCRIPT_PARAM_INFO, '')
		self.Menu.W:addParam('Mana', 'Always Save Mana for E', SCRIPT_PARAM_ONOFF, true)
		self.Menu.W:addParam('Draw', 'Draw Active Trap Timers', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addSubMenu('90 Caliber Net', 'E')
		self.Menu.E:addParam('info', '---Keys---', SCRIPT_PARAM_INFO, '')
    _Pewalk.AddMenuHeader('---Keys---')
		self.Menu.E:addParam('Mouse', 'Net To Mouse', SCRIPT_PARAM_ONKEYDOWN, false, ('E'):byte())
		self.Menu.E:addParam('space', '', SCRIPT_PARAM_INFO, '')
		self.Menu.E:addParam('info', '---Farming---', SCRIPT_PARAM_INFO, '')
		self.Menu.E:addParam('LastHit', 'Use for Last Hits', SCRIPT_PARAM_ONOFF, false)
		self.Menu.E:addParam('space', '', SCRIPT_PARAM_INFO, '')
		self.Menu.E:addParam('info', '---Miscellaneous---', SCRIPT_PARAM_INFO, '')
		self.Menu.E:addParam('Dash', 'Anti Gap Close', SCRIPT_PARAM_ONOFF, true)
		self.Menu.E:addParam('NeverBlock', 'Never block E Casts', SCRIPT_PARAM_ONOFF, false)
		self.Menu.E:addParam('Block', 'Block Failed Wall Jumps', SCRIPT_PARAM_ONOFF, true)
		self.Menu.E:addParam('MinimumBlock', 'Do Not Block if Will Jump This Far', SCRIPT_PARAM_SLICE, 350, 20, 490)
	self.Menu:addSubMenu('Ace in the Hole', 'R')
		self.Menu.R:addParam('info', '---Keys---', SCRIPT_PARAM_INFO, '')
		self.Menu.R:addParam('Key', 'Kill Key', SCRIPT_PARAM_ONKEYDOWN, false, ('R'):byte())
		self.Menu.R:addParam('space', '', SCRIPT_PARAM_INFO, '')
		self.Menu.R:addParam('info', '---Miscellaneous---', SCRIPT_PARAM_INFO, '')
		self.Menu.R:addParam('CrossHair', 'Draw Can Kill Alert', SCRIPT_PARAM_ONOFF, true)
		self.Menu.R:addParam('Line', 'Draw Line to Killable Character', SCRIPT_PARAM_ONOFF, true)
		self.Menu.R:addParam('Indicator', 'Draw Health Remaining Indicator', SCRIPT_PARAM_ONOFF, true)
		self.Menu.R:addParam('Auto', 'Use Automatically', SCRIPT_PARAM_ONOFF, false)
	self.Menu:addParam('Combo', 'W - E - Q Combo', SCRIPT_PARAM_ONKEYDOWN, false, ('T'):byte())
	self.Menu:addParam('Prediction2', 'Prediction Selection', SCRIPT_PARAM_LIST, 1, {'HPrediction', FHPrediction and 'FHPrediction' or 'FHPrediction not found!',})
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
		if PewtilityHPBars and PewtilityHPBars.Active then
			for i, enemy in ipairs(self.Enemies) do
				if enemy.valid and not enemy.dead and enemy.visible then
					PewtilityHPBars.Addon[enemy.networkID] = {}					
          if self.qReady then
            insert(PewtilityHPBars.Addon[enemy.networkID], {
              ['color'] = 0x7300FF00,
              ['damage'] = self:RDamage(enemy),
              ['text'] = 'R',
            })
          end
					PewtilityHPBars.Addon[enemy.networkID].bMana = myHero.mana > 100
				end
			end
    else
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
end

function Caitlyn:GetLinePoint(ax, ay, bx, by, cx, cy)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)	
	return { x = ax + rL * (bx - ax), z = ay + rL * (by - ay) }, (rL < 0 and 0 or (rL > 1 and 1 or rL)) == rL
end

function Caitlyn:GetPrediction(unit, hitchance)
	if self.Menu.Prediction2==2 then
    if FHPrediction then
      local CastPos, HitChance = FHPrediction.GetPrediction(self.FH_Q, unit, myHero) 
      return CastPos and HitChance >= hitchance, CastPos
    else
      self.Menu.Prediction2 = 1
    end
	end
	
	local CastPos, HitChance = self.HP:GetPredict(self.HP_Q, unit, myHero)
  return CastPos and HitChance >= hitchance, CastPos
end

function Caitlyn:GetUltRange()
	return (500 * myHero:GetSpellData(_R).level) + 1500
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

function Caitlyn:NewPath(unit,startPos,endPos,isDash,dashSpeed,dashGravity,dashDistance)
	if unit.valid and unit.type == 'AIHeroClient' and unit.team~=myHero.team and isDash and GetDistanceSqr(startPos, endPos) > 30625 then
		if not self.DashExceptions then
      self.DashExceptions = {
        Aatrox = function(unit, speed) return speed<100 end,
        Alistar = function(unit, speed) return true end,
        Ahri = function(unit, speed) return unit:GetSpellData(_R).currentCd > 10 end,
        AurelionSol = function(unit, speed) return speed==600 end,
        Azir = function(unit, speed) return speed==1700 end,
        Ekko = function(unit, speed) return speed>1100 and speed<1200 end,
        Fizz = function(unit, speed) return speed>1000 and speed<1150 end,
        Gnar = function(unit, speed) return speed>850 and speed<950 and unit:GetSpellData(_E).cd-unit:GetSpellData(_E).currentCd<0.5 end,
        Hecarim = function(unit, speed) return true end,
        Kalista = function(unit, speed) return speed>700 and speed<900 end,
        Leblanc = function(unit, speed) return speed==1600 end,
        Quinn = function(unit, speed) return speed==2500 end,
        Renekton = function(unit, speed) return speed>1050 and speed<1150 and unit:GetSpellData(_E).cd-unit:GetSpellData(_E).currentCd<0.5 end,
        Riven = function(unit, speed) return speed<1150 end,
        Yasuo = function(unit, speed) return true end,
      }
    end
    
    if self.DashExceptions[unit.charName] and self.DashExceptions[unit.charName](unit, dashSpeed) then return end
    
    table.insert(self.Dashing, {
      startTime = clock(),
      speed = dashSpeed,
      startPos = Vector(unit.x, unit.y, unit.z),
      endPos = Vector(endPos),
      endTime = clock() + (GetDistance(startPos, endPos) / dashSpeed),
      range = GetDistanceSqr(startPos, endPos),
      unit = unit,
    })
    self:AntiGapClose()
	end
end

function Caitlyn:ProcessSpell(u, s)
	if u.valid and u.type == 'AIHeroClient' and u.team == TEAM_ENEMY and self.OnSpells[s.name] then
		self.OnSpells[s.name](s.endPos)
	end
end

function Caitlyn:RDamage(unit)
	local baseDmg = ((225 * myHero:GetSpellData(_R).level) + (myHero.addDamage * 2)) * self:CalcArmor(unit)
	for _, buff in ipairs(_Pewalk.GetBuffs(unit)) do
		if self.OnBuff.DamageMods[buff.name] and buff.endT > clock() + 1 then
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
  if OM.Carry then
    if not self.CarryTimer then
      self.CarryTimer = clock()
    end
  else
    self.CarryTimer = nil
  end
  
	self:AntiGapClose()
  
	if self.Combo then
    if self.Combo.Time > clock() then			
      if self.Combo.UseQ then
        local CastPos = self.HP:GetPredict(self.HP_Q, self.Combo.target, Vector(self.Combo.startPos.x, myHero.y, self.Combo.startPos.z))
        if CastPos then  
          CastSpell(_Q, CastPos.x, CastPos.z)
          self.Combo = self.qReady and self.Combo or nil
        end
      else
        local CastPos = self.HP:GetPredict(self.HP_E, self.Combo.target, Vector(self.Combo.startPos.x, myHero.y, self.Combo.startPos.z))
        if CastPos then  
          self.AllowECast = {x=CastPos.x, z=CastPos.z}
          CastSpell(_E, CastPos.x, CastPos.z)
          self.Combo.UseQ = self.eReady==false
        end
      end
    else
      self.Combo = nil
    end
    return
	end
	if self.eReady and self.Menu.Combo and not self.Combo then --self.qReady and 
    local target, shortestDist = nil, huge
    for i, e in ipairs(self.Enemies) do
      if _Pewalk.ValidTarget(e) then
        local dist = GetDistanceSqr(e)
        if dist < 640000 then
          if not target or shortestDist>dist then
            target, shortestDist = e, dist
          end
        end
      end
    end
    if target then
      local bCast, CastPos = self:GetPrediction(target, 0.25)
      if CastPos and GetDistanceSqr(CastPos) < 640000 and _Pewalk.GetCollision(target, CastPos, {length=800, width=80, delay=0.125}, myHero)  then
        self.Combo = {
          ['Time'] = clock() + 1, 
          ['startPos'] = {['x']=myHero.x, ['z'] = myHero.z,},
          ['dashPos'] = NormalizeX(CastPos, myHero, -390),
          ['target'] = target,
        }          
        if myHero.mana > 95 then
          CastSpell(_W, CastPos.x, CastPos.z)
        end
        return
      end
    end
  end
	
	if Evade then return end
	if self.qReady and not self.Menu.Combo then
		if _Pewalk.CanMove() then
			if not self.Menu.Q.Mana or (myHero.mana - ((myHero:GetSpellData(_Q).level * 10) + 40)) > 75 then	
				local c1 = OM.Carry and self.Menu.Q.Carry and self.CarryTimer and self.CarryTimer + 1 < clock()
				local c2 = OM.Mixed and self.Menu.Q.Mixed and not _Pewalk.WaitForMinion()
				local c3 = OM.LaneClear and self.Menu.Q.Clear and not _Pewalk.WaitForMinion()
        if c1 or c2 or c3 then
					local c4 = self.Menu.Q.Method == 1 and self:CheckDamage()
					local c5 = self.Menu.Q.Method == 2 and self.Menu.Q.Toggle
					if c4 or c5 then
						local target = _Pewalk.GetTarget(1300)
						if target then
							local bCast, castPos = self:GetPrediction(target, self.Menu.Q.HitChance2)
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
	if self.wReady and myHero.mana - 50 > 75 and self.PreventSpam < clock() then
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
			local CastPos = {x=myHero.x + ((x / nLength) * (-400)), z=myHero.z + ((z / nLength) * (-400))}
			self.AllowECast = {x=CastPos.x, z=CastPos.z}
			CastSpell(_E, CastPos.x, CastPos.z)
		end
		if (OM.Farm or OM.Clear) and self.Menu.E.LastHit then
			local d = function() return (50 * myHero:GetSpellData(_E).level) + 30 + (myHero.ap * 0.8) end
			local t = _Pewalk.GetSkillFarmTarget(0.125, d, 2000, 1000, true)
			if t and GetDistanceSqr(t, self.SpawnPos) > GetDistanceSqr(self.SpawnPos)  then
				local CastPos = self:MinionPrediction(t, 0.125, 80, 2000, myHero)
				if CastPos and _Pewalk.GetCollision(t, CastPos, {length=1000, width=80, delay=0.125}, myHero)	 then
					self.AllowECast = {x=CastPos.x, z=CastPos.z}
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
        DrawText('Download Status: '..(self.DownloadStatus or 'Unknown'),20,10,50,ARGB(0xFF,0xFF,0xFF,0xFF))
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
