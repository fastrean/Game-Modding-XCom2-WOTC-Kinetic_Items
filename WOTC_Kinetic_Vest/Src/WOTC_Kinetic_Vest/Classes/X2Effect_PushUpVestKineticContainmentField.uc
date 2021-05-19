class X2Effect_PushUpVestKineticContainmentField extends X2Effect_PersistentStatChange config(PushUpVestData);//config(GameCore);//X2Effect_Persistent;

var localized string ContainmentFieldName, ContainmentFieldDesc, KineticContainmentFieldTickFlyover, KineticContainmentFieldAddedString, KineticContainmentFieldPersistsString, KineticContainmentFieldRemovedString, KineticContainmentFieldLostFlyover, ParalyzedTitle;
var config array<name> FlyoverNames;
var name ImmobilizeStartAnim, ImmobilizeStopAnim;
var bool bAllowReorder;
var bool bSkipAnimation;
var protectedwrite int ImmobilizeDuration;

static function X2Effect_PushUpVestKineticContainmentField CreateKineticContainmentField (int Duration, string StatusIcon)
{
	local X2Effect_PushUpVestKineticContainmentField  Effect;

	Effect = new class'X2Effect_PushUpVestKineticContainmentField';
	Effect.BuildPersistentEffect(1, false, false, true, eGameRule_PlayerTurnBegin);
	Effect.bUseSourcePlayerState = false;
	Effect.bRemoveWhenTargetDies = true;
	Effect.bAllowReorder = false;

	Effect.SetDisplayInfo(ePerkBuff_Penalty, default.ContainmentFieldName, default.ContainmentFieldDesc, StatusIcon);

	Effect.AddPersistentStatChange(eStat_Dodge, 0, MODOP_PostMultiplication);       //  no dodge for you
	Effect.AddPersistentStatChange(eStat_Defense, class'X2Effect_DLC_Day60Freeze'.default.DefenseMod);
	Effect.AddPersistentStatChange(eStat_SightRadius, 0, MODOP_PostMultiplication);
	Effect.AddPersistentStatChange(eStat_ShieldHP, Duration*5);

	Effect.CustomIdleOverrideAnim='HL_StunnedIdle';
	Effect.ImmobilizeStartAnim='HL_StunnedStart';
	Effect.ImmobilizeStopAnim='HL_StunnedStop';

	Effect.ImmobilizeDuration = Duration;

	return Effect;
}

static function X2Effect CreateKineticContainmentFieldRemoveEffects()
{
	local X2Effect_RemoveEffectsByDamageType RemoveEffects;

	RemoveEffects = new class'X2Effect_RemoveEffectsByDamageType';
	RemoveEffects.DamageTypesToRemove.AddItem('stun');
	RemoveEffects.DamageTypesToRemove.AddItem('fire');
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Effect_PushUpVestKineticImmobilize'.default.EffectName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.ConfusedName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.PanickedName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.StunnedName);

	return RemoveEffects;
}

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	EffectObj = EffectGameState;

	EventMgr.RegisterForEvent(EffectObj, 'ShieldsExpended', EffectGameState.OnShieldsExpended, ELD_OnStateSubmitted, , UnitState);
}

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnit;
	local X2EventManager EventMan;

	TargetUnit = XComGameState_Unit(kNewTargetState);

	if (TargetUnit != none)
	{
		//  Freeze overrides stun, so clear out any stunned action points - they cannot be recovered
		TargetUnit.StunnedActionPoints = 0;
		TargetUnit.StunnedThisTurn = 0;
		//  Now knock off all of their AP
		TargetUnit.ActionPoints.Length = 0;
		TargetUnit.ReserveActionPoints.Length = 0;
		//  immobilize
		TargetUnit.SetUnitFloatValue(class'X2Ability_DefaultAbilitySet'.default.ImmobilizedValueName, 1);

		EventMan = `XEVENTMGR;
		TargetUnit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.UnburrowActionPoint);      //  will be useless for units without unburrow, just add it blindly
		EventMan.TriggerEvent(class'X2Ability_Chryssalid'.default.UnburrowTriggerEventName, kNewTargetState, kNewTargetState, NewGameState);
	}

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

simulated function bool FullTurnComplete(XComGameState_Effect kEffect, XComGameState_Player Player)
{
	local XComGameState_Unit TargetUnit;
	local int CachedUnitActionPlayerId;

	// all units tick at the start of their turn
	TargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(kEffect.ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	CachedUnitActionPlayerId = Player.ObjectID;
	return CachedUnitActionPlayerId == TargetUnit.ControllingPlayer.ObjectID;
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local XComGameState_Unit TargetUnit;
	
	// add action points
	TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if (TargetUnit == none)
	{
		TargetUnit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	}

	if (TargetUnit != none && !class'X2Helpers_DLC_Day60'.static.IsUnitAlienRuler(TargetUnit))
	{
		TargetUnit.GiveStandardActionPoints();
	}

	//  stop the immobilize
	TargetUnit.ClearUnitValue(class'X2Ability_DefaultAbilitySet'.default.ImmobilizedValueName);

	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);
}

function bool ProvidesDamageImmunity(XComGameState_Effect EffectState, name DamageType)
{
	return DamageType == 'stun';
}

function int GetStartingNumTurns(const out EffectAppliedData ApplyEffectParameters)
{
	local XComGameState_Unit TargetUnit;
	local int RulerFreezeCount;

	TargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if (TargetUnit == none) // don't apply to non-units
		return 0;

	if(class'X2Helpers_DLC_Day60'.static.IsUnitAlienRuler(TargetUnit))
	{
		// Get per ruler modifier here and subtract it from the turns
		RulerFreezeCount = `SYNC_RAND(class'X2Item_DLC_Day60Grenades'.default.FROSTBOMB_MAX_RULER_FREEZE_DURATION - class'X2Item_DLC_Day60Grenades'.default.FROSTBOMB_MIN_RULER_FREEZE_DURATION) + class'X2Item_DLC_Day60Grenades'.default.FROSTBOMB_MIN_RULER_FREEZE_DURATION;
		RulerFreezeCount -= class'X2Helpers_DLC_Day60'.static.GetRulerFreezeModifier(TargetUnit);
		return RulerFreezeCount;
	}
	else
	{
		// "normal" unit
		return ImmobilizeDuration;
	}
}

