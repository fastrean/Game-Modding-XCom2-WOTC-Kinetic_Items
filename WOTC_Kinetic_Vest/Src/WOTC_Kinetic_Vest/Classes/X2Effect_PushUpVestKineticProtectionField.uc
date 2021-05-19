class X2Effect_PushUpVestKineticProtectionField extends X2Effect_PersistentStatChange;

var int MaxShieldAmount, ShiledsToAdd;

function int GetDefendingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, X2Effect_ApplyWeaponDamage WeaponDamageEffect, optional XComGameState NewGameState)
{
	local array<name> IncomingTypes;
	local name ImmuneType;
	local XComGameState_Unit UnitState;
	local int DamageMod;
	UnitState = XComGameState_Unit(TargetDamageable);
	ImmuneType = 'Mental';
	WeaponDamageEffect.GetEffectDamageTypes(NewGameState, AppliedData, IncomingTypes);
	DamageMod = UnitState.GetCurrentStat(eStat_ShieldHP);
	if (CurrentDamage < DamageMod)
		DamageMod -= 1;
	if (IncomingTypes.Find(ImmuneType) != INDEX_NONE)
		return 0;
	return -DamageMod;
}	

DefaultProperties
{
	DuplicateResponse = eDupe_Refresh
	EffectName = "KineticProtectionFieldEffect"
}