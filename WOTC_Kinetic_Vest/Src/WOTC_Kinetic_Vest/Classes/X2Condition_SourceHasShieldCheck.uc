class X2Condition_SourceHasShieldCheck extends X2Condition;
var int ShieldAmount;
event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{
	local XComGameState_Unit SourceUnit;

	SourceUnit = XComGameState_Unit(kTarget);
	if (SourceUnit.GetCurrentStat(eStat_ShieldHP) == ShieldAmount)
	{
		return 'AA_Success';
	}
	else if (SourceUnit.GetCurrentStat(eStat_ShieldHP) > class'X2Ability_PushUpVest'.default.MaxShieldAmount)
	{
		if ( ShieldAmount == class'X2Ability_PushUpVest'.default.MaxShieldAmount)
		{
			return 'AA_Success';
		}
	}
	return 'AA_AbilityUnavailable';
}