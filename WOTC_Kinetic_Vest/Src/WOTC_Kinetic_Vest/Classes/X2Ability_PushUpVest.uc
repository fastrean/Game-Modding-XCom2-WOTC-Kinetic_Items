class X2Ability_PushUpVest extends X2Ability
	dependson (XComGameStateContext_Ability) config(PushUpVestData);

var config int MaxShieldAmount;
var config int ShieldPerCharge;
var config int STUNNED_HIERARCHY_VALUE;

var config array<int> ShieldAmounts;
var config array<int> Eruption_Radius;
var config array<int> Detonation_Radius;
var config array<string> IconColors;

var config array<name> KineticEruptionAnim;
var config array<name> KineticDetonationAnim;
var config array<name> KineticEruptionAbilityNames;
var config array<name> KineticDetonationAbilityNames;
var config array<name> KineticProtectionFieldAbilityNames;
var config array<name> KineticContainmentFieldAbilityNames;
var config array<name> KineticLevitatedAbilityNames;

var config array<WeaponDamageValue> Eruption_Damages;
var config array<int> Eruption_EnvironmentalDamages;
var config array<WeaponDamageValue> Detonation_Damages;
var config array<WeaponDamageValue> KineticSlamDamages;

var localized string StunnedFriendlyName;
var localized string StunnedFriendlyDesc;
var localized string StunnedEffectAcquiredString;
var localized string StunnedEffectTickedString;
var localized string StunnedEffectLostString;
var localized string StunnedPerActionFriendlyName;

var localized string RoboticStunnedFriendlyName;
var localized string RoboticStunnedFriendlyDesc;
var localized string RoboticStunnedEffectAcquiredString;
var localized string RoboticStunnedEffectTickedString;
var localized string RoboticStunnedEffectLostString;
var localized string RoboticStunnedPerActionFriendlyName;

var config string StunnedParticle_Name;
var config name StunnedSocket_Name;
var config name StunnedSocketsArray_Name;

var name LevitatedName;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local int i;

	Templates.AddItem(CreatePushUpShield());	
	Templates.AddItem(CreatePushUpCharge());	
	Templates.AddItem(CreatePushUpKineticSnap());	
	Templates.AddItem(CreatePushUpKineticRoundsInit());	
	Templates.AddItem(CreatePushUpKineticRoundsLevitate());	
	Templates.AddItem(CreateKineticLevitationProximityMineDetonation());	
	
	for(i =0; i <default.ShieldAmounts.length; i++)
	{	
		Templates.AddItem(CreatePushUpKineticEruption(default.KineticEruptionAbilityNames[i], default.KineticEruptionAnim[i], default.Eruption_Damages[i], default.Eruption_EnvironmentalDamages[i], default.Eruption_Radius[i], default.ShieldAmounts[i], default.IconColors[i]));	
		Templates.AddItem(CreatePushUpKineticProtectionField(default.KineticProtectionFieldAbilityNames[i], default.Detonation_Radius[i], default.ShieldAmounts[i], default.IconColors[i]));	
		Templates.AddItem(CreatePushUpKineticContainmentField(default.KineticContainmentFieldAbilityNames[i], default.ShieldAmounts[i], default.IconColors[i]));	
		Templates.AddItem(CreatePushUpKineticLevitated(default.KineticLevitatedAbilityNames[i], default.ShieldAmounts[i], default.IconColors[i]));	
		if (i<2)
		{	
			Templates.AddItem(CreatePushUpKineticDetonation(default.KineticDetonationAbilityNames[i], default.KineticDetonationAnim[0], default.Detonation_Damages[i], default.Eruption_EnvironmentalDamages[i], default.Detonation_Radius[i], default.ShieldAmounts[i], default.IconColors[i]));	
		}
		else
		{
			Templates.AddItem(CreatePushUpKineticDetonation(default.KineticDetonationAbilityNames[i], default.KineticDetonationAnim[1], default.Detonation_Damages[i], default.Eruption_EnvironmentalDamages[i], default.Detonation_Radius[i], default.ShieldAmounts[i], default.IconColors[i]));
		}
	}

	return Templates;
}

