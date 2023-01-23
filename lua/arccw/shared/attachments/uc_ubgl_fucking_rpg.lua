att.PrintName = "URBPG Underslung Rocket Launcher"
att.AbbrevName = "URBPG Rocket Launcher"
att.Icon = Material("entities/att/rpega.png", "mips smooth")
att.Description = "85x40mm selectable underslung rocket-propelled grenade launcher."

att.SortOrder = -100000

att.AutoStats = true
att.Desc_Pros = {
}
att.Slot = "uc_ubgl"
att.ExcludeFlags = {"uc_noubgl"}

att.LHIK = true

att.ModelOffset = Vector(0, 0, 0)
att.Model = "models/weapons/arccw/atts/uc_ubgl_fucking_rpg.mdl"

att.SelectUBGLSound =  ""
att.ExitUBGLSound = ""

att.UBGL = true

att.UBGL_PrintName = "UBGL"
att.UBGL_Automatic = false
att.UBGL_MuzzleEffect = "muzzleflash_m79"
att.UBGL_Entity = "arccw_uc_40mm_he"
att.UBGL_Ammo = "smg1_grenade"
att.UBGL_RPM = 600
att.UBGL_Recoil = 2

-- ??
att.UBGL_Capacity = 1
att.UBGL_ClipSize = 1

att.LHIK_GunDriver = 2
att.LHIK_CamDriver = 3

local function Ammo(wep)
    return wep:GetOwner():GetAmmoCount("smg1_grenade")
end

local function uglbglmodel(wep, owner)
    local vm = owner:GetViewModel()
    
    local lhik_model = owner
    
    for i, k in pairs(wep.Attachments) do
        -- PrintTable(k)
        if k.Installed == "uc_ubgl_fucking_rpg" then
            lhik_model = k
        end
    end
    if !IsValid(lhik_model) then return owner end

    return lhik_model
end

att.Hook_LHIK_TranslateAnimation = function(wep, key)
    local retu = "idle"

    if key == "idle" then
        if wep:GetInUBGL() then retu = retu .. "_armed"  end
        if wep:Clip2() == 0 then retu = retu .. "_empty" end

        return retu
    end
end

att.Hook_ShouldNotSight = function(wep)
    if wep:GetInUBGL() then
        return true
    end
end

att.Hook_OnSelectUBGL = function(wep)
    wep:SetNextSecondaryFire(CurTime() + 0.7)
    wep:DoLHIKAnimation((wep:Clip2() == 0) and "to_armed_empty" or "to_armed", 0.7)
    wep:PlaySoundTable({
        {s = "arccw_uc/common/rattle_b2i_rifle.ogg", t = 0},
        {s = "arccw_uc/common/raise.ogg", t = 0.2},
        -- {s = "arccw_uc/common/grab.ogg", t = 0.5},
    })
end

att.Hook_OnDeselectUBGL = function(wep)
    wep:SetNextSecondaryFire(CurTime() + 0.8)
    wep:DoLHIKAnimation((wep:Clip2() == 0) and "to_idle_empty" or "to_idle", 0.8)
    wep:PlaySoundTable({
        {s = "arccw_uc/common/rattle_b2i_rifle.ogg", t = 0},
        {s = "arccw_uc/common/shoulder.ogg", t = 0.4},
    })
end


local blast =     "arccw_uc/common/rocket/fire-01.ogg", "arccw_uc/common/rocket/fire-02.ogg", "arccw_uc/common/rocket/fire-03.ogg", "arccw_uc/common/rocket/fire-04.ogg", "arccw_uc/common/rocket/fire-05.ogg", "arccw_uc/common/rocket/fire-06.ogg"
local tail =     "arccw_uc/common/rocket/fire-dist-01.ogg", "arccw_uc/common/rocket/fire-dist-02.ogg", "arccw_uc/common/rocket/fire-dist-03.ogg", "arccw_uc/common/rocket/fire-dist-04.ogg", "arccw_uc/common/rocket/fire-dist-05.ogg", "arccw_uc/common/rocket/fire-dist-06.ogg"
local mech =     "arccw_uc/common/rocket/mech-01.ogg", "arccw_uc/common/rocket/mech-02.ogg", "arccw_uc/common/rocket/mech-03.ogg", "arccw_uc/common/rocket/mech-04.ogg", "arccw_uc/common/rocket/mech-05.ogg", "arccw_uc/common/rocket/mech-06.ogg"

