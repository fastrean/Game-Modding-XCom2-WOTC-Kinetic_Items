class X2Effect_PushUpVestPersonalKineticShield extends X2Effect_PersistentStatChange config(PushUpVestData);

var int ShieldPerCharge;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMan;
	local XComGameState_Effect_PushUp EffectState;
	local Object EffectObj;

	EffectState = XComGameState_Effect_PushUp(EffectGameState);
	`assert(EffectState != none);
	EventMan = `XEVENTMGR;
	EffectObj = EffectGameState;
	//EventMan.RegisterForEvent(EffectObj, 'PushUpActivated', class'XComGameState_Effect_PushUp'.static.KineticPlatingListener, ELD_OnStateSubmitted);
	EventMan.RegisterForEvent(EffectObj, 'PushUpActivated', EffectState.KineticPlatingListener, ELD_OnStateSubmitted);

}

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
	XComGameState_Unit(kNewTargetState).SetCurrentStat(eStat_ShieldHP, 0);
}

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
	DuplicateResponse = eDupe_Ignore
	EffectName = "PersonalKineticShieldEffect"
	GameStateEffectClass = class'XComGameState_Effect_PushUp'
}