static function X2AbilityTemplate CreatePushUpShield()
{
	local X2AbilityTemplate							Template;
	local X2Effect_PushUpVestPersonalKineticShield	PersonalKineticShield;
	local X2Effect_PushUpVestKineticManipulation	KineticManipulation;
	//Ability Name & UI
	`CREATE_X2ABILITY_TEMPLATE(Template, 'PushUpShield');
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;
	//Targeting
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.DeadEye;
	//Triggers
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	//Apply Effects
	//Apply max Kinetic Shield but init shiled at 0
	PersonalKineticShield = new class'X2Effect_PushUpVestPersonalKineticShield';
	PersonalKineticShield.AddPersistentStatChange(eStat_ShieldHP, default.MaxShieldAmount);
	PersonalKineticShield.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage);
	PersonalKineticShield.ShieldPerCharge = default.ShieldPerCharge;
	PersonalKineticShield.BuildPersistentEffect(1, true, false, false);
	Template.AddTargetEffect(PersonalKineticShield);
	//Apply Damage Bonus
	KineticManipulation = new class'X2Effect_PushUpVestKineticManipulation';
	KineticManipulation.BuildPersistentEffect(1, true, false, false);
	KineticManipulation.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage);
	Template.AddTargetEffect(KineticManipulation);
	//Build game State and Visualization
	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	return Template;
}

static function X2AbilityTemplate CreatePushUpCharge(name TemplateName = 'PushUpCharge')
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Condition_UnitProperty          PropertyCondition;
	local X2Effect_PushUpVestPushUpCharge   PushUpVisual; 
	local X2Effect_PersistentStatChange     PersistentStatChangeEffect; 
	local X2AbilityTrigger_PlayerInput      InputTrigger;
	local array<name>                       SkipExclusions;
	local X2Effect_RemoveEffects			RemoveEffects;
	//Ability Name & UI
	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);
	Template.IconImage = "img:///PushUpVest.PerkIcons.UIPerk_PushUpCharge";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.HUNKER_DOWN_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.ConcealmentRule = eConceal_AlwaysEvenWithObjective;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.Hostility = eHostility_Defensive;
	Template.bDisplayInUITooltip = false;
	//Cost
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.AllowedTypes.AddItem(class'X2CharacterTemplateManager'.default.DeepCoverActionPoint);
	Template.AbilityCosts.AddItem(ActionPointCost);
	//Targeting
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = new class'X2AbilityTarget_Cursor';
	Template.TargetingMethod = class'X2TargetingMethod_PathTarget';
	//Triggers
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	//Conditions
	//shooter is alive
	PropertyCondition = new class'X2Condition_UnitProperty';	
	PropertyCondition.ExcludeDead = true;                           // Can't hunkerdown while dead
	PropertyCondition.ExcludeFriendlyToSource = false;              // Self targeted
	Template.AbilityShooterConditions.AddItem(PropertyCondition);
	//ability can be use while burning or disoriented
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);
	//Apply Effects
	//Stats Boost
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.EffectName = 'PushUpChargeBouns';
	PersistentStatChangeEffect.BuildPersistentEffect(1, false, true, false, eGameRule_UnitGroupTurnBegin); 
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Dodge, class'X2Ability_DefaultAbilitySet'.default.HUNKERDOWN_DODGE);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Defense, class'X2Ability_DefaultAbilitySet'.default.HUNKERDOWN_DEFENSE); 
	PersistentStatChangeEffect.DuplicateResponse = eDupe_Refresh;
	Template.AddShooterEffect(PersistentStatChangeEffect);
	//Play Push Up Animation and Grant Cover Effect
	PushUpVisual = new class'X2Effect_PushUpVestPushUpCharge';
	PushUpVisual.EffectName = 'PushUpChargeEffect';
	PushUpVisual.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd); 
	PushUpVisual.bIsImpairing = true;
	PushUpVisual.bCanTickEveryAction = true;
	PushUpVisual.bRemoveWhenSourceDamaged=true;
	PushUpVisual.EffectHierarchyValue = 950;
	PushUpVisual.CustomIdleOverrideAnim='Ex_PushUps_Normal_LO01';
	PushUpVisual.PushUpStopAnimName='PushUp2Stand';
	PushUpVisual.DuplicateResponse = eDupe_Refresh;
	Template.AddShooterEffect(PushUpVisual);
	//Remove Burning Effect
	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffect(RemoveEffects);
	//Build game State and Visualization
	Template.PostActivationEvents.AddItem('PushUpActivated');
	Template.CustomFireAnim='Stand2PushUp';
	Template.ActivationSpeech = 'HunkerDown'; 
	Template.AbilityConfirmSound = "TacticalUI_Activate_Ability_Run_N_Gun";
	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;
	Template.bDontDisplayInAbilitySummary = true;
	return Template;
}	

static function X2AbilityTemplate CreatePushUpKineticEruption(name AbilityName, name CustomAnim, WeaponDamageValue KineticEruptionDamage, int KineticEruptionEnvironmentalDamage, int EruptionRadius, int ShieldAmount, string IconColor)
{
	local X2AbilityTemplate					Template;
	local X2Effect_ApplyWeaponDamage        KineticEruptionDamageEffect;
	local X2Effect_PersistentStatChange 	DazedEffect;
	local X2Effect_Stunned					StunnedEffect;
	local X2Effect_Knockback				KnockbackEffect;
	local X2Effect_CostAllEnergyShield		CostEneryShield;
	local X2AbilityMultiTarget_Radius       RadiusMultiTarget;
	local X2AbilityCost_ActionPoints   	 	ActionPointCost;
	local X2Condition_UnitProperty          PropertyCondition;
	local X2Condition_SourceHasShieldCheck  EnergyShieldCondition;
	//Ability Name & UI
	`CREATE_X2ABILITY_TEMPLATE(Template, AbilityName);
	Template.IconImage = "img:///PushUpVest.PerkIcons.UIPerk_KineticEruption";
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Offensive;
	Template.AbilityIconColor = IconColor;
	Template.bFriendlyFireWarning = true;
	//Cost
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);
	//Targeting
	Template.AbilityTargetStyle = new class'X2AbilityTarget_Cursor';
	Template.TargetingMethod = class'X2TargetingMethod_PathTarget';
	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = EruptionRadius;
	RadiusMultiTarget.bIgnoreBlockingCover = true; 
	RadiusMultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;
	Template.AbilityToHitCalc = default.DeadEye;
	//Triggers
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	//Conditions
	//Shooter have shields
	EnergyShieldCondition = new class'X2Condition_SourceHasShieldCheck';
	EnergyShieldCondition.ShieldAmount= ShieldAmount;
	Template.AddShooterEffectExclusions();
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityShooterConditions.AddItem(EnergyShieldCondition);
	//Apply Effects
	//Remove Shooter's shields
	Template.AddShooterEffect(new class'X2Effect_CostAllEnergyShield');
	Template.AddShooterEffect(RemoveShieldedEffect());
	Template.AddShooterEffect(RemoveKineticProtectionField());
	//KnockBack
	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.ApplyChanceFn = ApplyChance_EruptionStunAndKnockBack;
	KnockbackEffect.KnockbackDistance = EruptionRadius;
	KnockbackEffect.OnlyOnDeath = false;
	Template.AddMultiTargetEffect(KnockbackEffect);
	//Kinetic Eruption Damage Effect
	KineticEruptionDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	KineticEruptionDamageEffect.bExplosiveDamage = true;
	KineticEruptionDamageEffect.EnvironmentalDamageAmount = KineticEruptionEnvironmentalDamage;
	KineticEruptionDamageEffect.DamageTypes.AddItem('NoFireExplosion');
	KineticEruptionDamageEffect.EffectDamageValue = KineticEruptionDamage;
	Template.AddMultiTargetEffect(KineticEruptionDamageEffect);
	//Target conditions
	PropertyCondition = new class'X2Condition_UnitProperty';	
	PropertyCondition.ExcludeDead = true;                          
	PropertyCondition.ExcludeRobotic = true;
	PropertyCondition.ExcludeTurret = true;
	//Disoriented Effect;
	DazedEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect();
	DazedEffect.DuplicateResponse = eDupe_Refresh;
	DazedEffect.bRemoveWhenTargetDies = true;
	DazedEffect.ApplyChanceFn = ApplyChance_EruptionStunAndKnockBack;
	DazedEffect.TargetConditions.AddItem(PropertyCondition);
	Template.AddMultiTargetEffect(DazedEffect);
	//Stun Effect
	StunnedEffect = class'X2StatusEffects'.static.CreateStunnedStatusEffect(1, KineticEruptionEnvironmentalDamage, false);
	StunnedEffect.DuplicateResponse = eDupe_Refresh;
	StunnedEffect.bRemoveWhenTargetDies = true;
	StunnedEffect.TargetConditions.AddItem(PropertyCondition);
	Template.AddMultiTargetEffect(StunnedEffect);
	//Build game State and Visualization
	Template.CustomFireAnim = CustomAnim;
	Template.bShowActivation = true;
	Template.ActivationSpeech = 'ShredStormCannon';	
	Template.AbilityConfirmSound = "TacticalUI_SwordConfirm";
	Template.CinescriptCameraType = "AdvShieldBearer_EnergyShieldArmor";
	Template.bSkipExitCoverWhenFiring = false;
	Template.bSkipMoveStop = false;
	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;
	return Template;
}	

