class X2Effect_CostAllEnergyShield extends X2Effect; // X2Effect_ModifyStats

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit UnitState;
	local int CurrentShileds;
	UnitState = XComGameState_Unit(kNewTargetState);	
	CurrentShileds = UnitState.GetCurrentStat(eStat_ShieldHP);
	if (CurrentShileds != 0)
	{
		UnitState.SetCurrentStat(eStat_ShieldHP, 0);
	}
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

