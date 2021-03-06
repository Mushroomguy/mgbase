if engine.ActiveGamemode() != "sandbox" then return end
if CLIENT then
local PolyTable = {}
local PolyTable_Index = 0
local MousePause = 0
local cvarenable = CreateClientConVar("tool_drawpoly","0",FCVAR_NONE)

concommand.Add("tool_drawpoly_cleartable",function()
	PolyTable = {}
	PolyTable_Index = 0
	LocalPlayer():EmitSound("items/ammocrate_close.wav")
end)

concommand.Add("tool_drawpoly_printtable",function()
PrintTable(PolyTable)
end)

hook.Add("HUDPaint","TOOL_Poly",function()
if cvarenable:GetInt() == 1 and vgui.CursorVisible() then
if LocalPlayer():KeyDown(IN_ATTACK) then 
	if CurTime() >= MousePause then
	MousePause = CurTime() + .5
	PolyTable_Index = PolyTable_Index + 1
	PolyTable[PolyTable_Index] = {x = "ScrW() / "..math.Truncate(ScrW() /gui.MouseX(),3),y = "ScrH() / "..math.Truncate(ScrH() /gui.MouseY(),3)}
	LocalPlayer():EmitSound("items/medshot4.wav")
end
end

for i, v in pairs(PolyTable) do
	surface.SetDrawColor(255,0,0,255)
	surface.SetTextColor(255,0,0,255)
surface.DrawCircle(ScrW() / tonumber(string.Replace(v.x,"ScrW() / ","")),ScrH() / tonumber(string.Replace(v.y,"ScrH() / ","")),math.sin(CurTime() * 20 - i) * 2 + i * .5,Color(255,0,0,255))
if #PolyTable > 1 then
surface.DrawText(i,"Default",ScrW() / tonumber(string.Replace(v.x,"ScrW() /","")),ScrH() / tonumber(string.Replace(v.y,"ScrH() /","")))
surface.DrawLine(ScrW() / tonumber(string.Replace(v.x,"ScrW() /","")),ScrH() / tonumber(string.Replace(v.y,"ScrH() /","")),ScrW() / tonumber(string.Replace(table.FindNext(PolyTable,v).x,"ScrW() / ","")),ScrH() / tonumber(string.Replace(table.FindNext(PolyTable,v).y,"ScrH() / ","")))
end
end
end
end)
end


-------------------------------------
if CLIENT and SERVER then
game.AddParticles("particles/aurora_sphere2.pcf")
game.AddParticles("particles/hunter_shield_impact.pcf")
game.AddParticles("particles/door_explosion.pcf")
game.AddParticles("particles/grenade_fx.pcf")
game.AddParticles("particles/electrical_fx.pcf")
game.AddParticles("particles/striderbuster.pcf")
PrecacheParticleSystem("aurora_shockwave")
PrecacheParticleSystem("hunter_shield_impactglow")
PrecacheParticleSystem("door_explosion_core")
PrecacheParticleSystem("grenade_explosion_01h")
PrecacheParticleSystem("grenade_explosion_01e")
PrecacheParticleSystem("st_elmos_fire_cp0")
PrecacheParticleSystem("striderbuster_shotdown_core_flash")
PrecacheParticleSystem("striderbuster_shotdown_explosion_trail")
end
if SERVER then
util.AddNetworkString("BL2_Orbs")
COND_NPC_UNFREEZE = 68
COND_NPC_FREEZE = 67
local GlobalNPCTable = {}

for i,p in pairs(player.GetAll()) do
p.InPerk = false 
p.PerkEntity = nil 
p.PerkTime = 3 
p.Sentry = nil
p.LastPerkUse = CurTime()
end

function BL2PerkSetUp(p)
p.InPerk = false 
p.PerkEntity = nil 
p.PerkTime = 3 
p.Sentry = nil
p.LastPerkUse = CurTime()
end

hook.Add("PlayerSpawn","BL2PerkSetUp",BL2PerkSetUp)

concommand.Add("bl2_BL2Class",function(ply,cmd,args)
ply.BL2Class = args[1]
ply:Spawn()
print(ply.BL2Class)
end)