static function X2AbilityTemplate CreatePushUpKineticDetonation(name AbilityName, name CustomAnim, WeaponDamageValue DetonationDamage, int DetonationEnvironmentalDamage, int DetonationRadius, int ShieldAmount, string IconColor)
{
	local X2AbilityTemplate					Template;
	local X2Effect_ApplyWeaponDamage        DetonationDamageEffect;
	local X2Effect_RemoveEffects 			RemoveEffects;
	local X2Effect_CostAllEnergyShield		CostEneryShield;
	local X2AbilityMultiTarget_Radius       RadiusMultiTarget;
	local X2AbilityCost_ActionPoints   	 	ActionPointCost;
	local X2Condition_UnitProperty          PropertyCondition;
	local X2Condition_SourceHasShieldCheck  EnergyShieldCondition;
	//Ability Name & UI
	`CREATE_X2ABILITY_TEMPLATE(Template, AbilityName);
	Template.IconImage = "img:///PushUpVest.PerkIcons.UIPerk_KineticDetonation";
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Offensive;
	Template.AbilityIconColor = IconColor;
	Template.bFriendlyFireWarning = true;
	//Cost
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);
	//Targeting
	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = DetonationRadius;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	//Triggers
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	//Conditions
	//Shooter have shields
	EnergyShieldCondition = new class'X2Condition_SourceHasShieldCheck';
	EnergyShieldCondition.ShieldAmount= ShieldAmount;
	Template.AddShooterEffectExclusions();
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityShooterConditions.AddItem(EnergyShieldCondition);
	//Target have shields
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(new class'X2Condition_EnergyShieldCheck');
	//Apply Effects
	//Remove Shooter's Filed
	Template.AddShooterEffect(new class'X2Effect_CostAllEnergyShield');
	Template.AddShooterEffect(RemoveShieldedEffect());
	Template.AddShooterEffect(RemoveKineticProtectionField());
	//Remove Target's Shield
	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Effect_EnergyShield'.default.EffectName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Effect_PushUpVestKineticContainmentField'.default.EffectName);
	Template.AddTargetEffect(RemoveEffects);
	Template.AddTargetEffect(RemoveShieldedEffect()); 
	//Kinetic Detonation Damage Effect
	DetonationDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	DetonationDamageEffect.bExplosiveDamage = true;
	DetonationDamageEffect.EnvironmentalDamageAmount = DetonationEnvironmentalDamage;
	DetonationDamageEffect.DamageTypes.AddItem('NoFireExplosion');
	DetonationDamageEffect.EffectDamageValue = DetonationDamage;
	Template.AddTargetEffect(DetonationDamageEffect);
	Template.AddMultiTargetEffect(DetonationDamageEffect);
	//Build game State and Visualization
	Template.ActivationSpeech = 'BlasterLauncher';
	Template.CustomFireAnim = CustomAnim;
	Template.CinescriptCameraType = "Psionic_FireAtUnit";
	Template.AbilityConfirmSound = "TacticalUI_SwordConfirm";
	Template.bShowActivation = true;
	Template.bSkipFireAction = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = class'X2Helpers_KineticItems'.static.KineticDetonation_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;
	return Template;
}

static function X2AbilityTemplate CreatePushUpKineticProtectionField(name AbilityName, int FriendlyShieldRadius, int ShieldAmount, string IconColor)
{
	local X2AbilityTemplate 							Template;
	local X2AbilityCost_ActionPoints 					ActionPointCost;
	local X2Condition_SourceHasShieldCheck 				EnergyShieldCondition;;
	local X2Condition_UnitProperty 						UnitPropertyCondition;
	local X2AbilityTrigger_PlayerInput 					InputTrigger;
	local X2Effect_PersistentStatChange 				ShieldedEffect;
	local X2AbilityMultiTarget_Radius 					MultiTarget;
	//Ability Name & UI
	`CREATE_X2ABILITY_TEMPLATE(Template, AbilityName);
	Template.IconImage = "img:///PushUpVest.PerkIcons.UIPerk_KineticProtectionField";
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.Hostility = eHostility_Defensive;
	Template.AbilityIconColor = IconColor;
	//Cost
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);
	//Targeting
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	//Multi target
	MultiTarget = new class'X2AbilityMultiTarget_Radius';
	MultiTarget.fTargetRadius = class'X2Ability_AdventShieldBearer'.default.ENERGY_SHIELD_RANGE_METERS;
	MultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = MultiTarget;
	//Triigers
	InputTrigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(InputTrigger);
	//Conditions
	//Shooter have shields
	EnergyShieldCondition = new class'X2Condition_SourceHasShieldCheck';
	EnergyShieldCondition.ShieldAmount= ShieldAmount;
	Template.AddShooterEffectExclusions();
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityShooterConditions.AddItem(EnergyShieldCondition);
	// The Targets must be within the AOE, LOS, and friendly
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeHostileToSource = true;
	UnitPropertyCondition.ExcludeCivilian = true;
	UnitPropertyCondition.FailOnNonUnits = true;
	Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);
	//Apply Effects
	//Remove Shooter's Filed
	Template.AddShooterEffect(new class'X2Effect_CostAllEnergyShield');
	Template.AddShooterEffect(RemoveShieldedEffect());
	Template.AddShooterEffect(RemoveKineticProtectionField());
	// Friendlies in the radius receives a shield
	Template.AddMultiTargetEffect(RemoveKineticProtectionField());
	ShieldedEffect = new class'X2Effect_EnergyShield';
	ShieldedEffect.BuildPersistentEffect(class'X2Ability_AdventShieldBearer'.default.ENERGY_SHIELD_DURATION, false, true, , eGameRule_PlayerTurnEnd);
	ShieldedEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true);
	ShieldedEffect.AddPersistentStatChange(eStat_ShieldHP, ShieldAmount);
	ShieldedEffect.EffectName = 'KineticProtectionField';
	Template.AddMultiTargetEffect(ShieldedEffect);
	//Build game State and Visualization
	Template.ActivationSpeech = 'Inspire';
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.CustomFireAnim = 'HL_KineticProtectionField';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "AdvShieldBearer_EnergyShieldArmor";
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;
	return Template;
}	

