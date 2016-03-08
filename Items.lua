local function Print(text)
	print('<font color=\'#0099FF\'>[Items] </font> <font color=\'#FF6600\'>'..text..'</font>')
end

AddLoadCallback(function() 
	ItemCast()
	ScriptUpdate_Items(1.4,
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
	self.Defensive = {
		[3140] = { --Mercurial Scimitar (itemmercurial)
			['type'] = 'SelfCleanse',
			['range'] = 0,
		},
		[3139] = { --Quicksilver Sash (QuicksilverSash)
			['type'] = 'SelfCleanse', 
			['range'] = 0,
		},
		[3222] = { --Mikael's Crucible (ItemMorellosBane)
			['type'] = 'AllyCleanse',
			['range'] = 562500,
		},
		[2003] = { --(RegenerationPotion)
			['type'] = 'HealthPotion',
			['range'] = 0,
		},
		[2009] = { --(ItemMiniRegenPotion)
			['type'] = 'HealthPotion',
			['range'] = 0,
		},
		[2010] = { --(ItemMiniRegenPotion)
			['type'] = 'HealthPotion',
			['range'] = 0,
		},
		[2031] = { --Refillable Potion (ItemCrystalFlask)
			['type'] = 'HealthPotion',
			['range'] = 0,
		},
		[2032] = { --Hunters Potion (ItemCrystalFlaskJungle)
			['type'] = 'HealthPotion',
			['range'] = 0,
		},
		[2033] = { --Corrupting Potion (ItemDarkCrystalFlask)
			['type'] = 'HealthPotion',
			['range'] = 0,
		},
		[2004] = { --Mana Potion(FlaskOfCrystalWater)
			['type'] = 'ManaPotion', 
			['range'] = 0,
		},
		[3143] = { --Randuin's Omen (RanduinsOmen)
			['type'] = 'CrowdControl2', 
			['range'] =  202500, 
			['req'] = function() 
				return self.Menu.Offence.Randuins.Enable and self.Menu.Offence.Randuins.HitCount or 50
			end, 
		},
		[3069] = { --Talisman of Ascension (shurelyascrest)
			['type'] = 'Haste', 
			['range'] =  422500, 
			['req'] = function() 
				return self.Menu.Offence.ToS.Enable 
			end,
		},
	}	
	self.Offensive = {
		[3074] = { --Ravenous Hydra (ItemTiamatCleave)
			['type'] = 'Cleave',
			['range'] = 0, 
			['req'] = function()
				return self.Menu.Offence.RH.Enable
			end,
		},
		[3748] = { --Titanic Hydra (ItemTitanicHydraCleave)
			['type'] = 'Cleave',
			['range'] = 0,
			['req'] = function()
				return self.Menu.Offence.TH.Enable
			end,
		},
		[3077] = { --Tiamat (ItemTiamatCleave)
			['type'] = 'Cleave',
			['range'] = 0, 
			['req'] = function()
				return self.Menu.Offence.Tiamat.Enable
			end,
		},
		[3144] = { --Bilgewater Cutlass (BilgewaterCutlass)
			['type'] = 'Target',
			['range'] = 275625, 
			['req'] = function(t) 
				return self.Menu.Offence.BC.Enable and self.Menu.Offence.BC.MaxHP *.01 > t.health / t.maxHealth
			end, 
		},
		[3153] = { --Blade of the Ruined King (ItemSwordOfFeastAndFamine)
			['type'] = 'Target',
			['range'] = 275625,
			['req'] = function() 
				return self.Menu.Offence.BotRK.Enable and myHero.health / myHero.maxHealth < self.Menu.Offence.BotRK.MinHP * .01
			end,
		},
		[3146] = { --Hextech Gunblade(HextechGunblade)
			['type'] = 'Target',
			['range'] = 525625,
			['req'] = function(t) 
				return self.Menu.Offence.HG.Enable and self.Menu.Offence.HG.MaxHP *.01 > t.health / t.maxHealth 
			end, 
		},
		[3142] = { --Youmuus Ghostblade (YoumusBlade)
			['type'] = 'Cleave',
			['range'] = 0,
			['req'] = function(t)
				return self.Menu.Offence.YG.Enable and self.Menu.Offence.YG.MaxHP *.01 > t.health / t.maxHealth
			end,
		},
		[2138] = { --Elixir Of Iron (ElixirOfIron)
			['type'] = 'Cleave', 
			['range'] = 0, 
			['req'] = function()
				return self.Menu.Offence.Elixers.Enable
			end,
		},
		[2137] = { --Elixir Of Ruin (ElixirOfRuin)
			['type'] = 'Cleave',
			['range'] = 0, 
			['req'] = function()
				return self.Menu.Offence.Elixers.Enable
			end,
		},
		[2139] = { --Elixir Of Sorcery (ElixirOfSorcery)
			['type'] = 'Cleave',
			['range'] = 0, 
			['req'] = function()
				return self.Menu.Offence.Elixers.Enable
			end,
		},
		[2140] = { --Elixir Of Wrath (ElixirOfWrath)	
			['type'] = 'Cleave',
			['range'] = 0, 
			['req'] = function()
				return self.Menu.Offence.Elixers.Enable
			end,
		},	
	}
	self.HPBuffs = {
		['itemcrystalflask'] = true,
		['itemcrystalflaskjungle'] = true,
		['itemdarkcrystalflask'] = true,
		['regenerationpotion'] = true,
		['itemminiregenpotion'] = true,
	}	
	self.HardCC = { [5] = 'Stun', [11] = 'Root', [24] = 'Suppress',  [8] = 'Taunt', [22] = 'Charm', }
	self.SoftCC = {[10] = 'Slow', [21] = 'Fear',}
	self.ALLY = myHero.team
	self.ENEMY = 300 - self.ALLY
	self.Buffs = {}
	self.Allies = {}
	self.Enemies = {}
	self.Items = {}
	for i=1, heroManager.iCount do
		local hero = heroManager:getHero(i)
		if hero and hero.valid then
			self.Buffs[hero.networkID] = {}
			if hero.team == self.ENEMY then
				self.Enemies[#self.Enemies + 1] = hero
			elseif not hero.isMe then
				self.Allies[#self.Allies + 1] = hero
			end
		end
	end
	
	self:CreateMenu()
	AddApplyBuffCallback(function(source, unit, buff) self:ApplyBuff(source, unit, buff) end)
	AddRemoveBuffCallback(function(unit, buff) self:RemoveBuff(unit, buff) end)
	AddTickCallback(function() self:Tick() end)
	AddProcessAttackCallback(function(unit,attack) self:ProcessAttack(unit, attack) end)
end

function ItemCast:AllyCleanse(slot, info)
	local GT = GetGameTimer()
	if self.Menu.Defence.MC.Enable then
		for _, ally in ipairs(self.Allies) do
			if not ally.dead and ally.health < 1750 and GetDistanceSqr(ally) < info.range then
				for i, buff in ipairs(self.Buffs[ally.networkID]) do
					if self.HardCC[buff.type] and self.Menu.Defence.MC.Hard and buff.endTime > GT and buff.startTime + (self.Menu.Defence.MC.Humanizer * .001) < GT then
						CastSpell(slot, ally)
						return
					elseif self.SoftCC[buff.type] and self.Menu.Defence.MC.Soft and buff.endTime > GT and buff.startTime + (self.Menu.Defence.MC.Humanizer * .001) < GT then
						CastSpell(slot, ally)
						return
					end
				end
				if ally.health / ally.maxHealth < self.Menu.Defence.MC.Health * .01 and self:EnemyInRange(ally) then
					CastSpell(slot, ally)
					return
				end
			end
		end
		for i, buff in ipairs(self.Buffs[myHero.networkID]) do
			if buff.type == 11 and self.Menu.Defence.MC.Hard and buff.endTime > GT and buff.startTime + (self.Menu.Defence.MC.Humanizer * .001) < GT then
				CastSpell(slot, myHero)
			end
		end
		if myHero.health / myHero.maxHealth < self.Menu.Defence.MC.Health * .01 and self:EnemyInRange(myHero) then
			CastSpell(slot, myHero)
		end
	end
end

function ItemCast:ApplyBuff(source, unit, buff)
	if unit and unit.valid and unit.type == 'AIHeroClient' then
		table.insert(self.Buffs[unit.networkID], #self.Buffs[unit.networkID] + 1,{
				['name'] = buff.name:lower(),
				['type'] = buff.type,
				['endTime'] = buff.endTime,
				['startTime'] = buff.startTime,
		})
	end
end

function ItemCast:Cleave(slot, target, info)
	if self.Menu.Offence.Key and info.req(target) and target.type == 'AIHeroClient' and myHero:CanUseSpell(slot) == READY then
		CastSpell(slot)
	end
end

function ItemCast:CreateMenu()
	self.Menu = scriptConfig('Items', 'Items')	
	self.Menu:addSubMenu('Offensive Items', 'Offence')
		self.Menu.Offence:addSubMenu('Bilgewater Cutlass', 'BC')
			self.Menu.Offence.BC:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
			self.Menu.Offence.BC:addParam('MaxHP', 'Maximum Target HP (%)', SCRIPT_PARAM_SLICE, 50, 10, 100)
		self.Menu.Offence:addSubMenu('Blade of the Ruined King', 'BotRK')
			self.Menu.Offence.BotRK:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
			self.Menu.Offence.BotRK:addParam('MinHP', 'Minimum myHero HP (%)', SCRIPT_PARAM_SLICE, 50, 10, 100)
		self.Menu.Offence:addSubMenu('Elixers', 'Elixers')
			self.Menu.Offence.Elixers:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Offence:addSubMenu('Hextech Gunblade', 'HG')
			self.Menu.Offence.HG:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
			self.Menu.Offence.HG:addParam('MaxHP', 'Maximum Target HP (%)', SCRIPT_PARAM_SLICE, 50, 10, 100)
		self.Menu.Offence:addSubMenu('Randuins Omen', 'Randuins')
			self.Menu.Offence.Randuins:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
			self.Menu.Offence.Randuins:addParam('HitCount', 'Hit Count', SCRIPT_PARAM_SLICE, 1, 1, 5)
		self.Menu.Offence:addSubMenu('Talisman of Ascension', 'ToS')
			self.Menu.Offence.ToS:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Offence:addSubMenu('Tiamat', 'Tiamat')
			self.Menu.Offence.Tiamat:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Offence:addSubMenu('Titanic Hydra', 'TH')
			self.Menu.Offence.TH:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Offence:addSubMenu('Ravenous Hydra', 'RH')
			self.Menu.Offence.RH:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
		self.Menu.Offence:addSubMenu('Youmuus Ghostblade', 'YG')
			self.Menu.Offence.YG:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
			self.Menu.Offence.YG:addParam('MaxHP', 'Maximum Target HP (%)', SCRIPT_PARAM_SLICE, 50, 10, 100)
		self.Menu.Offence:addParam('space', '', SCRIPT_PARAM_INFO, '')
		self.Menu.Offence:addParam('space', '', SCRIPT_PARAM_INFO, '')
		self.Menu.Offence:addParam('Key', 'AutoCarry Key', SCRIPT_PARAM_ONKEYTOGGLE, false, 32)

	self.Menu:addSubMenu('Defensive Items', 'Defence')
		self.Menu.Defence:addSubMenu('Health Potions', 'HP')
			self.Menu.Defence.HP:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
			self.Menu.Defence.HP:addParam('Level1', 'Disable at Level 1', SCRIPT_PARAM_ONOFF, true)
			self.Menu.Defence.HP:addParam('Health', 'Minimum Health Percent', SCRIPT_PARAM_SLICE, 40, 0, 100, 5)
		self.Menu.Defence:addSubMenu('Mana Potions', 'MP')
			self.Menu.Defence.MP:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
			self.Menu.Defence.MP:addParam('Level1', 'Disable at Level 1', SCRIPT_PARAM_ONOFF, true)
			self.Menu.Defence.MP:addParam('Mana', 'Minimum Mana Percent', SCRIPT_PARAM_SLICE, 20, 0, 100, 5)
		self.Menu.Defence:addSubMenu('Mikaels Crucible', 'MC')
			self.Menu.Defence.MC:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
			self.Menu.Defence.MC:addParam('Hard', 'Hard CC', SCRIPT_PARAM_ONOFF, true)
			self.Menu.Defence.MC:addParam('Soft', 'Soft CC', SCRIPT_PARAM_ONOFF, false)
			self.Menu.Defence.MC:addParam('Humanizer', 'Humanizing Delay (ms)', SCRIPT_PARAM_SLICE, 0, 0, 500)
			self.Menu.Defence.MC:addParam('Health', 'Life Save (%)', SCRIPT_PARAM_SLICE, 20, 0, 100)
		self.Menu.Defence:addSubMenu('Quicksilver Sash & Mercurial Scimitar', 'QSS')
			self.Menu.Defence.QSS:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
			self.Menu.Defence.QSS:addParam('Hard', 'Hard CC', SCRIPT_PARAM_ONOFF, true)
			self.Menu.Defence.QSS:addParam('Soft', 'Soft CC', SCRIPT_PARAM_ONOFF, false)
			self.Menu.Defence.QSS:addParam('Humanizer', 'Humanizing Delay (ms)', SCRIPT_PARAM_SLICE, 0, 0, 500)
			self.Menu.Defence.QSS:addParam('ZedR', 'Zed Ultimate', SCRIPT_PARAM_ONOFF, true)
end

function ItemCast:CrowdControl2(slot, info)
	local count = 0
	for i, enemy in ipairs(self.Enemies) do
		if enemy.visible and not enemy.dead and GetDistanceSqr(enemy) < info.range then
			count = count + 1
		end
	end
	if count >= info.req() then
		CastSpell(slot)
	end
end

function ItemCast:EnemyInRange(from)
	for i, enemy in ipairs(self.Enemies) do
		if enemy.visible and not enemy.dead and GetDistanceSqr(enemy, from) < 490000 then
			return true
		end
	end
	return false
end

function ItemCast:Haste(slot, info)
	if self.Menu.Offence.Key and info.req() then
		local allyCount, enemyCount = 1, 0
		for i, ally in ipairs(self.Allies) do
			if not ally.dead and GetDistanceSqr(ally) < info.range then
				allyCount = allyCount + 1
			end
		end
		for i, enemy in ipairs(self.Enemies) do
			if enemy.visible and not enemy.dead and GetDistanceSqr(enemy) < info.range then
				enemyCount = enemyCount + 1
			end
		end
		if enemyCount >= 2 and allyCount >= 2 then
			CastSpell(slot)
		end
	end
end

function ItemCast:HealthPotion(slot)
	if self.Menu.Defence.HP.Enable then
		if self.Menu.Defence.HP.Level1 and myHero.level == 1 then return end
		if myHero.health / myHero.maxHealth < self.Menu.Defence.HP.Health * .01 then
			local GT = GetGameTimer()
			for i, buff in ipairs(self.Buffs[myHero.networkID]) do
				if self.HPBuffs[buff.name] and buff.endTime > GT then
					return
				end
			end
			if self:EnemyInRange(myHero) then
				CastSpell(slot)
			end
		end
	end
end

function ItemCast:ProcessAttack(unit, attack)
	if unit.valid and unit.isMe and attack.target then
		for i=ITEM_1, ITEM_6 do
			local Item = self.Items[i]
			if Item and self.Offensive[Item] then
				self[self.Offensive[Item].type](self, i, attack.target, self.Offensive[Item])
			end
		end
	end
end

function ItemCast:ManaPotion(slot)
	if self.Menu.Defence.MP.Enable then
		if self.Menu.Defence.MP.Level1 and myHero.level == 1 then return end
		if myHero.manamyHero.maxMana < self.Menu.Defence.MP.Mana * .01 then
			local GT = GetGameTimer()
			for i, buff in ipairs(self.Buffs[myHero.networkID]) do
				if buff.name == 'flaskofcrystalwater' and buff.endTime > GT then
					return
				end
			end
			if self:EnemyInRange(myHero) then
				CastSpell(slot)
			end
		end
	end
end

function ItemCast:RemoveBuff(unit, buff)
	if unit.valid and unit.type == 'AIHeroClient' then
		local bName = buff.name:lower()
		for i, b in ipairs(self.Buffs[unit.networkID]) do
			if b.name == bName then
				table.remove(self.Buffs[unit.networkID], i)
				return
			end
		end
	end
end

function ItemCast:SelfCleanse(slot, info)
	if self.Menu.Defence.QSS.Enable then
		local GT = GetGameTimer()
		for i, buff in ipairs(self.Buffs[myHero.networkID]) do
			if self.HardCC[buff.type] and self.Menu.Defence.QSS.Hard and buff.endTime > GT and buff.startTime + (self.Menu.Defence.QSS.Humanizer * .001) < GT  then
				CastSpell(slot)
				return
			elseif self.SoftCC[buff.type] and self.Menu.Defence.QSS.Soft and buff.endTime > GT and buff.startTime + (self.Menu.Defence.QSS.Humanizer * .001) < GT then
				CastSpell(slot)
				return
			elseif buff.name == 'zedrdeathmark' and self.Menu.Defence.QSS.ZedR and buff.startTime + (self.Menu.Defence.QSS.Humanizer * .001) < GT then
				CastSpell(slot)
				return
			end
		end
	end
end

function ItemCast:Target(slot, target, info)
	if self.Menu.Offence.Key and target.type == 'AIHeroClient' and myHero:CanUseSpell(slot) == READY and info.req(target) then
		CastSpell(slot, target)
	end
end

function ItemCast:Tick()
	for i=ITEM_1, ITEM_6 do
		local Item = myHero:getItem(i)
		if Item and Item.id then
			self.Items[i] = Item.id
			if self.Defensive[Item.id] and myHero:CanUseSpell(i) == READY then
				self[self.Defensive[Item.id].type](self, i, self.Defensive[Item.id])
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
            if self.OnlineVersion and self.OnlineVersion > self.LocalVersion then
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