function ModifyTurnStartActionPoints(XComGameState_Unit UnitState, out array<name> ActionPoints, XComGameState_Effect EffectState)
{
	//  no actions allowed while frozen
	ActionPoints.Length = 0;
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ModifyTrack, name EffectApplyResult)
{
	// Empty because we will be adding all this at the end with ModifyTracksVisualization
	local X2Action_PlayAnimation PlayAnimation;
	local XComGameState_Unit TargetUnit;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;

	TargetUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(ModifyTrack.StateObject_NewState.ObjectID));
	if (TargetUnit == None)
	{
		TargetUnit = XComGameState_Unit(ModifyTrack.StateObject_NewState);
	}

	if (EffectApplyResult == 'AA_Success' && TargetUnit != none && !bSkipAnimation)
	{
		if (TargetUnit.IsTurret())
		{
			class'X2Action_UpdateTurretAnim'.static.AddToVisualizationTree(ModifyTrack, VisualizeGameState.GetContext(), false, ModifyTrack.LastActionAdded);
		}
		else
		{
			PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ModifyTrack, VisualizeGameState.GetContext(), false, ModifyTrack.LastActionAdded));
			PlayAnimation.Params.AnimName = ImmobilizeStartAnim;
		}
	}

	super.AddX2ActionsForVisualization(VisualizeGameState, ModifyTrack, EffectApplyResult);
}

simulated function AddX2ActionsForVisualization_Sync( XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata )
{
	local X2Action_DLC_Day60Freeze FreezeAction;
	AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, 'AA_Success');
}

// rulers show a different flyover from other units, so this function splits that out
static protected function string GetFlyoverTickText(XComGameState_Unit UnitState)
{
	local XComGameState_Effect EffectState;
	local X2AbilityTag AbilityTag;
	local name FlyoverName;
	local string ExpandedString; // bsg-dforrest (7.27.17): need to clear out ParseObject


	EffectState = UnitState.GetUnitAffectedByEffectState(default.EffectName);
	if (EffectState != none)
	{
		AbilityTag = X2AbilityTag(`XEXPANDCONTEXT.FindTag("Ability"));
		AbilityTag.ParseObj = EffectState;
		// bsg-dforrest (7.27.17): need to clear out ParseObject
		ExpandedString = `XEXPAND.ExpandString(default.KineticContainmentFieldTickFlyover);
		AbilityTag.ParseObj = none;
		// bsg-dforrest (7.27.17): end
		return ExpandedString;
	}

}

simulated function ModifyTracksVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ModifyTrack, const name EffectApplyResult)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(ModifyTrack.StateObject_NewState);
	if( UnitState != none && EffectApplyResult == 'AA_Success' )
	{
		//  Make the freeze happen immediately after the wait, rather than waiting until after the apply damage action
		class'X2Action_DLC_Day60Freeze'.static.AddToVisualizationTree(ModifyTrack, VisualizeGameState.GetContext());
		class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(ModifyTrack, VisualizeGameState.GetContext(), GetFlyoverTickText(UnitState), '', eColor_Bad, default.StatusIcon);
		class'X2StatusEffects'.static.AddEffectMessageToTrack(ModifyTrack,
															  default.KineticContainmentFieldAddedString,
															  VisualizeGameState.GetContext(),
															  default.ParalyzedTitle,
															  default.StatusIcon,
															  eUIState_Bad);
		class'X2StatusEffects'.static.UpdateUnitFlag(ModifyTrack, VisualizeGameState.GetContext());
	}
}

