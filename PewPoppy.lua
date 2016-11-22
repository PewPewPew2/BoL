if myHero.charName~='Poppy' then return end

local version = 0.05

local pi, pi2, atan, cos, sin, sqrt = math.pi, math.pi*2, math.atan, math.cos, math.sin, math.sqrt
local Sector = pi * (110 / 180)
local Sector4 = Sector / 3
local Dashing, KeepersVerdictChannel = 0, 0
local DrawP, DrawS = 35, true
local HP, HP_Q, HP_R, HP_R2, FlashSlot, Menu
local Pillar, Buckler
local IceBlocks, Soldiers, J4Wall, Enemies = {}, {}, {}, {}	

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

function GetLinePoint(ax, ay, bx, by, cx, cy)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)	
	return { x = ax + rL * (bx - ax), z = ay + rL * (by - ay) }, (rL < 0 and 0 or (rL > 1 and 1 or rL)) == rL
end

function GetPath(unit)
	if unit.hasMovePath then
		if unit.pathCount == 1 then return unit.endPath end
		local unitPath = unit:GetPath(math.max(2,unit.pathIndex))
		if unitPath then
			return {x=unitPath.x,z=unitPath.z}
		end
		return unit.endPath
	end
	return unit
end

function GeneratePoints(range, pMax, ePos, sPos)
	local points, c = {}, -1
	local v2 = { ['x'] = sPos.x-ePos.x, ['z'] = sPos.z-ePos.z, }
	local a = (v2.x > 0) and pi-atan(v2.z/v2.x) or pi-atan(v2.z/v2.x)+pi
	for i = a, a+Sector, Sector4 do
		if #points==pMax then break end
		points[#points+1] = { 
			['x'] = sPos.x+(range*cos(i)), 
			['z'] = sPos.z-(range*sin(i)),
			['a'] = i,
		}
		c=c+2
		if #points==pMax then break end
		points[#points+1] = { 
			['x'] = sPos.x+(range*cos(i+(pi2-(c*Sector4)))),
			['z'] = sPos.z-(range*sin(i+pi2-(c*Sector4))),
			['a'] = i+pi2-(c*Sector4),
		}
	end
	return points
end

function Print(text, isError)
	if isError then
		print('<font color=\'#0099FF\'>[PewPoppy] </font> <font color=\'#FF0000\'>'..text..'</font>')	
		return
	end
	print('<font color=\'#0099FF\'>[PewPoppy] </font> <font color=\'#FF6600\'>'..text..'</font>')
end

function IsWallIntersection(s, e)
	for i=50, 350, 50 do
		local cp = NormalizeX(e, s, i)
		if IsWall2(D3DXVECTOR3(cp.x,myHero.y,cp.z)) then
			return true
		end
	end			
end

function IsWallCollision(cStart, cEnd)	
	if IsWallIntersection(cStart, cEnd) then
		local d1 = Normalize(cStart.x-(cStart.x-(cStart.z-cEnd.z)), cStart.z-(cStart.z+(cStart.x-cEnd.x)))
		local lEnd = {['x'] = cEnd.x + d1.x*-35, ['z'] = cEnd.z + d1.z*-35}
		local lStart = {['x'] = cStart.x + d1.x*-35, ['z'] = cStart.z + d1.z*-35}
		if IsWallIntersection(lStart, lEnd) then
			local rEnd = {['x'] = cEnd.x + d1.x*35, ['z'] = cEnd.z + d1.z*35}
			local rStart = {['x'] = cStart.x + d1.x*35, ['z'] = cStart.z + d1.z*35}
			if IsWallIntersection(rStart, rEnd) then
				return true
			end
		end
	end
	return false
end

