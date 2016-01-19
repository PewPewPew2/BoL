if myHero:GetSpellData(SUMMONER_1).name:find('smite') == nil and myHero:GetSpellData(SUMMONER_2).name:find('smite') == nil then return end

AddLoadCallback(function()
	SmiteCore()
end)

class 'SmiteCore'

function SmiteCore:__init()
	self.Mobs = SmiteMinions()
	self.Slot = myHero:GetSpellData(SUMMONER_1).name:find('smite') and SUMMONER_1 or SUMMONER_2
	self.LastClick = 0
	self.DamageTable = {390,410,430,450,480,510,540,570,600,640,680,720,760,800,850,900,950,1000,}
	self.Offsets = {
		['SRU_Blue'] 		= {['x'] = -72, ['y'] =  2, ['h'] = 9,  ['w'] = 144,},
		['SRU_Gromp']		= {['x'] = -44, ['y'] =  1, ['h'] = 4,  ['w'] = 90, },
		['SRU_Murkwolf'] 	= {['x'] = -38, ['y'] =  1, ['h'] = 4,  ['w'] = 78, },
		['Sru_Crab'] 		= {['x'] = -32, ['y'] = -6, ['h'] = 4,  ['w'] = 66, },
		['SRU_Razorbeak']	= {['x'] = -38, ['y'] =  1, ['h'] = 4,  ['w'] = 78, },
		['SRU_Red'] 		= {['x'] = -72, ['y'] =  2, ['h'] = 9,  ['w'] = 144,},
		['SRU_Krug'] 		= {['x'] = -41, ['y'] =  1, ['h'] = 4,  ['w'] = 84, },
		['SRU_Dragon'] 		= {['x'] = -72, ['y'] =  2, ['h'] = 9,  ['w'] = 144,},
		['SRU_RiftHerald'] 	= {['x'] = -72, ['y'] =  2, ['h'] = 9,  ['w'] = 144,},
		['SRU_Baron'] 		= {['x'] = -96, ['y'] =  1, ['h'] = 12, ['w'] = 192,},
	}
	self.White = ARGB(120,255,255,255)
	self.Menu = scriptConfig('Smiterino', 'Smite1234')
	for name, _ in pairs(self.Offsets) do
		self.Menu:addParam(name:gsub('_', ''), name:gsub('SRU_', ''):gsub('Sru_', ''), SCRIPT_PARAM_ONOFF, true)
	end
	self.Menu:addParam('space', '', SCRIPT_PARAM_INFO, '') 
	self.Menu:addParam('space', 'Double Click a Jungle Minion', SCRIPT_PARAM_INFO, '') 
	self.Menu:addParam('space', 'to enable/disable smite.', SCRIPT_PARAM_INFO, '') 
	AddTickCallback(function()
		if myHero:CanUseSpell(self.Slot) == READY then
			for i, mob in ipairs(self.Mobs.Objects) do
				if self:IsValid(mob) and self.Menu[mob.charName:gsub('_', '')] and mob.health < self:Damage() then
					if GetDistance(mob) < (500 + myHero.boundingRadius + mob.boundingRadius) then
						CastSpell(self.Slot, mob)
						return
					end
				end
			end
		end
	end)
	AddDrawCallback(function()
		for i, mob in ipairs(self.Mobs.Objects) do
			if self:IsValid(mob) and self.Menu[mob.charName:gsub('_', '')] then
				local HPBar = GetUnitHPBarPos(mob)
				if HPBar.x > -100 and HPBar.x < WINDOW_W + 100 and HPBar.y > -100 and HPBar.y < WINDOW_H + 100 then
					local x, y = math.floor(HPBar.x) + self.Offsets[mob.charName].x, math.floor(HPBar.y) + self.Offsets[mob.charName].y
					DrawLine(x, y, x+((self:Damage()/mob.maxHealth)*self.Offsets[mob.charName].w), y, self.Offsets[mob.charName].h, self.White)
				end				
			end
		end
	end)
	AddMsgCallback(function(m,k)
		if m==514 then
			if self.LastClick > os.clock() then
				for i, mob in ipairs(self.Mobs.Objects) do
					if self:IsValid(mob) and GetDistanceSqr(mob, mousePos) < 22500 then
						self.Menu[mob.charName:gsub('_', '')] = not self.Menu[mob.charName:gsub('_', '')]
					end
				end
			end
			self.LastClick = os.clock() + 0.25
		end
	end)
end

function SmiteCore:IsValid(mob)
	return mob and mob.valid and mob.visible and not mob.dead and mob.bTargetable and self.Mobs.AreValid[mob.charName]
end

function SmiteCore:Damage()
	return self.DamageTable[myHero.level]
end

class 'SmiteMinions'

function SmiteMinions:__init()
	self.Objects = {}
	for i = 0, objManager.maxObjects do
		if self:IsValid(objManager:getObject(i)) then
			table.insert(self.Objects, objManager:getObject(i))
		end
	end
	self.AreValid = {
		['SRU_Blue']  = true,
		['SRU_Gromp']  = true,
		['SRU_Murkwolf'] = true,
		['Sru_Crab']  = true,
		['SRU_Razorbeak']  = true,
		['SRU_Red']  = true,
		['SRU_Krug']  = true,
		['SRU_Dragon']  = true,
		['SRU_RiftHerald']  = true,
		['SRU_Baron']  = true,
	}
	AddTickCallback(function() self:Tick() end)
	AddCreateObjCallback(function(o) self:CreateObj(o) end)
	AddDeleteObjCallback(function(o) self:DeleteObj(o) end)
	return self
end

function SmiteMinions:IsValid(o)
	return o and o.valid and not o.dead and o.type == 'obj_AI_Minion' and o.team == 300
end

function SmiteMinions:IsValid2(charName)
	return self.AreValid[charName]
end

function SmiteMinions:Tick()
	for i=#self.Objects, 1, -1 do
		local o = self.Objects[i]
		if not self:IsValid(o) or not self:IsValid2(o.charName) then
			table.remove(self.Objects, i)
		end
	end
end

function SmiteMinions:CreateObj(o)
	if self:IsValid(o) then
		table.insert(self.Objects, #self.Objects + 1, o)
	end
end

function SmiteMinions:DeleteObj(o)
	if o.valid then
		for i, m in ipairs(self.Objects) do
			if m.networkID == o.networkID then
				table.remove(self.Objects, i)
				return
			end
		end
	end
end