concommand.Add("bl2_perk",function(ply)
if ply.InPerk == true then return end
if ply.BL2Class == nil then return end
if ply.BL2Class == "siren" then
if ply:GetEyeTrace().Entity:IsNPC() and ply.PerkTime >= 3 then
ply.LastPerkUse = CurTime()
ply.InPerk = true
ply.PerkEntity = ply:GetEyeTrace().Entity 
ply.PerkEntity.pos = ply.PerkEntity:GetPos() + Vector(0,0,50)
ply.PerkEntity.lerp = ply.PerkEntity:GetPos()
ply.PerkEntity.EffectInterval = 0
ParticleEffect("aurora_shockwave",ply.PerkEntity:GetPos(),Angle(0,0,0))
ply:EmitSound("vfx/fizzler_shutdown_01.wav")
else
if ply.PerkTime >= 3 then
ParticleEffect("hunter_shield_impactglow",ply:GetEyeTrace().HitPos,Angle(0,0,0))
ply:EmitSound("vfx/sphere_flashlight_on_01.wav")
end
ply.InPerk = false
ply.PerkEntity = nil
if IsValid(ply.PerkEntity) then
ply.PerkEntity.pos = nil
ply.PerkEntity.lerp = nil
end
end
elseif ply.BL2Class == "commando" then
if ply.PerkTime >= 3 then
ply.LastPerkUse = CurTime()
ply:EmitSound("npc/sphere/sphere_blips_md_"..math.random(10,23)..".wav")
ply.Sentry = ents.Create("prop_physics")
ply.PerkTime = 0
ply.InPerk = true
ply.Sentry.ROF = 0
ply.Sentry.LifeTime = 50
ply.Sentry.grenade = ents.Create("prop_physics")
ply.Sentry.grenade:SetModel("models/Items/combine_rifle_ammo01.mdl")
ply.Sentry.grenade:SetPos(ply:EyePos() + ply:EyeAngles():Forward() * 5)
ply.Sentry.grenade:SetAngles(ply:EyeAngles())
ply.Sentry.grenade:Spawn()
ply.Sentry.grenade:SetCollisionGroup(COLLISION_GROUP_WEAPON)
if IsValid(ply.Sentry.grenade:GetPhysicsObject()) then
ply.Sentry.grenade:GetPhysicsObject():SetVelocity(ply:EyeAngles():Forward() * 1000)
end
else 
ply:EmitSound("buttons/button_synth_negative_01.wav")
end
end
end)

