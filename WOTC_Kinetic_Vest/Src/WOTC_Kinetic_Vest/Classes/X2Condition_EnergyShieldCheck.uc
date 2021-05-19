class X2Condition_EnergyShieldCheck extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{ 
	local XComGameState_Unit UnitState;
	
	UnitState = XComGameState_Unit(kTarget);
	if (UnitState == none)
	{
		return 'AA_NotAUnit';
	}
	if (UnitState.GetCurrentStat(eStat_ShieldHP) == 0)
	{
		return 'AA_AbilityUnavailable';
	}
	return 'AA_Success'; 
}
