if myHero.charName ~= 'Taric' then return end

local huge, sqrt, clock, ipairs = math.huge, math.sqrt, os.clock, ipairs

local DazzleChannel = 0
local Menu, EvadeeeToggle, DazzleAngle, DazzleTarget
local Allies, Enemies, DSKey = {}, {}, {key = false}

function Normalize(x,z)
    local length  = sqrt(x * x + z * z)
	return { ['x'] = x / length, ['z'] = z / length, }
end

function NormalizeX(v1, v2, length)
	local x, z
	if v1.x==v2.x then x, z = 1, 1 else x, z = v1.x - v2.x, v1.z - v2.z	end
    local nLength  = sqrt(x * x + z * z)
	return { ['x'] = v2.x + ((x / nLength) * length), ['z'] = v2.z + ((z / nLength) * length)} 
end

function Print(text, isError)
	if isError then
		print('<font color=\'#0099FF\'>[PewTaric] </font> <font color=\'#FF0000\'>'..text..'</font>')	
		return
	end
	print('<font color=\'#0099FF\'>[PewTaric] </font> <font color=\'#FF6600\'>'..text..'</font>')
end

AddLoadCallback(function()
	local version = 0.05
	ScriptUpdate(
		version,
		true, 
		'raw.githubusercontent.com', 
		'/PewPewPew2/BoL/master/Versions/PewTaric.version', 
		'/PewPewPew2/BoL/master/PewTaric.lua', 
		SCRIPT_PATH.._ENV.FILE_NAME, 
		function() Print('Update Complete. Please reload. (F9 F9)') end, 
		function() Print('Loaded latest version. v'..version..'.') end, 
		function() Print('New version found, downloading now...') end,
		function() Print('There was an error during update.') end
	)

  if _Pewalk then
    for i=1, heroManager.iCount do
      local h = heroManager:getHero(i)
      if h then
        table.insert(h.team == myHero.team and Allies or Enemies, h)
      end
    end
    Menu = scriptConfig('PewTaric', 'PewTaric')
    Menu:addParam('info', '---Starlight\'s Touch---', SCRIPT_PARAM_INFO, '')
      _Pewalk.AddMenuHeader('---Starlight\'s Touch---')
      Menu:addParam('MinHP1', 'Min. Ally Health % - 1 Stack', SCRIPT_PARAM_SLICE, 10, 0, 100) 
      Menu:addParam('MinHP2', 'Min. Ally Health % - 2 Stack', SCRIPT_PARAM_SLICE, 30, 0, 100) 
      Menu:addParam('MinHP3', 'Min. Ally Health % - 3 Stack', SCRIPT_PARAM_SLICE, 60, 0, 100) 
      Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
    Menu:addParam('info', '---Bastion---', SCRIPT_PARAM_INFO, '')
      _Pewalk.AddMenuHeader('---Bastion---')
      Menu:addParam('info', 'Autoshield removed due to high maintenence ', SCRIPT_PARAM_INFO, '') 
      Menu:addParam('info', 'costs, please use an external autoshield such', SCRIPT_PARAM_INFO, '') 
      Menu:addParam('info', 'as eXtragoZ Auto Shield or Dancing Shoes.', SCRIPT_PARAM_INFO, '') 
      Menu:addParam('info', '', SCRIPT_PARAM_INFO, '') 
      Menu:addParam('WQ', 'Min. Mana for W-Q Healing', SCRIPT_PARAM_SLICE, 20, 0, 100)
      Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
    Menu:addParam('info', '---Dazzle---', SCRIPT_PARAM_INFO, '')
      _Pewalk.AddMenuHeader('---Dazzle---')
      Menu:addParam('DisableEvade', 'Disable Evades While Channeling', SCRIPT_PARAM_ONOFF, true)
      Menu:addParam('info', '(Increases Hitchance)', SCRIPT_PARAM_INFO, '')
    Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
    Menu:addParam('info', 'Uses Pewalks Keys.', SCRIPT_PARAM_INFO, '')
      
    AddCastSpellCallback(function(...) Taric_OnCastSpell(...) end)
    AddProcessSpellCallback(function(...) Taric_OnProcessSpell(...) end)
    AddTickCallback(function() Taric_OnTick() end)
    AddApplyBuffCallback(function(...) Taric_OnApplyBuff(...) end)
    AddRemoveBuffCallback(function(...) Taric_OnRemoveBuff(...) end)
  else
    Print('Pewalk is Required!!', true)
  end
	
	local DSAdded = false
	AddTickCallback(function()
		if not DSAdded and DancingShoes_AddDisableKey then 
			DSAdded = true
			DancingShoes_AddDisableKey(DSKey, 'key') 
		end	
	end)
end)