function AnalyzeCharge(t, from)
	local myPos = from or NormalizeX(GetPath(myHero), myHero, (GetLatency()*0.0005)*myHero.ms)
	local d1 = GetDistance(t, myPos)	
	local p1 = NormalizeX(t, myPos, (d1 + 400))
	if IsWallCollision(t, p1) then
		if t.hasMovePath then
			local pp = NormalizeX(GetPath(t), t, (d1 / 1800) * t.ms)
			local p2 = NormalizeX(pp, myPos, (GetDistance(pp, myPos) + 400))
			if IsWallCollision(pp, p2) then
				return true
			end						
		else
			return true
		end
	end
end

function IsImmune(unit)
	local buffs = _Pewalk and _Pewalk.GetBuffs(unit) or {}
	return buffs['blackshield'] or buffs['fioraw']
end

function IsWall2(p)
	if IsWall(p) then
		return true
	end
	for i=#IceBlocks, 1, -1 do
		local b = IceBlocks[i]
		if b and b.valid and b.endTime > os.clock() then
			if GetDistanceSqr(p, b) < 3600 then
				return true
			end
		else
			table.remove(IceBlocks, i)
		end
	end
	for i=#J4Wall, 1, -1 do
		local b = J4Wall[i]
		if b and b.valid and b.endTime > os.clock() and not b.dead then
			if GetDistanceSqr(p, b) < 10000 then
				return true
			end
		else
			table.remove(J4Wall, i)
		end
	end
	for i=#Soldiers, 1, -1 do
		local b = Soldiers[i]
		if b and b.valid and b.endTime > os.clock() then
			if GetDistanceSqr(p, b) < 3600 then
				return true
			end
		else
			table.remove(Soldiers, i)
		end
	end
	if Pillar then
		if Pillar.valid and Pillar.endTime > os.clock() then
			if GetDistanceSqr(p, Pillar) < 10000 then
				return true
			end			
		else
			Pillar = nil
		end
	end
end

function CalcArmor(unit, target)
	local baseArmor = target.armor-target.bonusArmor
	return 100 / (100 + (((target.bonusArmor * unit.bonusArmorPenPercent) + baseArmor) * unit.armorPenPercent) - ((unit.lethality * .4) + ((unit.lethality * .6) * (unit.level / 18))))
end

