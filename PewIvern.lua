if myHero.charName~='Ivern' then return end

local version = 0.01

local Menu, Daisy, HP_Q, HP
local Enemies = {}
local HPCost = {145,154,161,167,172,175,179,178,176,175,172,165,157,146,134,118,100,80,}
local MNCost = {135,141,146,150,153,155,156,154,151,147,145,141,133,124,113, 99, 84,67,}
local DaisyNextAttack, DaisyNextMove, LastQCast = 0, 0, 0

local function NormalizeX(v1, v2, length)
	local x, z
	if v1.x==v2.x then x, z = 1, 1 else x, z = v1.x - v2.x, v1.z - v2.z	end
    local nLength  = math.sqrt(x * x + z * z)
	return { ['x'] = v2.x + ((x / nLength) * length), ['z'] = v2.z + ((z / nLength) * length)} 
end

local function HardCC(buff)  
	local CC = { 
		[5] = 'Stun', 
		[11] = 'Snare',
		[24] = 'Suppresion', 
		[29] = 'KnockUp', 
	}
  return CC[buff.type]~=nil
end

local function Print(text, isError)
	if isError then
		print('<font color=\'#0099FF\'>[PewIvern] </font> <font color=\'#FF0000\'>'..text..'</font>')	
		return
	end
	print('<font color=\'#0099FF\'>[PewIvern] </font> <font color=\'#FF6600\'>'..text..'</font>')
end

AddLoadCallback(function()  
  if FileExist(LIB_PATH..'HPrediction.lua') then
    require('HPrediction')
    HP = HPrediction()
    HP_Q = HPSkillshot({type = 'DelayLine', delay = 0.25, range = 1100, width = 130, speed = 1300, collisionM=true})
  else
    Print('HPrediction required, please download manually!', true)
    return
  end
  if not _Pewalk then
    Print('Pewalk required, please download manually!', true)
    return
  end
  
  for i=1, heroManager.iCount do
    local h = heroManager:getHero(i)
    if h and h.valid and h.team~=myHero.team then
      table.insert(Enemies, h)
    end
  end
  
  Menu = scriptConfig('PewIvern', 'PewIvern')  
  Menu:addParam('info', '---Friend of the Forest---', SCRIPT_PARAM_INFO, '')
    _Pewalk.AddMenuHeader('---Friend of the Forest---')  
    Menu:addParam('PassiveCost', 'Draw Health and Mana Cost', SCRIPT_PARAM_ONOFF, true)
    Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
  Menu:addParam('info', '---Rootcaller---', SCRIPT_PARAM_INFO, '')
    _Pewalk.AddMenuHeader('---Rootcaller---')
    Menu:addParam('Force', 'Force Cast', SCRIPT_PARAM_ONKEYDOWN, false, ('H'):byte()) 
    Menu:addParam('HC', 'Hit Chance', SCRIPT_PARAM_SLICE, 0.75, 0, 3)   
    Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
  Menu:addParam('info', '---Brushmaker---', SCRIPT_PARAM_INFO, '')
    _Pewalk.AddMenuHeader('---Brushmaker---')  
    Menu:addParam('Vision', 'Cast On Lose Vision', SCRIPT_PARAM_ONOFF, true)
    Menu:addParam('CC', 'Cast On CC\'d Allies', SCRIPT_PARAM_ONOFF, true)    
    Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
  Menu:addParam('info', '---Triggerseed---', SCRIPT_PARAM_INFO, '')
    _Pewalk.AddMenuHeader('---Triggerseed---')
    Menu:addParam('info', 'Please use an external autoshield such as', SCRIPT_PARAM_INFO, '') 
    Menu:addParam('info', 'eXtragoZ Auto Shield or Dancing Shoes.', SCRIPT_PARAM_INFO, '')
    Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
  Menu:addParam('info', '---Daisy!---', SCRIPT_PARAM_INFO, '')
    _Pewalk.AddMenuHeader('---Daisy!---')
    Menu:addParam('Orb', 'Toggle Daisy Orbwalking', SCRIPT_PARAM_ONKEYTOGGLE, true, ('T'):byte())
    
  AddTickCallback(function() Tick() end)
  AddDrawCallback(function() Draw() end)
  AddApplyBuffCallback(function(...) ApplyBuff(...) end)
  AddCreateObjCallback(function(...) CreateObj(...) end)
  AddAnimationCallback(function(...) Animation(...) end)
    
	ScriptUpdate(
		version,
		true, 
		'raw.githubusercontent.com', 
		'/PewPewPew2/BoL/master/Versions/PewIvern.version', 
		'/PewPewPew2/BoL/master/PewIvern.lua', 
		SCRIPT_PATH.._ENV.FILE_NAME, 
		function() Print('Update Complete. Please reload. (F9 F9)') end, 
		function() Print('Loaded latest version. v'..version..'.') end, 
		function() Print('New version found, downloading now...') end,
		function() Print('There was an error during update.') end
	)
end)

