local p_TopA, p_TopB, p_MidA, p_MidB, p_BotA, p_BotB, p_Neut
local floor, clock = math.floor, os.clock
--Minion Arrays
local m_Top, m_Mid, m_Bot, m_Global = {['Name'] = 'Top'}, {['Name'] = 'Mid'}, {['Name'] = 'Bot'}, nil
--Drawing
local anchor = {x=20, y=160}
local barSprite
--Menu
local menuKey, isMoving, movingOffset, Menu = GetSave('scriptConfig')['Menu']['menuKey'], false, nil, nil

local momentum_Value = {
	['SRU_OrderMinionMelee']  = 0.5,
	['SRU_OrderMinionRanged'] = 0.35,
	['SRU_OrderMinionSiege']  = 1.5,
	['SRU_OrderMinionSuper']  = 4,
	['SRU_ChaosMinionMelee']  = 0.5,
	['SRU_ChaosMinionRanged'] = 0.35,
	['SRU_ChaosMinionSiege']  = 1.5,
	['SRU_ChaosMinionSuper']  = 4,
} 

AddLoadCallback(function()
	if GetMap().shortName ~= 'summonerRift' then return end
	--Create Menu
	Menu = scriptConfig('Lane Momentum', 'Lane Momentum')
	Menu:addParam('Scale', 'HUD Scale', SCRIPT_PARAM_SLICE, 100, 50, 100)
	--Top Polygons
	p_TopA = PewPoly({x=2633,z=12058},{x=547,z=14617},{x=774,z=1981},{x=1635,z=2012})
	p_TopB = PewPoly({x=2633,z=12058},{x=547,z=14617},{x=12905,z=13843},{x=12802,z=13166})
	--Middle Polygon
	p_MidA = PewPoly({x=1626,z=2384},{x=2371,z=1578},{x=7900,z=6860},{x=6870,z=7850})
	p_MidB = PewPoly({x=13252,z=12422},{x=12332,z=13291},{x=6870,z=7850},{x=7900,z=6800})
	--Bottom Polygons
	p_BotA = PewPoly({x=12006,z=3021},{x=14358,z=550},{x=2000,z=800},{x=1933,z=1732})
	p_BotB = PewPoly({x=12006,z=3021},{x=14358,z=550},{x=14101,z=12531},{x=13203,z=12651})
	--Neutral Area
	p_Neut = PewPoly({x=12700,z=930},{x=14250,z=2370},{x=2150,z=14100},{x=630,z=13000})
	--Initialize minion array
	m_Global = MomentumMinions()	
	--Save HUD position
	if FileExist(LIB_PATH..'\\Saves\\LaneMomentum.save') then
		local file = loadfile(LIB_PATH ..'Saves\\LaneMomentum.save')
		if type(file) == "function" then
			anchor = file()
		end
	end
	local function savePos()
		local f = io.open(LIB_PATH..'\\Saves\\LaneMomentum.save', 'w')
		f:write('return {x='..anchor.x..',y='..anchor.y..'}')
		f:close()
	end
	AddBugsplatCallback(savePos)
	AddUnloadCallback(savePos)
	AddExitCallback(savePos)
	--Create Sprite
	if FileExist(SPRITE_PATH..'\\LaneMomentum.png') then
		barSprite = createSprite(SPRITE_PATH..'\\LaneMomentum.png')
	else 
		print('Lane momentum sprite missing!!')
	end
	print('Lane Momentum Indicator')
	AddMsgCallback(OnMsg)
	AddProcessAttackCallback(OnSpell)
	AddDrawCallback(Draw)
end)

function OnMsg(m,k)
	if m==WM_LBUTTONDOWN and IsKeyDown(menuKey) then
		local CursorPos = GetCursorPos()
		if CursorPos.x > anchor.x and CursorPos.x < anchor.x+GetScale(160) then
			if CursorPos.y > anchor.y and CursorPos.y < anchor.y+GetScale(132) then
				isMoving = true
				movingOffset = {x=CursorPos.x-anchor.x, y=CursorPos.y-anchor.y,}
			end
		end
	end
	if m==WM_LBUTTONUP and isMoving then
		isMoving=false
	end
