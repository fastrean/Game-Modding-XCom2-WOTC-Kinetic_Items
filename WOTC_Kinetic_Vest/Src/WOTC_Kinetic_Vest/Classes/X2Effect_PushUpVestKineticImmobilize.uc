class X2Effect_PushUpVestKineticImmobilize extends X2Effect_PersistentStatChange config(PushUpVestData);

var config WeaponDamageValue KineticWeaponSlam, KineticLevitateSlam;
var localized string KineticImmobilizeName, KineticImmobilizeDesc, KineticImmobilizeTickFlyover, KineticImmobilizeAddedString, KineticImmobilizePersistsString, KineticImmobilizeRemovedString, KineticImmobilizeLostFlyover, KineticImmobilizeTitle;
var name ImmobilizeStartAnim, ImmobilizeStopAnim;
var WeaponDamageValue ApplyDamageValue;
var bool bAllowReorder;
var bool bSkipAnimation;
var bool bApplyDamageOnRemove;

var protectedwrite int ImmobilizeDuration;

static function X2Effect_PushUpVestKineticImmobilize CreateKineticLevitate (int Duration, string StatusIcon)
{
	local X2Effect_PushUpVestKineticImmobilize  Effect;
	local X2Effect_ApplyWeaponDamage 			DamageEffect;
	Effect = new class'X2Effect_PushUpVestKineticImmobilize';
	Effect.BuildPersistentEffect(Duration, false, false, true, eGameRule_PlayerTurnBegin);
	Effect.SetDisplayInfo(ePerkBuff_Penalty, default.KineticImmobilizeName, default.KineticImmobilizeDesc, StatusIcon);

	Effect.AddPersistentStatChange(eStat_Dodge, 0, MODOP_PostMultiplication);       //  no dodge for you
	Effect.AddPersistentStatChange(eStat_SightRadius, 0, MODOP_PostMultiplication);
	Effect.AddPersistentStatChange(eStat_Defense, -10);

	Effect.bUseSourcePlayerState = false;
	Effect.bRemoveWhenTargetDies = true;
	Effect.bApplyDamageOnRemove = false;
	Effect.CustomIdleOverrideAnim='HL_LevitatedLoop';
	Effect.ImmobilizeStartAnim='HL_LevitatedStart';
	Effect.ImmobilizeStopAnim='HL_LevitatedStopSlamA';
	Effect.ImmobilizeDuration = Duration;

	DamageEffect = new class'X2Effect_ApplyWeaponDamage';
	DamageEffect.EffectDamageValue = class'X2Item_DLC_Day60Weapons'.default.VIPERNEONATE_BIND_BASEDAMAGE;
	DamageEffect.EffectDamageValue.DamageType = 'Falling';
	DamageEffect.bIgnoreBaseDamage = false;
	DamageEffect.DamageTypes.AddItem('Falling');
	DamageEffect.bAllowFreeKill = false;
	DamageEffect.bIgnoreArmor = false;
	Effect.ApplyOnTick.AddItem(DamageEffect);

	return Effect;
}	

static function X2Effect_PushUpVestKineticImmobilize  CreateKineticLevitateMineDenoteEffect(int Duration)
{
	local X2Effect_PushUpVestKineticImmobilize  Effect;
	local X2Condition_UnitEffects 				UnitEffects;
	local X2Condition_UnitProperty          	UnitPropertyCondition;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeLargeUnits = true;
	UnitPropertyCondition.ExcludeInStasis= true;
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = true;
	UnitPropertyCondition.ExcludeHostileToSource = false;
	UnitPropertyCondition.ExcludeCivilian = false;
	UnitPropertyCondition.ExcludeTurret = true;
	UnitPropertyCondition.FailOnNonUnits = true;

	UnitEffects = new class'X2Condition_UnitEffects';
	UnitEffects.AddExcludeEffect(class'X2Effect_Stasis'.default.EffectName, 'AA_DuplicateEffectIgnored');
	UnitEffects.AddExcludeEffect(class'X2Effect_PushUpVestKineticImmobilize'.default.EffectName, 'AA_DuplicateEffectIgnored');
	UnitEffects.AddExcludeEffect(class'X2Effect_PushUpVestKineticContainmentField'.default.EffectName, 'AA_DuplicateEffectIgnored');
	
	Effect = new class'X2Effect_PushUpVestKineticImmobilize';
	Effect.BuildPersistentEffect(Duration, false, false, true, eGameRule_PlayerTurnBegin);
	Effect.SetDisplayInfo(ePerkBuff_Penalty, default.KineticImmobilizeName, default.KineticImmobilizeDesc, "img:///PushUpVest.PerkIcons.UIPerk_KineticGeyser");

	Effect.AddPersistentStatChange(eStat_Dodge, 0, MODOP_PostMultiplication);       //  no dodge for you
	Effect.AddPersistentStatChange(eStat_SightRadius, 0, MODOP_PostMultiplication);
	Effect.AddPersistentStatChange(eStat_Defense, -10);

	Effect.bUseSourcePlayerState = false;
	Effect.bRemoveWhenTargetDies = true;
	Effect.bApplyDamageOnRemove = false;
	Effect.CustomIdleOverrideAnim='HL_LevitatedLoop';
	Effect.ImmobilizeStartAnim='HL_LevitatedStart';
	Effect.ImmobilizeStopAnim='HL_LevitatedStopSlamA';
	Effect.ImmobilizeDuration = Duration;
	Effect.TargetConditions.additem(UnitEffects);
	Effect.TargetConditions.additem(UnitPropertyCondition);
	
	return Effect;
}		