function Tick()
  for i=1, #Enemies do
    if Enemies[i].dead or Enemies[i].visible then
      Enemies[i].inFoW = nil
    elseif not Enemies[i].inFoW then
      Enemies[i].inFoW = os.clock()
    end
  end

  if _Pewalk.GetActiveMode().Carry and not Evade then
    if myHero:CanUseSpell(_Q) == READY and LastQCast < os.clock() then
      local t = _Pewalk.GetTarget((Menu.Force and 1000 or 1100),false)
      if t then
        local cp, hc = HP:GetPredict(HP_Q, t, myHero)
        if cp and (hc > Menu.HC or (Menu.Force and hc > -1)) then
          CastSpell(_Q, cp.x, cp.z)
          LastQCast = os.clock() + 2.5
        end
      end
    end
    if Menu.Vision and myHero:CanUseSpell(_W) == READY then      
      for i=1, #Enemies do
        local e = Enemies[i]
        if not e.dead and not e.visible and e.inFoW and os.clock() - e.inFoW < 2 then
          if e.health / e.maxHealth < .4 and GetDistanceSqr(e) < 1440000 then
            local p = NormalizeX(e.endPath, e, 100)
            local d = D3DXVECTOR3(p.x,e.y,p.z)
            if IsWallOfGrass(d) or CalculatePath(myHero, d).count > 3 then
              CastSpell(_W, e.x, e.z)
            end					
          end
        end
      end
    end
  end
  
  if Daisy then
    if Daisy.valid and not Daisy.dead then
      if Menu.Orb then
        local t = _Pewalk.GetTarget(700, false, Daisy)
        if t then
          if _Pewalk.ValidTarget(t, 300, true, Daisy) then
            if DaisyNextAttack < os.clock() then
              CastSpell(_R, t)
              DaisyNextAttack = os.clock() + .25
              DaisyNextMove = os.clock() + .25
            elseif DaisyNextMove < os.clock() then
              local p = NormalizeX(t, Daisy, 500)
              CastSpell(_R, p.x, p.z)
              DaisyNextMove = os.clock() + .25
            end
          elseif DaisyNextMove < os.clock() then
            local p = NormalizeX(t, Daisy, 500)
            if p then 
              CastSpell(_R, p.x, p.z) 
              DaisyNextMove = os.clock() + .25
            end
          end
        elseif not Daisy.hasMovePath and myHero.hasMovePath and DaisyNextMove < os.clock() then
          CastSpell(_R, myHero.endPath.x, myHero.endPath.z)
        end
      end
    else
      Daisy = nil
    end
  end
end

function ApplyBuff(source,unit,buff)
  if Menu.CC and unit and unit.valid and unit.team==myHero.team and unit.type=='AIHeroClient' and not unit.isMe and HardCC(buff) then
    if not Evade and myHero:CanUseSpell(_W) == READY and GetDistanceSqr(unit) < 1600*1600 then
      for _, b in pairs(_Pewalk.GetBuffs(unit)) do
        if b.type == 30 then
          return 
        end
      end        
      CastSpell(_W, unit.x, unit.z)
    end
  end
end

function CreateObj(o)
  if o.valid and o.type == 'obj_AI_Minion' and o.team == myHero.team and o.name == 'IvernMinion' then
    Daisy = o
  end
end

function Animation(unit,animation, hash)
  if unit.valid and unit==Daisy then
    if animation ~= 'Idle1' and unit.spell then
      DaisyNextAttack = os.clock() + unit.spell.animationTime
      DaisyNextMove = os.clock() + unit.spell.windUpTime
    end
  end
end

function Draw()
  if Menu.PassiveCost then
    local HC, MC = HPCost[myHero.level < 19 and myHero.level or 18], MNCost[myHero.level < 19 and myHero.level or 18]
    if HC < myHero.health and MC < myHero.mana then
      local Center = GetUnitHPBarPos(myHero)
      if Center.x > -100 and Center.x < WINDOW_W+100 and Center.y > -100 and Center.y < WINDOW_H+100 then
        local Offset = GetUnitHPBarOffset(myHero)
        local y = Center.y + Offset.y * 53 + 24
        local x = Center.x - 42
        DrawLine(
          x + myHero.health / myHero.maxHealth * 105,
          y, 
          x + (myHero.health-HC) / myHero.maxHealth * 105,
          y,
          10, 
          0x99CC1111
        )
        DrawLine(
          x + myHero.mana / myHero.maxMana * 105,
          y+6, 
          x + (myHero.mana-MC) / myHero.maxMana * 105,
          y+6,
          5, 
          0x99CC0000
        )
      end
    end
  end
  
  if Daisy and Daisy.valid and Menu.Orb then
    DrawText3D('AutoOrbwalk',Daisy.x,Daisy.y,Daisy.z,20,0x99FFFFFF,true)
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
