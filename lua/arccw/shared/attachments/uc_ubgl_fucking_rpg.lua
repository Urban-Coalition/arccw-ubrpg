att.PrintName = "URBPG Underslung Rocket Launcher"
att.AbbrevName = "URBPG Rocket Launcher"
att.Icon = Material("entities/att/rpega.png", "mips smooth")
att.Description = "Selectable underslung rocket launcher. "

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

att.UBGL_Fire = function(wep, ubgl)
    if wep:Clip2() <= 0 then return end

    local owner = wep:GetOwner()
    local class = wep:GetBuff_Override("UBGL_Entity")

    
    local proj = wep:FireRocket(class, 5000)
    if SERVER then
        proj.Damage = 999
    end
    wep:MyEmitSound(")^/arccw_uc/common/40mm/fire-0" .. math.random(1, 6) .. ".ogg", 100, 100, 1, CHAN_WEAPON)
    wep:MyEmitSound(")^/arccw_uc/common/40mm/fire-dist-0" .. math.random(1, 6) .. ".ogg", 149, 100, 0.5, CHAN_BODY)
    wep:MyEmitSound(")^/arccw_uc/common/40mm/mech-0" .. math.random(1, 6) .. ".ogg", 149, 100, 0.5, CHAN_AUTO)


	local d = DamageInfo()
	d:SetDamage(math.random(30, 60))
	d:SetAttacker(owner)
	d:SetDamageType(DMG_BURN) 
    owner:TakeDamageInfo(d)
    
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

att.UBGL_Reload = function(wep, ubgl)
    if wep:Clip2() >= 1 then return end
    if Ammo(wep) <= 0 then return end

    wep:SetNextSecondaryFire(CurTime() + 4.6)

    wep:DoLHIKAnimation("reload", 4.6)
    wep:PlaySoundTable({
        {s = { "arccw_uc/common/rattle1.ogg", "arccw_uc/common/rattle2.ogg", "arccw_uc/common/rattle3.ogg" }, t = 0},
        -- {s = "arccw_uc/common/40mm/203open.ogg", t = 0.2},
        -- {s = "arccw_uc/common/magpouch_replace_small.ogg", t = 0.9},
        -- {s = "arccw_uc/common/40mm/203insert.ogg", t = 1.2},
        -- {s = "arccw_uc/common/shoulder.ogg", t = 1.5},
        -- {s = "arccw_uc/common/40mm/203close.ogg", t = 1.7},
        -- {s = "arccw_uc/common/shoulder.ogg", t = 2.3},
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