static function KineticContainmentFieldVisualizationTicked(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(ActionMetadata.StateObject_NewState);
	if (UnitState != none)
	{
		class'X2StatusEffects'.static.AddEffectCameraPanToAffectedUnitToTrack(ActionMetadata, VisualizeGameState.GetContext());
		class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(ActionMetadata, VisualizeGameState.GetContext(), GetFlyoverTickText(UnitState), '', eColor_Bad, default.StatusIcon);
		class'X2StatusEffects'.static.AddEffectMessageToTrack(ActionMetadata,
															  default.KineticContainmentFieldPersistsString,
															  VisualizeGameState.GetContext(),
															  default.ParalyzedTitle,
															  default.StatusIcon,
															  eUIState_Warning);
		class'X2StatusEffects'.static.UpdateUnitFlag(ActionMetadata, VisualizeGameState.GetContext());
	}
}

simulated function AddX2ActionsForVisualization_Removed(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult, XComGameState_Effect RemovedEffect)
{
	local XComGameState_Unit UnitState;
	local string FlyoverText;
	local XComGameStateVisualizationMgr VisMgr;
	local X2Action_SKULLJACK FromSkullJack;
	local X2Action_CameraLookAt LookAtAction;
	local X2Action_PlayAnimation PlayAnimation;

	VisMgr = `XCOMVISUALIZATIONMGR;

	super.AddX2ActionsForVisualization_Removed(VisualizeGameState, ActionMetadata, EffectApplyResult, RemovedEffect);

	UnitState = XComGameState_Unit(ActionMetadata.StateObject_NewState);

	if (UnitState != none && UnitState.IsAlive())
	{
		// new add play effect end animation start
		if (UnitState.IsTurret())
		{
			class'X2Action_UpdateTurretAnim'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded);
		}

		//new add play effect end animation end
		FromSkullJack = X2Action_SKULLJACK(VisMgr.GetNodeOfType(VisMgr.BuildVisTree, class'X2Action_SkullJack'));
		if( FromSkullJack != None )
		{
			class'X2Action_DLC_Day60FreezeEnd'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), true, , FromSkullJack.ParentActions);
		}
		else if (!UnitState.IsIncapacitated() && !UnitState.IsDazed()) //Don't play the animation if the unit is going straight from stunned to killed
		{
			LookAtAction = X2Action_CameraLookAt(class'X2Action_CameraLookAt'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
			LookAtAction.UseTether = false;
			LookAtAction.LookAtObject = UnitState;
			LookAtAction.BlockUntilActorOnScreen = true;

			// The unit is not a turret and is not dead/unconscious/bleeding-out
			PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
			PlayAnimation.Params.AnimName = ImmobilizeStopAnim;
			PlayAnimation.Params.BlendTime = 0.5f;
		}	
		else
		{
			class'X2Action_DLC_Day60FreezeEnd'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded);
		
		}
		FlyoverText = default.KineticContainmentFieldLostFlyover;
		class'X2StatusEffects'.static.AddEffectCameraPanToAffectedUnitToTrack(ActionMetadata, VisualizeGameState.GetContext());
		class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(ActionMetadata, VisualizeGameState.GetContext(), FlyoverText, '', eColor_Good, default.StatusIcon);
		class'X2StatusEffects'.static.AddEffectMessageToTrack(ActionMetadata,
																default.KineticContainmentFieldRemovedString,
																VisualizeGameState.GetContext(),
																default.ParalyzedTitle,
																default.StatusIcon,
																eUIState_Good);
		class'X2StatusEffects'.static.UpdateUnitFlag(ActionMetadata, VisualizeGameState.GetContext());
	}
}

DefaultProperties
{
	bIsImpairing = true
	bAllowReorder = true
	EffectName = "Freeze"
	DuplicateResponse = eDupe_Ignore
	//DamageTypes(0) = "Frost"
	ModifyTracksFn = ModifyTracksVisualization
	EffectTickedVisualizationFn = KineticContainmentFieldVisualizationTicked
	bCanTickEveryAction=true

	Begin Object Class=X2Condition_UnitEffects Name=UnitEffectsCondition
		ExcludeEffects(0)=(EffectName="Unconscious", Reason="AA_UnitIsUnconscious")
	End Object

	TargetConditions.Add(UnitEffectsCondition)
}
