class X2Effect_PushUpVestKineticLevitateBonus extends X2Effect_Persistent;//X2Effect_Stunned;//;   X2Effect_PersistentStatChange

var bool bSkipAnimation;

var localized string CannotBeLiftedFlyoverText;

function bool ChangeHitResultForAttacker(XComGameState_Unit Attacker, XComGameState_Unit TargetUnit, XComGameState_Ability AbilityState, const EAbilityHitResult CurrentResult, out EAbilityHitResult NewHitResult)
{
	local int TargetDodge, AttackerAim;

	//  change any miss into a hit, if we haven't already done that this turn
	if (TargetUnit.GetUnitAffectedByEffectState(class'X2Ability_PushUpVest'.default.LevitatedName) == none)
	{
		return false;
	}
	if (class'XComGameStateContext_Ability'.static.IsHitResultMiss(CurrentResult))
	{
		TargetDodge = `SYNC_RAND(TargetUnit.GetCurrentStat(eStat_Defense)+TargetUnit.GetCurrentStat(eStat_Dodge));
		AttackerAim = Attacker.GetCurrentStat(estat_Offense) + Attacker.GetCurrentStat(eStat_CritChance);
		if (TargetDodge < AttackerAim)
		{
			NewHitResult = eHit_Crit;
		}
		else
		{
			NewHitResult = eHit_Success;
		}
		return true;
	}
	return false;
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local XComGameState_Unit TargetUnitState;
	local EffectAppliedData NewEffectParams;
	local X2Effect_ApplyWeaponDamage DamageEffect;

	if (bCleansed)
		bSkipAnimation = true;

	TargetUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if(TargetUnitState != none && TargetUnitState.IsAlive())
	{
		TargetUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(TargetUnitState.Class, TargetUnitState.ObjectID));
		NewEffectParams = ApplyEffectParameters;
		NewEffectParams.AbilityResultContext.HitResult = eHit_Success;
		NewEffectParams.TargetStateObjectRef = TargetUnitState.GetReference();
		DamageEffect = new class'X2Effect_ApplyWeaponDamage';
		DamageEffect.EffectDamageValue.Damage = 3;
		DamageEffect.EffectDamageValue.DamageType = 'Falling';
		DamageEffect.bIgnoreBaseDamage = true;
		DamageEffect.DamageTypes.AddItem('Falling');
		DamageEffect.bAllowFreeKill = true;
		DamageEffect.bIgnoreArmor = true;
		`assert(DamageEffect != none);
		DamageEffect.ApplyEffect(NewEffectParams, TargetUnitState, NewGameState);
	}
	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, true, RemovedEffectState);
}

defaultproperties
{
	EffectName="LevitatedBonus"
	DuplicateResponse = eDupe_Ignore
	bRemoveWhenTargetDies = true
	bCanTickEveryAction = true
}

