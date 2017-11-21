local lshift, band, bxor = bit32.lshift, bit32.band, bit32.bxor
local floor, ceil, huge, cos, sin, pi, pi2, abs, sqrt, min, max = math.floor, math.ceil, math.huge, math.cos, math.sin, math.pi, math.pi*2, math.abs, math.sqrt, math.min, math.max
local clock, pairs, ipairs, tostring = os.clock, pairs, ipairs, tostring
local TEAM_ENEMY, TEAM_ALLY
local MainMenu, GlobalAnchors = nil, {}
local menuKey = (GetSave('scriptConfig') and GetSave('scriptConfig')['Menu']) and GetSave('scriptConfig')['Menu']['menuKey'] or 16
local Missing, o_valid = {}, {}
local isMenuOpen = false

local _Game, _Map, _HUD

local function GetGame2()
  if not _Game then
    _Game = {
      ['Map'] = {
        ['Name'] = 'unknown',
        ['Min'] = { ['x'] = 0, ['y'] = 0 },
        ['Max'] = { ['x'] = 0, ['y'] = 0 },
        ['x'] = 1,
        ['y'] = 1,
      }
    }
    for i = 1, objManager.maxObjects do
      local object = objManager:getObject(i)
      if object and object.valid then
        if object.type == 'obj_Shop' and object.team == 100 then
          if floor(object.x) == 232 and floor(object.y) == 163 and floor(object.z) == 1277 then --all wrong??
            _Game.Map = { 
              ['Name'] = 'SummonerRift', 
              ['Min'] = { ['x'] = 80, ['y'] = 140 }, 
              ['Max'] = { ['x'] = 14279, ['y'] = 14527 }, 
              ['x'] = 14817, 
              ['y'] = 14692, 
            }
            break
          elseif floor(object.x) == 1313 and floor(object.y) == 123 and floor(object.z) == 8005 then
            _Game.Map = { 
              ['Name'] = 'TwistedTreeline', 
              ['Min'] = { ['x'] = 150, y = 250}, 
              ['Max'] = { ['x'] = 14120, y = 13877 }, 
              ['x'] = 15116, 
              ['y'] = 15116, 
            }
            break
          elseif math.floor(object.x) == 16 and math.floor(object.y) == 168 and math.floor(object.z) == 4452 then
            _Game.Map = { 
              ['Name'] = 'CrystalScar', 
              ['Min'] = { ['x'] = 52, ['y'] = 150 }, 
              ['Max'] = { ['x'] = 13911, ['y'] = 13703 }, 
              ['x'] = 13911, 
              ['y'] = 13703, 
            }
            break
          elseif math.floor(object.x) == 497 and math.floor(object.y) == -40 and math.floor(object.z) == 1932 then
            _Game.Map = { 
              ['Name'] = 'HowlingAbyss', 
              ['Min'] = { ['x'] = -20, ['y'] = 40 }, 
              ['Max'] = { ['x'] = 12820, ['y'] = 12839 }, 
              ['x'] = 12876, 
              ['y'] = 12877, 
            }
            break
          elseif math.floor(object.x) == 497 and math.floor(object.y) == -180 and math.floor(object.z) == 1932 then
            _Game.Map = { 
              ['Name'] = 'ButchersBridge', 
              ['Min'] = { ['x'] = -20, ['y'] = 40 }, 
              ['Max'] = { ['x'] = 12820, ['y'] = 12839 }, 
              ['x'] = 12876, 
              ['y'] = 12877, 
            }
            break
          end
        end
      end
    end
  end
  return _Game
end

local function GetHUDSettings()
	if not _HUD then
		_HUD = ReadIni(GAME_PATH .. "\\DATA\\menu\\hud\\hud" .. WINDOW_W .. "x" .. WINDOW_H .. ".ini")
	end
	return _HUD
end

local function _Map_Load()
    if not _Map then
		local Ratio, Flip, Settings = 1, false, GetGameSettings()
		if Settings and Settings.General and Settings.General.Width and Settings.General.Height then
			Ratio = (Settings.HUD and Settings.HUD.MinimapScale) and (WINDOW_H / 1080) * (0.75 + (Settings.HUD.MinimapScale * 0.25)) or WINDOW_H / 1080
			Flip = Settings.HUD and Settings.HUD.FlipMiniMap and Settings.HUD.FlipMiniMap == 1
		end
		local Map = GetGame2().Map
		_Map = {
			['Step'] = { 
				['x'] = (257 * Ratio) / Map.x, 
				['y'] = (-253 * Ratio) / Map.y 
			},
		}
		_Map.x = Flip and (20 + Ratio) - _Map.Step.x * Map.Min.x or WINDOW_W - (Ratio * 266) - _Map.Step.x * Map.Min.x
		_Map.y = WINDOW_H - 15 + ((1-Ratio) * 10) - _Map.Step.y * Map.Min.y
    end 
    return _Map ~= nil
end

local function GetMinimap(v)
	_Map_Load()
	return _Map_Load() and D3DXVECTOR2(_Map.x + (_Map.Step.x * v.x), _Map.y + (_Map.Step.y * v.z)) or D3DXVECTOR2(-100, -100)
end

local function GetScale(int, scl)
	return floor((scl / 100) * int)
end

local function GetScale2(int, scl)
	return (scl / 100) * int
end

local function BytesToFloat(bytes)
  if bytes[1] and bytes[2] and bytes[3] and bytes[4] then
    return DwordToFloat(bxor(lshift(band(bytes[1],0xFF),24),lshift(band(bytes[2],0xFF),16),lshift(band(bytes[3],0xFF),8),band(bytes[4],0xFF)))
  end
  return 0
end

local function JSONIntegrity(content)
  if content:match('^%s*<') or content:sub(1,1):byte() == 0 or (content:len() >= 2 and content:sub(2,2):byte() == 0) then
    return false
  end
  return true
end

local function GetLevel(unit)
  if unit.type == 'AIHeroClient' then
    return min(unit.level, 18)
  end
  return 1
end

local function round(num)
  return num>=0 and floor(num + 0.5) or ceil(num - 0.5)
end

-- AddDrawCallback(function()
	-- local v = GetMinimap(myHero)
	-- DrawLine(v.x-10,v.y,v.x+10,v.y,1,ARGB(255,255,255,255))
	-- DrawLine(v.x,v.y-10,v.x,v.y+10,1,ARGB(255,255,255,255))
-- end)

local Downloads = {
  [1] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/barTemplate_r3.png',
    ['HOST'] = 'puu.sh',
    ['URL'] = '/tETmH/19d176febd.png',
  },
  [2] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/summonerbarrier.png',
    ['HOST'] = 'i.imgur.com',
    ['URL'] = '/68VUJSl.png',
  },
  [3] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/summonerboost.png',
    ['HOST'] = 'i.imgur.com',
    ['URL'] = '/CAVVQ9B.png',
  },
  [4] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/summonerclairvoyance.png',
    ['HOST'] = 'i.imgur.com',
    ['URL'] = '/gvYFTpu.png',
  },
  [5] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/summonerdot.png',
    ['HOST'] = 'i.imgur.com',
    ['URL'] = '/kCD3WjZ.png',
  },
  [6] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/summonerexhaust.png',
    ['HOST'] = 'i.imgur.com',
    ['URL'] = '/8EsF90W.png',
  },
  [7] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/summonerflash.png',
    ['HOST'] = 'i.imgur.com',
    ['URL'] = '/LhnU93g.png',
  },
  [8] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/summonerhaste.png',
    ['HOST'] = 'i.imgur.com',
    ['URL'] = '/K4fmF83.png',
  },
  [9] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/summonerheal.png',
    ['HOST'] = 'i.imgur.com',
    ['URL'] = '/yTwLorm.png',
  },
  [10] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/summonermana.png',
    ['HOST'] = 'i.imgur.com',
    ['URL'] = '/Rt0i7HR.png',
  },
  [11] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/summonerodingarrison.png',
    ['HOST'] = 'i.imgur.com',
    ['URL'] = '/nCHmZra.png',
  },
  [12] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/summonersmite.png',
    ['HOST'] = 'i.imgur.com',
    ['URL'] = '/j6XAgXK.png',
  },
  [13] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/summonersnowball.png',
    ['HOST'] = 'i.imgur.com',
    ['URL'] = '/D5TIXXe.png',
  },
  [14] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/aatroxpassiveactivate.png',
    ['HOST'] = 'puu.sh',
    ['URL'] = '/sDAm0/b7f81022b4.png',
  },
  [15] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/rebirthcooldown.png',
    ['HOST'] = 'puu.sh',
    ['URL'] = '/sDAFS/ae20a6213b.png',
  },
  [16] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/manabarriercooldown.png',
    ['HOST'] = 'puu.sh',
    ['URL'] = '/sDAvU/4d0816aca1.png',
  },
  [17] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/zacrebirthcooldown.png',
    ['HOST'] = 'puu.sh',
    ['URL'] = '/sDAB2/1bc9b041a7.png',
  },
  [18] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/volibearpassivecd.png',
    ['HOST'] = 'puu.sh',
    ['URL'] = '/sDAE1/a98a9dc51b.png',
  },
  [19] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/summonerteleport.png',
    ['HOST'] = 'i.imgur.com',
    ['URL'] = '/uY8WKfV.png',
  },
  [20] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/s5_summonersmiteduel.png',
    ['HOST'] = 'puu.sh',
    ['URL'] = '/sE9ge/58706c3b1d.png',
  },
  [21] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/s5_summonersmiteplayerganker.png',
    ['HOST'] = 'puu.sh',
    ['URL'] = '/sE9rb/e457f5e689.png',
  },
  [22] = {
    ['FILE_PATH'] = SPRITE_PATH..'/Pewtility/s5_summonersmiteplayerganker.png',
    ['HOST'] = 'puu.sh',
    ['URL'] = '/tFEzn/93f1c1b961.png',
  },
}

AddLoadCallback(function()  
	CreateDirectory(SPRITE_PATH..'Pewtility/')
	CreateDirectory(SPRITE_PATH..'Pewtility/SideHud/')
	CreateDirectory(LIB_PATH..'Saves/')
  
  for i=1, heroManager.iCount do
    local h = heroManager:getHero(i)
    if h and not Downloads[h.charName..'.png'] then
      local v = string.split(GetGameVersion(), '.')
      Downloads[#Downloads+1] = {
        ['FILE_PATH'] = SPRITE_PATH..'Pewtility/SideHud/'..h.charName..'.png',
        ['HOST'] = 'ddragon.leagueoflegends.com',
        ['URL'] = '/cdn/'..v[1]..'.'..v[2]..'.1/img/champion/'..h.charName..'.png',
      }
    end
  end

  local DL, CDL, DLC, LoadComplete = 1, nil, #Downloads, false
  AddDrawCallback(function()
    isMenuOpen = IsKeyDown(menuKey)
    if DL==DLC+1 then      
      if not LoadComplete then
        LoadScript()
        LoadComplete = true
      end
      return 
    end
    
    if FileExist(Downloads[DL].FILE_PATH) and not CDL then
      DL=DL+1
      return
    end
    
    if not CDL then
      CDL = AwareUpdate(
        'isDownload', 
        Downloads[DL].FILE_PATH, 
        Downloads[DL].HOST, 
        nil, 
        Downloads[DL].URL, 
        function() end, 
        function() end, 
        function() end, 
        function(state) Print('Error ['..state..'] downloading file.', true) end
      )
    elseif CDL.GotScriptUpdate then
      DL=DL+1
      CDL=nil
    end    
  end)
end)

function Print(text, isError)
	if isError then
		print('<font color=\'#0099FF\'><b>[Pewtility] </b></font> <font color=\'#FF0000\'>'..text..'</font>')
		return
	end
	print('<font color=\'#0099FF\'><b>[Pewtility] </b></font> <font color=\'#FF6600\'>'..text..'</font>')
end

function LoadScript()
	local Version = 11.1
	TEAM_ALLY, TEAM_ENEMY = myHero.team, 300-myHero.team
  -- TEAM_ENEMY=myHero.team
  
	MainMenu = scriptConfig('Pewtility', 'Pewtility')
	MainMenu:addParam('space', '', SCRIPT_PARAM_INFO, '')
	MainMenu:addParam('info', '---Turret Ranges---', SCRIPT_PARAM_INFO, '')
  o_valid['---Turret Ranges---']=true
	MainMenu:addParam('turret', 'Draw Turret Ranges', SCRIPT_PARAM_ONOFF, true)
	MainMenu:addParam('AllyTurret', 'Draw Ally Turret Ranges', SCRIPT_PARAM_ONOFF, false)
  
	if FileExist(LIB_PATH..'\\Saves\\Pewtility.save') then
		local file = io.open(LIB_PATH ..'Saves\\Pewtility.save', 'r')
		if file then
			local content = file:read('*all')
			if content and content:sub(1, 6) ~= 'return' and JSONIntegrity(content) then
				local SaveTable = JSON:decode(content)
				if SaveTable and type(SaveTable) == 'table' then
					GlobalAnchors = SaveTable
				end
			end
		end
	end
	local function SaveAnchors()
		local savefile = io.open(LIB_PATH..'\\Saves\\Pewtility.save', 'w')
		local content = JSON:encode(GlobalAnchors)
		savefile:write(content)
		savefile:close()
	end
	AddBugsplatCallback(SaveAnchors)
	AddUnloadCallback(SaveAnchors)
	AddExitCallback(SaveAnchors)
	
	HPBars()
	JungleTimers()
	MagneticWarding()
	Awareness()
	TrinketAssistant()
	WardTracker()
  
	OTHER()
  
	AwareUpdate(
		Version,
		SCRIPT_PATH.._ENV.FILE_NAME, 
		'raw.githubusercontent.com', 
		'/PewPewPew2/BoL/master/Versions/Pewtility.version', 
		'/PewPewPew2/BoL/master/Pewtility.lua', 
		function() Print('Loaded.') end, 
		function() Print('New Version Found, please wait...') end, 
		function() Print('Update Complete. Please reload (F9 F9).') end, 
		function(state) Print('Error ['..state..'] during update.') end
	)
end

class 'WardTracker'

function WardTracker:__init()
  local OffsetVersions = {
    ['7.23'] = {
      ['SourcePtr'] = 0x440,
      ['NetworkIDPtr'] = 0xE4,
    },
    ['7.22'] = {
      ['SourcePtr'] = 0x420,
      ['NetworkIDPtr'] = 0xE4,
    },
  }
	self.Offsets = OffsetVersions[GetGameVersion():sub(1,4)]
  
	self.Types = {
		['YellowTrinket'] 	= { ['color'] = 0xFFFFFF00, ['duration'] = 60,   ['isWard'] = true,  },
		['BlueTrinket'] 		= { ['color'] = 0xFF0000BB, ['duration'] = huge, ['isWard'] = false, },
		['SightWard'] 			= { ['color'] = 0xFF00FF00, ['duration'] = 150,  ['isWard'] = true,  },
		['JammerDevice']  	= { ['color'] = 0xFFFF32FF, ['duration'] = huge, ['isWard'] = true,  },
		['TeemoMushroom'] 	= { ['color'] = 0xFFFF0000, ['duration'] = 600,  ['isWard'] = false, },
		['ShacoBox'] 			  = { ['color'] = 0xFFFF0000, ['duration'] = 60, 	 ['isWard'] = false, },
	}
	self.OnSpell = {
		['trinkettotemlvl1'] 	= { ['color'] = 0xFFFFFF00, ['duration'] = 60,   ['isWard'] = true,  },
		['trinketorblvl3'] 		= { ['color'] = 0xFF0000BB, ['duration'] = huge, ['isWard'] = false, },
		['itemghostward'] 		= { ['color'] = 0xFF00FF00, ['duration'] = 150,  ['isWard'] = true,  },
		['jammerdevice']  		= { ['color'] = 0xFFFF32FF, ['duration'] = huge, ['isWard'] = true,  },
		['bantamtrap'] 		 	  = { ['color'] = 0xFFFF0000, ['duration'] = 600,  ['isWard'] = false, },
		['jackinthebox'] 		  = { ['color'] = 0xFFFF0000, ['duration'] = 60, 	 ['isWard'] = false, },
	}	
	self.Anchor = {
		['x'] = GlobalAnchors.WardTracker and GlobalAnchors.WardTracker.x or 40,
		['y'] = GlobalAnchors.WardTracker and GlobalAnchors.WardTracker.y or WINDOW_H - 72,
	}
	self.Hex = {D3DXVECTOR2(0,0),D3DXVECTOR2(0,0),D3DXVECTOR2(0,0),D3DXVECTOR2(0,0),D3DXVECTOR2(0,0),D3DXVECTOR2(0,0),D3DXVECTOR2(0,0)}
	self.Active = {}
	self.Known = {}
  self.DoubleClickTolerance = 0
  
	self:CreateMenu()
  
	AddDrawCallback(function() self:Draw() end)
	AddProcessSpellCallback(function(u, s) self:ProcessSpell(u, s) end)
	AddDeleteObjCallback(function(o) self:DeleteObj(o) end)
  AddAnimationCallback(function(...) self:Animation(...) end)
	AddMsgCallback(function(m,k) self:WndMsg(m,k) end)
	if self.Offsets then 
    for i=1, objManager.maxObjects do
      local o = objManager:getObject(i)
      if o and o.valid then
        self:CreateObj(o)
      end
    end
    AddCreateObjCallback(function(o) self:CreateObj(o) end) 
  end
