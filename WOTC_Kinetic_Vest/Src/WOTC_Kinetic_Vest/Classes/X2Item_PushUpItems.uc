class X2Item_PushUpItems extends X2Item config(PushUpVestData);

var config int AlienAlloyCost;
var config int SuppliesCost;
var config int TradeValue;
var config int PushUpDuration;
var config name BaseCost;
var config name ExtraCost;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Items;

	Items.AddItem(CreatePushUpKineticVest());
	Items.AddItem(CreateKineticLevitationRounds());
	Items.AddItem(CreateKineticLevitationProximityMine());
	Items.AddItem(CreatePushUpGrenade());
	return Items;
}

static function X2DataTemplate CreatePushUpKineticVest()
{
	local X2EquipmentTemplate Template;
	local ArtifactCost Resources;
	local ArtifactCost Artifacts;
	local int i;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'PushUpKineticVest');
	Template.ItemCat = 'defense';
	Template.InventorySlot = eInvSlot_Utility;
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Nano_Fiber_Vest";
	Template.EquipSound = "StrategyUI_Vest_Equip";

	Template.Abilities.AddItem('PushUpShield');
	Template.Abilities.AddItem('PushUpCharge');
	Template.Abilities.AddItem('PushUpKineticSnap');
	
	
	for(i=0;i<class'X2Ability_PushUpVest'.default.KineticEruptionAbilityNames.Length;++i)
	{	
		Template.Abilities.AddItem(class'X2Ability_PushUpVest'.default.KineticEruptionAbilityNames[i]);
		Template.Abilities.AddItem(class'X2Ability_PushUpVest'.default.KineticDetonationAbilityNames[i]);
		Template.Abilities.AddItem(class'X2Ability_PushUpVest'.default.KineticProtectionFieldAbilityNames[i]);
		Template.Abilities.AddItem(class'X2Ability_PushUpVest'.default.KineticContainmentFieldAbilityNames[i]);
		Template.Abilities.AddItem(class'X2Ability_PushUpVest'.default.KineticLevitatedAbilityNames[i]);
	}

	Template.CanBeBuilt = true;
	Template.TradingPostValue = default.TradeValue;
	Template.PointsToComplete = 0;
	Template.Tier = 0;

	Template.bShouldCreateDifficultyVariants = true;

	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'X2Ability_ItemGrantedAbilitySet'.default.NANOFIBER_VEST_HP_BONUS);

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('HybridMaterials');
	Template.Requirements.RequiredTechs.AddItem('MagnetizedWeapons');
	// Cost
	Resources.ItemTemplateName = default.BaseCost;
	Resources.Quantity = default.SuppliesCost;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Artifacts.ItemTemplateName = default.ExtraCost;
	Artifacts.Quantity = default.AlienAlloyCost;
	Template.Cost.ArtifactCosts.AddItem(Artifacts);

	return Template;
}

