print('PewPoppy')
require('HPrediction')
local Enemies = {}
for i=1, heroManager.iCount do
	local h = heroManager:getHero(i)
	if h and h.team~=myHero.team then
		table.insert(Enemies, h)
	end
end
local PushDistance = {
	[70] = 310,
	[80] = 310,
	[90] = 310,
	[100] = 310,
	[110] = 310,
	[120] = 310,
	[130] = 310,
	[140] = 310,
	[150] = 410,
	[160] = 420,
	[170] = 430,
	[180] = 350,
	[190] = 270,
	[200] = 280,
	[210] = 290,
	[220] = 390,
	[230] = 310,
	[240] = 410,
	[250] = 330,
	[260] = 430,
	[270] = 350,
	[280] = 360,
	[290] = 370,
	[300] = 380,
	[310] = 390,
	[320] = 400,
	[330] = 410,
	[340] = 420,
	[360] = 350,
	[370] = 360,
	[380] = 370,
	[390] = 380,
	[400] = 390,
	[410] = 400,
	[430] = 420,
	[440] = 430,
	[450] = 350,
	[460] = 270,
	[470] = 370,
	[480] = 380,
	[490] = 390,
	[500] = 400,
	[510] = 310,
	[520] = 420,
	[530] = 430,
	[540] = 350,
	[550] = 360,
	[560] = 370,
	[570] = 380,
	[580] = 390,
	[590] = 400,
	[600] = 410,
	[610] = 420,
	[620] = 430,
	[630] = 350,
	[640] = 360,
	[650] = 370,
}		
local HP = HPrediction()
local HP_Q = HPSkillshot({type = 'PromptLine', delay = 0.375, range = 350, width = 150, speed = math.huge})
local HP_R = HPSkillshot({type = 'PromptLine', delay = 0.450, range = 550, width = 275, speed = math.huge})
local HP_R2 = HPSkillshot({type = 'DelayLine', delay = 0, range = 1200, width = 275, speed = 1600})
local pFlash = myHero:GetSpellData(SUMMONER_1).name == 'summonerflash' and SUMMONER_1 or (myHero:GetSpellData(SUMMONER_2).name == 'summonerflash') and SUMMONER_2 or nil	
local channelingR = 0
local pMenu = scriptConfig('Poppy', 'Poppy')
pMenu:addParam('Key', ' Carry Key', SCRIPT_PARAM_ONKEYDOWN, false, 32)
pMenu:addParam('FlashKey', 'Flash E', SCRIPT_PARAM_ONKEYDOWN, false, ('C'):byte())
pMenu:addParam('KS', 'Killsteal R', SCRIPT_PARAM_ONKEYTOGGLE, true, ('T'):byte())
local amDashing, poppyShield = 0, nil
local function checkLine(s, e)
	for i=50, 350, 50 do
		local cp = NormalizeX(e, s, i)
		if IsWall(D3DXVECTOR3(cp.x,myHero.y,cp.z)) then
			return true
		end
	end			
end
local function checkWallCollision(cStart, cEnd)	
	if checkLine(cStart, cEnd) then
		local d1 = Normalize(cStart.x-(cStart.x-(cStart.z-cEnd.z)), cStart.z-(cStart.z+(cStart.x-cEnd.x)))
		local lEnd = {['x'] = cEnd.x + (d1.x*(-70)), ['z'] = cEnd.z + (d1.z*(-70))}
		local lStart = {['x'] = cStart.x + (d1.x*(-70)), ['z'] = cStart.z + (d1.z*(-70))}
		if checkLine(lStart, lEnd) then
			local rEnd = {['x'] = cEnd.x + (d1.x*70), ['z'] = cEnd.z + (d1.z*70)}
			local rStart = {['x'] = cStart.x + (d1.x*70), ['z'] = cStart.z + (d1.z*70)}
			if checkLine(rStart, rEnd) then
				return true
			end
		end
	end
	return false
end
local function checkE(t, from)
	local myPos = from or NormalizeX(GetPath(myHero), myHero, (GetLatency()*0.0005)*myHero.ms)
	local d1 = GetDistance(t, myPos)	
	local p1 = NormalizeX(t, myPos, (d1 + (PushDistance[math.round(d1 * 0.1, 0)*10] or 350)))
	if checkWallCollision(t, p1) then
		if t.hasMovePath then
			local pp = NormalizeX(GetPath(t), t, (d1 / 1800) * t.ms)
			local p2 = NormalizeX(pp, myPos, (GetDistance(pp, myPos) + (PushDistance[math.round(GetDistance(myPos, pp) * 0.1, 0)*10] or 350)))
			if checkWallCollision(pp, p2) then
				return true
			end						
		else
			return true
		end
	end