end

function OnSpell(unit,spell)
	if unit.valid and unit.type == 'obj_AI_Minion' then
		for i=#m_Global.Objects, 1, -1 do
			local minion = m_Global.Objects[i]
			if minion and m_Global:IsValid(minion) and m_Global.AreValid[minion.charName] and minion==unit then
				if p_TopA:contains(minion.x, minion.z) then
					AddToLane(m_Top, minion, i, 100)
				elseif p_TopB:contains(minion.x, minion.z) then
					AddToLane(m_Top, minion, i, 200)
				elseif p_MidA:contains(minion.x, minion.z) then
					AddToLane(m_Mid, minion, i, 100)
				elseif p_MidB:contains(minion.x, minion.z) then
					AddToLane(m_Mid, minion, i, 200)
				elseif p_BotA:contains(minion.x, minion.z) then
					AddToLane(m_Bot, minion, i, 100)
				elseif p_BotB:contains(minion.x, minion.z) then
					AddToLane(m_Bot, minion, i, 200)
				end
			end
		end		
	end
end

function Draw()
	local a_Top, e_Top, test = GetDifference(m_Top)
	local a_Mid, e_Mid, test2 = GetDifference(m_Mid)
	local a_Bot, e_Bot, test3 = GetDifference(m_Bot)
	--Top
	DrawMomentum(22, 5 + ReduceNumber(RoundNumber(a_Top - e_Top)), test)
	--Middle
	DrawMomentum(66, 5 + ReduceNumber(RoundNumber(a_Mid - e_Mid)), test2)
	--Bottom
	DrawMomentum(110, 5 + ReduceNumber(RoundNumber(a_Bot - e_Bot)), test3)
	--Draw Sprite (Border)
	if barSprite then
		barSprite:SetScale((Menu.Scale / 100) * 1, (Menu.Scale / 100) * 1)
		barSprite:Draw(anchor.x,anchor.y, IsKeyDown(menuKey) and 160 or 255)
	end
	--Moving Anchor
	if isMoving then
		local CursorPos = GetCursorPos()
		anchor.x = CursorPos.x-movingOffset.x
		anchor.y = CursorPos.y-movingOffset.y
	end
end

