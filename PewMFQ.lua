if myHero.charName~='MissFortune' then return end
local pi, atan, cos, sin = math.pi, math.atan, math.cos, math.sin
local sqrt = math.sqrt
local insert, remove=table.insert, table.remove
local clock = os.clock

function Print(text, isError)
	if isError then
		print('<font color=\'#0099FF\'>[PewMF] </font> <font color=\'#FF0000\'>'..text..'</font>')	
		return
	end
	print('<font color=\'#0099FF\'>[PewMF] </font> <font color=\'#FF6600\'>'..text..'</font>')
end

AddLoadCallback(function()
	if _Pewalk then
		MF()
		Print('Loaded.')
	else
		Print('Pewalk not detected!', true)
	end
end)

class 'MF'

function MF:__init()
	self.Enemies = {}
	self.ValidEnemies = {}
	self.ValidMinions = {}
	self.LastOrder = {}
	self.LastEndPos = {}
	for i=1, heroManager.iCount do
		local h = heroManager:getHero(i)
		if h.valid and h.team ~= myHero.team then
			self.Enemies[#self.Enemies+1] = h
			self.LastOrder[h.networkID] = 0
			self.LastEndPos[h.networkID] = Vector(0,0,0)
		end
	end
	
	self.Success = 0
	self.Attempts = 0
	self.LastCast = 0
	
	self:CreateMenu()

	_Pewalk.AddAfterAttackCallback(function(target)
		if target.type == 'AIHeroClient' then
			if myHero:CanUseSpell(_Q) == READY and self.qReady then
				CastSpell(_Q, target)
			elseif self.Menu.CarryW and myHero:CanUseSpell(_W) == READY and _Pewalk.ValidTarget(target,myHero.range+myHero.boundingRadius,true) then
				CastSpell(_W)
			end
		end
	end)
	
	AddCreateObjCallback(function(o) self:CreateObj(o) end)
	AddDrawCallback(function() self:Draw() end)
	AddNewPathCallback(function(...) self:NewPath(...) end)
end

function MF:CastQBounce(target)
	local PPos = self:GetPos(target, 0.25 + (GetLatency() * 0.001) + (GetDistance(target) / 1400))
	local t = self:GetBounceTarget(target, PPos, self:CreateCone(PPos, pi*(22 / 180), false), self:CreateCone(PPos, pi*(18 / 180), false))
	if t then
		if t.type == 'AIHeroClient' then 
			self.LastCast = os.clock() + 1.25
			CastSpell(_Q, target) 
		end					
	else
		local t = self:GetBounceTarget(target, PPos, self:CreateCone(PPos, pi*(42 / 180), false), self:CreateCone(PPos, pi*(38 / 180), false))
		if t then
			if t.type == 'AIHeroClient' then 
				self.LastCast = os.clock() + 1.25
				CastSpell(_Q, target) 
			end	
		else
			local t = self:GetBounceTarget(target, PPos, self:CreateCone(PPos, pi*(92 / 180), true), self:CreateCone(PPos, pi*(88 / 180), false))
			if t then
				if t.type == 'AIHeroClient' then 
					self.LastCast = os.clock() + 1.25
					CastSpell(_Q, target) 
				end
			end
		end
	end	
end

function MF:CreateCone(target, sector, allowDraw)
    local poly = _Poly()
	local vx, vz = myHero.x-target.x, myHero.z-target.z
	poly:Add({['x'] = target.x, ['z'] = target.z,})
	local a = (vx > 0) and atan(vz/vx) or atan(vz/vx)+pi
	a = (pi)-(a+(sector/2))
	for i = a, a+sector+(sector/10), (sector/10) do
		poly:Add({['x'] = target.x+(self.Menu.ConeRadius*cos(i)), ['z'] = target.z-(self.Menu.ConeRadius*sin(i)), }) --460
    end
	if allowDraw and self.Menu.DrawCones then
		poly:draw(0x44FFFFFF, 0)
	end
	return poly
end

function MF:CreateMenu()
	self.Menu = scriptConfig('PewMF', 'MFQ')
	self.Menu:addParam('qInfo', '-Q-', SCRIPT_PARAM_INFO, '') 
	self.Menu:addParam('CarryQ', 'Use in Carry Mode', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('MixedQ', 'Use in Mixed Mode', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('ClearQ', 'Use in Clear Mode', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('DrawCones', 'Draw Cones (Debug Only)', SCRIPT_PARAM_ONOFF, true) 
	self.Menu:addParam('DrawRate', 'Draw Success Rate', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('KillOnly', 'Kill Only When <X% mana', SCRIPT_PARAM_SLICE, 40, 0, 100)
	self.Menu:addParam('HighHit', 'High Hit Chance Only', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('ConeRadius', 'Cone Radius (Dont Touch)', SCRIPT_PARAM_SLICE, 460, 300, 487)
	self.Menu:addParam('space', '', SCRIPT_PARAM_INFO, '') 
	self.Menu:addParam('wInfo', '-W-', SCRIPT_PARAM_INFO, '') 
	self.Menu:addParam('CarryW', 'Use in Carry Mode', SCRIPT_PARAM_ONOFF, true) 
	self.Menu:addParam('space', '', SCRIPT_PARAM_INFO, '') 
	self.Menu:addParam('wInfo', '-E-', SCRIPT_PARAM_INFO, '') 
	self.Menu:addParam('CarryE', 'Use in Carry Mode', SCRIPT_PARAM_ONOFF, true) 
end

function MF:CreateObj(o)
	if o.valid and o.type == 'MissileClient' and o.spellOwner and o.spellOwner.isMe then
		if o.spellName == 'MissFortuneRShotExtra' then
			if self.LastCast > clock() then
				local isHit = false
				for i, enemy in pairs(self.Enemies) do
					if enemy.valid and enemy.visible and not enemy.dead then
						if GetDistanceSqr(enemy, o.spellEnd) < 22500 then
							isHit = true
							break
						end
					end				
				end
				self.Success = self.Success + (isHit and 1 or 0)
			end
		elseif o.spellName == 'MissFortuneRicochetShot'	then
			if self.LastCast > clock() then
				self.Attempts = self.Attempts + 1
			end		
		end
	end
end

function MF:Draw()
	if self.Menu.DrawRate then
		DrawText('Hit / Total: '..self.Success..' / '..self.Attempts,26,WINDOW_W - 175,WINDOW_H * .075,0xFFFFFFFF)
	end	
	
	local AM = _Pewalk.GetActiveMode()
	self.qReady = myHero:CanUseSpell(_Q) == READY and (AM.Carry and self.Menu.CarryQ) or (AM.Mixed and self.Menu.MixedQ) or (AM.LaneClear and self.Menu.ClearQ)
	
	if _Pewalk.CanMove() then
		if self.qReady then
			self.ValidEnemies = {}
			for i, enemy in ipairs(self.Enemies) do
				if enemy.valid and enemy.visible and not enemy.dead and enemy.bTargetable and GetDistanceSqr(enemy) < 1300*1300 then
					if not self.Menu.HighHit or self.LastOrder[enemy.networkID] > clock() then
						self.ValidEnemies[#self.ValidEnemies + 1] = enemy
					end
				end
			end
			self.ValidMinions = {}
			for i, minion in ipairs(_Pewalk.GetMinions()) do
				if GetDistanceSqr(minion) < 1300*1300 then
					self.ValidMinions[#self.ValidMinions + 1] = minion	
				end
			end
			
			if self.ValidEnemies[2] then
				for i, enemy in ipairs(self.ValidEnemies) do
					if _Pewalk.ValidTarget(enemy, 650, true) then --615?
						self:CastQBounce(enemy)
					end
				end
			end
			
			if self.ValidEnemies[1] then
				local qDamage = 5 + (myHero:GetSpellData(_Q).level * 15) + (0.85 * myHero.totalDamage) + (0.35 * myHero.ap)
				for i, m in ipairs(self.ValidMinions) do
					if _Pewalk.ValidTarget(m, 650, true) and (self.Menu.KillOnly * 0.01 < myHero.mana/myHero.maxMana or qDamage > _Pewalk.PredictMinionHealth(m, 0.25 + GetDistance(m) / 1400)) then
						self:CastQBounce(m)
					end
				end
			end
		end
		if AM.Carry and self.Menu.CarryE and myHero:CanUseSpell(_E) == READY then
			local t = _Pewalk.GetTarget(900, false)
			if t then
				local cp = self:GetPos(t, .45)
				if cp then
					CastSpell(_E, cp.x, cp.z)
				end
			end
		end			
	end
end

function MF:GetBounceTarget(target, pos, cone1, cone2)
	local DelayTime = 0.25 + (GetLatency() * 0.001) + (GetDistance(pos) / 1400)
	local Candidates = {}
	for k, e in ipairs(self.ValidEnemies) do
		if e and e~=target then
			if GetDistanceSqr(e) < 1000000 and e.hasMovePath then
				local PPos = self:GetPos(e, DelayTime)
				if cone2 and cone2:contains(PPos.x, PPos.z) and cone2:contains(e.x, e.z) then
					Candidates[#Candidates+1] = {t=e, p=e}
				end
			end
		end
	end
	for k, m in ipairs(self.ValidMinions) do
		if m~=target then
			local PPos = self:GetPos(m, DelayTime)
			if cone1 and cone1:contains(PPos.x, PPos.z) or cone1:contains(m.x, m.z) then
				Candidates[#Candidates+1] = {t=m, p=PPos}
				Candidates[#Candidates+1] = {t=m, p=m}
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

function MF:GetPos(unit, delay)
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
			local x, z = Waypoints[i + 1].x - Waypoints[i].x, Waypoints[i + 1].z - Waypoints[i].z
			local nLength  = sqrt(x * x + z * z)
			return { ['x'] = Waypoints[i].x + ((x / nLength) * pathPotential), ['z'] = Waypoints[i].z + ((z / nLength) * pathPotential)} 
		elseif i == (#Waypoints - 1) then
			return Waypoints[i + 1]
		end
		pathPotential = pathPotential - CurrentDistance
	end	
	return Waypoints[1]
end

function MF:NewPath(unit,startPos,endPos,isDash,dashSpeed,dashGravity,dashDistance)
	if unit.valid and unit.type == 'AIHeroClient' and unit.team~=myHero.team and self.LastEndPos[unit.networkID].x ~= endPos.x then
		self.LastOrder[unit.networkID] = clock() + 0.1
		self.LastEndPos[unit.networkID] = Vector(endPos)	
	end
end

class '_Poly'

function _Poly:__init(...)
	self.points = {...}
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
		if #self.points == 3 then
			insert(self.triangles, self)
		else
			for i=2, #self.points-1 do
				insert(self.triangles, _Poly(self.points[1], self.points[i], self.points[i+1]))
			end	
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
		DrawLines2(p, 2, color)
	end
end
