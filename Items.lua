local function Print(text)
	print('<font color=\'#0099FF\'>[Items] </font> <font color=\'#FF6600\'>'..text..'</font>')
end

if FileExist(LIB_PATH..'\\HPrediction.lua') then
	require('HPrediction')
else
	Print('HPrediction is required, please download manually.')
end	

AddLoadCallback(function() 
	ItemCast()
	ScriptUpdate_Items(1.2,
		true,
		'raw.githubusercontent.com', 
		'/PewPewPew2/BoL/master/Versions/Items.version', 
		'/PewPewPew2/BoL/master/Items.lua', 
		SCRIPT_PATH.._ENV.FILE_NAME, 
		function() Print('Download complete.') end, 
		function() Print('Loaded') end, 
		function() Print('New version found...') end,
		function() Print('Download Error') end
	)
end)
	
class 'ItemCast'

function ItemCast:__init()
	self.Prediction = HPrediction()
	self.FQQC = HPSkillshot({
		['type'] = 'DelayCircle',
		['range'] = 800,
		['delay'] = 0,
		['radius'] = 275,
		['speed'] = 1600,
	})
	self.IDS = {
		['itemmercurial'] = {  --Mercurial Scimitar(3140)
			['type'] = 'SelfCleanse',
			['range'] = 0,
		},
		['QuicksilverSash'] = {  --Quicksilver Sash(3139)
			['type'] = 'SelfCleanse', 
			['range'] = 0,
		},
		['ItemMorellosBane'] = { --Mikael's Crucible (3222)
			['type'] = 'AllyCleanse',
			['range'] = 562500,
		},
		['RegenerationPotion'] = { --(2003)
			['type'] = 'HealthPotion',
			['range'] = 0,
		},
		['ItemMiniRegenPotion'] = { --(2010)(2009)
			['type'] = 'HealthPotion',
			['range'] = 0,
		},
		['ItemCrystalFlask'] = {
			['type'] = 'HealthPotion',
			['range'] = 0,
		},
		['ItemCrystalFlaskJungle'] = {
			['type'] = 'HealthPotion',
			['range'] = 0,
		},
		['ItemDarkCrystalFlask'] = {
			['type'] = 'HealthPotion',
			['range'] = 0,
		},
		['FlaskOfCrystalWater'] = { --(2004)
			['type'] = 'ManaPotion', 
			['range'] = 0,
		},
		['ItemWraithCollar'] = { --Frost Queen's Claim(3092)
			['type'] = 'CrowdControl',
			['range'] = 722500,
		},
		['RanduinsOmen'] = { --Randuin's Omen(3143)
			['type'] = 'CrowdControl2', 
			['range'] =  202500, 
			['req'] = function() 
				return self.Menu.Randuins.Enable and self.Menu.Randuins.HitCount or 50
			end, 
		},
		--Both of these need to be reworked
		['shurelyascrest'] = { --Talisman of Ascension (3069)
			['type'] = 'Haste', 
			['range'] =  422500, 
			['req'] = function() 
				return self.Menu.ToS.Enable 
			end,
		},
		['ItemRighteousGlory'] = { --Righteous Glory(3800)
			['type'] = 'Haste',
			['range'] =  422500, 
			['req'] = function() 
				return self.Menu.RG.Enable 
			end,
		},
	}	
	self.OnAttack = {
		['ItemTiamatCleave'] = {  --Ravenous Hydra(3074)
			['type'] = 'Cleave',
			['range'] = 0, 
			['req'] = function()
				return self.Menu.RH.Enable
			end,
		},
		['ItemTiamatCleave'] = {  --Tiamat(3077)
			['type'] = 'Cleave',
			['range'] = 0, 
			['req'] = function()
				return self.Menu.Tiamat.Enable
			end,
		},
		['BilgewaterCutlass'] = {  --Bilgewater Cutlass(3144)
			['type'] = 'Target',
			['range'] = 275625, 
			['req'] = function() 
				return self.Menu.BC.Enable 
			end, 
		},
		['ItemSwordOfFeastAndFamine'] = { --Blade of the Ruined King(3153)
			['type'] = 'Target',
			['range'] = 275625,
			['req'] = function() 
				return self.Menu.BotRK.Enable and (myHero.health * 100) / myHero.maxHealth < self.Menu.BotRK.MinHP 
			end,
		},
		['HextechGunblade'] = { --Hextech Gunblade(3146)
			['type'] = 'Target',
			['range'] = 525625,
			['req'] = function() 
				return self.Menu.HG.Enable 
			end, 
		},
	}
	self.OnOrder = {
		['Muramana'] = {  --Muramana(3042)
			['type'] = 'Muramana',
			['range'] = 0, 
		},
		['ItemTitanicHydraCleave'] = { --Titanic Hydra
			['type'] = 'Cleave',
			['range'] = 0,
			['req'] = function()
				return self.Menu.TH.Enable
			end,
		},
		['YoumusBlade'] = { --Youmuus Ghostblade(3142)
			['type'] = 'Cleave',
			['range'] = 0,
			['req'] = function()
				return self.Menu.YG.Enable
			end,
		},
		['ElixirOfIron'] = { --Elixir Of Iron(2138)
			['type'] = 'Cleave', 
			['range'] = 0, 
			['req'] = function()
				return self.Menu.Elixers.Enable
			end,
		},
		['ElixirOfRuin'] = {  --Elixir Of Ruin(2137)
			['type'] = 'Cleave',
			['range'] = 0, 
			['req'] = function()
				return self.Menu.Elixers.Enable
			end,
		},
		['ElixirOfSorcery'] = { --Elixir Of Sorcery(2139)
			['type'] = 'Cleave',
			['range'] = 0, 
			['req'] = function()
				return self.Menu.Elixers.Enable
			end,
		},
		['ElixirOfWrath'] = {  --Elixir Of Wrath(2140)	
			['type'] = 'Cleave',
			['range'] = 0, 
			['req'] = function()
				return self.Menu.Elixers.Enable
			end,
		},	
	}
	self.HPBuffs = {
		['ItemCrystalFlask'] = true,
		['ItemCrystalFlaskJungle'] = true,
		['ItemDarkCrystalFlask'] = true,
		['RegenerationPotion'] = true,
		['ItemMiniRegenPotion'] = true,
	}	
	self.HardCC = { [5] = 'Stun', [11] = 'Root', [24] = 'Suppress', }
	self.SoftCC = { [8] = 'Taunt', [10] = 'Slow', [21] = 'Fear', [22] = 'Charm', }
	self.ALLY = myHero.team
	self.ENEMY = self.ALLY == 100 and 200 or 100
	self.MyBuffs = {}
	self.Allies = {}
	self.Enemies = {}
	self.Items = {}
	for i=1, heroManager.iCount do
		local hero = heroManager:getHero(i)
		if hero and hero.valid then
			if hero.team == self.ALLY then
				if not hero.isMe then	
					self.Allies[#self.Allies + 1] = { ['Hero'] = hero, ['Buffs'] = {}, }
				end
			else
				self.Enemies[#self.Enemies + 1] = { ['Hero'] = hero, ['Buffs'] = {}, }	
			end
		end
	end
	self:CreateMenu()
	AddApplyBuffCallback(function(source, unit, buff) self:ApplyBuff(source, unit, buff) end)
	AddRemoveBuffCallback(function(unit, buff) self:RemoveBuff(unit, buff) end)
	AddTickCallback(function() self:Tick() end)
	AddProcessSpellCallback(function(unit,spell) self:ProcessSpell(unit, spell) end)
	AddIssueOrderCallback(function(sPos, order, ePos, target) self:IssueOrder(sPos, order, ePos, target) end)
	AddCastSpellCallback(function(iSlot,startPos,endPos,target) self:CastSpell(iSlot,startPos,endPos,target) end)

end

function ItemCast:AllyCleanse(slot, info)
	if self.Menu.MC.Enable then
		for _, ally in ipairs(self.Allies) do
			if not ally.Hero.dead and ally.Hero.health < 1750 and GetDistanceSqr(ally.Hero) < info.range then
				for i, buff in ipairs(self.Allies[_].Buffs) do
					if self.HardCC[buff.type] and self.Menu.MC.Hard and buff.endTime > GetGameTimer() and buff.startTime + (self.Menu.MC.Humanizer / 1000) < GetGameTimer() then
						CastSpell(slot, ally.Hero)
						return
					elseif self.SoftCC[buff.type] and self.Menu.MC.Soft and buff.endTime > GetGameTimer()and buff.startTime + (self.Menu.MC.Humanizer / 1000) < GetGameTimer() then
						CastSpell(slot, ally.Hero)
						return
					end
				end
				if ((ally.Hero.health * 100) / ally.Hero.maxHealth) < self.Menu.MC.Health and self:EnemyInRange(ally.Hero) then
					CastSpell(slot, ally.Hero)
					return
				end
			end
		end
		for i, buff in ipairs(self.MyBuffs) do
			if buff.type == 11 and self.Menu.MC.Hard and buff.endTime > GetGameTimer() and buff.startTime + (self.Menu.MC.Humanizer / 1000) < GetGameTimer() then
				CastSpell(slot, myHero)
			end
		end
		if ((myHero.health * 100) / myHero.maxHealth) < self.Menu.MC.Health and self:EnemyInRange(myHero) then
			CastSpell(slot, myHero)
		end
	end
end

function ItemCast:ApplyBuff(source, unit, buff)
	if unit.valid and unit.type == 'AIHeroClient' then
		if unit.isMe then
			table.insert(self.MyBuffs, #self.MyBuffs + 1, {
				['name'] = buff.name,
				['type'] = buff.type,
				['endTime'] = buff.endTime+ GetGameTimer(),
				['startTime'] = buff.startTime,
			})
			if buff.name == 'Muramana' then
				self.MuramanaToggled = true
			end
			return
		end
		if unit.team == self.ALLY then
			for i, ally in ipairs(self.Allies) do
				if ally.Hero.networkID == unit.networkID then
					table.insert(self.Allies[i].Buffs, #self.Allies[i].Buffs + 1, {
						['name'] = buff.name,
						['type'] = buff.type,
						['endTime'] = buff.endTime,
						['startTime'] = buff.startTime,
					})
					return		
				end
			end
		else
			for i, enemy in ipairs(self.Enemies) do
				if enemy.Hero.networkID == unit.networkID then
					table.insert(self.Enemies[i].Buffs, #self.Enemies[i].Buffs + 1, {
						['name'] = buff.name,
						['type'] = buff.type,
						['endTime'] = buff.endTime,
						['startTime'] = buff.startTime,
					})
					return	
				end
			end		
		end
	end
