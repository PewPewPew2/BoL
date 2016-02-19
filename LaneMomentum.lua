local floor, clock = math.floor, os.clock
--Minion Arrays
local m_Top, m_Mid, m_Bot, m_Global = {['Name'] = 'Top'}, {['Name'] = 'Mid'}, {['Name'] = 'Bot'}, nil
--MinionBonus
local m_Bonus
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
	--Initialize minion array
	m_Global = MomentumMinions()	
	--Initialize minion bonus class
	m_Bonus = MinionBonus()
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
				local lane = minion.name:find('L0') and m_Bot or minion.name:find('L1') and m_Mid or minion.name:find('L2') and m_Top
				AddToLane(lane, minion, i)
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

function AddToLane(tbl, minion, index)
	table.insert(tbl, #tbl+1, {['minion'] = minion, ['time'] = clock() + 10, ['bonus'] = m_Bonus:GetBonus(minion),})
	table.remove(m_Global.Objects, index)
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
		DrawText(test,GetScale(26), anchor.x+GetBarOffset(test==string.char(27) and off or off-1), anchor.y+GetScale(y-14), 0xFFFFFFFF)
	end
end

function GetDifference(lane)
	local ally, ally_Count, enemy, enemy_Count, direction = 0, 0, 0, 0, nil
	for i, info in ipairs(lane) do
		if info and info.minion and m_Global:IsValid(info.minion) and momentum_Value[info.minion.charName] then
			local MV = momentum_Value[info.minion.charName]
			if info.minion.team == myHero.team then
				if info.time < clock() then
					ally_Count = ally_Count + 1
					ally=ally+MV+(MV*info.bonus)
				else
					ally=ally+(MV * 0.25)+(MV*info.bonus)
				end
			else
				if info.time < clock() then
					enemy_Count = enemy_Count + 1
					enemy=enemy+MV+(MV*info.bonus)
				else
					enemy=enemy+(MV*0.25)+(MV*info.bonus)
				end
			end
		end
	end
	if ally_Count > 0 and enemy_Count > 0 then
		local difference = ally_Count-enemy_Count
		if difference > 4 then
			ally = ally + 2
			direction = string.char(187)
		elseif difference < -4 then
			enemy = enemy + 2
			direction = string.char(171)
		end		
	elseif ally_Count == 0 and enemy_Count > 7 then
		enemy = enemy + 2
		direction = string.char(171)
	elseif enemy_Count == 0 and ally_Count > 7 then
		ally = ally + 2
		direction = string.char(187)
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

class 'MinionBonus'

function MinionBonus:__init()
	self.Turrets = {['Top'] = {}, ['Mid'] = {}, ['Bot'] = {},}
	self.Assigned = {}
	local turretsInit = {
		['Turret_T1_C_07_A'] = 'Bot', --rito plz
		['Turret_T1_R_02_A'] = 'Bot',
		['Turret_T1_R_03_A'] = 'Bot',
		['Turret_T1_C_03_A'] = 'Mid',
		['Turret_T1_C_04_A'] = 'Mid',
		['Turret_T1_C_05_A'] = 'Mid',
		['Turret_T1_C_06_A'] = 'Top', --rito plz
		['Turret_T1_L_02_A'] = 'Top',
		['Turret_T1_L_03_A'] = 'Top',
		['Turret_T2_R_01_A'] = 'Bot',
		['Turret_T2_R_02_A'] = 'Bot',
		['Turret_T2_R_03_A'] = 'Bot',
		['Turret_T2_C_03_A'] = 'Mid',
		['Turret_T2_C_04_A'] = 'Mid',
		['Turret_T2_C_05_A'] = 'Mid',
		['Turret_T2_L_01_A'] = 'Top',
		['Turret_T2_L_02_A'] = 'Top',
		['Turret_T2_L_03_A'] = 'Top',
	}
	for i=objManager.maxObjects, 1, -1 do
		local o = objManager:getObject(i)
		if o and o.valid and o.type == 'obj_AI_Turret' and turretsInit[o.name] then
			self.Turrets[turretsInit[o.name]][#self.Turrets[turretsInit[o.name]] + 1] = o
		end
	end		
end

function MinionBonus:GetLane(minion)
	if not self.Assigned[minion.networkID] then
		self.Assigned[minion.networkID] = minion.name:find('L0') and 'Bot' or minion.name:find('L1') and 'Mid' or minion.name:find('L2') and 'Top'
	end
	return self.Assigned[minion.networkID]
end

function MinionBonus:GetLevelDifference(team)
	local AllyTotal, EnemyTotal, AllyLevels, EnemyLevels = 0, 0, 0, 0
	for i=1, heroManager.iCount do
		local h = heroManager:getHero(i)
		if h.team==team then
			AllyLevels, AllyTotal = AllyLevels + h.level, AllyTotal + 1
		else
			EnemyLevels, EnemyTotal = EnemyLevels + h.level, EnemyTotal + 1
		end
	end
	local HeroLevelDifference = (AllyTotal ~= 0 and AllyLevels / AllyTotal or 0) - (EnemyTotal ~= 0 and EnemyLevels / EnemyTotal or 0)
	return math.min(math.max(HeroLevelDifference, -3), 3)
end

function MinionBonus:GetTurretDifference(lane, team)
	local TurretDifference = 0
	for i, turret in ipairs(self.Turrets[lane]) do
		if turret.valid and not turret.dead then
			TurretDifference = TurretDifference + (turret.team == team and 1 or -1)
		end
	end
	return TurretDifference
end

function MinionBonus:GetBonus(unit) 
	local bonus = 0
	local level = self:GetLevelDifference(unit.team)
	if level ~= 0 and GetInGameTimer() > 210 then
		if level > 0 then
			local lane = self:GetLane(unit)
			if lane then
				local turret = self:GetTurretDifference(lane, unit.team)
				bonus = 0.05 + (0.05 * math.max(0, turret))
			end
		elseif unit.spell and unit.spell.target then
			local lane = self:GetLane(unit.spell.target)
			if lane then
				local turret = self:GetTurretDifference(lane, unit.spell.target.team)
				bonus = -0.05 - (0.05 * math.max(0, turret))
			end
		end
	end
	return bonus
end