end

function WardTracker:Animation(unit, animation)
  if unit.valid and animation=='DEATH' then
		for i, ward in ipairs(self.Known) do
			if ward.object and ward.object == unit then
        table.remove(self.Known, i)
				return
			end
		end	
  end
end

function WardTracker:CreateMenu()
	MainMenu:addSubMenu('Ward Tracking', 'WardTracker')
	self.Menu = MainMenu.WardTracker
	self.Menu:addParam('info', '---Ward Tracking---', SCRIPT_PARAM_INFO, '')
  o_valid['---Ward Tracking---']=true,
	self.Menu:addParam('EnableEnemy', 'Enable', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('Type', 'Timer Type', SCRIPT_PARAM_LIST, 1, { 'Seconds', 'Minutes' })
	self.Menu:addParam('MapType', 'Minimap Marker Type', SCRIPT_PARAM_LIST, 2, { 'Marker', 'Timer' })
	self.Menu:addParam('MapSize', 'Minimap Marker Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	self.Menu:addParam('Size', 'Text Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	self.Menu:addParam('DrawHex', 'Draw Hexagon on Timers', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('DrawRange', 'Draw Ward Vision Radius', SCRIPT_PARAM_ONKEYDOWN, false, ('G'):byte())
	self.Menu:addParam('info', 'Double Click a ward to manually remove it.', SCRIPT_PARAM_INFO, '') 
	self.Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('info', '---Self Tracking---', SCRIPT_PARAM_INFO, '')
  o_valid['---Self Tracking---']=true,
	self.Menu:addParam('EnableSelf', 'Enable', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('SelfType', 'Timer Type', SCRIPT_PARAM_LIST, 1, { 'Seconds', 'Minutes' })
	self.Menu:addParam('Scale', 'HUD Scale', SCRIPT_PARAM_SLICE, 100, 50 , 100)
end

function WardTracker:CreateObj(o)
  if o.valid and o.type == 'AIMinion' and self.Types[o.charName] then
    local sourcePtr = ReadDWORD(o.ptr+self.Offsets.SourcePtr)
    if sourcePtr then
      local sourceNetworkID = DwordToFloat(ReadDWORD(sourcePtr+self.Offsets.NetworkIDPtr))
      if sourceNetworkID then
        local source = objManager:GetObjectByNetworkId(sourceNetworkID)
        if source and source.valid then
					for i, ward in ipairs(self.Known) do
						if ward and not ward.object and ward.pos and GetDistanceSqr(ward.pos, o) < 50000 then
							table.remove(self.Known, i)
							break
						end
					end
          if source.isMe and self.Types[o.charName].isWard then          
            if self.Types[o.charName].duration then								
              if self.Types[o.charName].duration ~= huge then
                table.insert(self.Active, 1, {
                  ['object'] = o,
                  ['endTime'] = clock() + o.mana,
                  ['startTime'] = clock(),
                })
                if self.Active[4] then table.remove(self.Active, 4) end
              else
                self.Active['Pink'] = o
              end
            end
          elseif source.team == TEAM_ENEMY then
            self.Known[#self.Known + 1] = {
              ['color']	 = self.Types[o.charName].color, 
              ['endTime']	 = self.Types[o.charName].duration == huge and huge or clock() + o.mana,
              ['charName'] = source.charName,
              ['isWard']   = self.Types[o.charName].isWard,
              ['object']	 = o,
              ['pos']	     = Vector(o),
              ['mapPos']	 = GetMinimap(Vector(o.pos)),
            }					
          end          
        end
      end
    end
  end
end

function WardTracker:DeleteObj(o)
	if o.valid and o.type == 'AIMinion' and self.Types[o.charName] then
		for i, ward in ipairs(self.Known) do
			if ward.object == o then
				table.remove(self.Known, i)
				return
			end
		end	
	end
end

function WardTracker:Draw()
	if self.Menu.EnableEnemy then 
		for i, ward in ipairs(self.Known) do
			if ward.pos then
				if ward.isWard and self.Menu.DrawRange then
					local wts = WorldToScreen(D3DXVECTOR3(ward.pos.x, ward.pos.y, ward.pos.z))
					local d32 = D3DXVECTOR2(wts.x,wts.y)
					if d32.x > 0 and d32.x < WINDOW_W and d32.y > 0 and d32.y < WINDOW_W then
						local vision = {}
						for theta = 0, (pi2+(pi2/30)), (pi2/30) do
							local p
							for i=20, 1100, 20 do
								local p2 = D3DXVECTOR3(ward.pos.x+(i*cos(theta)), ward.pos.y, ward.pos.z-(i*sin(theta)))
								if IsWall(p2) or i==1100 then
									p = p2
									break
								end
							end
							local tS = WorldToScreen(p)
							vision[#vision + 1] = D3DXVECTOR2(tS.x, tS.y)
						end
						DrawLines2(vision,2,ward.color)
					end
				end
				local text, mapText
				if ward.endTime == huge or self.Menu.MapType==1 then
					mapText = 'o'
					text = ward.charName
				else
					local timer = ward.endTime-clock()
					if self.Menu.Type == 1 then
						mapText = ('%d'):format(timer)
						text = mapText..'\n'..ward.charName
					else
						mapText = ('%d:%.2d'):format(timer/60, timer%60)
						text = mapText..'\n'..ward.charName
					end
				end	
				DrawText3D(text, ward.pos.x, ward.pos.y+85, ward.pos.z+10, self.Menu.Size, ward.color, true)
				local c = GetTextArea(mapText, self.Menu.MapSize)
				DrawText(mapText, self.Menu.MapSize, ward.mapPos.x - (c.x / 2), ward.mapPos.y - (c.y / 2), ward.color)
				if self.Menu.DrawHex then
					self:DrawHex(ward.pos.x, ward.pos.y, ward.pos.z, ward.color)
				end
				if ward.endTime < clock() then
					table.remove(self.Known, i)
					return
				end
			end
		end
	end
	if self.Menu.EnableSelf then
		DrawLine( --Background
			self.Anchor.x - 3, 
			self.Anchor.y, 
			self.Anchor.x + GetScale(70, self.Menu.Scale) + 3, 
			self.Anchor.y, 
			GetScale(95, self.Menu.Scale) + 6, 
			isMenuOpen and 0x77FFFFFF or 0x99838687
		)
		DrawLine( --Background
			self.Anchor.x, 
			self.Anchor.y, 
			self.Anchor.x + GetScale(70, self.Menu.Scale), 
			self.Anchor.y, 
			GetScale(95, self.Menu.Scale), 
			isMenuOpen and 0x77FFFFFF or 0x991C1D20
		)  -- 
    if isMenuOpen then
      local textSize = GetScale(14, self.Menu.Scale)
      local area = GetTextArea('Self',textSize)
      DrawText('Self',textSize,self.Anchor.x+GetScale(35, self.Menu.Scale)-area.x*.5,self.Anchor.y-5-area.y, 0xFFFFFFFF)
      DrawText('Ward',textSize,self.Anchor.x+GetScale(35, self.Menu.Scale)-GetTextArea('Ward',textSize).x*.5,self.Anchor.y-5, 0xFFFFFFFF)
      DrawText('Tracker',textSize,self.Anchor.x+GetScale(35, self.Menu.Scale)-GetTextArea('Tracker',textSize).x*.5,self.Anchor.y-5+area.y, 0xFFFFFFFF)
    else
      for k=1, 3 do
        local v = self.Active[k]
        if v then
          if v.object then
            local t = v.endTime - clock()
            if t < 1 or not v.object or not v.object.valid or v.object.dead then
              table.remove(self.Active, k)
              return
            else
              local str = self.Menu.SelfType == 1 and ('%d'):format(t) or ('%d:%.2d'):format(t/60, t%60)
              local size = GetScale(26, self.Menu.Scale)
              DrawText(
                str, 
                size, 
                self.Anchor.x+GetScale(35, self.Menu.Scale)-GetTextArea(str, size).x*.5, 
                self.Anchor.y + GetScale(42 - (k * 22), self.Menu.Scale), 
                0x9600FF00
              )
            end
          end
        else
          local size = GetScale(26, self.Menu.Scale)
          DrawText(
            '---', 
            size, 
            self.Anchor.x+GetScale(35, self.Menu.Scale)-GetTextArea('---', size).x*.5, 
            self.Anchor.y + GetScale(42 - (k * 22), self.Menu.Scale), 
            0xFFFFFFFF
          )		
        end
      end
      if self.Active['Pink'] then
        if self.Active['Pink'].valid and not self.Active['Pink'].dead then
          local size = GetScale(26, self.Menu.Scale)
          DrawText(
            'Active', 
            size, 
            self.Anchor.x+GetScale(35, self.Menu.Scale)-GetTextArea('Active', size).x*.5, 
            self.Anchor.y - GetScale(46, self.Menu.Scale),  
            0xC8FF32FF
          )
        else
          self.Active['Pink'] = nil
        end
      else
        local size = GetScale(26, self.Menu.Scale)
        DrawText(
          '---', 
          size,
          self.Anchor.x+GetScale(35, self.Menu.Scale)-GetTextArea('---', size).x*.5, 
          self.Anchor.y - GetScale(46, self.Menu.Scale),  
          0x96FF0000
        )
      end
    end
		if self.IsMoving then
			local CursorPos = GetCursorPos()
			self.Anchor.x = min(max(CursorPos.x-self.MovingOffset.x, 3), WINDOW_W-GetScale(70, self.Menu.Scale) - 3)
			self.Anchor.y = min(max(CursorPos.y-self.MovingOffset.y, GetScale(47, self.Menu.Scale))+3, WINDOW_H-GetScale(47, self.Menu.Scale)-3)
			GlobalAnchors.WardTracker = {
				['x'] = self.Anchor.x,
				['y'] = self.Anchor.y,
			}
		end
	end
end

function WardTracker:WndMsg(m,k)
	if (m==WM_LBUTTONDOWN and self.DoubleClickTolerance > clock()) or m==WM_LBUTTONDBLCLK then
    for i, ward in ipairs(self.Known) do
      if GetDistanceSqr(mousePos, ward.pos) < 90000 then
        table.remove(self.Known, i)
        return
      end			
    end
  end
	if m==WM_LBUTTONDOWN then
    self.DoubleClickTolerance = clock() + .4
	end
	if m==WM_LBUTTONDOWN and isMenuOpen then
		local CursorPos = GetCursorPos()
		if CursorPos.x > self.Anchor.x - GetScale(8, self.Menu.Scale) and CursorPos.x < self.Anchor.x + GetScale(181, self.Menu.Scale) then
			if CursorPos.y > self.Anchor.y - GetScale(47.5, self.Menu.Scale) and CursorPos.y < self.Anchor.y + GetScale(47.5, self.Menu.Scale) then
				self.IsMoving = true
				self.MovingOffset = {x=CursorPos.x-self.Anchor.x, y=CursorPos.y-self.Anchor.y,}
			end
		end
	end
	if m==WM_LBUTTONUP and self.IsMoving then
		self.IsMoving=false
	end
end

function WardTracker:ProcessSpell(u, s)
	if u.valid and self.OnSpell[s.name:lower()] then
		local name = s.name:lower()
		if u.team == TEAM_ENEMY then
			local duration = name == 'trinkettotemlvl1' and 56.5 + (GetLevel(u) * 3.5) or self.OnSpell[name].duration
			self.Known[#self.Known+1] = {
				['pos'] 	 = Vector(s.endPos),
				['mapPos']   = GetMinimap(Vector(s.endPos)),
				['color'] 	 = self.OnSpell[name].color,
				['endTime']  = clock()+duration,
				['charName'] = u.charName or 'Unknown',
				['isWard']   = self.OnSpell[name].isWard,
			}
		end
	end
end

function WardTracker:DrawHex(x, y, z, c)
	local p1 = WorldToScreen(D3DXVECTOR3(x+75, y, z))
	if p1.x > -100 and p1.x < WINDOW_W+100 and p1.y < WINDOW_H+100 and p1.y > -100 then
		local count = 1
		self.Hex[count].x, self.Hex[count].y = p1.x, p1.y
		for theta = (pi2/6), pi2, (pi2/6) do
			count=count+1
			local tS = WorldToScreen(D3DXVECTOR3(x+(75*cos(theta)), y, z-(75*sin(theta))))
			self.Hex[count].x, self.Hex[count].y = tS.x, tS.y
		end
		DrawLines2(self.Hex, 1, c)
	end
end

class 'Awareness'

function Awareness:__init()
	self.Packets = GetGameVersion():sub(1, 4) == '7.23' and {
		['LoseVision'] = { ['Header'] = 0x001C, ['pos'] = 2, },
		['GainVision'] = { ['Header'] = 0x018A, ['pos'] = 2, },
	} or GetGameVersion():sub(1,4) == '7.22' and {
		['LoseVision'] = { ['Header'] = 0x00E6, ['pos'] = 2, },
		['GainVision'] = { ['Header'] = 0x0148, ['pos'] = 2, },
	}
	self.recallTimes = {
		['recall'] = 7.9,
		['odinrecall'] = 4.4,
		['odinrecallimproved'] = 3.9,
		['recallimproved'] = 6.9,
		['superrecall'] = 3.9,
		['summonerteleport'] = 4.45,
	}
	self.Anchor = {
		['x'] = GlobalAnchors.RecallBar and GlobalAnchors.RecallBar.x or WINDOW_W - WINDOW_W*.14,
		['x2'] = WINDOW_W *.13,
		['y'] = GlobalAnchors.RecallBar and GlobalAnchors.RecallBar.y or WINDOW_H*.75,
	}
  self.RecallLastTick = {}
	self.ActiveRecalls = {}
	self.Sprites = {}	
	self.Allies = {}
	self.Enemies = {}
	self.JungleTracker = {}
  self.AnimationCheck = {}
  
	for i=0, objManager.maxObjects do
		local o = objManager:getObject(i)
		if o and o.name and o.name:find('__Spawn_T') and o.team == TEAM_ENEMY then
			self.RecallWorldPos = Vector(o.pos)
      self.RecallMapPos = GetMinimap(self.RecallWorldPos)
		end
	end
	for i=1, heroManager.iCount do
		local hero = heroManager:getHero(i)
		if hero.team == TEAM_ENEMY then
			self.Enemies[#self.Enemies + 1] = hero
			self.Sprites[hero.networkID] = createSprite(SPRITE_PATH..'Pewtility\\SideHud\\'..hero.charName..'.png')
      if not hero.visible then
        local p = hero.dead and self.RecallWorldPos or Vector(hero.pos)
				Missing[hero.networkID] = {
					['MapPos'] = GetMinimap(p),
					['Pos'] = Vector(p),
					['CharName'] = hero.charName, 
					['LastSeen'] = clock(),
				}
      end
		else
			self.Allies[#self.Allies + 1] = hero
		end
	end
    
	self:CreateMenu()

  AddDrawCallback(function() self:Draw() end)
  AddAnimationCallback(function(...) self:Animation(...) end)
  AddMsgCallback(function(m,k) self:WndMsg(m,k) end)
  if not self.Packets then
    Print('Opponent Tracking Packets are outdated!!', true)
    return
  end
  AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)
end

function Awareness:Animation(unit, animation)
  if unit.valid and unit.type=='AIMinion' and unit.team==TEAM_ALLY and unit.spell and unit.charName:find('Ranged')==nil and unit.charName:find('Melee')==nil and unit.charName:find('Siege')==nil then
    self.AnimationCheck[#self.AnimationCheck+1] = {
      timeOut = clock()+1,
      unit = unit,
    }
  end
end

function Awareness:CreateMenu()
	MainMenu:addSubMenu('Opponent Tracking', 'MissTracker')
	self.Menu = MainMenu.MissTracker
	self.Menu:addParam('info', '---MIA Tracking---', SCRIPT_PARAM_INFO, '')
  o_valid['---MIA Tracking---']=true
	self.Menu:addParam('Enable', 'Enable', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('TextSize', 'Text Size', SCRIPT_PARAM_SLICE, 14, 14, 24)
	self.Menu:addParam('SpriteSize', 'Sprite Scale', SCRIPT_PARAM_SLICE, 45, 1, 100)
	self.Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('info', '---Recall Tracking---', SCRIPT_PARAM_INFO, '')
  o_valid['---Recall Tracking---']=true
	self.Menu:addParam('EnableRecall', 'Enable', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('RecallScale', 'Scale', SCRIPT_PARAM_SLICE, 100, 50, 100)
	self.Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('info', '---FoW Jungle Tracking---', SCRIPT_PARAM_INFO, '')
  o_valid['---FoW Jungle Tracking---']=true
	self.Menu:addParam('EnableJungle', 'Enable', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('info', '---Path Drawing---', SCRIPT_PARAM_INFO, '')
  o_valid['---Path Drawing---']=true
	self.Menu:addParam('path', 'Enable', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('type', 'Draw Type', SCRIPT_PARAM_LIST, 1, { 'Lines', 'End Position', })
end

function Awareness:RecvPacket(p)
	if p.header == self.Packets.LoseVision.Header then
		p.pos=self.Packets.LoseVision.pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			if o.dead then
				Missing[o.networkID] = {
					['MapPos'] = self.RecallMapPos,
					['CharName'] = o.charName, 
					['LastSeen'] = clock(),
				}			
			else
				Missing[o.networkID] = {
					['MapPos'] = GetMinimap(Vector(o.pos)),
					['Pos'] = Vector(o.pos),
					['CharName'] = o.charName, 
					['LastSeen'] = clock(),
				}
				if GetDistance(o, o.endPath) > 100 then
					Missing[o.networkID].Direction = GetMinimap(Vector(o) + (Vector(o.endPath) - Vector(o)):normalized() * 1200)
				end
				return
			end
		end	
	end
	if p.header == self.Packets.GainVision.Header then
		p.pos=self.Packets.GainVision.pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			Missing[o.networkID] = nil
			return
		end
	end
end

function Awareness:WndMsg(m,k)
	if m==WM_LBUTTONDOWN and isMenuOpen then
		local CursorPos = GetCursorPos()
		if CursorPos.x > self.Anchor.x and CursorPos.x < self.Anchor.x + GetScale(self.Anchor.x2, self.Menu.RecallScale) then
			if CursorPos.y < self.Anchor.y and CursorPos.y > self.Anchor.y - GetScale(128, self.Menu.RecallScale) then
				self.IsMoving = true
				self.MovingOffset = {x=CursorPos.x-self.Anchor.x, y=CursorPos.y-self.Anchor.y,}
			end
		end
	end
	if m==WM_LBUTTONUP and self.IsMoving then
		self.IsMoving=false
	end
end

function Awareness:Draw()
  for i, enemy in ipairs(self.Enemies) do
    if not enemy.dead then
      local currentString = enemy.recall
      if currentString~='' and currentString~=self.RecallLastTick[enemy.networkID] and self.recallTimes[currentString:lower()] then
        self.ActiveRecalls[enemy.networkID] = {
          name = enemy.charName,
          startT = clock(),
          duration = self.recallTimes[currentString:lower()],
          endT = clock() + self.recallTimes[currentString:lower()],	
          isTP = currentString=='SummonerTeleport',
        }
      elseif currentString=='' and self.RecallLastTick[enemy.networkID]~='' and self.ActiveRecalls[enemy.networkID] then
        if self.ActiveRecalls[enemy.networkID].endT > clock() then
          self.ActiveRecalls[enemy.networkID] = nil
        else
          if not self.ActiveRecalls[enemy.networkID].isTP then
            Missing[enemy.networkID] = {
              ['MapPos'] = self.RecallMapPos,
              ['CharName'] = enemy.charName, 
              ['LastSeen'] = clock(),
            }
          end
          self.ActiveRecalls[enemy.networkID].complete = clock() + 3
        end
      end    
      self.RecallLastTick[enemy.networkID] = currentString
    end
  end


	if self.Menu.Enable then   
    for i, m in pairs(Missing) do
      if m then
        local unit = objManager:GetObjectByNetworkId(i)
        local SpriteScale = .2 + (.1 * (self.Menu.SpriteSize * 0.01))			
        local SpriteOffset = (SpriteScale * self.Sprites[i].width) * 0.5
        
        if m.Direction then
          DrawLine(m.Direction.x,m.Direction.y,m.MapPos.x,m.MapPos.y,3,0xFFFF0000)
        end
        self.Sprites[i]:SetScale(SpriteScale, SpriteScale)
        self.Sprites[i]:Draw(m.MapPos.x-SpriteOffset, m.MapPos.y-SpriteOffset, 200)
        local Text = ('%d'):format(clock()-m.LastSeen)
        local TextArea = GetTextArea(Text, self.Menu.TextSize)
        DrawText(Text, self.Menu.TextSize, m.MapPos.x-floor(TextArea.x*0.5), m.MapPos.y-floor(TextArea.y*0.5)+SpriteOffset, 0xFFFF0000)
        
        if m.Pos then
          local v = WorldToScreen(D3DXVECTOR3(m.Pos.x,m.Pos.y,m.Pos.z))
          if v.x>-100 and v.x<WINDOW_W+100 and v.y>-100 and v.y<WINDOW_H+100 then
            self.Sprites[i]:SetScale(.5, .5)
            self.Sprites[i]:Draw(v.x-30, v.y-30, 200)
            
            DrawText(Text, 30, v.x-floor(GetTextArea(Text, 30).x * 0.5), v.y-47, 0xFFFF0000)	
            
            local curHP = unit.charName == 'Kled' and unit.health + unit.mountHealth or unit.health
            local maxHP = unit.charName == 'Kled' and unit.maxHealth + unit.mountMaxHealth or unit.maxHealth
            
            local Text = ('%u / %u'):format(curHP, maxHP)
            local TextArea = floor(GetTextArea(Text, 16).x * 0.5)
            local Width = max(30, TextArea) 
            DrawLine(v.x-Width, v.y+39, v.x+Width,  v.y+39,18, 0x99888888)
            DrawLine(v.x-Width+1, v.y+39, v.x-Width+(Width*2*(curHP/maxHP))-1, v.y+39, 16, 0x99008800)
            DrawText(Text, 16, v.x-TextArea, v.y+30, 0xFFFFFFFF)
          end
        end
      end
    end
  end	
  if self.Menu.EnableRecall then		
		local Scale0 = GetScale(12, self.Menu.RecallScale)
		local Scale1 = GetScale(8, self.Menu.RecallScale)
		local Scale2 = GetScale(2, self.Menu.RecallScale)
		local Scale3 = GetScale(self.Anchor.x2, self.Menu.RecallScale)
		if isMenuOpen then
			for i=0, 4 do 
				local Scale4 = GetScale(i * 30, self.Menu.RecallScale)
				DrawLine(
					self.Anchor.x-2, 
					self.Anchor.y - Scale4, 
					self.Anchor.x + Scale3 + 2, 
					self.Anchor.y - Scale4, 
					GetScale(16, self.Menu.RecallScale) + 4, 
					0x77FFFFFF
				)
				DrawText(
					'Recall Bar Position', 
					Scale0, 
					self.Anchor.x + (Scale3 / 2) - (GetTextArea('Recall Bar Position', Scale0).x / 2), 
					self.Anchor.y - GetScale(6, self.Menu.RecallScale) - Scale4, 
					0xFFFFFFFF
				)	
			end
			if self.IsMoving then
				local CursorPos = GetCursorPos()
				self.Anchor.x = max(min(CursorPos.x-self.MovingOffset.x, WINDOW_W-self.Anchor.x2-4), 4)
				self.Anchor.y = max(min(CursorPos.y-self.MovingOffset.y, WINDOW_H-4-GetScale(8, self.Menu.RecallScale)), GetScale(132, self.Menu.RecallScale))
				GlobalAnchors.RecallBar = {
					['x'] = self.Anchor.x,
					['y'] = self.Anchor.y,
				}
			end
		else
			local RecallCount = 0
			for _, info in pairs(self.ActiveRecalls) do
				local Scale4 = GetScale(RecallCount * 30, self.Menu.RecallScale)
				local percent = (info.endT - clock()) / info.duration
				local x2 = self.Anchor.x + (Scale3 * (percent < 1 and percent or 1))
				DrawLine(
					self.Anchor.x-2, 
					self.Anchor.y - Scale4, 
					self.Anchor.x + Scale3 + 2, 
					self.Anchor.y - Scale4, 
					GetScale(16, self.Menu.RecallScale) + 4, 
					info.isTP and 0x770099FF or 0x77FFFFFF
				)
				DrawLine(
					self.Anchor.x, 
					self.Anchor.y - Scale4, 
					(x2 > self.Anchor.x+1 and x2 or self.Anchor.x), 
					self.Anchor.y - Scale4, 
					GetScale(16, self.Menu.RecallScale), 
					ARGB(255, 255 * percent, 255 - (255 * percent), 0)
				)
				if info.complete and info.complete < clock() then
          self.ActiveRecalls[_] = nil
					return
				end
				local text = info.complete and info.name..' Completed.' or info.isTP and info.name..': Teleport '..max(0, ceil(percent * 100))..'%' or info.name..' '..max(0, ceil(percent * 100))..'%'
				DrawText(
					text, 
					Scale0, 
					self.Anchor.x + (Scale3 / 2) - (GetTextArea(text, Scale0).x / 2), 
					self.Anchor.y - GetScale(6, self.Menu.RecallScale) - Scale4, 
					0xFFFFFFFF
				)	
				RecallCount = RecallCount + 1
			end
		end
	end
	if self.Menu.EnableJungle then	
    if not self.Size then self.Size = 20 end
    for i=#self.JungleTracker, 1, -1 do
      local camp=self.JungleTracker[i]
      
      if camp.startTime + 5 < clock() then
        table.remove(self.JungleTracker, i)
        return
      end
     
      local p, p2 = {}, {}
      for theta = 0, pi2, (pi2/36) do
        local c, s = cos(theta), sin(theta)
        p[#p+1] = D3DXVECTOR2(camp.pos.x+(self.Size*c),camp.pos.y+(self.Size*s))
        if self.Size < 12 then
          local sz = self.Size+3
          p2[#p2+1] = D3DXVECTOR2(camp.pos.x+(sz*c),camp.pos.y+(sz*s))
        end
      end
      
      local ratio = 0xFF * ((clock()-camp.startTime) / 5)
      local color = ARGB(0xFF, ratio, 0xFF-ratio, 0x00)
      DrawLines2(p, 1, color)
      DrawLines2(p2, 1, color)
    end
    self.Size=self.Size-.25
    if self.Size < 6 then self.Size=20 end
  end
	if self.Menu.path then
		for _, e in ipairs(self.Enemies) do
			if e and e.valid and not e.dead and e.visible and e.hasMovePath then
				local points = {}
				local eC = WorldToScreen(D3DXVECTOR3(e.x, 50, e.z))
				points[1] = D3DXVECTOR2(eC.x, eC.y)
				local pathLength = 0
				for i=e.pathIndex, e.pathCount do
					local p1 = e:GetPath(i)
					local p2 = e:GetPath(i-1)
					if p1 then
						local c = WorldToScreen(D3DXVECTOR3(p1.x, 50, p1.z))
						points[#points + 1] = D3DXVECTOR2(c.x, c.y)
						if p2 then
							if (i==e.pathIndex) then
								pathLength = pathLength + GetDistanceSqr(p1, e)
							else
								pathLength = pathLength + GetDistanceSqr(p1, p2)
							end
						end
					end
				end			
				if self.Menu.type == 1 then
					local draw = false
					for i, point in ipairs(points) do
						if point.x > 0 and point.x < WINDOW_W and point.y > 0 and point.y < WINDOW_H then
							draw = true
							break
						end
					end
					if draw then
						DrawLines2(points, 1, 0xFFFF0000)
						local x, y = points[#points].x, points[#points].y
						DrawText(('%.2f'):format(sqrt(pathLength)/(e.ms))..'\n'..e.charName,12,x,y,0xFFFFFFFF)
					end
				else
					local x, y = points[#points].x, points[#points].y
					if x > 0 and x < WINDOW_W and y > 0 and y < WINDOW_H then
						DrawText(('%.2f'):format(sqrt(pathLength)/(e.ms))..'\n'..e.charName,12,x,y,0xFFFFFFFF)
					end
				end
			end
		end
	end
end

class 'HPBars'
 
function HPBars:__init()
	self.Anchor = {
		['x'] = GlobalAnchors.SideHUD and GlobalAnchors.SideHUD.x or WINDOW_W,
		['y'] = GlobalAnchors.SideHUD and GlobalAnchors.SideHUD.y or WINDOW_H * .15,
	}
	self.Anchor2 = {
		['x'] = GlobalAnchors.SummonerCall and GlobalAnchors.SummonerCall.x or 0,
		['y'] = GlobalAnchors.SummonerCall and GlobalAnchors.SummonerCall.y or WINDOW_H / 6,
	}
	self.SkillText = {
		['summonerdot']      		  = 'Ignite',
		['summonerexhaust']  		  = 'Exhaust',
		['summonerflash']    		  = 'Flash',
		['summonerheal']     		  = 'Heal',
		['summonersmite']    		  = 'Smite',
		['summonerbarrier']  		  = 'Barrier',
		['summonerclairvoyance']  = 'Clairvoyance',
		['summonermana']     		  = 'Clarity',
		['summonerteleport']     	= 'Teleport',
		['summonerrevive']     		= 'Revive',
		['summonerhaste']     		= 'Ghost',
		['summonerboost']     		= 'Cleanse',
	}
	self.xOffsets = {
		['AniviaEgg'] = -0.1, --
		['Annie'] = -0.07,
		['Corki'] = -0.07,
		['Darius'] = -0.05,
		['Jhin'] = -0.07,
		['Renekton'] = -0.05,
		['Sion'] = -0.05, --
	}
	self.yOffsets = {
    ['Annie'] = 10, ['Jhin'] = 13, ['Corki'] = 10,
  }
	self.ParTypes = {
    ['Kled'] = 0xFF555555, ['RekSai'] = 0xFFFF3300, ['Vladimir'] = 0xFF000000, ['Katarina'] = 0xFF000000, ['Garen'] = 0xFF000000, ['Riven'] = 0xFF000000, ['DrMundo'] = 0xFF000000, ['Zac'] = 0xFF000000, ['Zed'] = 0xFFFFBB00, ['Akali'] = 0xFFFFBB00, ['Kennen'] = 0xFFFFBB00, ['LeeSin'] = 0xFFFFBB00, ['Shen'] = 0xFFFFBB00, ['Mordekaiser'] = 0xFF555555, ['Tryndamere'] = 0xFFFF3300,
  } --0xFF00AAFF
  self.Names = {
    ['Caitlyn'] = 'cait',['Ezreal'] = 'ez',['KogMaw'] = 'kog',['MasterYi'] = 'yi',['MissFortune'] = 'mf',['Tristana'] = 'trist',['Yasuo'] = 'yas',['AurelionSol'] = 'sol',['Cassiopeia'] = 'cassio',['Evelynn'] = 'eve',['FiddleSticks'] = 'fiddle',['Heimerdinger'] = 'heimer',['Karthus'] = 'karth',['Kassadin'] = 'kass',['Katarina'] = 'kat',['Leblanc'] = 'lb',['Lissandra'] = 'liss',['Malzahar'] = 'malz',['Mordekaiser'] = 'morde',['Nidalee'] = 'nid',['Orianna'] = 'ori',['Taliyah'] = 'tal',['TwistedFate'] = 'tf',['Veigar'] = 'veig',['Viktor'] = 'vik',['Velkoz'] = 'vel',['Zilean'] = 'zil',['Morgana'] = 'morg',['Pantheon'] = 'panth',['Tryndamere'] = 'trynd',['Gangplank'] = 'gp',['Chogath'] = 'cho',['Blitzcrank'] = 'blitz',['JarvanIV'] = 'j4',['Khazix'] = 'k6',['Vladimir'] = 'vlad',['MonkeyKing'] = 'wukong',['XinZhao'] = 'xin',['LeeSin'] = 'lee',['Gragas'] = 'grag',['Nocturne'] = 'noc',['RekSai'] = 'rek',['Renekton'] = 'rene',['Shyvana'] = 'shyv',['Hecarim'] = 'hec',['Alistar'] = 'ali',['Leona'] = 'leo',['TahmKench'] = 'tahm',['DrMundo'] = 'mundo',['Malphite'] = 'malph',['Maokai'] = 'mao',['Sejuani'] = 'sej',['Nautilus'] = 'naut',['Volibear'] = 'voli',['Warwick'] = 'ww',
  }
	self.SpellNames = {
		['summonerdot']      		  = 'ign',
		['summonerexhaust']  		  = 'exh',
		['summonerflash']    		  = 'f',
		['summonerheal']     		  = 'heal',
		['summonerbarrier']  		  = 'bar',
		['summonerteleport']     	= 'tp',
		['summonerhaste']     		= 'ghost',
	}
  self.SpecialParTypes = {
		['Aatrox'] = function(unit) return unit.mana == 100 and 0xFFFF3300 or 0xFF555555 end, 
		['Gnar'] = function(unit) return myHero.range == 410.5 and 0xFF555555 or 0xFFFF3300 end, 
		['Renekton'] = function(unit) return unit.mana > 50 and 0xFFFF3300 or 0xFF555555 end, 
		['Rengar'] = function(unit) return unit.mana < 5 and 0xFF555555 or 0xFFFF3300 end,
		['Rumble'] = function(unit) return unit.mana < 50 and 0xFF555555 or unit.mana < 100 and 0xFFFF9900 end,
		['Shyvana'] = function(unit) return unit.mana == 100 and 0xFFFF3300 or 0xFFFF9900 end,
		['Yasuo'] = function(unit) return unit.mana==unit.maxMana and 0xFFFF3300 or 0xFF555555 end, 
	}
	self.PassiveCooldowns = {
    ['Aatrox'] = 'aatroxpassiveactivate',
    ['Anivia'] = 'rebirthcooldown',
    ['Blitzcrank'] = 'manabarriercooldown',
    ['Volibear'] = 'volibearpassivecd',
    ['Zac'] = 'zacrebirthcooldown',
  }
  self.Heroes = {}
  self.IsDead = {}
  self.DeathTimers = {}
  self.SummonerChat = {}
  self.SpellDataValues = {}
  
	for i=1, heroManager.iCount do
		local hero = heroManager:getHero(i)
		if hero.team==TEAM_ENEMY or not hero.isMe then
			self.Heroes[#self.Heroes+1] = {
				['hero'] = hero,
				['icon'] = createSprite('Pewtility/SideHud/'..hero.charName..'.png'),
				['sum1'] = createSprite('Pewtility/'..hero:GetSpellData(SUMMONER_1).name..'.png'),
				['sum2'] = createSprite('Pewtility/'..hero:GetSpellData(SUMMONER_2).name..'.png'),
				['t1'] = self.SkillText[hero:GetSpellData(SUMMONER_1).name:lower()],
				['t2'] = self.SkillText[hero:GetSpellData(SUMMONER_2).name:lower()],
			}
      self.SpellDataValues[hero.networkID] = {[_Q]={update=0}, [_W]={update=0}, [_E]={update=0}, [_R]={update=0}, [SUMMONER_1]={update=0}, [SUMMONER_2]={update=0},}
      if self.PassiveCooldowns[hero.charName] then
        self.Heroes[#self.Heroes]['passive'] = createSprite('Pewtility/'..self.PassiveCooldowns[hero.charName]..'.png')        
      end
		end
	end
  
	self:CreateMenu()
	self.Sprite = createSprite('Pewtility/barTemplate_r3.png')
	self.LevelSprite = createSprite('Pewtility/levelSqaure.png')
	
	DelayAction(function() AddDrawCallback(function() self[self.Menu.Legacy and 'DrawLegacy' or 'Draw'](self) end) end, 3)
  AddMsgCallback(function(...) self:WndMsg(...) end)
  AddProcessSpellCallback(function(...) self:ProcessSpell(...) end)
end

function HPBars:CreateMenu()
	MainMenu:addSubMenu('Cooldown Tracking', 'CooldownTracker2')
	self.Menu = MainMenu.CooldownTracker2
	self.Menu:addParam('info', '---Cooldown Tracking---', SCRIPT_PARAM_INFO, '')
  o_valid['---Cooldown Tracking---']=true
	self.Menu:addParam('DrawEnemy', 'Enable Enemies', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('DrawAlly', 'Enable Allies', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('DrawSideHud', 'Enable Side HUD', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('SPACE', '', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('info', '---Summoner Calling---', SCRIPT_PARAM_INFO, '')
  o_valid['---Summoner Calling---']=true
	self.Menu:addParam('OnScreen', 'On Screen Spells Only', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('Scale2', 'Scale', SCRIPT_PARAM_SLICE, 100, 50, 100)
	self.Menu:addParam('SPACE', '', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('info', '---Use Legacy Tracker---', SCRIPT_PARAM_INFO, '')
  o_valid['---Use Legacy Tracker---']=true
	self.Menu:addParam('Legacy', 'Enable', SCRIPT_PARAM_ONOFF, false)
end

function HPBars:DeathCheck()
  for _, info in ipairs(self.Heroes) do
    local unit = info.hero
    if unit.team==TEAM_ENEMY then
      if unit.dead then
        if not self.IsDead[unit.networkID] then
          local duration
          if _Game.Map.Name == 'HowlingAbyss' then
            duration = GetLevel(unit) * 2 + 4
          else
            local base = (GetLevel(unit) * 2.5) + 7.5
            local GT = GetInGameTimer()
            local minutes = floor(GT/60)
            if GT > 3210 then
              duration = base * 1.5
            elseif GT > 2700 then
              duration = base + ((base / 100) * (minutes - 15) * 2 * 0.425) + ((base / 100) * (minutes - 30) * 2 * 0.30) + ((base / 100) * (minutes - 45) * 2 * 1.45)
            elseif GT > 1800 then
              duration = base + ((base / 100) * (minutes - 15) * 2 * 0.425) + ((base / 100) * (minutes - 30) * 2 * 0.30)
            elseif GT > 900 then
              duration = base + ((base / 100) * (minutes - 15) * 2 * 0.425)
            else
              duration = base
            end
          end          
          self.IsDead[unit.networkID] = {
            start = clock(),
            duration = duration,
          }
        end
      else
        self.IsDead[unit.networkID] = nil
      end
    end
  end
end

function HPBars:SummonerCalls(CursorPos)
  for i=#self.SummonerChat, 1, -1 do
    local info = self.SummonerChat[i]
    if info.endTime > clock() then
      local s = GetScale2(.45, self.Menu.Scale2)
      local iconWidth = self.Heroes[info.heroIndex].icon.width * s
      local height = iconWidth + 20
      local y = self.Anchor2.y + (i-1)*(height+8)
      
      info.mouseIsOver = CursorPos.x > self.Anchor2.x and CursorPos.x < self.Anchor2.x+iconWidth*2+14 and CursorPos.y > y-height*.5 and CursorPos.y < y+height*.5
      
      local opacity = info.mouseIsOver and 0xFF or 0x99
      
      DrawLine(self.Anchor2.x-2,y,self.Anchor2.x+iconWidth*2+14,y,height+4,ARGB(opacity, 0x83, 0x86, 0x87))
      DrawLine(self.Anchor2.x,y,self.Anchor2.x+iconWidth*2+12,y,height,ARGB(opacity, 0x1C, 0x1D, 0x20))
      
      DrawLine(self.Anchor2.x+4,y+height*.5-7,self.Anchor2.x+iconWidth*2+8,y+height*.5-7,6,ARGB(opacity, 0x83, 0x86, 0x87))
      DrawLine(self.Anchor2.x+6,y+height*.5-7,self.Anchor2.x+6+iconWidth*2*(info.endTime-clock())/15,y+height*.5-7,2, 0xFFA9A9FE)      
      
      self.Heroes[info.heroIndex].icon:SetScale(s, s)
      self.Heroes[info.heroIndex][info.spellIndex]:SetScale(GetScale2(.84375, self.Menu.Scale2), GetScale2(.84375, self.Menu.Scale2))
      
      self.Heroes[info.heroIndex].icon:Draw(self.Anchor2.x+4, y-height*.5+4, opacity)
      self.Heroes[info.heroIndex][info.spellIndex]:Draw(self.Anchor2.x+8+iconWidth, y-height*.5+4, opacity)
    else
      table.remove(self.SummonerChat, i)
    end
  end 
end

function HPBars:Draw()
  local CursorPos = GetCursorPos()
  self:DeathCheck()
  
	if isMenuOpen then
    if self.Menu.DrawSideHud then
      local x = self.Anchor.x - 184
      DrawLine(self.Anchor.x+3, self.Anchor.y+135, x-3, self.Anchor.y+135, 282, 0x77FFFFFF)
      DrawLine(self.Anchor.x, self.Anchor.y+135, x, self.Anchor.y+135, 276, 0x77FFFFFF)
      DrawText('Side HUD Position', 18, self.Anchor.x - 92 - GetTextArea('Side HUD Position', 18).x*.5, self.Anchor.y+135, 0xFFFFFFFF)    
      if self.IsMoving then
        local CursorPos = GetCursorPos()
        self.Anchor.x = max(min(CursorPos.x-self.MovingOffset.x, WINDOW_W-3), 187)
        self.Anchor.y = max(min(CursorPos.y-self.MovingOffset.y, WINDOW_H-276), 6)
        GlobalAnchors.SideHUD = {
          ['x'] = self.Anchor.x,
          ['y'] = self.Anchor.y,
        }
      end
    end
    
    local h = 120 * GetScale2(.45, self.Menu.Scale2)
    local x = self.Anchor2.x + h * 2 + 14 
    DrawLine(self.Anchor2.x-3,self.Anchor2.y,x+3,self.Anchor2.y, h+26, 0x77FFFFFF)
    DrawLine(self.Anchor2.x,self.Anchor2.y,x,self.Anchor2.y, h+20, 0x77FFFFFF)
    local textSize = GetScale(12, self.Menu.Scale2)
    DrawText('Summoner Buttons', textSize, self.Anchor2.x + h + 7 - GetTextArea('Summoner Buttons', textSize).x * .5,self.Anchor2.y-6,0xFFFFFFFF)    
    if self.Anchor2.Dragging then
      local CursorPos = GetCursorPos()
      self.Anchor2.x = max(min(CursorPos.x-self.Anchor2.ox, WINDOW_W - h * 2 - 17), 3)
      self.Anchor2.y = max(min(CursorPos.y-self.Anchor2.oy, WINDOW_H - 60 * GetScale2(.45, self.Menu.Scale2)) - 13, 60 * GetScale2(.45, self.Menu.Scale2) + 13)
      GlobalAnchors.SummonerCall = {
        ['x'] = self.Anchor2.x,
        ['y'] = self.Anchor2.y,
      }
    end
    return
  end
  
  self:SummonerCalls(CursorPos)  
 
  local count = 0  
	for _, info in ipairs(self.Heroes) do
    local unit = info.hero
		if unit.valid then
      if unit.team == TEAM_ALLY then
        if self.Menu.DrawAlly then
          if not unit.dead then
            local barX, barY = self:BarData(unit)
            if barX > -100 and barX < WINDOW_W + 100 and barY > -100 and barY < WINDOW_H + 100 then
              self:DrawBar(unit, barX, barY, info)              
            end
          end
        end
      else
        if self.Menu.DrawEnemy then
          if unit.visible and not unit.dead then
            local barX, barY = self:BarData(unit)
            if barX > -100 and barX < WINDOW_W + 100 and barY > -100 and barY < WINDOW_H + 100 then
              self:DrawBar(unit, barX, barY, info)              
            end
          end
        end
        if self.Menu.DrawSideHud then          
          local barX, barY = self.Anchor.x - 184, self.Anchor.y + 57*count
          local iconX, iconY = barX+134, barY
          
          self:DrawBar(unit, barX, barY, info, true) --draw hp/mana/passive on here          
          info.icon:SetScale(0.45, 0.45)
          info.icon:Draw(iconX, iconY, 255)
          
          if unit.dead and self.IsDead[unit.networkID] then
            local text = ('%d'):format(self.IsDead[unit.networkID].duration - (clock() - self.IsDead[unit.networkID].start))
            DrawLine(iconX, iconY+27, iconX+54, iconY+27, 54,0xAABB0000)            
            DrawText(text, 32, iconX + 27 - GetTextArea(text,32).x*0.5, iconY+9, 0xFFFFFFFF)
          elseif not unit.visible then
            DrawLine(iconX, iconY+27, iconX+54, iconY+27, 54,0xAA888888)
            if Missing[unit.networkID] then
              local text = ('%d'):format(clock()-Missing[unit.networkID].LastSeen)
              DrawText(text, 32, iconX + 27 - GetTextArea(text,32).x*0.5, iconY+9, 0xFFFFFFFF)
            end
          end            
          count=count+1
        end
      end
		end
	end
end

function HPBars:SpellData(unit, slot)
  local v = self.SpellDataValues[unit.networkID][slot]
  if v.update < clock() then
    if slot<SUMMONER_1 then
      local d = unit:GetSpellData(slot)
      v.level = d.level
      v.cd = d.cd
      v.currentCd = d.currentCd
      v.update = clock() + 0.25
    else
      v.currentCd = unit:GetSpellData(slot).currentCd
      v.update = clock() + 1
    end
  end
  return v
end

function HPBars:DrawBar(unit, barX, barY, info, isSideBar)
  self.Sprite:Draw(barX, barY, 255)  
  --Spells
  for i=_Q, _R do
    local d = self:SpellData(unit, i)
    if d.level>0 then
      local h, c = max(min(16*(d.cd>0 and d.currentCd/d.cd or 0), 16), 0), 0x99990000
      if d.currentCd==0 then
        h, c = 17, 0x99009900
      end
      local x, y = barX + (i+1)*20 - 10, barY+26
      DrawLine(x, y-h, x, y, 17, c)
    end
  end  
  
  --Summoners
  info.sum1:SetScale(.34375, .34375)
  info.sum1:Draw(barX+86, barY+3, 255)  
  local sum1Cd = self:SpellData(unit, SUMMONER_1).currentCd  
  if sum1Cd~=0 then
    local text = ('%u'):format(sum1Cd)
    local mTextArea = GetTextArea(mText, 12)
    DrawLine(barX+86, barY+14, barX+108, barY+14, 23, 0x99222222)
    DrawText(text, 11, barX+97-GetTextArea(text, 11).x*.5, barY+9, 0xFFFFFFFF)
  end
  
  info.sum2:SetScale(.34375, .34375)
  info.sum2:Draw(barX+110, barY+3, 255)  
  local sum2Cd = self:SpellData(unit, SUMMONER_2).currentCd
  if sum2Cd~=0 then
    local text = ('%u'):format(sum2Cd)
    DrawLine(barX+110, barY+14, barX+132, barY+14, 23, 0x99222222)
    DrawText(text, 11, barX+121-GetTextArea(text, 11).x*.5, barY+9, 0xFFFFFFFF)
  end
  
  if isSideBar then
    DrawLine(barX+2, barY+36, barX+108, barY+36, 15, 0xFF000000)
    
    --HP
    local curHP, maxHP = unit.dead and 0 or unit.health, unit.maxHealth
    if unit.charName=='Kled' and not unit.dead then
      curHP, maxHP = unit.health + unit.mountHealth, unit.maxHealth + unit.mountMaxHealth
    end
    local hpOffset = min(104, max(0, 104*(curHP/maxHP)))
    DrawLine(barX+3, barY+32, barX+3+hpOffset, barY+32, 3, 0xFFBA5141)
    DrawLine(barX+3, barY+36, barX+3+hpOffset, barY+36, 4, 0xFFAC2E1A)
    
    --MP
    local mpColor = self.ParTypes[unit.charName] or self.SpecialParTypes[unit.charName] and self.SpecialParTypes[unit.charName](unit) or 0xFF00AAFF
    if mpColor ~= 0xFF000000 then
      local mpOffset = min(104, max(0, 104*(unit.mana/unit.maxMana)))
      DrawLine(barX+3, barY+40, barX+3+mpOffset, barY+40, 2, mpColor)
      DrawLine(barX+3, barY+42, barX+3+mpOffset, barY+42, 2, mpColor)
    end    
    
    --Level
    local text = unit.level..''
    self.LevelSprite:Draw(barX+110, barY+29, 255)
    DrawText(text,18,barX+121-GetTextArea(text, 18).x*.5,barY+31,0xFFFFFFFF)    
    
    if info.passive then
      info.passive:SetScale(0.625, 0.625)
      info.passive:Draw(barX-40, barY+7, 255)
      
      local passiveCd = 0
      for i=1, 64 do
        local b = unit:getBuff(i)
        if b and b.name and self.PassiveCooldowns[unit.charName]==b.name and b.endT>GetInGameTimer() then
          passiveCd = b.endT-GetInGameTimer()
          break
        end
      end
      if passiveCd~=0 then
        local text = ('%u'):format(passiveCd)
        DrawLine(barX-40, barY+27, barX, barY+27, 40,0xAA888888)        
        DrawText(text, 24, barX-20-GetTextArea(text,24).x*0.5, barY+15, 0xFFFFFFFF)
      end          
    end
  end
end

function HPBars:DrawLegacy()
	for _, info in ipairs(self.Heroes) do
		if info.hero.valid and info.hero.visible and not info.hero.dead and ((info.hero.team == myHero.team and self.Menu.DrawAlly) or (info.hero.team ~= myHero.team and self.Menu.DrawEnemy)) then
			local barX, barY = self:BarData(info.hero)
			if barX > -100 and barX < WINDOW_W + 100 and barY > -100 and barY < WINDOW_H + 100 then
				barX, barY = barX+30, barY+12
				DrawLine(barX-29,barY+51,barX+62,barY+51,29,info.hero.team == myHero.team and 0xDC72D5F2 or 0xDCCC7E72)
				for i=_Q, _R do
					local data = info.hero:GetSpellData(i)
					local x = barX-27+(i*22)
					local y = barY+44
					if data.level > 0 then
						if data.currentCd ~= 0 then
							local cda=data.cd>0 and data.cd or 0
							local cd = cda-(cda-data.currentCd)
							DrawLine(x, y, x+((cd / cda) * 21), y, 12, 0xFFFF7D00)
							DrawLine(x+((cd / cda) * 21), y, x+21, y, 12, 0xFF808080)
              local text = ('%i'):format(cd)
              local tA = GetTextArea(text, 14)
              DrawText(text, 14, x + 11 - (tA.x / 2), y - (tA.y / 2), 0xFFFFFFFF)
						else
							DrawLine(x,y,x+21,y,12,0xFF00AA00)							
						end
					else
						DrawLine(x,y,x+21,y,12,0xFF808080)							
					end
				end
				for i=SUMMONER_1, SUMMONER_2 do
					local data = info.hero:GetSpellData(i)					
					local x = barX-27+((i-4)*42) + ((i-4)*2.5)
					local y = barY+47
					local text = info['t'..(i-3)]
					if data.currentCd ~= 0 then
						local cda = data.cd>0 and data.cd or 0
						local cd = cda-(cda-data.currentCd)
						DrawLine(x, y+11, x+((cd / cda) * 42), y+11, 12, 0xFFFF7D00)
						DrawLine(x+((cd / cda) * 42), y+11, x+42, y+11, 12, 0xFF808080)
						--self.CallTimers[enemy.charName] = {x=x, y=y+5,t=floor(data.currentCd+GetInGameTimer()), text=text}
					else
						DrawLine(x, y+11, x+42, y+11, 12, 0xFF00AA00)								
					end
          local tA = GetTextArea(text, 11)
          DrawText(text, 11, x + 22 - (tA.x / 2), y + 11 - (tA.y / 2), 0xFFFFFFFF)
				end
			end
		end
	end
end

function HPBars:BarData(enemy)
	local barPos = GetUnitHPBarPos(enemy)
	local barOff = GetUnitHPBarOffset(enemy)
	return barPos.x + round((self.xOffsets[enemy.charName] or barOff.x) * 140) - 69, barPos.y + round(barOff.y * 53) - 32 - (self.yOffsets[enemy.charName] or 0)
end

function HPBars:ProcessSpell(unit, spell)
  if unit.valid and unit.type=='AIHeroClient' and unit.team==TEAM_ENEMY and self.SpellNames[spell.name:lower()] then
    local isOnScreen = not self.Menu.OnScreen
    if not isOnScreen then
      local p = WorldToScreen(D3DXVECTOR3(unit.x,unit.y,unit.z))
      isOnScreen=p.x>-100 and p.x<WINDOW_W+100 and p.y>-100 and p.y<WINDOW_H+100
    end
    if isOnScreen then
      local heroIndex, spellIndex = nil, unit:GetSpellData(SUMMONER_1).name:lower()==spell.name:lower() and 'sum1' or 'sum2'
      for i, h in ipairs(self.Heroes) do if h.hero==unit then heroIndex=i end end
      local name = self.Names[unit.charName] or unit.charName:lower()
      local text = name..' '..self.SpellNames[spell.name:lower()]
      local cdTime = GetInGameTimer() + unit:GetSpellData(spellIndex=='sum1' and SUMMONER_1 or SUMMONER_2).cd
      table.insert(self.SummonerChat, {
        endTime = clock() + 15,
        spellIndex = spellIndex,
        heroIndex = heroIndex,
        text = text..(' %d%.2d'):format(cdTime/60, floor((cdTime%60)/10)*10),
      })
    end
  end
end

function HPBars:WndMsg(m, k)
	if m==WM_LBUTTONDOWN then
    if isMenuOpen then
      local CursorPos = GetCursorPos()
      if CursorPos.x < self.Anchor.x and CursorPos.x > self.Anchor.x - 184 then
        if CursorPos.y > self.Anchor.y and CursorPos.y < self.Anchor.y + 276 then
          self.IsMoving = true
          self.MovingOffset = {x=CursorPos.x-self.Anchor.x, y=CursorPos.y-self.Anchor.y,}
        end
      end
      if CursorPos.x > self.Anchor2.x and CursorPos.x < self.Anchor2.x + 120 * GetScale2(.45, self.Menu.Scale2) * 2 + 14 then
        if CursorPos.y > self.Anchor2.y - 120 * GetScale2(.45, self.Menu.Scale2) and CursorPos.y < self.Anchor2.y + 120 * GetScale2(.45, self.Menu.Scale2) then          
          self.Anchor2.Dragging = true
          self.Anchor2.ox = CursorPos.x-self.Anchor2.x
          self.Anchor2.oy = CursorPos.y-self.Anchor2.y
        end
      end
    end
    for i, info in ipairs(self.SummonerChat) do
      if info.mouseIsOver then
        SendChat(info.text)
        table.remove(self.SummonerChat, i)
        return
      end
    end
  end
	if m==WM_LBUTTONUP and (self.IsMoving or self.Anchor2.Dragging) then
		self.IsMoving=false
    self.Anchor2.Dragging = false
	end
end

class 'JungleTimers'

function JungleTimers:__init()
	self.Packets = GetGameVersion():sub(1,4) == '7.23' and {
		['Jungle'] = { ['Header'] = 0x00A3, ['campPos'] = 19, ['idPos'] = 11, ['idZero'] = 0xC7C7C7C7, }, --size 24 
		['Inhibitor'] = { ['Header'] = 0x00BA, ['pos'] = 2, },  --size 19
		['SummonerRift'] = {
			[0xFB] = { ['pos'] = Vector(3850, 60, 7880),  ['time'] = 300, ['spawn'] = 90, ['mapPos'] = GetMinimap(Vector(3850, 60, 7880)),  }, --Blue Side Blue Buff
			[0x8D] = { ['pos'] = Vector(3800, 60, 6500),  ['time'] = 150, ['spawn'] = 90,  ['mapPos'] = GetMinimap(Vector(3800, 60, 6500)),  }, --Blue Side Wolves
			[0xBB] = { ['pos'] = Vector(7000, 60, 5400),  ['time'] = 150, ['spawn'] = 90,  ['mapPos'] = GetMinimap(Vector(7000, 60, 5400)),  }, --Blue Side Raptors
			[0x34] = { ['pos'] = Vector(7800, 60, 4000),  ['time'] = 300, ['spawn'] = 90, ['mapPos'] = GetMinimap(Vector(7800, 60, 4000)),  }, --Blue Side Red Buff
			[0xA3] = { ['pos'] = Vector(8400, 60, 2700),  ['time'] = 150, ['spawn'] = 102, ['mapPos'] = GetMinimap(Vector(8400, 60, 2700)),  }, --Blue Side Krugs
			[0xFA] = { ['pos'] = Vector(9866, 60, 4414),  ['time'] = 360, ['spawn'] = 140, ['mapPos'] = GetMinimap(Vector(9866, 60, 4414)),  ['isDragon'] = true, }, --Dragon
			[0x9E] = { ['pos'] = Vector(10950, 60, 7030), ['time'] = 300, ['spawn'] = 90, ['mapPos'] = GetMinimap(Vector(10950, 60, 7030)), }, --Red Side Blue Buff
			[0x81] = { ['pos'] = Vector(11000, 60, 8400), ['time'] = 150, ['spawn'] = 90,  ['mapPos'] = GetMinimap(Vector(11000, 60, 8400)), }, --Red Side Wolves	
			[0x14] = { ['pos'] = Vector(7850, 60, 9500),  ['time'] = 150, ['spawn'] = 90,  ['mapPos'] = GetMinimap(Vector(7850, 60, 9500)),  }, --Red Side Raptors
			[0xE6] = { ['pos'] = Vector(7100, 60, 10900), ['time'] = 300, ['spawn'] = 90, ['mapPos'] = GetMinimap(Vector(7100, 60, 10900)), }, --Red Side Red Buff
			[0x3E] = { ['pos'] = Vector(6400, 60, 12250), ['time'] = 150, ['spawn'] = 102, ['mapPos'] = GetMinimap(Vector(6400, 60, 12250)), }, --Red Side Krugs
			[0xB8] = { ['pos'] = Vector(4950, 60, 10400), ['time'] = 420,                  ['mapPos'] = GetMinimap(Vector(4950, 60, 10400)), }, --Baron --19:51
			[0x02] = { ['pos'] = Vector(2200, 60, 8500),  ['time'] = 150, ['spawn'] = 102, ['mapPos'] = GetMinimap(Vector(2200, 60, 8500)),  }, --Blue Side Gromp
			[0x13] = { ['pos'] = Vector(12600, 60, 6400), ['time'] = 150, ['spawn'] = 102, ['mapPos'] = GetMinimap(Vector(12600, 60, 6400)), }, --Red Side Gromp
			[0xBC] = { ['pos'] = Vector(10500, 60, 5170), ['time'] = 180, ['spawn'] = 135, ['mapPos'] = GetMinimap(Vector(10500, 60, 5170)), }, --Dragon Crab
			[0xED] = { ['pos'] = Vector(4400, 60, 9600),  ['time'] = 180, ['spawn'] = 135, ['mapPos'] = GetMinimap(Vector(4400, 60, 9600)),  }, --Baron Crab
			[0xFFD23C3E] = { ['pos'] = Vector(1170, 90, 3570),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(1170, 91, 3570)),   }, --Blue Top Inhibitor
			[0xFF4A20F1] = { ['pos'] = Vector(3203, 92, 3208),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3203, 92, 3208)),   }, --Blue Middle Inhibitor
			[0xFF9303E1] = { ['pos'] = Vector(3452, 89, 1236),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3452, 89, 1236)),   }, --Blue Bottom Inhibitor
			[0xFF6793D0] = { ['pos'] = Vector(11261, 88, 13676), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(11261, 88, 13676)), }, --Red Top Inhibitor
			[0xFFFF8F1F] = { ['pos'] = Vector(11598, 89, 11667), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(11598, 89, 11667)), }, --Red Middle Inhibitor
			[0xFF26AC0F] = { ['pos'] = Vector(13604, 89, 11316), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(13604, 89, 11316)), }, --Red Bottom Inhibitor				
		},
		['TwistedTreeline'] = {
			[0xFB] = { ['pos'] =  Vector(4414, 60, 5774), ['time'] =  75, ['spawn'] = 65, ['mapPos'] = GetMinimap(Vector(4414, 60, 5774)),  },
			[0x8D] = { ['pos'] =  Vector(5088, 60, 8065), ['time'] =  75, ['spawn'] = 65, ['mapPos'] = GetMinimap(Vector(5088, 60, 8065)),  },
			[0xBB] = { ['pos'] =  Vector(6148, 60, 5993), ['time'] =  75, ['spawn'] = 65, ['mapPos'] = GetMinimap(Vector(6148, 60, 5993)),  },
			[0x34] = { ['pos'] = Vector(11008, 60, 5775), ['time'] =  75, ['spawn'] = 65, ['mapPos'] = GetMinimap(Vector(11008, 60, 5775)), },
			[0xA3] = { ['pos'] = Vector(10341, 60, 8084), ['time'] =  75, ['spawn'] = 65, ['mapPos'] = GetMinimap(Vector(10341, 60, 8084)), },
			[0xFA] = { ['pos'] =  Vector(9239, 60, 6022), ['time'] =  75, ['spawn'] = 65, ['mapPos'] = GetMinimap(Vector(9239, 60, 6022)),  },
			[0x9E] = { ['pos'] =  Vector(7711, 60, 6722), ['time'] =  90, ['spawn'] = 150, ['mapPos'] = GetMinimap(Vector(7711, 60, 6722)), },
			[0x81] = { ['pos'] = Vector(7711, 60, 10080), ['time'] = 360, ['spawn'] = 600, ['mapPos'] = GetMinimap(Vector(7711, 60, 10080)),},
			[0xFFD303E1] = { ['pos'] = Vector(2126, 11, 6146),   ['time'] = 240, ['mapPos'] = GetMinimap(Vector(2126, 11, 6146)),   }, --Left Bottom Inhibitor
			[0xFFD23C3E] = { ['pos'] = Vector(2146, 11, 8420),   ['time'] = 240, ['mapPos'] = GetMinimap(Vector(2146, 11, 8420)),   }, --Left Top Inhibitor
			[0xFF26AC0F] = { ['pos'] = Vector(13285, 17, 6124),  ['time'] = 240, ['mapPos'] = GetMinimap(Vector(13285, 17, 6124)),  }, --Right Bottom Inhibitor
			[0xFF6793D0] = { ['pos'] = Vector(13275, 17, 8416),  ['time'] = 240, ['mapPos'] = GetMinimap(Vector(13275, 17, 8416)),  }, --Right Top Inhibitor			
		},
		['HowlingAbyss'] = {
			[0xFB] = { ['pos'] = Vector(7582, -100, 6785), ['time'] =  60, ['spawn'] = 120, ['mapPos'] = GetMinimap(Vector(7582, -100, 6785)), },
			[0x8D] = { ['pos'] = Vector(5929, -100, 5190), ['time'] =  60, ['spawn'] = 120, ['mapPos'] = GetMinimap(Vector(5929, -100, 5190)), },
			[0xBB] = { ['pos'] = Vector(8893, -100, 7889), ['time'] =  60, ['spawn'] = 120, ['mapPos'] = GetMinimap(Vector(8893, -100, 7889)), },
			[0x34] = { ['pos'] = Vector(4790, -100, 3934), ['time'] =  60, ['spawn'] = 120, ['mapPos'] = GetMinimap(Vector(4790, -100, 3934)), },
			[0xFF4A20F1] = { ['pos'] = Vector(3110, -201, 3189), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3110, -201, 3189)), }, --Bottom Inhibitor
			[0xFFFF8F1F] = { ['pos'] = Vector(9689, -190, 9524), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(9689, -190, 9524)), }, --Top Inhibitor			
		},
	} or GetGameVersion():sub(1,4) == '7.22' and {
		['Jungle'] = { ['Header'] = 0x005B, ['campPos'] = 6, ['idPos'] = 15, ['idZero'] = 0xB5B5B5B5, }, --size 24 
		['Inhibitor'] = { ['Header'] = 0x00F4, ['pos'] = 2, },  --size 19
		['SummonerRift'] = {
			[0x44] = { ['pos'] = Vector(3850, 60, 7880),  ['time'] = 300, ['spawn'] = 90, ['mapPos'] = GetMinimap(Vector(3850, 60, 7880)),  }, --Blue Side Blue Buff
			[0x2B] = { ['pos'] = Vector(3800, 60, 6500),  ['time'] = 150, ['spawn'] = 90,  ['mapPos'] = GetMinimap(Vector(3800, 60, 6500)),  }, --Blue Side Wolves
			[0xC9] = { ['pos'] = Vector(7000, 60, 5400),  ['time'] = 150, ['spawn'] = 90,  ['mapPos'] = GetMinimap(Vector(7000, 60, 5400)),  }, --Blue Side Raptors
			[0x00] = { ['pos'] = Vector(7800, 60, 4000),  ['time'] = 300, ['spawn'] = 90, ['mapPos'] = GetMinimap(Vector(7800, 60, 4000)),  }, --Blue Side Red Buff
			[0x97] = { ['pos'] = Vector(8400, 60, 2700),  ['time'] = 150, ['spawn'] = 102, ['mapPos'] = GetMinimap(Vector(8400, 60, 2700)),  }, --Blue Side Krugs
			[0xA2] = { ['pos'] = Vector(9866, 60, 4414),  ['time'] = 360, ['spawn'] = 140, ['mapPos'] = GetMinimap(Vector(9866, 60, 4414)),  ['isDragon'] = true, }, --Dragon
			[0x2C] = { ['pos'] = Vector(10950, 60, 7030), ['time'] = 300, ['spawn'] = 90, ['mapPos'] = GetMinimap(Vector(10950, 60, 7030)), }, --Red Side Blue Buff
			[0x3A] = { ['pos'] = Vector(11000, 60, 8400), ['time'] = 150, ['spawn'] = 90,  ['mapPos'] = GetMinimap(Vector(11000, 60, 8400)), }, --Red Side Wolves	
			[0xF2] = { ['pos'] = Vector(7850, 60, 9500),  ['time'] = 150, ['spawn'] = 90,  ['mapPos'] = GetMinimap(Vector(7850, 60, 9500)),  }, --Red Side Raptors
			[0x45] = { ['pos'] = Vector(7100, 60, 10900), ['time'] = 300, ['spawn'] = 90, ['mapPos'] = GetMinimap(Vector(7100, 60, 10900)), }, --Red Side Red Buff
			[0x53] = { ['pos'] = Vector(6400, 60, 12250), ['time'] = 150, ['spawn'] = 102, ['mapPos'] = GetMinimap(Vector(6400, 60, 12250)), }, --Red Side Krugs
			[0xA6] = { ['pos'] = Vector(4950, 60, 10400), ['time'] = 420,                  ['mapPos'] = GetMinimap(Vector(4950, 60, 10400)), }, --Baron --19:51
			[0xB4] = { ['pos'] = Vector(2200, 60, 8500),  ['time'] = 150, ['spawn'] = 102, ['mapPos'] = GetMinimap(Vector(2200, 60, 8500)),  }, --Blue Side Gromp
			[0xE6] = { ['pos'] = Vector(12600, 60, 6400), ['time'] = 150, ['spawn'] = 102, ['mapPos'] = GetMinimap(Vector(12600, 60, 6400)), }, --Red Side Gromp
			[0xC1] = { ['pos'] = Vector(10500, 60, 5170), ['time'] = 180, ['spawn'] = 135, ['mapPos'] = GetMinimap(Vector(10500, 60, 5170)), }, --Dragon Crab
			[0xEC] = { ['pos'] = Vector(4400, 60, 9600),  ['time'] = 180, ['spawn'] = 135, ['mapPos'] = GetMinimap(Vector(4400, 60, 9600)),  }, --Baron Crab
			[0xFFD23C3E] = { ['pos'] = Vector(1170, 90, 3570),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(1170, 91, 3570)),   }, --Blue Top Inhibitor
			[0xFF4A20F1] = { ['pos'] = Vector(3203, 92, 3208),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3203, 92, 3208)),   }, --Blue Middle Inhibitor
			[0xFF9303E1] = { ['pos'] = Vector(3452, 89, 1236),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3452, 89, 1236)),   }, --Blue Bottom Inhibitor
			[0xFF6793D0] = { ['pos'] = Vector(11261, 88, 13676), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(11261, 88, 13676)), }, --Red Top Inhibitor
			[0xFFFF8F1F] = { ['pos'] = Vector(11598, 89, 11667), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(11598, 89, 11667)), }, --Red Middle Inhibitor
			[0xFF26AC0F] = { ['pos'] = Vector(13604, 89, 11316), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(13604, 89, 11316)), }, --Red Bottom Inhibitor				
		},
		['TwistedTreeline'] = {
			[0x44] = { ['pos'] =  Vector(4414, 60, 5774), ['time'] =  75, ['spawn'] = 65, ['mapPos'] = GetMinimap(Vector(4414, 60, 5774)),  },
			[0x2B] = { ['pos'] =  Vector(5088, 60, 8065), ['time'] =  75, ['spawn'] = 65, ['mapPos'] = GetMinimap(Vector(5088, 60, 8065)),  },
			[0xC9] = { ['pos'] =  Vector(6148, 60, 5993), ['time'] =  75, ['spawn'] = 65, ['mapPos'] = GetMinimap(Vector(6148, 60, 5993)),  },
			[0x00] = { ['pos'] = Vector(11008, 60, 5775), ['time'] =  75, ['spawn'] = 65, ['mapPos'] = GetMinimap(Vector(11008, 60, 5775)), },
			[0x97] = { ['pos'] = Vector(10341, 60, 8084), ['time'] =  75, ['spawn'] = 65, ['mapPos'] = GetMinimap(Vector(10341, 60, 8084)), },
			[0xA2] = { ['pos'] =  Vector(9239, 60, 6022), ['time'] =  75, ['spawn'] = 65, ['mapPos'] = GetMinimap(Vector(9239, 60, 6022)),  },
			[0x2C] = { ['pos'] =  Vector(7711, 60, 6722), ['time'] =  90, ['spawn'] = 150, ['mapPos'] = GetMinimap(Vector(7711, 60, 6722)), },
			[0x3A] = { ['pos'] = Vector(7711, 60, 10080), ['time'] = 360, ['spawn'] = 600, ['mapPos'] = GetMinimap(Vector(7711, 60, 10080)),},
			[0xFFD303E1] = { ['pos'] = Vector(2126, 11, 6146),   ['time'] = 240, ['mapPos'] = GetMinimap(Vector(2126, 11, 6146)),   }, --Left Bottom Inhibitor
			[0xFFD23C3E] = { ['pos'] = Vector(2146, 11, 8420),   ['time'] = 240, ['mapPos'] = GetMinimap(Vector(2146, 11, 8420)),   }, --Left Top Inhibitor
			[0xFF26AC0F] = { ['pos'] = Vector(13285, 17, 6124),  ['time'] = 240, ['mapPos'] = GetMinimap(Vector(13285, 17, 6124)),  }, --Right Bottom Inhibitor
			[0xFF6793D0] = { ['pos'] = Vector(13275, 17, 8416),  ['time'] = 240, ['mapPos'] = GetMinimap(Vector(13275, 17, 8416)),  }, --Right Top Inhibitor			
		},
		['HowlingAbyss'] = {
			[0x44] = { ['pos'] = Vector(7582, -100, 6785), ['time'] =  60, ['spawn'] = 120, ['mapPos'] = GetMinimap(Vector(7582, -100, 6785)), },
			[0x2B] = { ['pos'] = Vector(5929, -100, 5190), ['time'] =  60, ['spawn'] = 120, ['mapPos'] = GetMinimap(Vector(5929, -100, 5190)), },
			[0xC9] = { ['pos'] = Vector(8893, -100, 7889), ['time'] =  60, ['spawn'] = 120, ['mapPos'] = GetMinimap(Vector(8893, -100, 7889)), },
			[0x00] = { ['pos'] = Vector(4790, -100, 3934), ['time'] =  60, ['spawn'] = 120, ['mapPos'] = GetMinimap(Vector(4790, -100, 3934)), },
			[0xFF4A20F1] = { ['pos'] = Vector(3110, -201, 3189), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3110, -201, 3189)), }, --Bottom Inhibitor
			[0xFFFF8F1F] = { ['pos'] = Vector(9689, -190, 9524), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(9689, -190, 9524)), }, --Top Inhibitor			
		},
	}
  
	self.activeTimers = {}
	self.map = GetGame2().Map.Name
  
  if not self.Packets[self.map] then return end
  
	self.checkLastDragon = false
	self.checkLastBaron = false
	self:CreateMenu()
	if not self.Packets then
		Print('Jungle & Inhibitor Timers packets are outdated!!', true)
		return
	end
  
  for _, camp in pairs(self.Packets[self.map]) do
    if camp.spawn and GetInGameTimer() < camp.spawn then
				self.activeTimers[#self.activeTimers + 1] = {
					['spawnTime'] = clock()+(camp.spawn - GetInGameTimer()), 
					['pos'] = camp.pos,
					['minimap'] = camp.mapPos,
					['valid'] = true,
				}
    end
  end
  
	AddDrawCallback(function() self:Draw() end)
	AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)
	AddMsgCallback(function(m,k) self:WndMsg(m,k) end)