hook.Add("Think","BL2_PERK_MANAGER",function()
for i2,pl in pairs(player.GetAll()) do
--------------------
if pl.InPerk == false then
 if pl.BL2Class == "siren" then
 pl.PerkTime = math.Clamp(pl.PerkTime + 0.005,0,3)
 elseif pl.BL2Class == "commando" then
 pl.PerkTime = math.Clamp(pl.PerkTime + 0.0025,0,3)
 end
elseif pl.InPerk == true then
 if pl.BL2Class == "siren" then
 pl.PerkTime = pl.PerkTime - .01
elseif pl.BL2Class == "commando" then
pl.PerkTime = 0
end
end

------------------
 if pl.InPerk == true then
 if pl.BL2Class == "siren" then
 if IsValid(pl.PerkEntity) then
 if not pl.PerkEntity.IsVictim then
 pl.PerkEntity:SetCondition(67)
 pl.PerkEntity.IsVictim = true
 ApplyEffect( pl.PerkEntity,pl,pl,"slag",10,0)
 end
 if not pl.PerkEntity.LoopSound then
 pl.PerkEntity.LoopSound = CreateSound(pl.PerkEntity,"vfx/fizzler_vortex_lp_01.wav")
 end
 pl.PerkEntity.LoopSound:Play()
 pl.PerkEntity.LoopSound:ChangeVolume(1,0)
 pl.PerkEntity:StopMoving()
 pl.PerkEntity.lerp = LerpVector(.1,pl.PerkEntity.lerp,pl.PerkEntity.pos)
 pl.PerkEntity:SetPos(pl.PerkEntity.lerp)
 if CurTime() >= pl.PerkEntity.EffectInterval then
 pl.PerkEntity.EffectInterval = CurTime() + .1
 ParticleEffect("striderbuster_shotdown_core_flash",pl.PerkEntity:GetPos() + Vector(0,0,20),Angle(0,0,0))
 ParticleEffect("striderbuster_shotdown_explosion_trail",pl.PerkEntity:GetPos() + Vector(0,0,20),Angle(0,0,0))
 end
 end
 end

if (pl.PerkTime <= 0 or !IsValid(pl.PerkEntity) or pl.PerkEntity:Health() <= 0) and pl.BL2Class == "siren" then
if IsValid(pl.PerkEntity) and pl.PerkEntity:Health() <= 0 then 
net.Start("BL2_Orbs")
			   --V
net.WriteString("1") ---ORBS!
net.WriteVector(pl.PerkEntity:GetPos())
net.Broadcast()
for i, heals in pairs(player.GetAll()) do 								--V
heals:SetHealth(math.Clamp(heals:Health() + heals:GetMaxHealth() * (.15 * 1),0,heals:GetMaxHealth())) ---ORBS!
end
end
 pl.InPerk = false
 if IsValid(pl.PerkEntity) then
  pl.PerkEntity:SetCondition(68)
  pl.PerkEntity.IsVictim = nil
  pl.PerkEntity.LoopSound:ChangeVolume(0,.5)
  pl.PerkEntity = nil
 end
end
end
---------------------------------||
if pl.BL2Class == "commando" and IsValid(pl.Sentry) then
if IsValid(pl.Sentry.grenade) then
pl.Sentry.trace = util.TraceLine({
	start = pl.Sentry.grenade:GetPos(),
	endpos = pl.Sentry.grenade:GetPos() + pl:GetAngles():Up() * -10000,
})
end
if not pl.Sentry.Enemies then
pl.Sentry.Enemies = {}
end

for i2323,npc33 in pairs(ents.FindByClass("npc*")) do
if npc33.Disposition and npc33:Disposition(pl) == D_HT and npc33:GetPos():Distance(pl.Sentry:GetPos()) < 3000 and npc33:IsLineOfSightClear(pl.Sentry:GetAttachment(1).Pos) then 
	pl.Sentry.Enemies[i2323] = {enemy = npc33, index = i2323, distance = math.Round(npc33:GetPos():Distance(pl.Sentry:GetPos()))} 
	npc33:AddRelationship("npc_bullseye D_HT 99")
end
--if not npc33.Disposition then
	--print(npc33)
--end
end
if CurTime() >= pl.LastPerkUse + 1.5 then
pl.Sentry:SetModel("models/npcs/turret/turret.mdl")
pl.Sentry:SetPos(pl.Sentry.trace.HitPos)
pl.Sentry:SetSkin(1)
BL2.SetLevel(pl.Sentry,BL2.GetLevel(pl))
pl.Sentry:SetAngles(Angle(0,0,0))
pl.Sentry:Spawn()
pl.Sentry:SetHealth(1)
pl.Sentry:GetPhysicsObject():EnableMotion(false)
pl.Sentry.ready = true
if IsValid(pl.Sentry.grenade) then
pl.Sentry.grenade:Remove()
pl.Sentry.grenade = nil
pl.Sentry:EmitSound("npc/turret_floor/turret_active_"..math.random(1,8)..".wav")
pl.Sentry:EmitSound("music/hotlinemiami_01/startaction_0"..math.random(1,2)..".mp3")
ParticleEffect("grenade_explosion_01h",pl.Sentry:GetPos(),Angle(0,0,0))
ParticleEffect("grenade_explosion_01e",pl.Sentry:GetPos(),Angle(0,0,0))
end
pl.Sentry:SetSequence("fire")
end
pl.Sentry.SetFoe = function(enemy,damge)
if enemy:IsLineOfSightClear(pl.Sentry:GetAttachment(1).Pos) then
enemy:TakeDamage(damge,pl,pl.Sentry)
else return end
end
if pl.Sentry.ready == true then
pl.Sentry.LifeTime = pl.Sentry.LifeTime - 0.05
--[[pl.Sentry.attachmenttrace = util.TraceLine({
 start = pl.Sentry:GetAttachment(1).Pos,
 endpos = pl.Sentry:GetAttachment(1).Pos + pl.Sentry:GetAttachment(1).Ang:Forward() * 1500,
})
render.SetMaterial(Material("red"))
render.DrawBeam(pl.Sentry.attachmenttrace.StartPos,pl.Sentry.attachmenttrace.HitPos,.1,0,10,Color(255,0,0,255))]]

if #pl.Sentry.Enemies > 0 and (!IsValid(pl.Sentry.Enemies[#pl.Sentry.Enemies].enemy) or pl.Sentry.Enemies[#pl.Sentry.Enemies].enemy:Health() <= 0 or pl.Sentry.Enemies[#pl.Sentry.Enemies].enemy:IsLineOfSightClear(pl.Sentry:GetAttachment(1).Pos) == false)  then print(";D") table.remove(pl.Sentry.Enemies,pl.Sentry.Enemies[#pl.Sentry.Enemies].index) end --pl.Sentry.Enemies[#pl.Sentry.Enemies].enemy = pl.Sentry.Enemies[math.Clamp(#pl.Sentry.Enemies - 1,1,#pl.Sentry.Enemies)].enemy end
	
	if table.Count(pl.Sentry.Enemies) > 0 then
		local foe = nil
		for k,v in pairs(pl.Sentry.Enemies) do
			if IsValid(v.enemy) and v.enemy:Health() > 0 and v.enemy:IsLineOfSightClear(pl.Sentry:GetAttachment(1).Pos) then
				foe = v
				break
			end
			
		end
		if foe then
			foe = foe.enemy
			if pl.Sentry.ROF < CurTime() then

				pl.Sentry:ResetSequence("fire")
				pl.Sentry:EmitSound("npc/turret/turret_fire_4x_01.wav",100,math.random(90,120))
				pl.Sentry.SetFoe(foe,5)
				pl.Sentry.ROF = CurTime() + 0.15
			end
			pl.Sentry:PointAtEntity(foe)
			end
		end
	end
end
if IsValid(pl.Sentry) then
	if pl.Sentry.LifeTime <= 0 or !pl:Alive() then 
		if IsValid(pl.Sentry.grenade) then pl.Sentry.grenade:Remove()end
		pl.Sentry.ready = false
		pl.PerkTime = 0
		ParticleEffect("door_explosion_core",pl.Sentry:GetPos(),Angle(0,0,270))
		pl.Sentry:EmitSound("container/containercrash01.wav")
		pl.Sentry:Remove()
		pl.Sentry = nil
		pl.InPerk = false
		pl.PerkTime = math.Clamp(pl.PerkTime + 0.002,0,3)

	end
elseif pl.InPerk and pl.BL2Class == "commando" then
	--pl.PerkTime = 0
	pl.InPerk = false
	--pl.PerkTime = math.Clamp(pl.PerkTime + 0.002,0,3)
end

end
end)
end