function AddToLane(tbl, minion, index, team)
	table.insert(tbl, #tbl+1, {['minion'] = minion, ['time'] = clock() + 10})
	table.remove(m_Global.Objects, index)
	tbl['Advantage'] = p_Neut:contains(minion.x, minion.z) and nil or team
end

function RoundNumber(num)
	return floor(num + 0.5)
end

function ReduceNumber(num)
	return num > 5 and 5 or num < -5 and -5 or num
end

function DrawMomentum(y, off, test)
	DrawLine(
		anchor.x+GetScale(11), 
		anchor.y+GetScale(y), 
		anchor.x+GetBarOffset(off), 
		anchor.y+GetScale(y), 
		GetScale(24), 
		ARGB((IsKeyDown(menuKey) and 125 or 200),0,230,0)
	)
	DrawLine(
		anchor.x+GetBarOffset(off), 
		anchor.y+GetScale(y), 
		anchor.x+GetScale(149), 
		anchor.y+GetScale(y), 
		GetScale(24), 
		ARGB((IsKeyDown(menuKey) and 125 or 200),230,0,0)
	)
	if test then
		DrawText(test,GetScale(26), anchor.x+GetBarOffset(test==string.char(27) and off or off-1), anchor.y+GetScale(y-12), 0xFFFFFFFF)
	end
end

function GetDifference(lane)
	local ally, ally_Count, enemy, enemy_Count, direction = 0, 0, 0, 0, nil
	for i, info in ipairs(lane) do
		if info and info.minion and m_Global:IsValid(info.minion) and momentum_Value[info.minion.charName] then
			if info.minion.team == myHero.team then
				if info.time < clock() then
					ally_Count = ally_Count + 1
					ally=ally+momentum_Value[info.minion.charName]
				else
					ally=ally+(momentum_Value[info.minion.charName] * 0.25)					
				end
			else
				if info.time < clock() then
					enemy_Count = enemy_Count + 1
					enemy=enemy+momentum_Value[info.minion.charName]
				else
					enemy=enemy+(momentum_Value[info.minion.charName]*0.25)			
				end
			end
		end
	end
	if ally_Count > 0 and enemy_Count > 0 then
		local difference = ally_Count-enemy_Count
		if difference > 4 then
			ally = ally + 2
			direction = string.char(26)
		elseif difference < -4 then
			enemy = enemy + 2
			direction = string.char(27)
		end		
	elseif ally_Count == 0 and enemy_Count > 7 then
		enemy = enemy + 2
		direction = string.char(27)
	elseif enemy_Count == 0 and ally_Count > 7 then
		ally = ally + 2
		direction = string.char(26)
	end
	if lane.Advantage then
		if lane.Advantage == myHero.team then
			ally = ally + 0.75
		else
			enemy = enemy + 0.75
		end
	end
	return ally, enemy, direction
end

function GetBarOffset(value)
	return GetScale(11 + (13 * value) + value)
end

function GetScale(m)
	return floor((Menu.Scale / 100) * m)
end

class 'PewPoly'

function PewPoly:__init(...)
	self.points = {...}
end

function PewPoly:Add(point)
	insert(self.points, point)
	self.lineSegments = nil
	self.triangles = nil
end

function PewPoly:contains(px, pz)
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

function PewPoly:triangulate()
	if not self.triangles then
		self.triangles = {}
		local nVertices = #self.points
		if nVertices > 3 then			
			if nVertices == 4 then
				table.insert(self.triangles, PewPoly(self.points[1], self.points[2], self.points[3]))
				table.insert(self.triangles, PewPoly(self.points[1], self.points[3], self.points[4]))
			end
		elseif #self.points == 3 then
			table.insert(self.triangles, self)
		end
	end
	return self.triangles
end

class 'MomentumMinions'

function MomentumMinions:__init()
	self.Objects = {}
	for i = 0, objManager.maxObjects do
		if self:IsValid(objManager:getObject(i)) then
			table.insert(self.Objects, objManager:getObject(i))
		end
	end
	self.AreValid = {
		--Summoner Rift
		['SRU_OrderMinionMelee']  = true,
		['SRU_OrderMinionRanged'] = true,
		['SRU_OrderMinionSiege']  = true,
		['SRU_OrderMinionSuper']  = true,
		['SRU_ChaosMinionMelee']  = true,
		['SRU_ChaosMinionRanged'] = true,
		['SRU_ChaosMinionSiege']  = true,
		['SRU_ChaosMinionSuper']  = true,
	}
	AddTickCallback(function() self:Tick() end)
	AddCreateObjCallback(function(o) self:CreateObj(o) end)
	AddDeleteObjCallback(function(o) self:DeleteObj(o) end)
	return self
end

function MomentumMinions:IsValid(o)
	return o and o.valid and not o.dead and o.type == 'obj_AI_Minion' and o.team ~= 300
end

function MomentumMinions:Tick()
	for i=#self.Objects, 1, -1 do
		local o = self.Objects[i]
		if not self:IsValid(o) or not self.AreValid[o.charName] then
			table.remove(self.Objects, i)
		end
	end
end

function MomentumMinions:CreateObj(o)
	if self:IsValid(o) then
		table.insert(self.Objects, #self.Objects + 1, o)
	end
end

function MomentumMinions:DeleteObj(o)
	if o.valid then
		for i, m in ipairs(self.Objects) do
			if m.networkID == o.networkID then
				table.remove(self.Objects, i)
				return
			end
		end
	end
end