static function X2Effect_PushUpVestKineticImmobilize  CreateKineticRoundsLevitateEffect(int Duration)
{
	local X2Effect_PushUpVestKineticImmobilize  Effect;
	Effect = CreateKineticLevitateMineDenoteEffect(Duration);
	Effect.ImmobilizeStartAnim='';
	return Effect;
}		

static function X2Effect CreateKineticImmobilizeRemoveEffects()
{
	local X2Effect_RemoveEffectsByDamageType RemoveEffects;

	RemoveEffects = new class'X2Effect_RemoveEffectsByDamageType';
	RemoveEffects.DamageTypesToRemove.AddItem('stun');
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Ability_Viper'.default.BindSustainedEffectName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.ConfusedName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.PanickedName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.StunnedName);
	return RemoveEffects;
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

function bool ChangeHitResultForAttacker(XComGameState_Unit Attacker, XComGameState_Unit TargetUnit, XComGameState_Ability AbilityState, const EAbilityHitResult CurrentResult, out EAbilityHitResult NewHitResult)
{
	local int TargetDodge, AttackerAim;

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
	local XComGameState_Unit 			TargetUnit;
	local EffectAppliedData 			NewEffectParams;
	local X2Effect_ApplyWeaponDamage 	DamageEffect;
	// add action points
	TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if (TargetUnit == none)
	{
		TargetUnit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	}

	if (TargetUnit != none && !class'X2Helpers_DLC_Day60'.static.IsUnitAlienRuler(TargetUnit))
	{
		TargetUnit.GiveStandardActionPoints();
		if(TargetUnit.IsAlive() && default.bApplyDamageOnRemove ==true)
		{
			NewEffectParams = ApplyEffectParameters;
			NewEffectParams.AbilityResultContext.HitResult = eHit_Success;
			NewEffectParams.TargetStateObjectRef = TargetUnit.GetReference();

			DamageEffect = new class'X2Effect_ApplyWeaponDamage';
			DamageEffect.EffectDamageValue = KineticLevitateSlam;
			DamageEffect.EffectDamageValue.DamageType = 'Falling';
			DamageEffect.bIgnoreBaseDamage = false;
			DamageEffect.DamageTypes.AddItem('Falling');
			DamageEffect.bAllowFreeKill = true;
			DamageEffect.bIgnoreArmor = false;
			`assert(DamageEffect != none);
			DamageEffect.ApplyEffect(NewEffectParams, TargetUnit, NewGameState);
		}
		else if (TargetUnit.IsAlive() && default.bApplyDamageOnRemove ==false)
		{
			NewEffectParams = ApplyEffectParameters;
			NewEffectParams.AbilityResultContext.HitResult = eHit_Success;
			NewEffectParams.TargetStateObjectRef = TargetUnit.GetReference();

			DamageEffect = new class'X2Effect_ApplyWeaponDamage';
			DamageEffect.EffectDamageValue = KineticWeaponSlam;
			DamageEffect.bIgnoreBaseDamage = false;
			DamageEffect.DamageTypes.AddItem('Falling');
			DamageEffect.bAllowFreeKill = true;
			DamageEffect.bIgnoreArmor = false;
			`assert(DamageEffect != none);
			DamageEffect.ApplyEffect(NewEffectParams, TargetUnit, NewGameState);
		}
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
		else if ( ImmobilizeStartAnim !='' )
		{
			PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ModifyTrack, VisualizeGameState.GetContext(), false, ModifyTrack.LastActionAdded));
			PlayAnimation.Params.AnimName = ImmobilizeStartAnim;
			PlayAnimation.Params.BlendTime = 0.5f;
		}
	}
	super.AddX2ActionsForVisualization(VisualizeGameState, ModifyTrack, EffectApplyResult);
}