AddLoadCallback(function()
  if FileExist(LIB_PATH..'HPrediction.lua') then
    require('HPrediction')
    HP = HPrediction()
    HP_Q = HPSkillshot({type = 'PromptLine', delay = 0.375, range = 350, width = 150, speed = math.huge})
    HP_R = HPSkillshot({type = 'PromptLine', delay = 0.450, range = 550, width = 275, speed = math.huge})
    HP_R2 = HPSkillshot({type = 'DelayLine', delay = 0, range = 1200, width = 275, speed = 1600})
  else
    Print('HPrediction required, please download manually!', true)
    return
  end
  if not _Pewalk then
    Print('Pewalk required, please download manually!', true)
    return
  end
  
  FlashSlot = myHero:GetSpellData(SUMMONER_1).name:lower() == 'summonerflash' and SUMMONER_1 or (myHero:GetSpellData(SUMMONER_2).name:lower() == 'summonerflash') and SUMMONER_2 or nil	
 
  for i=1, heroManager.iCount do
    local h = heroManager:getHero(i)
    if h and h.team~=myHero.team then
      table.insert(Enemies, h)
    end
  end
  
  Menu = scriptConfig('PewPoppy', 'PewPoppy')
  Menu:addParam('info', '---General---', SCRIPT_PARAM_INFO, '')
    _Pewalk.AddMenuHeader('---General---')
    Menu:addParam('KS', 'Killsteal', SCRIPT_PARAM_ONKEYTOGGLE, true, ('T'):byte())
    Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
  Menu:addParam('info', '---Hammer Shock---', SCRIPT_PARAM_INFO, '')
    _Pewalk.AddMenuHeader('---Hammer Shock---')
    Menu:addParam('KSQ', 'Killsteal Q', SCRIPT_PARAM_ONOFF, true)
    Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
    Menu:addParam('info', '---Steadfast Presence---', SCRIPT_PARAM_INFO, '')
  _Pewalk.AddMenuHeader('---Steadfast Presence---')
    for _, enemy in ipairs(Enemies) do
      Menu:addParam(enemy.charName, 'Allow Cast On: '..enemy.charName, SCRIPT_PARAM_ONOFF, true)
    end  
    Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
  Menu:addParam('info', '---Heroic Charge---', SCRIPT_PARAM_INFO, '')
    _Pewalk.AddMenuHeader('---Heroic Charge---')
    Menu:addParam('FlashKey', 'Flash E', SCRIPT_PARAM_ONKEYDOWN, false, ('C'):byte())
    Menu:addParam('ForceE', 'Force E (No Wall Check)', SCRIPT_PARAM_ONKEYDOWN, false, 20)
    Menu:addParam('space', '  Carry Key must be ON for Force', SCRIPT_PARAM_INFO, '')
    Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
    Menu:addParam('info', '---Keeper\'s Verdict---', SCRIPT_PARAM_INFO, '')
  _Pewalk.AddMenuHeader('---Keeper\'s Verdict---')
    Menu:addParam('KSR', 'Killsteal R', SCRIPT_PARAM_ONOFF, true)
    Menu:addParam('ForceR', 'Force Snap Cast R', SCRIPT_PARAM_ONKEYDOWN, false, ('M'):byte())
    Menu:addParam('MinR', 'Snap Cast R If Can Hit X', SCRIPT_PARAM_SLICE, 3, 2, 5)
    Menu:addParam('SecondCast', 'Allow Auto Charged Cast', SCRIPT_PARAM_ONOFF, true)
  
  AddNewPathCallback(NewPath)
  AddCreateObjCallback(CreateObj)
  AddTickCallback(Tick)
  AddDrawCallback(Draw)
  AddAnimationCallback(Animation)
	
  ScriptUpdate(
		version,
		true, 
		'raw.githubusercontent.com', 
		'/PewPewPew2/BoL/master/Versions/PewPoppy.version', 
		'/PewPewPew2/BoL/master/PewPoppy.lua', 
		SCRIPT_PATH.._ENV.FILE_NAME, 
		function() Print('Update Complete. Please reload. (F9 F9)') end, 
		function() Print('Loaded latest version. v'..version..'.') end, 
		function() Print('New version found, downloading now...') end,
		function() Print('There was an error during update.') end
	)
end)

function NewPath(unit,startPos,endPos,isDash,dashSpeed,dashGravity,dashDistance)
	if unit.valid and isDash and unit.type == 'AIHeroClient' then
		if unit.isMe then
			Dashing = os.clock() + (GetDistance(startPos, endPos) / dashSpeed) - (GetLatency() * 0.0005)
		elseif Menu[unit.charName] and unit.team ~= myHero.team and Dashing < os.clock() and GetDistanceSqr(startPos, endPos) > 22500 then
			local dp, bp = GetLinePoint(startPos.x, startPos.z, endPos.x, endPos.z, myHero.x, myHero.z)
			if (bp and GetDistanceSqr(dp) < 160000) or GetDistanceSqr(endPos) < 160000 or GetDistanceSqr(startPos) < 160000 then
				CastSpell(_W)
			end
		end
	end
end

function CreateObj(o)
	if o.valid then
		if o.name == 'IceBlock' then
			o.endTime = os.clock() + 4
			table.insert(IceBlocks, o)
		elseif o.name == 'AzirRSoldier' and o.team == myHero.team then
			o.endTime = os.clock() + 4.75
			table.insert(Soldiers, o)
		elseif o.name == 'JarvanIVWall' then
			o.endTime = os.clock() + 3
			table.insert(J4Wall, o)
		elseif o.name == 'PlagueBlock' then
			o.endTime = os.clock() + 5.5
			Pillar = o
    elseif o.name == 'Shield' and o.team == myHero.team then 
      Buckler = o
      Buckler.time = os.clock() + 5 - (GetLatency() * 0.0005)
    end
	end
