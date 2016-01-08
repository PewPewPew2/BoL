  if myHero.charName~='MissFortune' then return end
local pi, atan, cos, sin = math.pi, math.atan, math.cos, math.sin
local sqrt = math.sqrt
local insert, remove=table.insert, table.remove
local Minions, Enemies
local ValidMinions = {}
local ValidEnemies = {}
local LastOrder = {}
local LastEndPos = {}
local lastCast, success, attempts = 0, 0, 0
local Menu = scriptConfig('MFQ', 'MFQ')
Menu:addParam('DrawCones', 'Draw Cones (Debug Only)', SCRIPT_PARAM_ONOFF, true) 
Menu:addParam('DrawRate', 'Draw Success Rate', SCRIPT_PARAM_ONOFF, true)
Menu:addParam('KillOnly2', 'Kill Only When <X% mana', SCRIPT_PARAM_SLICE, 40, 0, 100)
Menu:addParam('donttouhc', '', SCRIPT_PARAM_INFO, '')
Menu:addParam('donttouhc', 'Dont Touch Below', SCRIPT_PARAM_INFO, '')
Menu:addParam('ConeRadius', 'Cone Radius', SCRIPT_PARAM_SLICE, 460, 300, 487)
Menu:addParam('HighHit', 'High Hit Chance Only', SCRIPT_PARAM_ONOFF, true)