static function X2DataTemplate CreateKineticLevitationRounds()
{
	local X2AmmoTemplate Template;
	local X2Condition_UnitProperty Condition_UnitProperty;
	local ArtifactCost Resources;
	local WeaponDamageValue DamageValue;
	local X2Effect_RemoveEffects RemoveEffects;

	`CREATE_X2TEMPLATE(class'X2AmmoTemplate', Template, 'KineticLevitationRounds');
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Bluescreen_Rounds";
	Template.ModClipSize = 0;
	Template.CanBeBuilt = true;
	Template.TradingPostValue = 20;
	Template.PointsToComplete = 0;
	Template.Tier = 1;
	Template.EquipSound = "StrategyUI_Ammo_Equip";
	Template.bBypassShields = true;

	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Effect_EnergyShield'.default.EffectName);
	Template.TargetEffects.AddItem(RemoveEffects);

	Template.Abilities.AddItem('PushUpKineticRoundsInit');
	Template.Abilities.AddItem('PushUpKineticRoundsLevitate');

	// Requirements
	//Template.Requirements.RequiredTechs.AddItem('MagnetizedWeapons');
	//Template.Requirements.RequiredTechs.AddItem('HybridMaterials');
	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 75;
	//Template.Cost.ResourceCosts.AddItem(Resources);
		
	//FX Reference
	Template.GameArchetype = "Ammo_Bluescreen.PJ_Bluescreen";
	
	return Template;
}

static function X2GrenadeTemplate CreateKineticLevitationProximityMine()
{
	local X2GrenadeTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2GrenadeTemplate', Template, 'KineticLevitationProximityMine');

	Template.strImage = "img:///PushUpVest.X2InventoryIcons.Inv_Proximity_Mine";
	Template.EquipSound = "StrategyUI_Grenade_Equip";
	Template.AddAbilityIconOverride('ThrowGrenade', "img:///UILibrary_PerkIcons.UIPerk_grenade_proximitymine");
	Template.AddAbilityIconOverride('LaunchGrenade', "img:///UILibrary_PerkIcons.UIPerk_grenade_proximitymine");
	Template.iRange = class'X2Item_DefaultGrenades'.default.PROXIMITYMINE_RANGE;
	Template.iRadius = class'X2Item_DefaultGrenades'.default.PROXIMITYMINE_RADIUS;
	Template.iClipSize = 1;
	Template.BaseDamage = class'X2Item_DefaultGrenades'.default.SmokeGrenade_BaseDamage;
	Template.iSoundRange = 10;
	Template.iEnvironmentDamage = 20;
	Template.DamageTypeTemplateName = 'Explosion';
	Template.Tier = 2;

	Template.Abilities.AddItem('ThrowGrenade');
	Template.Abilities.AddItem('KineticLevitationProximityMineDetonation');
	Template.Abilities.AddItem('GrenadeFuse');

	Template.bOverrideConcealmentRule = true;               //  override the normal behavior for the throw or launch grenade ability
	Template.OverrideConcealmentRule = eConceal_Always;     //  always stay concealed when throwing or launching a proximity mine
	
	Template.GameArchetype = "WP_Proximity_Mine.WP_Proximity_Mine";

	Template.iPhysicsImpulse = 10;

	Template.CanBeBuilt = true;	
	Template.TradingPostValue = 25;
	
	// Requirements
	Template.Requirements.RequiredTechs.AddItem('MagnetizedWeapons');
	Template.Requirements.RequiredTechs.AddItem('HybridMaterials');

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 100;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , class'X2Item_DefaultGrenades'.default.PROXIMITYMINE_RANGE);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RadiusLabel, , class'X2Item_DefaultGrenades'.default.PROXIMITYMINE_RADIUS);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.ShredLabel, , class'X2Item_DefaultGrenades'.default.PROXIMITYMINE_BASEDAMAGE.Shred);
	
	return Template;
}

static function X2WeaponTemplate CreatePushUpGrenade()
{
	local X2GrenadeTemplate Template;
	local ArtifactCost Resources;
	local X2Condition_UnitType UnitTypeCondition;
	local X2Effect_Persistent LureEffect;
	local X2Effect_AlertTheLost LostActivateEffect;

	`CREATE_X2TEMPLATE(class'X2GrenadeTemplate', Template, 'PushUpGrenade');

	Template.strImage = "img:///UILibrary_XPACK_StrategyImages.Inv_UltrasonicLure";
	Template.EquipSound = "StrategyUI_Grenade_Equip";
	Template.AddAbilityIconOverride('ThrowGrenade', "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_ultrasoniclure");
	Template.AddAbilityIconOverride('LaunchGrenade', "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_ultrasoniclure");
	Template.GameArchetype = "WP_Ultrasonic_Lure.WP_Ultrasonic_Lure";

	Template.Abilities.AddItem('ThrowGrenade');
	Template.Abilities.AddItem('GrenadeFuse');

	Template.ItemCat = 'tech';
	Template.WeaponCat = 'utility';
	Template.WeaponTech = 'conventional';
	Template.InventorySlot = eInvSlot_Utility;
	Template.StowedLocation = eSlot_BeltHolster;
	Template.bMergeAmmo = true;
	Template.iClipSize = 2;
	Template.Tier = 1;

	Template.bShouldCreateDifficultyVariants = true;

	Template.iRadius = class'X2Item_XpackUtilityItems'.default.ULTRASONICLURE_RADIUS/2;
	Template.iRange = class'X2Item_XpackUtilityItems'.default.ULTRASONICLURE_RANGE/2;
	Template.bIgnoreRadialBlockingCover = true;

	Template.CanBeBuilt = true;
	Template.PointsToComplete = 0;
	Template.TradingPostValue = 6;

	Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , class'X2Item_XpackUtilityItems'.default.ULTRASONICLURE_RANGE);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RadiusLabel, , class'X2Item_XpackUtilityItems'.default.ULTRASONICLURE_RADIUS);

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('Tech_AdventDatapad');
	Template.Requirements.RequiredTechs.AddItem('AutopsyAdventOfficer');

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 30;
	Template.Cost.ResourceCosts.AddItem(Resources);

	// Apply an effect on Advent unit
	Template.ThrownGrenadeEffects.AddItem(class'X2Helpers_KineticItems'.static.CreateStunnedStatusEffect(default.PushUpDuration,100));

	// Apply an effect on all lost units within sight range, to activate inactive lost groups.
	Template.LaunchedGrenadeEffects = Template.ThrownGrenadeEffects;
	Template.bFriendlyFireWarning = false;

	return Template;
}