end

function Tick()
	if _Pewalk.GetActiveMode().Carry then
		if myHero:CanUseSpell(_E) == READY then
			local t = _Pewalk.GetTarget(425 + myHero.boundingRadius, true)
			if t then
				if AnalyzeCharge(t) or Menu.ForceE then
					if not IsImmune(t) then
						CastSpell(_E, t)
					end
				end
			end
			for i, e in ipairs(Enemies) do
				if e~=t and _Pewalk.ValidTarget(e, 425 + myHero.boundingRadius, true) and not IsImmune(e) then
					if _Pewalk.IsHighPriority(e, 2) and AnalyzeCharge(e) then
						CastSpell(_E, e)
					end
				end
			end
		end
		if myHero:CanUseSpell(_Q) == READY then
			local t = _Pewalk.GetTarget(375)
			if t then
				local CP, HC = HP:GetPredict(HP_Q, t, Vector(myHero))
				if CP then
					if HC > 1.4 then
						CastSpell(_Q, CP.x, CP.z)
					elseif Menu.KS and Menu.KSQ then
						local qDamage = 15 + (25 * myHero:GetSpellData(_Q).level) + (.8 * myHero.addDamage) + (.07 * t.maxHealth)
						if qDamage > t.health * CalcArmor(myHero, t) then
							CastSpell(_Q, CP.x, CP.z)
						end
					end
				end
			end
		end
		if myHero:CanUseSpell(_R) == READY then
			local t = _Pewalk.GetTarget(450)
			if t then
				local CP, HC = HP:GetPredict(HP_R, t, Vector(myHero))
				local NH = 1
				for i=1, heroManager.iCount do
					local h = heroManager:getHero(i)
					if h and h~=t and h.valid and h.team ~= myHero.team and not h.dead and h.visible then
						local p, isOn = GetLinePoint(myHero.x, myHero.z, CP.x, CP.z, h.x, h.z)
						if isOn and GetDistanceSqr(p, h) < 10000 then
							NH = NH + 1
						end
					end
				end
				if CP and HC > 1 and (NH >= Menu.MinR or Menu.ForceR) then
					CastSpell(_R, CP.x, CP.z)
					CastSpell2(_R, D3DXVECTOR3(CP.x,myHero.y,CP.z))
				elseif Menu.KS and Menu.KSR and HC > 0.75 then
					local fd = 100 + (myHero:GetSpellData(_R).level * 100) + (myHero.addDamage * 0.9)
					if t.health + t.shield < fd * CalcArmor(myHero, t) then
						CastSpell(_R, CP.x, CP.z)
						CastSpell2(_R, D3DXVECTOR3(CP.x,myHero.y,CP.z))
					end
				end
			end				
		end	
	end	
	if Menu.FlashKey and FlashSlot then
		if myHero:CanUseSpell(_E) == READY and myHero:CanUseSpell(FlashSlot) == READY then
			local t = _Pewalk.GetTarget(850)
			local d = (425 + myHero.boundingRadius) ^ 2
			if t and not IsImmune(t) then
				local myPos = NormalizeX(GetPath(myHero), myHero, (GetLatency()*0.0005)*myHero.ms)
				local tPos = NormalizeX(GetPath(t), t, (GetLatency()*0.0005)*t.ms)
				for _, p in ipairs(GeneratePoints(400, 7, tPos, myPos)) do
					if GetDistanceSqr(p, tPos) < d and not IsWall(D3DXVECTOR3(p.x,myHero.y,p.z)) and AnalyzeCharge(tPos, p) then
						CastSpell(FlashSlot, p.x, p.z)
						DelayAction(function() CastSpell(_E, t) end)
						return
					end
				end
			end
		end
	end
	if KeepersVerdictChannel + 4 > os.clock() and Menu.SecondCast then
		local windUp = os.clock() - KeepersVerdictChannel
		if windUp > 1 then
			local InRange = {}     
      for i, enemy in ipairs(Enemies) do
        if _Pewalk.ValidTarget(enemy, 1200) then
          local CP, HC = HP:GetPredict(HP_R2, enemy, Vector(myHero))
          table.insert(InRange, {
            unit=enemy,
            pred=CP,
            hc=HC,
          })
        end
      end
      
      local MaxHit, MaxHitPos = 0, nil
      for i, t1 in ipairs(InRange) do
        if t1.pred and t1.hc > .5 then
          local CurrentHit = 1
          for k, t2 in ipairs(InRange) do
            if i~=k then
              if GetDistanceSqr(t1.pred, t2.pred) < 90000 then
                CurrentHit = CurrentHit + 1
              else
                local CollisionPoint, IsOnLine = GetLinePoint(myHero.x, myHero.z, t1.pred.x, t1.pred.z, t2.pred.x, t2.pred.z)
                if IsOnLine and GetDistanceSqr(CollisionPoint, t2.pred) < 62500 and GetDistanceSqr(CollisionPoint) < GetDistanceSqr(t1.pred) then
                  CurrentHit = 0
                  break
                end
              end
            end
          end
          if CurrentHit > MaxHit then
            MaxHit, MaxHitPos = CurrentHit, t1.pred
          end
        end
      end
      if MaxHit > 1 and MaxHitPos then
        CastSpell2(_R, D3DXVECTOR3(MaxHitPos.x, myHero.y, MaxHitPos.z))
      end
      
      local TankiestTarget, Ratio = nil, 0
      for i, t in ipairs(InRange) do
        local CurrentRatio = t.unit.health * t.unit.armor * t.unit.magicArmor
        if not TankiestTarget or Ratio < CurrentRatio then
          TankiestTarget, Ratio = t, CurrentRatio
        end
      end
      
			if TankiestTarget then
				if TankiestTarget.pred and TankiestTarget.hc > 0.5 then
					CastSpell2(_R, D3DXVECTOR3(TankiestTarget.pred.x, myHero.y, TankiestTarget.pred.z))
				end
			end
		end
	end