att.UBGL_Fire = function(wep, ubgl)
    if wep:Clip2() <= 0 then return end

    local owner = wep:GetOwner()
    local class = wep:GetBuff_Override("UBGL_Entity")

    
    local proj = wep:FireRocket(class, 5000)
    if SERVER then
        proj.Damage = 999
    end
	
    wep:MyEmitSound(blast, 100, 100, 1, CHAN_WEAPON)
    wep:MyEmitSound(tail, 149, 100, 0.8, CHAN_BODY)
    wep:MyEmitSound(mech, 149, 100, 0.6, CHAN_AUTO)

	if SERVER then
		local d = DamageInfo()
		d:SetDamage(math.random(30, 60))
		d:SetAttacker(owner)
		d:SetDamageType(DMG_BURN) 
		owner:TakeDamageInfo(d)
	end
    
    -- print(uglbglmodel(wep, owner))
    -- smoke_exhaust_01
    -- ParticleEffectAttach("explosion", PATTACH_POINT_FOLLOW, uglbglmodel(wep, owner), 1)
    local vPoint = uglbglmodel(wep, owner):GetPos()
    local effectdata = EffectData()
    effectdata:SetOrigin( vPoint )
    util.Effect( "HelicopterMegaBomb", effectdata )
    -- owner:ScreenFade( SCREENFADE.IN, Color( 255, 255, 255, 255), 1, 0 )
    owner:ScreenFade( SCREENFADE.IN, Color( 255, 0, 0, 255), 2, 0 )
    -- timer.Simple(2, function()
    --     if !IsValid(wep) or !IsValid(owner) then return end
    --     uglbglmodel(wep, owner):StopParticles()
    -- end)
    wep:DoLHIKAnimation("fire")
    wep:SetClip2(wep:Clip2() - 1)
    wep:DoEffects()
end

local common = ")/arccw_uc/common/"
local rottle = {common .. "cloth_1.ogg", common .. "cloth_2.ogg", common .. "cloth_3.ogg", common .. "cloth_4.ogg", common .. "cloth_6.ogg", common .. "rattle.ogg"}
local ratel = {common .. "rattle1.ogg", common .. "rattle2.ogg", common .. "rattle3.ogg"}

att.UBGL_Reload = function(wep, ubgl)
    if wep:Clip2() >= 1 then return end
    if Ammo(wep) <= 0 then return end

    wep:SetNextSecondaryFire(CurTime() + 4.6)

    wep:DoLHIKAnimation("reload", 4.6)
    wep:PlaySoundTable({
        {s = ratel, t = 0},
        {s = "arccw_uc/common/magpouch_replace_small.ogg", t = 0.9},
        {s = rottle, t = 1.0},
        {s = "arccw_uc/common/rocket/tap.ogg", t = 1.9},
        {s = "arccw_uc/common/rocket/slide1.ogg", t = 2.0},
        {s = rottle, t = 2.1},
        {s = "arccw_uc/common/rocket/slide2.ogg", t = 2.8},
        {s = rottle, t = 2.9},
        {s = "arccw_uc/common/rocket/insert.ogg", t = 3.2},
        {s = rottle, t = 3.3},
        {s = "arccw_uc/common/rocket/cock.ogg", t = 4.0},
        {s = ratel, t = 3.8},
    })

    local reserve = Ammo(wep)
    reserve = reserve + wep:Clip2()
    local clip = 1
    local load = math.Clamp(clip, 0, reserve)
    wep:GetOwner():SetAmmo(reserve - load, "smg1_grenade")
    wep:SetClip2(load)
end

att.Mult_SightTime = 1.2
att.Mult_SpeedMult = 0.9
att.Mult_SightedSpeedMult = 0.85