AddLoadCallback(function()
	Minions = _Minions().Objects
	Enemies = {}
	for i=1, heroManager.iCount do
		local h = heroManager:getHero(i)
		if h.valid and h.team ~= myHero.team then
			Enemies[#Enemies+1] = h
			LastOrder[h.networkID] = 0
			LastEndPos[h.networkID] = Vector(0,0,0)
		end
	end
	print('hi')
end)

AddCreateObjCallback(function(o)
	if o.valid and o.type == 'MissileClient' and o.spellOwner and o.spellOwner.isMe then
		if o.spellName == 'MissFortuneRShotExtra' then
			if lastCast > os.clock() then
				local isHit = false
				for i, enemy in pairs(Enemies) do
					if enemy.valid and enemy.visible and not enemy.dead then
						if GetDistanceSqr(enemy, o.spellEnd) < 22500 then
							isHit = true
							break
						end
					end				
				end
				success = success+(isHit and 1 or 0)
			end
		elseif o.spellName == 'MissFortuneRicochetShot'	then
			if lastCast > os.clock() then
				attempts = attempts + 1
			end		
		end
	end
end)

AddNewPathCallback(function(unit,startPos,endPos,isDash,dashSpeed,dashGravity,dashDistance)
	if unit.valid and unit.type == 'AIHeroClient' and unit.team~=myHero.team and LastEndPos[unit.networkID].x ~= endPos.x then
		LastOrder[unit.networkID] = os.clock() + 0.1
		LastEndPos[unit.networkID] = Vector(endPos)	
	end
end)

AddDrawCallback(function()
	if Menu.DrawRate then
		DrawText(success..' / '..attempts,30,100,400,0xFFFFFFFF)
	end
	if myHero:CanUseSpell(_Q) == READY then
		ValidEnemies = {}
		for i, enemy in ipairs(Enemies) do
			if enemy.valid and enemy.visible and not enemy.dead and enemy.bTargetable and GetDistanceSqr(enemy) < 1690000 then
				if not Menu.HighHit or Menu.KillOnly2 * 0.01 > myHero.mana/myHero.maxMana then
					ValidEnemies[#ValidEnemies + 1] = enemy
				elseif LastOrder[enemy.networkID] > os.clock() then
					ValidEnemies[#ValidEnemies + 1] = enemy
				end
			end
		end
		ValidMinions = {}
		for i, minion in ipairs(Minions) do
			if minion.valid and minion.visible and not minion.dead and minion.bTargetable and GetDistanceSqr(minion) < 1690000 then
				ValidMinions[#ValidMinions + 1] = minion	
			end
		end
		for i, enemy in ipairs(ValidEnemies) do
			if GetDistance(enemy) < 615 then
				local PPos = Position(enemy, 0.25 + (GetLatency() * 0.001) + (GetDistance(enemy) / 1400))
				local t = GetBounceTarget(enemy, PPos, Cone(PPos, pi*(22 / 180), false), Cone(PPos, pi*(18 / 180), false))
				if t then
					if t.type == 'AIHeroClient' then 
						lastCast = os.clock() + 1.25
						CastSpell(_Q, enemy) 
					end					
				else
					local t = GetBounceTarget(enemy, PPos, Cone(PPos, pi*(42 / 180), false), Cone(PPos, pi*(38 / 180), false))
					if t then
						if t.type == 'AIHeroClient' then 
							lastCast = os.clock() + 1.25
							CastSpell(_Q, enemy) 
						end	
					else
						local t = GetBounceTarget(enemy, PPos, Cone(PPos, pi*(92 / 180), true),Cone(PPos, pi*(88 / 180), false))
						if t then
							if t.type == 'AIHeroClient' then 
								lastCast = os.clock() + 1.25
								CastSpell(_Q, enemy) 
							end		
						end
					end
				end					
			end
		end
		local qDamage = 5 + (myHero:GetSpellData(_Q).level * 15) + (0.85 * myHero.totalDamage) + (0.35 * myHero.ap)
		for i, minion in ipairs(ValidMinions) do
			local validMinion = GetDistance(minion) < 615
			if Menu.KillOnly2 * 0.01 > myHero.mana/myHero.maxMana then
				validMinion = qDamage > PredictHP(minion)
			end
			if validMinion then
				local PPos = Position(minion, 0.25 + (GetLatency() * 0.001) + (GetDistance(minion) / 1400))
				local t = GetBounceTarget(minion, PPos, Cone(PPos, pi*(22 / 180), false), Cone(PPos, pi*(18 / 180), false))
				if t then
					if t.type == 'AIHeroClient' then 
						lastCast = os.clock() + 1.25
						CastSpell(_Q, minion) 
					end	
				else
					local t = GetBounceTarget(minion, PPos, Cone(PPos, pi*(42 / 180), false), Cone(PPos, pi*(38 / 180), false))
					if t then
						if t.type == 'AIHeroClient'  then 
							lastCast = os.clock() + 1.25
							CastSpell(_Q, minion) 
						end		
					else
						local t = GetBounceTarget(minion, PPos, Cone(PPos, pi*(92 / 180), true), Cone(PPos, pi*(88 / 180), false))
						if t then
							if t.type == 'AIHeroClient' then 
								lastCast = os.clock() + 1.25
								CastSpell(_Q, minion) 
							end		
						end
					end
				end	
			end
		end
	end
end)

function PredictHP(unit)
	local pHP = unit.health
	if _G.AutoCarry then
		pHP = _G.AutoCarry.DamagePred:GetPred(unit, 2, {Speed = 1.4, Delay = 250})
	elseif Pewalk_PredictMinionHealth then
		pHp = Pewalk_PredictMinionHealth(unit, 0.25 + GetDistance(unit) / 1400)
	end
	return pHP
end

function GetBounceTarget(target, pos, cone1, cone2)
	local DelayTime = 0.25 + (GetLatency() * 0.001) + (GetDistance(pos) / 1400)
	local Candidates = {}
	for k, enemy in ipairs(ValidEnemies) do
		if enemy~=target then
			if GetDistanceSqr(enemy) < 1000000 and enemy.hasMovePath then
				local PPos = Position(enemy, DelayTime)
				if cone2 and cone2:contains(PPos.x, PPos.z) and cone2:contains(enemy.x, enemy.z) then
					DrawText3D('P',PPos.x,enemy.y,PPos.z,30,0xFFFF0000)
					DrawText3D('X',enemy.x,enemy.y,enemy.z,30,0xFFFF0000)
					Candidates[#Candidates+1] = {t=enemy, p=enemy}
				end
			end
		end
	end
	for k, minion in ipairs(ValidMinions) do
		if minion~=target then
			local PPos = Position(minion, DelayTime)
			if cone1 and cone1:contains(PPos.x, PPos.z) or cone1:contains(minion.x, minion.z) then
				Candidates[#Candidates+1] = {t=minion, p=PPos}
				Candidates[#Candidates+1] = {t=minion, p=minion}
			end
		end
	end
	local BounceTarget, Distance = nil, math.huge
	for i, bounce in ipairs(Candidates) do
		local dist = GetDistanceSqr(target, bounce.p)
		if not BounceTarget or dist < Distance then
			BounceTarget, Distance = bounce.t, dist
		end
	end
	return BounceTarget
end

function Cone(target, sector, allowDraw)
    local poly = _Poly()
	poly:declareCone()
	local vx, vz = myHero.x-target.x, myHero.z-target.z
	poly:Add({['x'] = target.x, ['z'] = target.z,})
	local a = (vx > 0) and atan(vz/vx) or atan(vz/vx)+pi
	a = (pi)-(a+(sector/2))
	for i = a, a+sector+(sector/10), (sector/10) do
		poly:Add({['x'] = target.x+(Menu.ConeRadius*cos(i)), ['z'] = target.z-(Menu.ConeRadius*sin(i)), }) --460
    end
	if allowDraw and Menu.DrawCones then
		poly:draw(0xFFFFFFFF, 0)
	end
	return poly
end

function Normalize(x,z)
    local length  = sqrt(x * x + z * z)
	return {['x'] = x / length, ['z'] = z / length}
end

function NormalizeX(v1, v2, length)
	x, z = v1.x - v2.x, v1.z - v2.z
    local nLength  = sqrt(x * x + z * z)
	return { ['x'] = v2.x + ((x / nLength) * length), ['z'] = v2.z + ((z / nLength) * length)} 
end

function Position(unit, delay)
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

class '_Poly'

function _Poly:__init(...)
	self.points = {...}
end

function _Poly:declareCone()
	self.bCone = true
end

function _Poly:Add(point)
	insert(self.points, point)
	self.lineSegments = nil
	self.triangles = nil
end

function _Poly:contains(px, pz)
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

function _Poly:triangulate()
	if not self.triangles then
		self.triangles = {}
		local nVertices = #self.points
		if nVertices > 3 then			
			if nVertices == 4 then
				insert(self.triangles, _Poly(self.points[1], self.points[2], self.points[3]))
				insert(self.triangles, _Poly(self.points[1], self.points[3], self.points[4]))
			elseif self.bCone then
				for i=2, #self.points-1 do
					insert(self.triangles, _Poly(self.points[1], self.points[i], self.points[i+1]))
				end
			elseif self.bArc then
				for i=1, nVertices/2 do
					insert(self.triangles, _Poly(self.points[i], self.points[nVertices-(i-1)], self.points[nVertices-i]))
					insert(self.triangles, _Poly(self.points[i], self.points[nVertices-i], self.points[i+1]))
				end		
			else
				if not self.Center then
					local xt, zt = 0, 0
					for i, point in ipairs(self.points) do
						xt=xt+point.x
						zt=zt+point.z
					end
					self.Center = { ['x'] = xt/nVertices, ['z'] = zt/nVertices, }
				end
				for i=1, nVertices-1 do
					insert(self.triangles, _Poly(self.Center, self.points[i], self.points[i+1]))
				end
			end
		elseif #self.points == 3 then
			insert(self.triangles, self)
		end
	end
	return self.triangles
end

function _Poly:draw(color, yValue)
    if not self.points[1] then return end
	local p = {}
	for i, point in ipairs(self.points) do
		local c = WorldToScreen(D3DXVECTOR3(point.x, yValue, point.z))
		p[#p + 1] = D3DXVECTOR2(c.x, c.y)
	end
	p[#p + 1] = p[1]
	if #p > 1 then
		DrawLines2(p, 3, color)
	end
end

--SSL LINE
class '_Minions'

function _Minions:__init()
	self.Objects = {}
	self.Others = {}
	for i = 0, objManager.maxObjects do
		if self:IsValid(objManager:getObject(i)) then
			insert(self.Objects, objManager:getObject(i))
		end
	end
	self.AreValid = {
		['Blue_Minion_Basic'] 	  = true,
		['Blue_Minion_Wizard'] 	  = true,
		['Blue_Minion_MechCannon']= true,
		['Blue_Minion_MechMelee'] = true,
		['Red_Minion_Basic'] 	  = true,
		['Red_Minion_Wizard'] 	  = true,
		['Red_Minion_MechCannon'] = true,
		['Red_Minion_MechMelee']  = true,
		--Summoner Rift
		['SRU_OrderMinionMelee']  = true,
		['SRU_OrderMinionRanged'] = true,
		['SRU_OrderMinionSiege']  = true,
		['SRU_OrderMinionSuper']  = true,
		['SRU_ChaosMinionMelee']  = true,
		['SRU_ChaosMinionRanged'] = true,
		['SRU_ChaosMinionSiege']  = true,
		['SRU_ChaosMinionSuper']  = true,
		['SRU_BlueMini']  = true,
		['SRU_BlueMini2'] = true,
		['SRU_Blue']  = true,
		['SRU_Gromp']  = true,
		['SRU_MurkwolfMini']  = true,
		['SRU_Murkwolf'] = true,
		['Sru_Crab']  = true,
		['SRU_Razorbeak']  = true,
		['SRU_RazorbeakMini']  = true,
		['SRU_RedMini'] = true,
		['SRU_Red']  = true,
		['SRU_Krug']  = true,
		['SRU_KrugMini']  = true,
		['SRU_Dragon']  = true,
		['SRU_RiftHerald']  = true,
		['SRU_Baron']  = true,
		--BilgeWater
		['BilgeLaneMelee_Order']  = true,
		['BilgeLaneRanged_Order'] = true,
		['BilgeLaneCannon_Order']  = true,
		['BilgeLaneMelee_Chaos']  = true,
		['BilgeLaneRanged_Chaos'] = true,
		['BilgeLaneCannon_Chaos']  = true,
		['BW_Razorfin']  = true,
		['BW_Ironback'] = true,
		['BW_Ocklepod']  = true,
		['BW_Plundercrab']  = true,
		--Twisted Treeline & Howling Abyss
		['HA_ChaosMinionMelee']   = true,
		['HA_ChaosMinionRanged']  = true,
		['HA_ChaosMinionSiege']   = true,
		['HA_ChaosMinionSuper']   = true,
		['HA_OrderMinionMelee']   = true,
		['HA_OrderMinionRanged']  = true,
		['HA_OrderMinionSiege']   = true,
		['HA_OrderMinionSuper']   = true,
		['TT_NWraith2']   = true,
		['TT_NWraith']   = true,
		['TT_NGolem']   = true,
		['TT_NGolem2']  = true,
		['TT_NWolf']   = true,
		['TT_NWolf2']   = true,
		['TT_Spiderboss']   = true,
		--Crystal Scar
		['Odin_Red_Minion_Caster']= true,
		['Odin_Blue_Minion_Caster']=true,
		['OdinRedSuperminion']	  = true,
		['OdinBlueSuperminion']   = true,
		--Others
		['MalzaharVoidling'] = true,
		['AnnieTibbers'] = true,
		['YorickDecayedGhoul'] = true,
		['YorickRavenousGhoul'] = true,
		['YorickSpectralGhoul'] = true,
		['ShacoBox'] = true,
		['HeimerTBlue'] = true,
		['HeimerTYellow'] = true,
		['OdinBlueSuperminion'] = true,
		['OdinRedSuperminion'] = true,
		['ZacRebirthBloblet'] = true,
	}	
	self.ToOthers = {
		['ZyraGraspingPlant'] = true,
		['RobotBuddy'] = true,
		['ZyraThornPlant'] = true,
		['TeemoMushroom'] = true,
		['God'] = true,
	}
	AddTickCallback(function() self:Tick() end)
	AddCreateObjCallback(function(o) self:CreateObj(o) end)
	AddDeleteObjCallback(function(o) self:DeleteObj(o) end)
	return self
end

function _Minions:IsValid(o)
	return o and o.valid and not o.dead and o.type == 'obj_AI_Minion' and o.team ~= myHero.team
end

function _Minions:IsValid2(charName)
	return self.AreValid[charName]
end

function _Minions:Tick()
	for i=#self.Objects, 1, -1 do
		local o = self.Objects[i]
		if not self:IsValid(o) then
			remove(self.Objects, i)
		elseif self.ToOthers[o.name] or o.name:lower():find('ward') then
			insert(self.Others, #self.Others+1, o)
			remove(self.Objects, i)
		elseif not self:IsValid2(o.charName) then
			remove(self.Objects, i)
		end
	end
	for i=#self.Others, 1, -1 do
		if not self:IsValid(self.Others[i]) then
			remove(self.Others, i)
		end	
	end
end

function _Minions:CreateObj(o)
	if self:IsValid(o) then
		insert(self.Objects, #self.Objects + 1, o)
	end
end

function _Minions:DeleteObj(o)
	if o.valid then
		for i, m in ipairs(self.Objects) do
			if m.networkID == o.networkID then
				remove(self.Objects, i)
				return
			end
		end
	end
end