static function X2AbilityTemplate CreatePushUpKineticContainmentField(name AbilityName, int ShieldAmount, string IconColor)
{
	local X2AbilityTemplate								Template;
	local X2Effect_PushUpVestKineticContainmentField    KineticContainmentField;
	local X2Effect_PushUpVestKineticImmobilize   		KineticImmobilize;
	local X2Effect_PersistentStatChange			    	BoundEffect;
	local X2Effect_RemoveEffects 						RemoveEffects;
	local X2Effect_CostAllEnergyShield					CostEneryShield;
	local X2AbilityCost_ActionPoints   	 				ActionPointCost;
	local X2Condition_UnitEffects 						UnitEffects;
	local X2Condition_UnitProperty          			UnitPropertyCondition;
	local X2Condition_SourceHasShieldCheck  			EnergyShieldCondition;
	//Ability Name & UI
	`CREATE_X2ABILITY_TEMPLATE(Template, AbilityName);
	Template.IconImage = "img:///PushUpVest.PerkIcons.UIPerk_KineticContainmentField";
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Offensive;
	Template.AbilityIconColor = IconColor;
	Template.bFriendlyFireWarning = true;
	//Cost
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);
	//Targeting
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	//Trigers
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	//Conditions
	//Shooter have shields
	EnergyShieldCondition = new class'X2Condition_SourceHasShieldCheck';
	EnergyShieldCondition.ShieldAmount= ShieldAmount;
	Template.AddShooterEffectExclusions();
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityShooterConditions.AddItem(EnergyShieldCondition);
	//Target Conditions
	// The Targets must be within the AOE, LOS, and friendly
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeCosmetic = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeHostileToSource = false;
	UnitPropertyCondition.ExcludeCivilian = false;
	UnitPropertyCondition.FailOnNonUnits = true;
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);
	// Target not in statis
	UnitEffects = new class'X2Condition_UnitEffects';
	UnitEffects.AddExcludeEffect(class'X2Ability_CarryUnit'.default.CarryUnitEffectName, 'AA_CarryingUnit');
	UnitEffects.AddExcludeEffect(class'X2Effect_Stasis'.default.EffectName, 'AA_DuplicateEffectIgnored');
	UnitEffects.AddExcludeEffect(class'X2Effect_DLC_Day60Freeze'.default.EffectName, 'AA_UnitIsFrozen');
	UnitEffects.AddExcludeEffect(class'X2Effect_PushUpVestKineticImmobilize'.default.EffectName, 'AA_DuplicateEffectIgnored');
	UnitEffects.AddExcludeEffect(class'X2Effect_PushUpVestKineticContainmentField'.default.EffectName, 'AA_DuplicateEffectIgnored');
	Template.AbilityTargetConditions.AddItem(UnitEffects);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(new class'X2Condition_FirendlyBindCheck');
	//Apply Effects
	//Remove Shooter's Filed
	Template.AddShooterEffect(new class'X2Effect_CostAllEnergyShield');
	Template.AddShooterEffect(RemoveShieldedEffect());
	Template.AddShooterEffect(RemoveKineticProtectionField());
	//Remove exist Bing effect
	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Ability_Viper'.default.BindSustainedEffectName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.BoundName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Ability_DLC_Day60ViperKing'.default.KingBindSustainedEffectName);	
	Template.AddTargetEffect(RemoveEffects);
	Template.AddTargetEffect(class'X2Effect_PushUpVestKineticContainmentField'.static.CreateKineticContainmentField(ShieldAmount,Template.IconImage));
	Template.AddTargetEffect(class'X2Effect_PushUpVestKineticContainmentField'.static.CreateKineticContainmentFieldRemoveEffects());
	//Build game State and Visualization
	Template.CustomFireAnim = 'HL_KineticContainmentField';
	Template.CinescriptCameraType = "Psionic_FireAtUnit";
	Template.ActivationSpeech = 'Insanity';
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.bShowActivation = true;
	Template.bSkipFireAction = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;
	return Template;
}

static function X2AbilityTemplate CreatePushUpKineticLevitated(name AbilityName, int ShieldAmount, string IconColor)
{
	local X2AbilityTemplate							Template;
	local X2Effect_CostAllEnergyShield				CostEneryShield;
	local X2AbilityCost_ActionPoints   	 			ActionPointCost;
	local X2Condition_UnitProperty          		UnitPropertyCondition;
	local X2Condition_UnitProperty 					UnitPropCondition;
	local X2Condition_SourceHasShieldCheck  		EnergyShieldCondition;
	local X2Condition_UnitEffects 					UnitEffects;
	local X2Effect_PushUpVestKineticGeyser			StunnedEffect;
	local X2Effect_PushUpVestKineticLevitateBonus	KineticLevitateBonus;
	//Ability Name & UI
	`CREATE_X2ABILITY_TEMPLATE(Template, AbilityName);
	Template.IconImage = "img:///PushUpVest.PerkIcons.UIPerk_KineticGeyser";
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Offensive;
	Template.AbilityIconColor = IconColor;
	Template.bFriendlyFireWarning = true;
	//Cost
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);
	//Targeting
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	//Trigers
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	//Conditions
	//Shooter have shields
	EnergyShieldCondition = new class'X2Condition_SourceHasShieldCheck';
	EnergyShieldCondition.ShieldAmount= ShieldAmount;
	Template.AddShooterEffectExclusions();
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityShooterConditions.AddItem(EnergyShieldCondition);
	// The Targets must be within the AOE, LOS, and friendly
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeLargeUnits = true;
	UnitPropertyCondition.ExcludeInStasis= true;
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = true;
	UnitPropertyCondition.ExcludeHostileToSource = false;
	UnitPropertyCondition.ExcludeCivilian = false;
	UnitPropertyCondition.ExcludeTurret = true;
	UnitPropertyCondition.FailOnNonUnits = true;
	// Target not in statis
	UnitEffects = new class'X2Condition_UnitEffects';
	UnitEffects.AddExcludeEffect(class'X2Effect_Stasis'.default.EffectName, 'AA_DuplicateEffectIgnored');
	UnitEffects.AddExcludeEffect(class'X2Effect_PushUpVestKineticImmobilize'.default.EffectName, 'AA_DuplicateEffectIgnored');
	UnitEffects.AddExcludeEffect(class'X2Effect_PushUpVestKineticContainmentField'.default.EffectName, 'AA_DuplicateEffectIgnored');
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);
	Template.AbilityTargetConditions.AddItem(UnitEffects);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	//Apply Effects
	//Remove Shooter's Filed
	Template.AddShooterEffect(new class'X2Effect_CostAllEnergyShield');
	Template.AddShooterEffect(RemoveShieldedEffect());
	Template.AddShooterEffect(RemoveKineticProtectionField());
	//Remove exist Bing effect
	Template.AddTargetEffect(class'X2Effect_PushUpVestKineticImmobilize'.static.CreateKineticImmobilizeRemoveEffects());
	//Kinetic Levitated Effect
	Template.AddTargetEffect(class'X2Effect_PushUpVestKineticImmobilize'.static.CreateKineticLevitate(ShieldAmount,Template.IconImage));
	//Build game State and Visualization
	Template.CustomFireAnim = 'HL_KineticLevitated';
	Template.CinescriptCameraType = "Psionic_FireAtUnit";
	Template.ActivationSpeech = 'Domination';
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.bShowActivation = true;
	Template.bSkipFireAction = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;
	return Template;
}	

