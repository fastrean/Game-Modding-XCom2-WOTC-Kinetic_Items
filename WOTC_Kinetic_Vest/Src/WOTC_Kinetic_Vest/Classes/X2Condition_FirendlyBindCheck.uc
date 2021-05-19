class X2Condition_FirendlyBindCheck extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{ 
	local XComGameState_Unit UnitState;
	
	UnitState = XComGameState_Unit(kTarget);
	if (UnitState == none)
	{
		return 'AA_NotAUnit';
	}
	if (UnitState.GetTeam() == eTeam_XCom)
	{
		if (UnitState.IsUnitAffectedByEffectName(class'X2Ability_Viper'.default.BindSustainedEffectName))
		{
			return 'AA_AbilityUnavailable';
		}
		if (UnitState.IsUnitAffectedByEffectName(class'X2AbilityTemplateManager'.default.BoundName))
		{
			return 'AA_AbilityUnavailable';
		}
		if (UnitState.IsUnitAffectedByEffectName(class'X2Ability_DLC_Day60ViperKing'.default.KingBindSustainedEffectName))
		{
			return 'AA_AbilityUnavailable';
		}	
	}	
	
	return 'AA_Success'; 
}