end
AddNewPathCallback(function(unit,startPos,endPos,isDash,dashSpeed,dashGravity,dashDistance)
	if unit.valid and isDash and unit.type == 'AIHeroClient' then
		if unit.isMe then
			amDashing = os.clock() + (GetDistance(startPos, endPos) / dashSpeed) - (GetLatency() * 0.0005)
		elseif unit.team ~= myHero.team and amDashing < os.clock() then
			local dp, bp = GetLinePoint(startPos.x, startPos.z, endPos.x, endPos.z, myHero.x, myHero.z)
			if bp and GetDistanceSqr(dp) < 160000 then
				CastSpell(_W)
			end
		end
	end
end)
AddTickCallback(function()
	if pMenu.Key then
		if myHero:CanUseSpell(_Q) == READY then
			local t = _Pewalk.GetTarget(375)
			if t then
				local CP, HC = HP:GetPredict(HP_Q, t, Vector(myHero))
				if CP then
					CastSpell(_Q, CP.x, CP.z)
				end
			end
		end
		if myHero:CanUseSpell(_E) == READY then
			local t = _Pewalk.GetTarget(700)
			if t and checkE(t) then
				CastSpell(_E, t)
			end
			for i, e in ipairs(Enemies) do
				if e~=t and isValid(e, 700) and _Pewalk.IsHighPriority(e, 2) and checkE(e) then
					CastSpell(_E, e)						
				end
			end
		end
		if myHero:CanUseSpell(_R) == READY then
			local t = _Pewalk.GetTarget(450)
			if t then
				local CP, HC, NH = HP:GetPredict(HP_R, t, Vector(myHero), 3)
				if CP and HC > 1 and NH > 2 then
					CastSpell(_R, CP.x, CP.z)
					CastSpell2(_R, D3DXVECTOR3(CP.x,myHero.y,CP.z))
				elseif pMenu.KS and HC > 0.75 then
					local fd = 100 + (myHero:GetSpellData(_R).level * 100) + (myHero.addDamage * 0.9)
					local ar = 100 / (100 + ((t.armor * myHero.armorPenPercent) - myHero.armorPen))
					if t.health + t.shield < fd * ar then
						CastSpell(_R, CP.x, CP.z)
						CastSpell2(_R, D3DXVECTOR3(CP.x,myHero.y,CP.z))
					end
				end
			end				
		end	
	end	
	if pMenu.FlashKey and pFlash then
		if myHero:CanUseSpell(_E) == READY and myHero:CanUseSpell(pFlash) == READY then
			local t = _Pewalk.GetTarget(1000)
			if t then
				local myPos = NormalizeX(GetPath(myHero), myHero, (GetLatency()*0.0005)*myHero.ms)
				local tPos = NormalizeX(GetPath(t), t, (GetLatency()*0.0005)*t.ms)
				for _, p in ipairs(GeneratePoints(400, 7, tPos, myPos)) do
					if GetDistanceSqr(p, tPos) < 390625 and not IsWall(D3DXVECTOR3(p.x,myHero.y,p.z)) and checkE(tPos, p) then
						CastSpell(pFlash, p.x, p.z)
						DelayAction(function() CastSpell(_E, t) end)
						return
					end
				end
			end
		end
	end
	if channelingR + 4 > os.clock() then
		local windUp = os.clock() - channelingR
		if windUp > 1 then
			local t = _Pewalk.GetTarget(1200)
			if t then
				local CP, HC = HP:GetPredict(HP_R2, t, Vector(myHero))
				if CP and HC > 0.5 then
					CastSpell2(_R, D3DXVECTOR3(CP.x, myHero.y, CP.z))
				end
			end
		end
	end
end)
local recip = 0
AddDrawCallback(function()	
	if poppyShield and poppyShield.valid and not poppyShield.dead then
		local tr = poppyShield.time - os.clock()
		if tr > 0 then
			DrawText3D(('%.2f'):format(tr),poppyShield.x,poppyShield.y + 150,poppyShield.z,36,0xFFFF9900,true)
		end
	end
	if pMenu.KS then
		local sr = 70 * (sin(recip) + 2.5)
		local cr = 70 * (cos(recip) + 2.5)
		DrawCircle(myHero.x, myHero.y, myHero.z, sr, RGB(300-sr, 0, sr-70))
		DrawCircle(myHero.x, myHero.y, myHero.z, cr, RGB(300-cr, 0, cr-70))
		recip = recip+0.02
	end
end)	
AddCreateObjCallback(function(o)
	if o.valid and o.name == 'Shield' and o.team == myHero.team then 
		poppyShield = o
		poppyShield.time = os.clock() + 5 - (GetLatency() * 0.0005)
	end
end)
AddAnimationCallback(function(unit, animation)
	if unit.valid and unit.isMe then
		if animation=='' then
			channelingR = os.clock()
		elseif animation:find('Spell4') then
			channelingR = 0
		end
	end
end)