end

function JungleTimers:CreateMenu()
	MainMenu:addSubMenu('Jungle & Inhibitor Timers', 'ObjectTimers')
	self.Menu = MainMenu.ObjectTimers
	self.Menu:addParam('info', '---Game World---', SCRIPT_PARAM_INFO, '')
  o_valid['---Game World---']=true
	self.Menu:addParam('draw', 'Enable', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('type', 'Timer Type', SCRIPT_PARAM_LIST, 1, { 'Seconds', 'Minutes' })
	self.Menu:addParam('size', 'Text Size', SCRIPT_PARAM_SLICE, 16, 2, 24)
	self.Menu:addParam('RGB', 'Text Color', SCRIPT_PARAM_COLOR, {255,255,255,255})
  
	self.Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('info', '---Mini-Map---', SCRIPT_PARAM_INFO, '')
  o_valid['---Mini-Map---']=true
	self.Menu:addParam('mapsize', 'Minimap Text Size', SCRIPT_PARAM_SLICE, 14, 2, 24)
	self.Menu:addParam('mapRGB', 'Minimap Text Color', SCRIPT_PARAM_COLOR, {255,255,255,255})
	self.Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('info', '---Custom Timer Key---', SCRIPT_PARAM_INFO, '')
  o_valid['---Custom Timer Key---']=true
	self.Menu:addParam('modKey', 'Key (Default: Alt)', SCRIPT_PARAM_ONKEYDOWN, false, 18)
	self.Menu:addParam('', 'Hold Key down and left click a camp.', SCRIPT_PARAM_INFO, '')
end

function JungleTimers:Draw()
	-- for k, v in pairs(self.Packets.SummonerRift) do
		-- DrawText3D(('0x%02X'):format(k),v.pos.x,v.pos.y,v.pos.z,22,ARGB(255,255,255,255))
	-- end
	
	if not self.Menu.draw then return end
  
  
	for i, info in ipairs(self.activeTimers) do
		local timer = info.spawnTime-clock()
		local text = (self.Menu.type == 1) and ('%d'):format(timer) or ('%d:%.2d'):format(timer/60, timer%60)
		DrawText3D(text, info.pos.x, info.pos.y, (info.pos.z-50), self.Menu.size, ARGB(self.Menu.RGB[1], self.Menu.RGB[2], self.Menu.RGB[3], self.Menu.RGB[4]))
		DrawText(text, self.Menu.mapsize, info.minimap.x-5, info.minimap.y-5, ARGB(self.Menu.mapRGB[1], self.Menu.mapRGB[2], self.Menu.mapRGB[3], self.Menu.mapRGB[4]))
		if timer <= 1 then 
			table.remove(self.activeTimers,i)
		end
	end
end

function JungleTimers:RecvPacket(p)
	if p.header == self.Packets.Jungle.Header then
		p.pos = self.Packets.Jungle.campPos
		local camp = p:Decode1()
		-- print(('0x%02X'):format(camp))
		
		if self.Packets[self.map][camp] then
			p.pos = self.Packets.Jungle.idPos
			if p:Decode4() ~= self.Packets.Jungle.idZero then
				for i, timer in ipairs(self.activeTimers) do
					if timer.pos == self.Packets[self.map][camp].pos then
						table.remove(self.activeTimers, i)
					end
				end
				local respawnTime = (self.Packets[self.map][camp].isDragon and GetInGameTimer() > 2100) and 600 or self.Packets[self.map][camp].time
				self.activeTimers[#self.activeTimers + 1] = {
					['spawnTime'] = clock()+respawnTime, 
					['pos'] = self.Packets[self.map][camp].pos, 
					['minimap'] = self.Packets[self.map][camp].mapPos,
					['valid'] = true,
				}
			end
		end
		return
	end
	if p.header == self.Packets.Inhibitor.Header then
		p.pos=self.Packets.Inhibitor.pos
		local inhib = p:Decode4()
		if self.Packets[self.map][inhib] then
			self.activeTimers[#self.activeTimers + 1] = {
				['spawnTime'] = clock()+self.Packets[self.map][inhib].time, 
				['pos'] = self.Packets[self.map][inhib].pos, 
				['minimap'] = self.Packets[self.map][inhib].mapPos,
			}
		end
	end
end

function JungleTimers:WndMsg(m,k)
	if m == WM_LBUTTONDOWN and IsKeyDown(self.Menu._param[7].key) then --17 ctrl
		local cP = GetCursorPos()
		for _, info in pairs(self.Packets[self.map]) do
			if _ <= 0xFF then
				local miniMap = info.mapPos
				if abs(cP.x-miniMap.x) < 17 and abs(cP.y-miniMap.y) < 17 then
					for i, timer in ipairs(self.activeTimers) do
						if timer.pos == info.pos then
							if timer.valid then return end
							table.remove(self.activeTimers, i)					
						end
					end
					self.activeTimers[#self.activeTimers + 1] = {
						['spawnTime'] = clock()+info.time, 
						['pos'] = info.pos, 
						['minimap'] = info.mapPos,
						['valid'] = false,
					}
					return
				end
			end
		end
	end
end

class 'OTHER'

function OTHER:__init()
	self.Turrets = {}
	for i=1, objManager.maxObjects do
		local obj = objManager:getObject(i)
		if obj and obj.valid and obj.type == 'AITurret' and obj.name:find('Shrine') == nil then
			self.Turrets[#self.Turrets+1] = obj
		end
	end
	
	self.TurretRange = GetGame2().Map.Name == 'TwistedTreeline' and 775 + myHero.boundingRadius or 850 + myHero.boundingRadius
  
	AddDrawCallback(function() self:Draw() end)
	for i=1, heroManager.iCount do
		local h = heroManager:getHero(i)
		if (h.team == TEAM_ALLY and not h.isMe and h.charName == 'Thresh') then
			Print('Ally Thresh detected, AutoLantern loaded')
      MainMenu:addParam('space', '', SCRIPT_PARAM_INFO, '')
      MainMenu:addParam('info', '---Thresh Lantern---', SCRIPT_PARAM_INFO, '')
      o_valid['---Thresh Lantern---']=true			
      MainMenu:addParam('LanternKey', 'Thresh Lantern Key', SCRIPT_PARAM_ONKEYDOWN, false, 32)
			MainMenu:addParam('LanternHealth', 'Lantern if Health Less than (%)', SCRIPT_PARAM_SLICE, 25, 0, 100)
			MainMenu:addParam('LanternDelay', 'Lantern Humanizer Delay (ms)', SCRIPT_PARAM_SLICE, 250, 0, 1000)  
      AddCreateObjCallback(function(o)
				if o.valid and o.team == TEAM_ALLY and o.name == 'ThreshLantern' then
					self.Lantern = o
					self.LanternDelay = clock() + (MainMenu.LanternDelay / 1000)
				end
			end)
			AddTickCallback(function()
				if self.Lantern and self.Lantern.valid and GetDistanceSqr(self.Lantern) < 105625 and self.LanternDelay < clock() then
					if MainMenu.LanternKey or (myHero.health * 100) / myHero.maxHealth <= MainMenu.LanternHealth and self.Lantern.Interact then
            self.Lantern:Interact()
					end
				end
			end)
			break
		end
	end
end

function OTHER:Draw()
	if MainMenu.turret then
		for i, turret in ipairs(self.Turrets) do
			if turret and turret.valid and not turret.dead then
				local d = GetDistance(turret)
				if d < self.TurretRange+500 then
					local t = d-self.TurretRange
					if turret.team == TEAM_ENEMY then
						DrawCircle3D(turret.x,turret.y,turret.z,self.TurretRange,1, ARGB(t>0 and 255 * ((500-t) / 500) or 255, 255, 0, 0))
					elseif MainMenu.AllyTurret then
						local p = t>0 and ((500-t) / 500) or 1
						DrawCircle3D(turret.x,turret.y,turret.z,self.TurretRange,1, ARGB(t>0 and 255 * ((500-t) / 500) or 255, 255, 120, 120))
					end
				end
			else
				table.remove(self.Turrets, i)
			end
		end
	end	
end

class 'TrinketAssistant'

function TrinketAssistant:__init()
	if GetGame().map.shortName ~= 'summonerRift' then return end
	self.Packet = GetGameVersion():sub(1,4) == '7.22' and {
		['Header'] = 0x00FF, ['pos'] = 16, ['ssID'] = 0x4545C541,
	} or GetGameVersion():sub(1,4) == '7.23' and {
		['Header'] = 0x00E9, ['pos'] = 12, ['ssID'] = 0x0C0CEF08,
	}
	self.trinketID = {
		['TrinketTotemLvl1'] = 3340,
		['TrinketSweeperLvl1'] = 3341,
		['TrinketOrbLvl3'] = 3363,
		['TrinketSweeperLvl3'] = 3364,
	}
	if not self.Packet then 
		Print('Trinket Utiltity packet is outdated!!', true)
		return
	end
  
	self:CreateMenu()
  
	AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)
end

function TrinketAssistant:CreateMenu()
	MainMenu:addSubMenu('Trinket Assistant', 'Trinket')
	self.Menu = MainMenu.Trinket
  
	self.Menu:addParam('info', '---Purchase Sweeping Lens after Sightstone---', SCRIPT_PARAM_INFO, '')
  o_valid['---Purchase Sweeping Lens after Sightstone---']=true  
	self.Menu:addParam('Sightstone', 'Enable', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('info', '---Timed Sweeping Lens Purchase---', SCRIPT_PARAM_INFO, '')
  o_valid['---Timed Sweeping Lens Purchase---']=true  
	self.Menu:addParam('Sweeper', 'Enable', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('Timer', 'Allow after minute: ', SCRIPT_PARAM_SLICE, 10, 1, 60)
	self.Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('info', '---Upgrades---', SCRIPT_PARAM_INFO, '')
  o_valid['---Upgrades---']=true  
	self.Menu:addParam('UpgradeTotem', 'Upgrade Warding Totem after Lvl:', SCRIPT_PARAM_SLICE, 13, 9, 19)
	self.Menu:addParam('UpgradeLens', 'Upgrade Sweeping Lens after Lvl:', SCRIPT_PARAM_SLICE, 9, 9, 19)
end

function TrinketAssistant:RecvPacket(p)
	if p.header == self.Packet.Header then
		if p:DecodeF() == myHero.networkID then
      p.pos=self.Packet.pos      
			local isSightStone = p:Decode4() == self.Packet.ssID
			local currentTrinket = myHero:GetSpellData(ITEM_7)
			if not currentTrinket then return end
			local gameTime = GetInGameTimer()/60
      if self.Menu.Sweeper and self.trinketID[currentTrinket.name] == 3340 and gameTime >= self.Menu.Timer then
        BuyItem(3341)
				return
			end
			if self.Menu.Sightstone and isSightStone then
				if self.trinketID[currentTrinket.name] == 3340 then
					BuyItem(3341)
					return
				end
			end
      if currentTrinket.name == 'TrinketTotemLvl1' and GetLevel(myHero) >= self.Menu.UpgradeTotem then
        BuyItem(3363)
      elseif currentTrinket.name == 'TrinketSweeperLvl1' and GetLevel(myHero) >= self.Menu.UpgradeLens then
        BuyItem(3364)
      end
		end
	end
end

class 'MagneticWarding'

function MagneticWarding:__init()
	if GetGame().map.shortName ~= 'summonerRift' then return end	
	self.Positions = {
		{['x']=6550, ['y']=49, ['z']=4789},
		{['x']=6609, ['y']=51, ['z']=3081},
		{['x']=5476, ['y']=52, ['z']=3535},
		{['x']=7890, ['y']=53, ['z']=3455},
		{['x']=8591, ['y']=53, ['z']=4877},
		{['x']=10446, ['y']=52, ['z']=3142},
		{['x']=11720, ['y']=-70, ['z']=4074},
		{['x']=10111, ['y']=-71, ['z']=4734},
		{['x']=10547, ['y']=-62, ['z']=5100},
		{['x']=9315, ['y']=-71, ['z']=5725},
		{['x']=10016, ['y']=49, ['z']=6608},
		{['x']=10079, ['y']=52, ['z']=7754},
		{['x']=11615, ['y']=52, ['z']=7057},
		{['x']=4692, ['y']=51, ['z']=7210},
		{['x']=3248, ['y']=52, ['z']=7843},
		{['x']=2875, ['y']=52, ['z']=8380},
		{['x']=11934, ['y']=52, ['z']=6572},
		{['x']=4419, ['y']=57, ['z']=11763},
		{['x']=6266, ['y']=55, ['z']=10118},
		{['x']=7041, ['y']=55, ['z']=11438},
		{['x']=7794, ['y']=57, ['z']=11880},
		{['x']=8281, ['y']=57, ['z']=11813},
		{['x']=9406, ['y']=53, ['z']=11418},
		{['x']=9136, ['y']=55, ['z']=11335},
		{['x']=8120, ['y']=53, ['z']=8106},
		{['x']=6576, ['y']=52, ['z']=6714},
		{['x']=5329, ['y']=51, ['z']=5593},
		{['x']=5763, ['y']=51, ['z']=1264},
		{['x']=4792, ['y']=-71, ['z']=10233},
		{['x']=4279, ['y']=-69, ['z']=9795},
		{['x']=8222, ['y']=50, ['z']=10218},
		{['x']=4835, ['y']=33, ['z']=8363},	
		{['x']=5364, ['y']=-71, ['z']=9139},	
		{['x']=3148, ['y']=-66, ['z']=10820},	
	}
	self.Jumps = {
		[1] = {
			['cast'] = {['x']=2031, ['y']=53, ['z']=10165},
			['pos'] = {['x']=1774, ['y']=52, ['z']=10756},
		},
		[2] = {
			['cast'] = {['x']=4006, ['y']=41, ['z']=11907},
			['pos'] = {['x']=3424, ['y']=-62, ['z']=11767},
		},
		[3] = {
			['cast'] = {['x']=10699, ['y']=48, ['z']=3036},
			['pos'] = {['x']=11252, ['y']=-68, ['z']=3248},
		},
		[4] = {
			['cast'] = {['x']=4627, ['y']=50, ['z']=11393},
			['pos'] = {['x']=4824, ['y']=-71, ['z']=10906},
		},
		[5] = {
			['cast'] = {['x']=8148, ['y']=52, ['z']=3426},
			['pos'] = {['x']=8372, ['y']=52, ['z']=2908},
		},
		[6] = {
			['cast'] = {['x']=8425, ['y']=51, ['z']=4598},
			['pos'] = {['x']=8008, ['y']=54, ['z']=4270},
		},
		[7] = {
			['cast'] = {['x']=5184, ['y']=51, ['z']=6936},
			['pos'] = {['x']=5500, ['y']=52, ['z']=6424},
		},
		[8] = {
			['cast'] = {['x']=4980, ['y']=51, ['z']=7168},
			['pos'] = {['x']=5392, ['y']=52, ['z']=7496},
		},
		[9] = {
			['cast'] = {['x']=6436, ['y']=52, ['z']=10387},
			['pos'] = {['x']=6874, ['y']=56, ['z']=10656},
		},
		[10] = {
			['cast'] = {['x']=9712, ['y']=52, ['z']=7756},
			['pos'] = {['x']=9186, ['y']=53, ['z']=7560},
		},
		[11] = {
			['cast'] = {['x']=12119, ['y']=-71, ['z']=4189},
			['pos'] = {['x']=12322, ['y']=52, ['z']=4558},
		},
		[12] = {
			['cast'] = {['x']=12777, ['y']=52, ['z']=4740},
			['pos'] = {['x']=13069, ['y']=52, ['z']=4237},
		},
		[13] = {
			['cast'] = {['x']=6690, ['y']=54, ['z']=11495},
			['pos'] = {['x']=6524, ['y']=57, ['z']=12006},
		},
		[14] = {
			['cast'] = {['x']=9543, ['y']=74, ['z']=8015},
			['pos'] = {['x']=9272, ['y']=52, ['z']=8506},
		},
		[15] = {
			['cast'] = {['x']=10288, ['y']=74, ['z']=3368},
			['pos'] = {['x']=10072, ['y']=52, ['z']=3908},
		},
	}
	self.Wards = {
		['sightward'] = true, 
		['JammerDevice'] = true,
		['ItemGhostWard'] = true, 
		['TrinketTotemLvl2'] =  true,
		['TrinketTotemLvl1'] = true, 
		['TrinketTotemLvl3'] = true, 
		['TrinketTotemLvl3b'] = true, 
		['TrinketOrbLvl3'] = true,
	}
  
	self:CreateMenu()
  
	AddCastSpellCallback(function(...) self:CastSpell(...) end)	
	AddMsgCallback(function(m,k) self:WndMsg(m,k) end)
	AddDrawCallback(function() self:Draw() end)
end

function MagneticWarding:CreateMenu()
	MainMenu:addSubMenu('Magnetic Warding', 'MagWards')
	self.Menu = MainMenu.MagWards
	self.Menu:addParam('info', '---Keybindings---', SCRIPT_PARAM_INFO, '')
  o_valid['---Keybindings---']=true
	self.Menu:addParam('Item1', 'Item Slot 1', SCRIPT_PARAM_ONKEYDOWN, false, ('1'):byte())
	self.Menu:addParam('Item2', 'Item Slot 2', SCRIPT_PARAM_ONKEYDOWN, false, ('2'):byte())
	self.Menu:addParam('Item3', 'Item Slot 3', SCRIPT_PARAM_ONKEYDOWN, false, ('3'):byte())
	self.Menu:addParam('Item4', 'Item Slot 4', SCRIPT_PARAM_ONKEYDOWN, false, ('5'):byte())
	self.Menu:addParam('Item5', 'Item Slot 5', SCRIPT_PARAM_ONKEYDOWN, false, ('6'):byte())
	self.Menu:addParam('Item6', 'Item Slot 6', SCRIPT_PARAM_ONKEYDOWN, false, ('7'):byte())
	self.Menu:addParam('Item7', 'Trinket Slot', SCRIPT_PARAM_ONKEYDOWN, false, ('4'):byte())
	self.Menu:addParam('info', '', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('QuickCast', 'QuickCast', SCRIPT_PARAM_ONOFF, false)	
end

function MagneticWarding:Draw()
	if self.DrawSpots then
		for _, p in ipairs(self.Positions) do
			local c = WorldToScreen(D3DXVECTOR3(p.x,p.y,p.z))
			if c.x > -100 and c.x < WINDOW_W+100 and c.y > -100 and c.y < WINDOW_H+100 then
				local color = GetDistanceSqr(p, mousePos) < 6400 and RGB(0,0,255) or RGB(255,255,255)
				-- for i=1, 5 do DrawCircle(p.x, p.y, p.z, 75, color) end
				DrawCircle3D(p.x,p.y,p.z,75,2,color)
			end
		end
		for _, p in ipairs(self.Jumps) do
			local c = WorldToScreen(D3DXVECTOR3(p.pos.x,p.pos.y,p.pos.z))
			if c.x > -100 and c.x < WINDOW_W+100 and c.y > -100 and c.y < WINDOW_H+100 then
				local isHovered = GetDistanceSqr(mousePos, p.pos) < 6400 or GetDistanceSqr(mousePos, p.cast) < 6400
				local color = isHovered and RGB(0,0,255) or RGB(255,125,0)			
				-- for i=1, 5 do
					-- DrawCircle(p.pos.x, p.pos.y, p.pos.z, 75, color)
					-- DrawCircle(p.cast.x, p.cast.y, p.cast.z, 50, color)
				-- end
				-- DrawText3D(_..'',p.pos.x,p.pos.y,p.pos.z,20,color,true)
				DrawCircle3D(p.pos.x,p.pos.y,p.pos.z,75,2,color)
				DrawCircle3D(p.cast.x,p.cast.y,p.cast.z,50,2,color)
				local x, z = p.pos.x - p.cast.x, p.pos.z - p.cast.z
				local nLength  = sqrt(x * x + z * z)			
				DrawLine3D(
					p.pos.x + ((x / nLength) * -70), 
					p.pos.y, 
					p.pos.z + ((z / nLength) * -70),
					p.cast.x + ((x / nLength) * 50), 
					p.cast.y, 
					p.cast.z + ((z / nLength) * 50),
					2,
					isHovered and 0x640000FF or 0x64AFE100
				)
			end
		end
	end
end

function MagneticWarding:WndMsg(m,k)
	if m==KEY_DOWN then
		for _, param in ipairs(self.Menu._param) do
			if param.pType == SCRIPT_PARAM_ONKEYDOWN and param.key == k then
				local slot = _G['ITEM_'..param.var:sub(#param.var, #param.var)]
				if self.Wards[myHero:GetSpellData(slot).name] then
					self.DrawSpots = slot
				end
				return
			end
		end
	elseif m==KEY_UP and self.DrawSpots and self.Menu.QuickCast then
		DelayAction(function() self.DrawSpots = nil end, 0.25)
	elseif (m==WM_LBUTTONDOWN or m==WM_RBUTTONDOWN) and not self.Menu.QuickCast then
		DelayAction(function() self.DrawSpots = nil end, 0.25)		
	end
end

function MagneticWarding:CastSpell(iSlot,startPos,endPos,target)
	if self.DrawSpots == iSlot then
		for _, p in ipairs(self.Positions) do
			if GetDistanceSqr(mousePos, p) < 6400 then
				endPos.x = p.x
				endPos.z = p.z
			end
		end
		for _, p in ipairs(self.Jumps) do
			local isHovered = GetDistanceSqr(mousePos, p.pos) < 6400 or GetDistanceSqr(mousePos, p.cast) < 6400
			if isHovered then
				endPos.x = p.cast.x
				endPos.z = p.cast.z
			end
		end
	end
end

_G.PEW_UPDATE_INSTANCES_A = {}
class "AwareUpdate"

function AwareUpdate:__init(LocalVersion, SavePath, Host, VersionPath, ScriptPath, OnLoad, OnPreUpdate, OnPostUpdate, OnError)
  self.SavePath = SavePath
  self.Host = Host
  self.OnLoad = OnLoad
  self.OnPreUpdate = OnPreUpdate
  self.OnPostUpdate = OnPostUpdate
  self.OnError = OnError 
  
  local FilePath = string.split(self.SavePath, '/')
  FilePath = string.split(FilePath[#FilePath], '\\')
  self.FileName = FilePath[#FilePath]:gsub('/','')
  
  if LocalVersion == 'isDownload' then
		self.isDownload = true
		self.AllowDLBarDraw = true
    table.insert(PEW_UPDATE_INSTANCES_A, self.FileName)
    if #PEW_UPDATE_INSTANCES_A > 4 then table.remove(PEW_UPDATE_INSTANCES_A, 1) end
    if self.Host=='raw.githubusercontent.com' then
      self:CreateSocket('/BoL/TCPUpdater/GetScript5.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999))
      AddMsgCallback(function(...) self:OnWndMsg(...) end)
      AddDrawCallback(function()
        self:DownloadUpdate()
        self:DrawDownloadBar()
      end)
    else
      if not self.LuaSocket then
        self.LuaSocket = require("socket")
      else
        self.Socket:close()
        self.Socket = nil
        self.Size = nil
        self.RecvStarted = false
      end

      self.Socket = self.LuaSocket.connect(self.Host, 80)
      if not self.Socket then
        
      end
      self.Socket:send("GET "..ScriptPath.." HTTP/1.0\r\nHost: "..Host.."\r\n\r\n")
      self.Socket:settimeout(0, 'b')
      self.Socket:settimeout(99999999, 't')

      self.File = ''
      AddMsgCallback(function(...) self:OnWndMsg(...) end)
      AddDrawCallback(function() 
        self:DownloadFile() 
        self:DrawDownloadBar()
      end)   
    end
	else
		self.LocalVersion = LocalVersion
		self.VersionPath = '/BoL/TCPUpdater/GetScript5.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
		self.ScriptPath = '/BoL/TCPUpdater/GetScript5.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
		self.DownloadStatus = 'Connecting...'
		
    self:CreateSocket(self.VersionPath)
		AddTickCallback(function() self:GetOnlineVersion() end)
	end
end

function AwareUpdate:DrawDownloadBar()  
	if not self.AllowDLBarDraw then return end 
  
  local CenterX = floor(WINDOW_W * .175)
  local Width = floor(WINDOW_W * .125)
  local Height = floor(WINDOW_H * .03)
  local Height2 = floor(Height * .5)
  
  local pos = 1  
  for k=#PEW_UPDATE_INSTANCES_A, 1, -1 do
    if PEW_UPDATE_INSTANCES_A[k] and PEW_UPDATE_INSTANCES_A[k]==self.FileName then
      pos=k
    end
  end	
  
  local CenterY = math.floor(WINDOW_H * .02) + (Height + 10) * pos
  
  DrawLine(CenterX-Width-2, CenterY, CenterX+Width+2+Height, CenterY, Height+4, 0xFF838687)
  DrawLine(CenterX-Width, CenterY, CenterX-Width+math.floor((self.File and self.Size) and Width*2*math.round(100/self.Size*self.File:len(),2)/100 or 0), CenterY, Height, 0xFF1C1D20)
  local Text = 'Downloading: '..self.FileName..' '..(self.DownloadStatus or 'Connecting...')	
  local TextArea = GetTextArea(Text:find('%%') and 'Downloading: '..self.FileName..' (00.00%)' or Text, 16)
  DrawText(Text, 16, CenterX-TextArea.x*.5, CenterY-TextArea.y*.5, 0xFFFEA900)
  
  local CursorPos = GetCursorPos()
  self.CloseDLDraw = CursorPos.x > CenterX+Width+2 and CursorPos.x < CenterX+Width+6+Height and CursorPos.y > CenterY-Height*.5 and CursorPos.y < CenterY+Height*.5
  DrawLine(CenterX+Width+10, CenterY-Height2+10, CenterX+Width+Height-10, CenterY+Height2-10, self.CloseDLDraw and 3 or 2, 0xFF1C1D20)
  DrawLine(CenterX+Width+10, CenterY+Height2-10, CenterX+Width+Height-10, CenterY-Height2+10, self.CloseDLDraw and 3 or 2, 0xFF1C1D20)
end

function AwareUpdate:OnWndMsg(m,k) 
	if m==WM_LBUTTONDOWN then
    if self.CloseDLDraw and self.AllowDLBarDraw then
			self.AllowDLBarDraw = false	
      for k=#PEW_UPDATE_INSTANCES_A, 1, -1 do
        if PEW_UPDATE_INSTANCES_A[k] and PEW_UPDATE_INSTANCES_A[k]==self.FileName then
          table.remove(PEW_UPDATE_INSTANCES_A, k)
        end
      end	
		end
		if self.ScrollBarHovered and self.AllowLogDraw then
			self.ScrollBar.Offset = self.ScrollBar.y-GetCursorPos().y
			self.ScrollBar.Dragging = true
		end
	elseif m==WM_LBUTTONUP and self.AllowLogDraw then
		if self.ScrollBar and self.ScrollBar.Dragging then
			self.ScrollBar.Dragging = false
		end
	end
end

function AwareUpdate:CreateSocket(url)
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
  if not self.Socket then    
    if self.OnError and type(self.OnError) == 'function' then
      self.OnError('0x01')
      return
    end
  end
  self.Socket:settimeout(0, 'b')
  self.Socket:settimeout(99999999, 't')
  self.Socket:connect('sx-bol.eu', 80)
  self.Url = url
  self.Started = false
  self.LastPrint = ""
  self.File = ""
end

function AwareUpdate:Base64Encode(data)
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

function AwareUpdate:GetOnlineVersion()
  if self.GotScriptVersion then return end

  self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
  if self.Status == 'timeout' and not self.Started then
    self.Started = true
    self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
  end
  if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
    self.RecvStarted = true
    self.DownloadStatus = 'Checking for updates...'
  end

  self.File = self.File .. (self.Receive or self.Snipped)
  if self.File:find('</si'..'ze>') then
    if not self.Size then
      self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1) or '1')
    end
    if self.File:find('<scr'..'ipt>') then
      local _,ScriptFind = self.File:find('<scr'..'ipt>')
      local ScriptEnd = self.File:find('</scr'..'ipt>')
      if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
      local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
      self.DownloadStatus = 'Checking for updates...'
    end
  end
  if self.File:find('</scr'..'ipt>') then
    self.DownloadStatus = 'Checking for updates...'
    local a,b = self.File:find('\r\n\r\n')
    self.File = self.File:sub(a,-1)
    self.NewFile = ''
    for line,content in ipairs(self.File:split('\n')) do
      if content:len() > 5 then
        self.NewFile = self.NewFile .. content
      end
    end
    local HeaderEnd, ContentStart = self.File:find('<scr'..'ipt>')
    local ContentEnd, _ = self.File:find('</scr'..'ipt>')
    if not ContentStart or not ContentEnd then
      if self.OnError and type(self.OnError) == 'function' then
        self.OnError('0x02')
      end
    else
      self.OnlineVersion = (Base64Decode(self.File:sub(ContentStart + 1,ContentEnd-1)))
      self.OnlineVersion = tonumber(self.OnlineVersion or '0')
			if self.OnlineVersion and self.OnlineVersion > self.LocalVersion then
				if self.OnPreUpdate and type(self.OnPreUpdate) == 'function' then
          self.OnPreUpdate(self.OnlineVersion,self.LocalVersion)
        end
        self.DownloadStatus = 'Connecting...'
        self.AllowDLBarDraw = true
        self:CreateSocket(self.ScriptPath)          
        AddMsgCallback(function(...) self:OnWndMsg(...) end)
        AddDrawCallback(function()
          self:DownloadUpdate()
          self:DrawDownloadBar()
        end)
      else
        if self.OnLoad and type(self.OnLoad) == 'function' then
          self.OnLoad(self.LocalVersion)
        end
      end
    end
    self.GotScriptVersion = true
  end
end

function AwareUpdate:DownloadUpdate()
  if self.GotScriptUpdate then return end
  self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
  if self.Status == 'timeout' and not self.Started then
    self.Started = true
    self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
  end
  if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
    self.RecvStarted = true
    self.DownloadStatus = '(0%)'
  end

  self.File = self.File .. (self.Receive or self.Snipped)
  if self.File:find('</si'..'ze>') then
    if not self.Size then
      self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1) or '1')
    end
    if self.File:find('<scr'..'ipt>') then
      local _,ScriptFind = self.File:find('<scr'..'ipt>')
      local ScriptEnd = self.File:find('</scr'..'ipt>')
      if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
      local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
      self.DownloadStatus = '('..math.round(100/self.Size*DownloadedSize,2)..'%)'
    end
  end
  if self.File:find('</scr'..'ipt>') then
    self.DownloadStatus = '(100%)'
    local a,b = self.File:find('\r\n\r\n')
    self.File = self.File:sub(a,-1)
    self.NewFile = ''
    for line,content in ipairs(self.File:split('\n')) do
      if content:len() > 6 then
        self.NewFile = self.NewFile .. content
      end
    end
    local HeaderEnd, ContentStart = self.NewFile:find('<scr'..'ipt>')
    local ContentEnd, _ = self.NewFile:find('</scr'..'ipt>')
    if not ContentStart or not ContentEnd then
      if self.OnError and type(self.OnError) == 'function' then
        self.OnError('0x05')
      end
    else
      local newf = self.NewFile:sub(ContentStart+1,ContentEnd-1)
      newf = newf:gsub('\r', ''):gsub('\n', '')
      self.GotScriptUpdate = true
      if newf:len() ~= self.Size then
        if self.OnError and type(self.OnError) == 'function' then
          self.OnError('0x06')
        end
        return
      end
      newf = Base64Decode(newf)
      if not self.isDownload and type(load(newf)) ~= 'function' then
        if self.OnError and type(self.OnError) == 'function' then
          self.OnError('0x07')
        end
      else
        local f = io.open(self.SavePath,"w+b")
        f:write(newf)
        f:close()
        if self.OnPostUpdate and type(self.OnPostUpdate) == 'function' then
          self.OnPostUpdate(self.OnlineVersion,self.LocalVersion)
        end
      end
    end
    self.GotScriptUpdate = true
  end
end

function AwareUpdate:DownloadFile()
  if self.GotScriptUpdate then return end
  if self.Status == 'closed' then return end
  self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
  if self.Receive then
    if self.LastPrint ~= self.Receive then
      self.LastPrint = self.Receive
      self.File = self.File .. self.Receive
    end
  end

  if self.Snipped ~= "" and self.Snipped then
    self.File = self.File .. self.Snipped
  end
  if self.File:find('Length') then
    if not self.Size then
      self.Size = tonumber(self.File:sub(self.File:find('Length')+8, self.File:find('Length')+12) or '1') + 602
      self.DownloadStatus = '('..math.round(100/self.Size*self.File:len(),2)/100 or 0*100 ..'%)'
    end
  end
  if self.Status == 'closed' then
    local HeaderEnd, ContentStart = self.File:find('\r\n\r\n')
    if HeaderEnd and ContentStart then
      self.Size = self.File:len()
      self.DownloadStatus = '(100%)'
      local f = io.open(self.SavePath, 'w+b')
      f:write(self.File:sub(ContentStart+1))
      f:close()
      self.GotScriptUpdate = true
    else
      self.OnError('0x11')
    end
  end
end

--scriptConfig customization
local o_OnDraw = scriptConfig.OnDraw
function scriptConfig:OnDraw()
	if #self._subInstances > 0 or #self._param > 0 or #self._tsInstances > 0 then
		o_OnDraw(self)
	end
end

local o_DT = DrawText
local o_DSI = scriptConfig._DrawSubInstance
local o_DP = scriptConfig._DrawParam
local o_DL = DrawLine
function scriptConfig:_DrawSubInstance(index)
	if o_valid[self._subInstances[index].header] or self._subInstances[index].header == '' then
		local m,xb = 0, 0
		if self._subInstances[index].header ~= '' then
			_G.DrawLine = function(x1,y1,x2,y2,width,color)
				color = color~=1422721024 and color or 1413167931
				m = (x2 - x1) * .5
				xb=x2
				o_DL(x1,y1,x2,y2,width,color)
			end
		else
			_G.DrawLine = function(x1,y1,x2,y2,width,color)
				o_DL(x1,y1,x2,y2,width,color~=1422721024 and color or 1413167931)
			end
		end
		_G.DrawText = function(str,size,x,y,color) 
			if str:find(">>") == nil then
				local s = (size*.5)+1
				if self._subInstances[index].header ~= '' and self._subInstances[index].header ~= 'None Available' then 
					o_DL(x,y+s,xb,y+s,s*2,0xAA222222)
					o_DT(str,size,x+m-(GetTextArea(str,size).x*.5),y,color)
				else
					o_DT(str,size,x,y,color)
				end
			end
		end
	end
	o_DSI(self, index)
	_G.DrawLine = o_DL
	_G.DrawText = o_DT
end

function scriptConfig:_DrawParam(varIndex)
	if o_valid[self._param[varIndex].text] then
		local m = 0
		_G.DrawLine = function(x1,y1,x2,y2,width,color)
			local d = (x2-x1)*1.25
			m=d*.5
			o_DL(x1,y1,x1+d+4,y2,width,0xAA222222)
		end
		_G.DrawText = function(str,size,x,y,color)
			o_DT(str,size,x+m-(GetTextArea(str,size).x*.5),y,color)
		end
	end
	o_DP(self, varIndex)
	_G.DrawLine = o_DL
	_G.DrawText = o_DT
end