static function X2AbilityTemplate CreatePushUpKineticSnap()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityCooldown                 Cooldown;
	local X2Condition_UnitProperty          UnitPropertyCondition;
	local X2Condition_UnblockedNeighborTile UnblockedNeighborTileCondition;
	local X2Effect_ApplyWeaponDamage		EnvironmentDamageForProjectile;
	local X2Effect_RemoveEffects			RemoveEffects;
	//Ability Name & UI
	`CREATE_X2ABILITY_TEMPLATE(Template, 'PushUpKineticSnap');
	Template.IconImage = "img:///PushUpVest.PerkIcons.UIPerk_KineticSnap";
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.Hostility = eHostility_Offensive;
	//Cost
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);
	//Cooldown
    Cooldown = New class'X2AbilityCooldown';
	Cooldown.iNumTurns = 2;
	Template.AbilityCooldown = Cooldown;
	//Targetting 
	Template.AbilityTargetStyle = new class'X2AbilityTarget_Single';
	Template.AbilityToHitCalc = default.DeadEye;
	//Trigger
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	//Conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();
	//There must be a free tile around the source unit
	UnblockedNeighborTileCondition = new class'X2Condition_UnblockedNeighborTile';
	UnblockedNeighborTileCondition.RequireVisible = true;
	Template.AbilityShooterConditions.AddItem(UnblockedNeighborTileCondition);
	// The Target must be alive and a humanoid
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeCosmetic = true;
	UnitPropertyCondition.ExcludeTurret = true;
	UnitPropertyCondition.ExcludeRobotic = true;
	UnitPropertyCondition.ExcludeNonHumanoidAliens = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.RequireWithinMinRange = true;
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(class'X2Ability_TemplarAbilitySet'.static.InvertAndExchangeEffectsCondition());
	//Apply Effects
	//Pull Effect
	Template.AddTargetEffect(class'X2Helpers_KineticItems'.static.CreatePullEffect());
	//Envirment Damage
	EnvironmentDamageForProjectile = new class'X2Effect_ApplyWeaponDamage';
	EnvironmentDamageForProjectile.bIgnoreBaseDamage = true;
	EnvironmentDamageForProjectile.EnvironmentalDamageAmount = 30;
	Template.AddTargetEffect(EnvironmentDamageForProjectile);
	//Remove Supperssion Effect
	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Effect_Suppression'.default.EffectName);
	Template.AddTargetEffect(RemoveEffects);
	//Build game State and Visualization
	Template.bForceProjectileTouchEvents = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = class'X2Helpers_KineticItems'.static.PushUpKineticSnap_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.Hostility = eHostility_Offensive;
//BEGIN AUTOGENERATED CODE: Template Overrides 'Justice'
	Template.bFrameEvenWhenUnitIsHidden = true;
	Template.ActionFireClass = class'XComGame.X2Action_ViperGetOverHere';
	Template.ActivationSpeech = 'Justice';
//END AUTOGENERATED CODE: Template Overrides 'Justice'
	return Template;
}

static function X2AbilityTemplate CreateKineticLevitationProximityMineDetonation()	
{
	local X2AbilityTemplate							Template;
	local X2AbilityToHitCalc_StandardAim			ToHit;
	local X2Condition_UnitProperty					UnitPropertyCondition;
	local X2Condition_AbilitySourceWeapon			GrenadeCondition;
	local X2AbilityTarget_Cursor					CursorTarget;
	local X2AbilityMultiTarget_Radius	            RadiusMultiTarget;
	local X2Effect_ApplyWeaponDamage				WeaponDamage;
	//Ability Name & UI
	`CREATE_X2ABILITY_TEMPLATE(Template, 'KineticLevitationProximityMineDetonation');
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_grenade_proximitymine";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_GRENADE_PRIORITY;
	Template.bUseAmmoAsChargesForHUD = true;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	//Targeting
	ToHit = new class'X2AbilityToHitCalc_StandardAim';
	ToHit.bIndirectFire = true;
	Template.AbilityToHitCalc = ToHit;
	//
	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.IncreaseWeaponRange = 2;
	Template.AbilityTargetStyle = CursorTarget;
	//
	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.bUseWeaponRadius = true;
	RadiusMultiTarget.fTargetRadius = 2;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;
	//Conditions
	//Unit types
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeLargeUnits = true;
	UnitPropertyCondition.ExcludeInStasis= true;
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeHostileToSource = false;
	UnitPropertyCondition.ExcludeCivilian = false;
	UnitPropertyCondition.ExcludeTurret = true;
	UnitPropertyCondition.FailOnNonUnits = true;
	Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);
	//exclude friendly unit
	GrenadeCondition = new class'X2Condition_AbilitySourceWeapon';
	GrenadeCondition.CheckGrenadeFriendlyFire = true;
	Template.AbilityMultiTargetConditions.AddItem(GrenadeCondition);
	//Apply Effects
	//Break concealment
	Template.AddShooterEffect(new class'X2Effect_BreakUnitConcealment');
	//Apply Damage
	WeaponDamage = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamage.bExplosiveDamage = true;
	Template.AddMultiTargetEffect(WeaponDamage);
	//Apply lift up
	Template.AddMultiTargetEffect(class'X2Effect_PushUpVestKineticImmobilize'.static.CreateKineticLevitateMineDenoteEffect(1));
	//Build game State and Visualization
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');   
	Template.FrameAbilityCameraType = eCameraFraming_Never;
	Template.ActivationSpeech = 'Explosion';
	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = class'X2Helpers_KineticItems'.static.KineticLevitationProximityMineDetonation_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.MergeVisualizationFn = class'X2Ability_Death'.static.DeathExplostion_MergeVisualization;
	// cannot interrupt this explosion
	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.GrenadeLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;
	return Template;
}