function Taric_OnCastSpell(iSlot,startPos,endPos,target)
	if iSlot == _E then
		DazzleChannel = clock() + (GetLatency() * .001) + .15
		DazzleAngle = Normalize(endPos.x-startPos.x, endPos.z-startPos.z)
	end	
end

function Taric_OnProcessSpell(unit, spell)
	if unit.valid and unit.isMe and spell.name == 'TaricE' then
		DazzleChannel = clock() - (GetLatency() * .001) + 1.5
		DazzleAngle = Normalize(spell.endPos.x-unit.x, spell.endPos.z-unit.z)
	end	
end
	
function Taric_OnTick()	
	DSKey.key = false
	if EvadeeeToggle then
		EvadeeeToggle = false
		Evadeee_SetEvading(true, 'PewTaric')	
	end
	_Pewalk.AllowAttack(true)
	
	if _Pewalk.GetActiveMode().Carry then
		if DazzleChannel > clock() and DazzleAngle and _Pewalk.ValidTarget(DazzleTarget) then
			_Pewalk.AllowAttack(false)
			
			if Menu.DisableEvade then
				if Evadeee_SetEvading then
					if not EvadeeeToggle then
						EvadeeeToggle = true
						Evadeee_SetEvading(false, 'PewTaric')
					end
				end
				DSKey.key = true
			end
			
			local pp = _Pewalk.GetCastPos(DazzleTarget, {speed=huge, delay=(GetLatency() * .001) + .25})
			pp.y = myHero.y
			local tMP = NormalizeX(mousePos, myHero, 200)
			local mp =  Vector(pp.x + (DazzleAngle.x * 400), myHero.y, pp.z + (DazzleAngle.z * 400))
			local p = VectorPointProjectionOnLine(Vector(pp), mp, Vector(tMP.x, myHero.y, tMP.z))
			_Pewalk.ForcePoint(p, nil, true)
		elseif myHero:CanUseSpell(_E) == READY then
			local t = _Pewalk.GetTarget(575)
			if t then
				DazzleTarget = t
				CastSpell(_E, t.x, t.z)
			end
		end
		if myHero:CanUseSpell(_Q)==READY and DazzleChannel < clock() then
			local s = myHero:GetSpellData(_Q).stacks
			if s > 0 then
				if Menu['MinHP'..s]==nil then print(s) return end
				local m = Menu['MinHP'..s] * .01
				for i, ally in ipairs(Allies) do
					if not ally.dead and ally.health/ally.maxHealth < m then
						local d = GetDistanceSqr(ally)
						if d < 105625 then
							CastSpell(_Q)
						elseif wAlly and not wAlly.dead and GetDistanceSqr(wAlly) < 1690000 and GetDistanceSqr(wAlly, ally) < 105625 then
							CastSpell(_Q)
						elseif myHero:CanUseSpell(_W) == READY and d < 640000 then
							if myHero.mana / myHero.maxMana > Menu.WQ * .01 then
								CastSpell(_W, ally)
							end
						end
					end
				end
			end
		end
	end
end

function Taric_OnApplyBuff(source, unit, buff)
	if unit and unit.valid and source == myHero and buff.name == 'taricwallybuff' then
		wAlly = unit
	end
end

function Taric_OnRemoveBuff(unit, buff)
	if unit.valid and unit.team==myHero.team and buff.name == 'taricwallybuff' then
		wAlly = nil
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
    print('<font color="#FFFFFF">'..clock()..': '..str)
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