end

function Draw()	
	if Buckler and Buckler.valid and not Buckler.dead then
		local tr = Buckler.time - os.clock()
		if tr > 0 then
			DrawText3D(('%.2f'):format(tr),Buckler.x,Buckler.y + 150,Buckler.z,36,0xFFFF9900,true)
		end
	end
  
	if Menu.KS then
    local v = WorldToScreen(D3DXVECTOR3(myHero.x,myHero.y,myHero.z))
    if v.x > -200 and v.x < WINDOW_W + 200 and v.y > -200 and v.y < WINDOW_W + 200 then    
      local points = {}
      local R, r = 84, 49    
      DrawP=DrawS and DrawP+1 or DrawP-1
      if DrawP>120 then
        DrawS=false
      elseif DrawP<10 then
        DrawS=true
      end
      
      for i=1, 270 do
        local v = WorldToScreen(D3DXVECTOR3(myHero.x+((R+r)*cos(i) + DrawP*cos((R+r)*i/r)),myHero.y,myHero.z+((R+r)*sin(i) + DrawP*sin((R+r)*i/r))))
        points[i] = D3DXVECTOR2(v.x, v.y)
      end
      DrawLines2(points,1,ARGB(0x99, 0, 0x55, 0x44 + DrawP))
    end
  end
end

function Animation(unit, animation, hash)
	if unit.valid and unit.isMe then
    if hash == '811C9DC5' then
			KeepersVerdictChannel = os.clock()
		elseif hash == 'B387DE61' or hash == '30BFBAC0' then
			KeepersVerdictChannel = 0
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