static function X2AbilityTemplate CreatePushUpKineticRoundsInit()
{
	local X2AbilityTemplate					Template;
	local X2Effect_PushUpKineticRoundsInit	KineticInit;
	//Ability Name & UI
	`CREATE_X2ABILITY_TEMPLATE(Template, 'PushUpKineticRoundsInit');
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;
	//Targeting
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	//Apply Effects
	//Add listener to trigger Lift Effect
	KineticInit = new class'X2Effect_PushUpKineticRoundsInit';
	KineticInit.AbilityToActivate='PushUpKineticRoundsLevitate';
	KineticInit.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
	Template.AddTargetEffect(KineticInit);
	//Build game State and Visualization
	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	return Template;
}

static function X2AbilityTemplate CreatePushUpKineticRoundsLevitate()
{
	local X2AbilityTemplate	Template;
	local array<name>       SkipExclusions;
	//Ability Name & UI
	`CREATE_X2ABILITY_TEMPLATE(Template, 'PushUpKineticRoundsLevitate');
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_blindfire";
	Template.Hostility = eHostility_Neutral;
	//Targeting
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	//Trigger
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');
	//Conditions
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	//Apply Effects
	//Add Lift Effect
	Template.AddTargetEffect(class'X2Effect_PushUpVestKineticImmobilize'.static.CreateKineticRoundsLevitateEffect(1));
	//Build game State and Visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	//Template.MergeVisualizationFn = class'X2Ability_Death'.static.DeathExplostion_MergeVisualization;
Template.MergeVisualizationFn = class'X2Helpers_KineticItems'.static.ClearHangs_MergeVisualization;
	Template.bShowActivation = false;
	Template.bSkipFireAction = true;
	Template.bFrameEvenWhenUnitIsHidden = true;
	return Template;
}


