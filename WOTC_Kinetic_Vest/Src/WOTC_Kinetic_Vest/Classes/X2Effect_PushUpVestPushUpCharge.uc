class X2Effect_PushUpVestPushUpCharge extends X2Effect_Persistent;//;X2Effect_PersistentStatChange

var bool bSkipAnimation;
var name PushUpStartAnimName;
var name PushUpStopAnimName;
var name PushUpSlamAnimName;

var localized string CannotBeLiftedFlyoverText;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnitState;

	TargetUnitState = XComGameState_Unit(kNewTargetState);
	if (TargetUnitState != none)
	{	
		// Immobilize to prevent scamper or panic from enabling this unit to move again.
		TargetUnitState.ReserveActionPoints.Length = 0;
		TargetUnitState.ActionPoints.Length = 0;
		TargetUnitState.SetUnitFloatValue(class'X2Ability_DefaultAbilitySet'.default.ImmobilizedValueName, 1);
		TargetUnitState.bGeneratesCover=true;
		TargetUnitState.bTreatLowCoverAsHigh=true;
	}
	//super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

// returns bool for TickCompleteEffect
function bool PushUpTicked(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication)
{
	return false;
}
/*
function ModifyTurnStartActionPoints(XComGameState_Unit UnitState, out array<name> ActionPoints, XComGameState_Effect EffectState)
{
	//  no actions allowed while in stasis1
	ActionPoints.Length = 0;
}
*/
simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local XComGameState_Unit TargetUnitState;

	if (bCleansed)
		bSkipAnimation = true;

	TargetUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if(TargetUnitState != none)
	{
		TargetUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(TargetUnitState.Class, TargetUnitState.ObjectID));
		TargetUnitState.SetUnitFloatValue(class'X2Ability_DefaultAbilitySet'.default.ImmobilizedValueName, 0);
	}
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, name EffectApplyResult)
{
	local X2Action_PlayAnimation PlayAnimation;
	local X2Action_ApplyWeaponDamageToUnit DamageAction;
	local XGUnit Unit;
	local XComUnitPawn UnitPawn;

	if( EffectApplyResult == 'AA_Success' )
	{
		Unit = XGUnit(ActionMetadata.VisualizeActor);
		if( Unit != None )
		{
			UnitPawn = Unit.GetPawn();
			if( UnitPawn != None && UnitPawn.GetAnimTreeController().CanPlayAnimation(PushUpStartAnimName) )
			{
				// Play the start stun animation
				PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
				PlayAnimation.Params.AnimName = PushUpStartAnimName;
				PlayAnimation.bResetWeaponsToDefaultSockets = true;
			}
		}

		super.AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, EffectApplyResult);

		DamageAction = X2Action_ApplyWeaponDamageToUnit(class'X2Action_ApplyWeaponDamageToUnit'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		DamageAction.OriginatingEffect = self;
	}
	else
	{
		super.AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, EffectApplyResult);
	}
}

simulated function AddX2ActionsForVisualization_Sync(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata)
{
	//We assume 'AA_Success', because otherwise the effect wouldn't be here (on load) to get sync'd
	AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, 'AA_Success');
}

simulated private function AddX2ActionsForVisualization_Removed_Internal(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local X2Action_PlayAnimation PlayAnimation;
	local XComGameState_Unit StunnedUnit;

	if (bSkipAnimation)
		return;

	StunnedUnit = XComGameState_Unit(ActionMetadata.StateObject_NewState);
	if ( StunnedUnit.IsAlive() && !StunnedUnit.IsIncapacitated() && !StunnedUnit.IsDazed()) //Don't play the animation if the unit is going straight from stunned to killed
	{
		// The unit is not a turret and is not dead/unconscious/bleeding-out
		PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		PlayAnimation.Params.AnimName = PushUpStopAnimName;
	}
}

simulated function AddX2ActionsForVisualization_Removed(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult, XComGameState_Effect RemovedEffect)
{
	local X2Action_PlayAnimation PlayAnimation;
	local XComGameState_Unit DownedUnit;
	local X2Action_CameraLookAt LookAtAction;

	super.AddX2ActionsForVisualization_Removed(VisualizeGameState, ActionMetadata, EffectApplyResult, RemovedEffect);

	if (bSkipAnimation)
		return;

	DownedUnit = XComGameState_Unit(ActionMetadata.StateObject_NewState);

	if (DownedUnit.IsTurret())
	{
		class'X2Action_UpdateTurretAnim'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded);
	}
	else if (DownedUnit.IsAlive() && !DownedUnit.IsIncapacitated() && !DownedUnit.IsDazed()) //Don't play the animation if the unit is going straight from stunned to killed
	{
		LookAtAction = X2Action_CameraLookAt(class'X2Action_CameraLookAt'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		LookAtAction.UseTether = false;
		LookAtAction.LookAtObject = DownedUnit;
		LookAtAction.BlockUntilActorOnScreen = true;

		// The unit is not a turret and is not dead/unconscious/bleeding-out
		PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		PlayAnimation.Params.AnimName = PushUpStopAnimName;
	}
}

defaultproperties
{
	bIsImpairing=true
	//DamageTypes(0) = "Unconscious"
	CustomIdleOverrideAnim="HL_VoidConduitTarget_Loop"
	EffectTickedFn = PushUpTicked
	GameStateEffectClass = class'XComGameState_Effect_PushUp'
	EffectName = "PushUp"
}