simulated function AddX2ActionsForVisualization_Sync( XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata )
{
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
		ExpandedString = `XEXPAND.ExpandString(default.KineticImmobilizeTickFlyover);
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
															  default.KineticImmobilizeAddedString,
															  VisualizeGameState.GetContext(),
															  default.KineticImmobilizeTitle,
															  default.StatusIcon,
															  eUIState_Bad);
		class'X2StatusEffects'.static.UpdateUnitFlag(ModifyTrack, VisualizeGameState.GetContext());
	}
}

static function ImmobilizeVisualizationTicked(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(ActionMetadata.StateObject_NewState);
	if (UnitState != none)
	{
		class'X2StatusEffects'.static.AddEffectCameraPanToAffectedUnitToTrack(ActionMetadata, VisualizeGameState.GetContext());
		class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(ActionMetadata, VisualizeGameState.GetContext(), GetFlyoverTickText(UnitState), '', eColor_Bad, default.StatusIcon);
		class'X2StatusEffects'.static.AddEffectMessageToTrack(ActionMetadata,
															  default.KineticImmobilizePersistsString,
															  VisualizeGameState.GetContext(),
															  default.KineticImmobilizeTitle,
															  default.StatusIcon,
															  eUIState_Warning);
		class'X2StatusEffects'.static.UpdateUnitFlag(ActionMetadata, VisualizeGameState.GetContext());
	}
}

simulated function AddX2ActionsForVisualization_Removed(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult, XComGameState_Effect RemovedEffect)
{
	local XComGameState_Unit NewUnitState, OldUnitState;
	local string FlyoverText;
	local XComGameStateVisualizationMgr VisMgr;
	local X2Action_SKULLJACK 			FromSkullJack;
	local X2Action_CameraLookAt 		LookAtAction;
	local X2Action_PlayAnimation 		PlayAnimation;
	local X2Action_Knockback 			KnockbackAction;
	local XGUnit          				SlamUnit;
	local XComUnitPawn    				SlamPawn;
	local int							LostHP;

	VisMgr = `XCOMVISUALIZATIONMGR;

	super.AddX2ActionsForVisualization_Removed(VisualizeGameState, ActionMetadata, EffectApplyResult, RemovedEffect);

	OldUnitState = XComGameState_Unit(ActionMetadata.StateObject_OldState);
	NewUnitState = XComGameState_Unit(ActionMetadata.StateObject_NewState);

	if (NewUnitState != none && NewUnitState.IsAlive())
	{
		SlamUnit = XGUnit(NewUnitState.GetVisualizer());
		SlamPawn = SlamUnit.GetPawn();

		//new add play effect end animation end
		FromSkullJack = X2Action_SKULLJACK(VisMgr.GetNodeOfType(VisMgr.BuildVisTree, class'X2Action_SkullJack'));
		if( FromSkullJack != None )
		{
			class'X2Action_DLC_Day60FreezeEnd'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), true, , FromSkullJack.ParentActions);
		}
		else if (!NewUnitState.IsIncapacitated() && !NewUnitState.IsDazed()) //Don't play the animation if the unit is going straight from stunned to killed
		{
			LookAtAction = X2Action_CameraLookAt(class'X2Action_CameraLookAt'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
			LookAtAction.UseTether = false;
			LookAtAction.LookAtObject = NewUnitState;
			LookAtAction.BlockUntilActorOnScreen = true;

			// The unit is not a turret and is not dead/unconscious/bleeding-out
			PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
			PlayAnimation.Params.AnimName = ImmobilizeStopAnim;
			PlayAnimation.Params.BlendTime = 0.5f;

			if (SlamPawn.DefaultUnitPawnAnimsets.Find(AnimSet(`CONTENT.RequestGameArchetype("AS_Muton"))) == INDEX_NONE )
			{
				PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
				PlayAnimation.Params.AnimName = 'HL_GetUp';
				PlayAnimation.Params.BlendTime = 0.5f;
			}
		}	
		else
		{
			class'X2Action_DLC_Day60FreezeEnd'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded);
		}
		
		FlyoverText = default.KineticImmobilizeLostFlyover;
		LostHP = OldUnitState.GetCurrentStat(eStat_HP) - NewUnitState.GetCurrentStat(eStat_HP);
		if (LostHP > 0)
		{
			FlyoverText = Repl(default.KineticImmobilizeLostFlyover, "<LostHP/>", LostHP);
		}	
		class'X2StatusEffects'.static.AddEffectCameraPanToAffectedUnitToTrack(ActionMetadata, VisualizeGameState.GetContext());
		class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(ActionMetadata, VisualizeGameState.GetContext(), FlyoverText, '', eColor_Bad, default.StatusIcon);
		class'X2StatusEffects'.static.AddEffectMessageToTrack(ActionMetadata,
																default.KineticImmobilizeRemovedString,
																VisualizeGameState.GetContext(),
																default.KineticImmobilizeTitle,
																default.StatusIcon,
																eUIState_Good);
		class'X2StatusEffects'.static.UpdateUnitFlag(ActionMetadata, VisualizeGameState.GetContext());
	}
}

DefaultProperties
{
	bIsImpairing = true
	bAllowReorder = false
	bApplyDamageOnRemove = true
	EffectName = "Freeze"
	DuplicateResponse = eDupe_Ignore
	EffectHierarchyValue=950
	StartAnimBlendTime=0.1f
	ModifyTracksFn = ModifyTracksVisualization
	EffectTickedVisualizationFn = ImmobilizeVisualizationTicked
	bCanTickEveryAction=true

	Begin Object Class=X2Condition_UnitEffects Name=UnitEffectsCondition
		ExcludeEffects(0)=(EffectName="Unconscious", Reason="AA_UnitIsUnconscious")
	End Object

	TargetConditions.Add(UnitEffectsCondition)
}