static function X2Effect_RemoveEffects RemoveShieldedEffect()
{
	local X2Effect_RemoveEffects RemoveEffects;
	local X2Condition_UnitEffects UnitEffects;

	UnitEffects = new class'X2Condition_UnitEffects';
	UnitEffects.AddRequireEffect(class'X2Effect_EnergyShield'.default.EffectName, 'AA_MissingRequiredEffect');
	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Effect_EnergyShield'.default.EffectName);
	RemoveEffects.TargetConditions.AddItem(UnitEffects);
	return RemoveEffects;
}

static function X2Effect_RemoveEffects RemoveKineticProtectionField()
{
	local X2Effect_RemoveEffects RemoveEffects;
	local X2Condition_UnitEffects UnitEffects;

	UnitEffects = new class'X2Condition_UnitEffects';
	UnitEffects.AddRequireEffect('KineticProtectionField', 'AA_MissingRequiredEffect');
	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem('KineticProtectionField');
	RemoveEffects.TargetConditions.AddItem(UnitEffects);
	return RemoveEffects;
}	

function name ApplyChance_EruptionStunAndKnockBack(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState)
{
	local int Tiles;
	local float RandRoll, ApplyChance;
	local XComGameState_Unit SourceUnit, TargetUnit;

	SourceUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	if( SourceUnit == none )
	{
		SourceUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	}
	TargetUnit = XComGameState_Unit(kNewTargetState);
	Tiles = SourceUnit.TileDistanceBetween(TargetUnit);
	if (Tiles > default.Eruption_Radius[4])
		ApplyChance = class'X2Ability_TemplarAbilitySet'.default.REND_DISORIENT_CHANCE;
	else
	ApplyChance = (float(default.Eruption_Radius[4]+1) - float(Tiles))/float(default.Eruption_Radius[4]);
	RandRoll = `SYNC_FRAND();
	if (RandRoll <= ApplyChance)
	{
		return 'AA_Success';
	}
	return 'AA_EffectChanceFailed';
}