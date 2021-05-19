class X2Effect_PushUpKineticRoundsInit extends X2Effect_Persistent;

var name AbilityToActivate;         //  ability to activate when the covering fire check is matched
var name GrantActionPoint;          //  action point to give the shooter when covering fire check is matched
var int MaxPointsPerTurn;           //  max times per turn the action point can be granted
var bool bDirectAttackOnly;         //  covering fire check can only match when the target of this effect is directly attacked
var bool bPreEmptiveFire;           //  if true, the reaction fire will happen prior to the attacker's shot; otherwise it will happen after
var bool bOnlyDuringEnemyTurn;      //  only activate the ability during the enemy turn (e.g. prevent return fire during the sharpshooter's own turn)
var bool bUseMultiTargets;          //  initiate AbilityToActivate against yourself and look for multi targets to hit, instead of direct retaliation
var bool bOnlyWhenAttackMisses;		//  Only activate the ability if the attack missed
var bool bSelfTargeting;			//  The ability being activated targets the covering unit (self)
var int	ActivationPercentChance;	//  If this is greater than zero, this is the percent chance the AbilityToActivate is activated

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local Object EffectObj;
	local XComGameState_Effect_PushUp EffectState;

	EffectState = XComGameState_Effect_PushUp(EffectGameState);
	`assert(EffectState != none);
	EventMgr = `XEVENTMGR;
	EffectObj = EffectGameState;
	EventMgr.RegisterForEvent(EffectObj, 'UnitTakeEffectDamage', EffectState.KineticRoundListener, ELD_OnStateSubmitted);
}

DefaultProperties
{
	bPreEmptiveFire = true
	bOnlyWhenAttackMisses = false
	bSelfTargeting = false
	ActivationPercentChance = 0
	GameStateEffectClass = class'XComGameState_Effect_PushUp'
}