end

function ItemCast:CastSpell(iSlot,startPos,endPos,target)
	if self.Menu.Muramana.Enable then
		if target then
			if target.type == 'AIHeroClient' and target.team ~= myHero.team then
				for i=ITEM_1, ITEM_6 do
					local Item = self.Items[i]
					if Item and Item == 'Muramana' then
						if not self.MuramanaToggled then
							CastSpell(i)
						end
					end
				end	
			else
				for i=ITEM_1, ITEM_6 do
					local Item = self.Items[i]
					if Item and Item == 'Muramana' then
						if self.MuramanaToggled then
							CastSpell(i)
						end
					end
				end					
			end
		else
			if self.Menu.Key then
				for i=ITEM_1, ITEM_6 do
					local Item = self.Items[i]
					if Item and Item == 'Muramana' then
						if not self.MuramanaToggled then
							CastSpell(i)
						end
					end
				end				
			else
				for i=ITEM_1, ITEM_6 do
					local Item = self.Items[i]
					if Item and Item == 'Muramana' then
						if self.MuramanaToggled then
							CastSpell(i)
						end
					end
				end	
			end
		end
	end
end

function ItemCast:Cleave(slot, target, info)
	if not self.CleaveTick then
		AddTickCallback(function()
			for i, slot in ipairs(self.CleaveTick) do
				if myHero:CanUseSpell(slot) ~= READY then
					table.remove(self.CleaveTick, i)
				elseif not myHero.isWindingUp then
					CastSpell(slot)
				end
			end
		end)
		self.CleaveTick = {}
	end
	if self.Menu.Key and info.req() and target.type == 'AIHeroClient' and myHero:CanUseSpell(slot) == READY then
		self.CleaveTick[#self.CleaveTick + 1] = slot
	end
end

function ItemCast:CreateMenu()
	self.Menu = scriptConfig('Items', 'Items')
	self.Menu:addParam('Key', 'AutoCarry Key', SCRIPT_PARAM_ONKEYTOGGLE, false, 32)
	self.Menu:addParam('info', '***Any Item Marked with (K), requires.', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('info', '***the hotkey to be active.', SCRIPT_PARAM_INFO, '')
	self.Menu:addSubMenu('Bilgewater Cutlass (K)', 'BC')
		self.Menu.BC:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addSubMenu('Blade of the Ruined King (K)', 'BotRK')
		self.Menu.BotRK:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
		self.Menu.BotRK:addParam('MinHP', 'Minimum myHero HP (%)', SCRIPT_PARAM_SLICE, 50, 10, 100)
	self.Menu:addSubMenu('Elixers (K)', 'Elixers')
		self.Menu.Elixers:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addSubMenu('Frost Queens Claim (K)', 'FQC')
		self.Menu.FQC:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
		self.Menu.FQC:addParam('HitChance', 'Hit Probability(%)', SCRIPT_PARAM_SLICE, 80, 50, 100)
	self.Menu:addSubMenu('Health Potions', 'HP')
		self.Menu.HP:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
		self.Menu.HP:addParam('Level1', 'Disable at Level 1', SCRIPT_PARAM_ONOFF, true)
		self.Menu.HP:addParam('Health', 'Minimum Health Percent', SCRIPT_PARAM_SLICE, 40, 0, 100, 5)
	self.Menu:addSubMenu('Hextech Gunblade (K)', 'HG')
		self.Menu.HG:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addSubMenu('Mana Potions', 'MP')
		self.Menu.MP:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
		self.Menu.MP:addParam('Level1', 'Disable at Level 1', SCRIPT_PARAM_ONOFF, true)
		self.Menu.MP:addParam('Mana', 'Minimum Mana Percent', SCRIPT_PARAM_SLICE, 20, 0, 100, 5)
	self.Menu:addSubMenu('Mikaels Crucible', 'MC')
		self.Menu.MC:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
		self.Menu.MC:addParam('Hard', 'Hard CC', SCRIPT_PARAM_ONOFF, true)
		self.Menu.MC:addParam('Soft', 'Soft CC', SCRIPT_PARAM_ONOFF, false)
		self.Menu.MC:addParam('Humanizer', 'Humanizing Delay (ms)', SCRIPT_PARAM_SLICE, 0, 0, 500)
		self.Menu.MC:addParam('Health', 'Life Save (%)', SCRIPT_PARAM_SLICE, 20, 0, 100)
	self.Menu:addSubMenu('Muramana (K)', 'Muramana')
		self.Menu.Muramana:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addSubMenu('Quicksilver Sash & Mercurial Scimitar', 'QSS')
		self.Menu.QSS:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
		self.Menu.QSS:addParam('Hard', 'Hard CC', SCRIPT_PARAM_ONOFF, true)
		self.Menu.QSS:addParam('Soft', 'Soft CC', SCRIPT_PARAM_ONOFF, false)
		self.Menu.QSS:addParam('Humanizer', 'Humanizing Delay (ms)', SCRIPT_PARAM_SLICE, 0, 0, 500)
		self.Menu.QSS:addParam('ZedR', 'Zed Ultimate', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addSubMenu('Randuins Omen (K)', 'Randuins')
		self.Menu.Randuins:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Randuins:addParam('HitCount', 'Hit Count', SCRIPT_PARAM_SLICE, 1, 1, 5)
	self.Menu:addSubMenu('Ravenous Hydra (K)', 'RH')
		self.Menu.RH:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addSubMenu('Righteous Glory (K)', 'RG')
		self.Menu.RG:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
		self.Menu.RG:addParam('info', 'Coming Soon.', SCRIPT_PARAM_INFO, '')
	self.Menu:addSubMenu('Talisman of Ascension (K)', 'ToS')
		self.Menu.ToS:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
		self.Menu.ToS:addParam('info', 'Coming Soon.', SCRIPT_PARAM_INFO, '')
	self.Menu:addSubMenu('Tiamat (K)', 'Tiamat')
		self.Menu.Tiamat:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addSubMenu('Titanic Hydra (K)', 'TH')
		self.Menu.TH:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addSubMenu('Twin Shadows (K)', 'TS')
		self.Menu.TS:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
		self.Menu.TS:addParam('HitCount', 'Hit Count', SCRIPT_PARAM_SLICE, 2, 1, 2)
	self.Menu:addSubMenu('Youmuus Ghostblade (K)', 'YG')
		self.Menu.YG:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
end

function ItemCast:CrowdControl(slot, info)
	if self.Menu.FQC.Enable then
		for _, enemy in ipairs(self.Enemies) do
			if not enemy.Hero.dead and enemy.Hero.visible and GetDistanceSqr(enemy.Hero) < info.range then
				local bValid = true
				for i, buff in ipairs(self.Enemies[_].Buffs) do
					if (self.HardCC[buff.name] or self.SoftCC[buff.name]) and buff.endTime > GetGameTimer() then
						bValid = false
					end
				end
				if bValid then
					local CastPos, HitChance = self.Prediction:GetPredict(self.FQQC, enemy.Hero, myHero)
					if CastPos and HitChance > (self.Menu.FQC.HitChance / 33.4) then
						CastSpell(slot, CastPos.x, CastPos.z)
					end
					return
				end
			end
		end
	end
end

function ItemCast:CrowdControl2(slot, info)
	if self.Menu.Key then
		local count = 0
		for i, enemy in ipairs(self.Enemies) do
			if enemy.Hero.visible and not enemy.Hero.dead and GetDistanceSqr(enemy.Hero) < info.range then
				count = count + 1
			end
		end
		if count >= info.req() then
			CastSpell(slot)
		end
	end
end

function ItemCast:EnemyInRange(from)
	for i, enemy in ipairs(self.Enemies) do
		if enemy.Hero.visible and not enemy.Hero.dead and GetDistanceSqr(enemy.Hero, from) < 490000 then
			return true
		end
	end
	return false
end

function ItemCast:Haste(slot, info)
	if self.Menu.Key and info.req() then
		local allyCount, enemyCount = 1, 0
		for i, ally in ipairs(self.Allies) do
			if not ally.Hero.dead and GetDistanceSqr(ally.Hero) < info.range then
				allyCount = allyCount + 1
			end
		end
		for i, enemy in ipairs(self.Enemies) do
			if enemy.Hero.visible and not enemy.Hero.dead and GetDistanceSqr(enemy.Hero) < info.range then
				enemyCount = enemyCount + 1
			end
		end
		if enemyCount >= 2 and allyCount >= 2 then
			CastSpell(slot)
		end
	end
end

function ItemCast:HealthPotion(slot)
	if self.Menu.HP.Enable then
		if self.Menu.HP.Level1 and myHero.level == 1 then return end
		if ((myHero.health * 100) / myHero.maxHealth) < self.Menu.HP.Health then
			for i, buff in ipairs(self.MyBuffs) do
				if self.HPBuffs[buff.name] and buff.endTime > GetGameTimer() then
					return
				end
			end
			if self:EnemyInRange(myHero) then
				CastSpell(slot)
			end
		end
	end
end

function ItemCast:ProcessSpell(unit, spell)
	if unit.valid and unit.isMe and spell.name:find('Attack') and spell.target then
		for i=ITEM_1, ITEM_6 do
			local Item = self.Items[i]
			if Item and self.OnAttack[Item] then
				self[self.OnAttack[Item].type](self, i, spell.target, self.OnAttack[Item])
			end
		end
	end
end

function ItemCast:IssueOrder(sPos, order, ePos, target)
	if order == 3 and target and target.valid and GetDistance(target) < (myHero.range + myHero.boundingRadius + 150) then
		for i=ITEM_1, ITEM_6 do
			local Item = self.Items[i]
			if Item and self.OnOrder[Item] then
				self[self.OnOrder[Item].type](self, i, target, self.OnOrder[Item])
			end
		end
	end
end

function ItemCast:ManaPotion(slot)
	if self.Menu.MP.Enable then
		if self.Menu.MP.Level1 and myHero.level == 1 then return end
		if ((myHero.mana * 100) / myHero.maxMana) < self.Menu.MP.Mana then
			for i, buff in ipairs(self.MyBuffs) do
				if buff.name == 'FlaskOfCrystalWater' and buff.endTime > GetGameTimer() then
					return
				end
			end
			if self:EnemyInRange(myHero) then
				CastSpell(slot)
			end
		end
	end
end

function ItemCast:Muramana(slot, target)
	if self.Menu.Muramana.Enable then
		if self.Menu.Key then
			if target.type == 'AIHeroClient' then
				if not self.MuramanaToggled then
					CastSpell(slot)
				end
			elseif self.MuramanaToggled then
				CastSpell(slot)
			end
		elseif self.MuramanaToggled then
			CastSpell(slot)
		end
	end
end

function ItemCast:Promote(slot, info)
	if not self.Cannons then
		self.Cannons = {}
		AddCreateObjCallback(function(o)
			if o.valid and o.type == 'obj_AI_Minion' and o.team == self.ALLY and (o.charName == 'SRU_OrderMinionSiege' or o.charName == 'SRU_ChaosMinionSiege') then
				self.Cannons[#self.Cannons + 1] = o
			end
		end)
	end
	for i, cannon in ipairs(self.Cannons) do
		if cannon.valid and not cannon.dead then
			if GetDistanceSqr(cannon) < info.range then
				CastSpell(slot, cannon)
				return
			end
		else
			table.remove(self.Cannons, i)
		end
	end
end

function ItemCast:RemoveBuff(unit, buff)
	if unit.valid and unit.type == 'AIHeroClient' then
		if unit.isMe then
			if buff.name == 'Muramana' then
				self.MuramanaToggled = false
			end	
			for i, b in ipairs(self.MyBuffs) do
				if b.name == buff.name then
					table.remove(self.MyBuffs, i)
					return
				end
			end	
			return
		end	
		if unit.team == self.ALLY then
			for _, ally in ipairs(self.Allies) do
				if ally.Hero.networkID == unit.networkID then
					for i, b in ipairs(self.Allies[_].Buffs) do
						if b.name == buff.name then
							table.remove(self.Allies[_].Buffs, i)
							return
						end
					end
				end
			end
		else
			for _, ally in ipairs(self.Enemies) do
				if ally.Hero.networkID == unit.networkID then
					for i, b in ipairs(self.Enemies[_].Buffs) do
						if b.name == buff.name then
							table.remove(self.Enemies[_].Buffs, i)
							return
						end
					end
				end
			end	
		end
	end
end

function ItemCast:SelfCleanse(slot, info)
	if self.Menu.QSS.Enable then
		for i, buff in ipairs(self.MyBuffs) do
			if self.HardCC[buff.type] and self.Menu.QSS.Hard and buff.endTime > GetGameTimer() and buff.startTime + (self.Menu.QSS.Humanizer / 1000) < GetGameTimer()  then
				CastSpell(slot)
				return
			elseif self.SoftCC[buff.type] and self.Menu.QSS.Soft and buff.endTime > GetGameTimer() and buff.startTime + (self.Menu.QSS.Humanizer / 1000) < GetGameTimer() then
				CastSpell(slot)
				return
			elseif buff.name == 'zedultexecute' and self.Menu.QSS.ZedR and buff.startTime + (self.Menu.QSS.Humanizer / 1000) < GetGameTimer() then
				CastSpell(slot)
				return
			end
		end
	end
end

function ItemCast:Target(slot, target, info)
	if self.Menu.Key and target.type == 'AIHeroClient' and myHero:CanUseSpell(slot) == READY and info.req() then
		CastSpell(slot, target)
	end
end

function ItemCast:Tick()
	for i=ITEM_1, ITEM_6 do
		local Item = myHero:GetSpellData(i)
		if Item and Item.name then
			self.Items[i] = Item.name
			if self.IDS[Item.name] and myHero:CanUseSpell(i) == READY then
				self[self.IDS[Item.name].type](self, i, self.IDS[Item.name])
			end
		end
	end
end

class "ScriptUpdate_Items"
function ScriptUpdate_Items:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
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

function ScriptUpdate_Items:print(str)
    print('<font color="#FFFFFF">'..os.clock()..': '..str)
end

function ScriptUpdate_Items:OnDraw()
    if self.DownloadStatus ~= 'Downloading Script (100%)' and self.DownloadStatus ~= 'Downloading VersionInfo (100%)'then
        DrawText('Download Status: '..(self.DownloadStatus or 'Unknown'),50,10,50,ARGB(0xFF,0xFF,0xFF,0xFF))
    end
end

function ScriptUpdate_Items:CreateSocket(url)
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

function ScriptUpdate_Items:Base64Encode(data)
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

function ScriptUpdate_Items:GetOnlineVersion()
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

function ScriptUpdate_Items:DownloadUpdate()
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
