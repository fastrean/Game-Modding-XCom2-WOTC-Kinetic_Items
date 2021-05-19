class X2Effect_KineticLevitationProximityMine extends X2Effect_ProximityMine;



function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMan;
	local XComGameState_Effect_PushUp EffectState;
	local Object EffectObj;

	EffectState = XComGameState_Effect_PushUp(EffectGameState);
	`assert(EffectState != none);
	EventMan = `XEVENTMGR;
	EffectObj = EffectGameState;
	EventMan.RegisterForEvent(EffectObj, 'ObjectMoved', EffectState.ProximityMine_ObjectMoved, ELD_OnStateSubmitted);
	EventMan.RegisterForEvent(EffectObj, 'AbilityActivated', EffectState.ProximityMine_AbilityActivated, ELD_OnStateSubmitted);

}


DefaultProperties
{
	EffectName="KineticLevitationProximityMine"
	GameStateEffectClass = class'XComGameState_Effect_PushUp'
	DuplicateResponse = eDupe_Allow;
	bCanBeRedirected = false;
}