if CLIENT then
local orbs = {}
	net.Receive("BL2_Orbs",function(len,ply)
	local perkorbs = tonumber(net.ReadString())
	local position = net.ReadVector()
	for i,p in pairs(player.GetAll()) do
	orbs[i] = {pos = position,index = i,number = perkorbs}
	end
	PrintTable(orbs)
	end)

	hook.Add("PostDrawTranslucentRenderables","BL2CAMSHIT",function()
	for r,c in pairs(orbs) do
	c.destination = Entity(c.index):EyePos() + Vector(0,0,-10)
	c.pos = LerpVector(1*FrameTime(),c.pos,c.destination)
	if not c.fxinterval then c.fxinterval = 0 end
	if c.pos:Distance(c.destination) > 20 then
	for n = 1,c.number do
	cam.Start3D2D(c.pos + Angle(0,EyeAngles().y + 90,270):Forward() * math.sin(CurTime() * (6 - n)) * (4 + n) + Angle(0,EyeAngles().y + 90,270):Right() * math.sin(CurTime() * (3)) * (4 - n),Angle(0,EyeAngles().y + 90,270),.1 + (n/10))
	draw.SimpleTextOutlined("+","BL2Font_3",0,0,Color(255,0,0,math.Clamp(0 + c.pos:Distance(c.destination),0,255)),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,Color(0,0,0,math.Clamp(0 + c.pos:Distance(c.destination),0,255)))
	cam.End3D2D()
	end
	else
	Entity(c.index):EmitSound("player/object_use_0"..math.random(1,2)..".wav",35,100)
	ParticleEffect("st_elmos_fire_cp0",c.pos + Angle(0,EyeAngles().y + 90,270):Forward() * math.sin(CurTime() * 6) * 4,Angle(0,0,0))
	table.remove(orbs,r)
	end
	end
	end)
end
