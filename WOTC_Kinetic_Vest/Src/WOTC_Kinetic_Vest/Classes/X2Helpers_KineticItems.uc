class X2Helpers_KineticItems extends Object config(PushUpVestData);

var localized string StunnedFriendlyName;
var localized string StunnedFriendlyDesc;
var localized string StunnedEffectAcquiredString;
var localized string StunnedEffectTickedString;
var localized string StunnedEffectLostString;
var localized string StunnedPerActionFriendlyName;


static function X2Effect_GetOverHere CreatePullEffect()
{
	local X2Effect_GetOverHere 		GetOverHereEffect;

	GetOverHereEffect = new class'X2Effect_GetOverHere';
	GetOverHereEffect.OverrideStartAnimName = 'NO_GrapplePullStart';
	GetOverHereEffect.OverrideStopAnimName = 'NO_GrapplePullStop';
	GetOverHereEffect.RequireVisibleTile = true;
	return GetOverHereEffect;
}

static function X2Effect_Stunned CreateStunnedStatusEffect(int StunLevel, int Chance)
{
	local X2Effect_Stunned StunnedEffect;
	local X2Condition_UnitProperty UnitPropCondition;

	StunnedEffect = class'X2StatusEffects'.static.CreateStunnedStatusEffect(2, 100, false);
	StunnedEffect.SetDisplayInfo(ePerkBuff_Penalty, default.StunnedFriendlyName, default.StunnedFriendlyDesc, "img:///UILibrary_PerkIcons.UIPerk_disoriented");
	StunnedEffect.bRemoveWhenSourceDies = false;
	StunnedEffect.DuplicateResponse = eDupe_Ignore;
	StunnedEffect.VisualizationFn = StunnedVisualization;
	StunnedEffect.EffectTickedVisualizationFn = StunnedVisualizationTicked;
	StunnedEffect.EffectRemovedVisualizationFn = StunnedVisualizationRemoved;
	StunnedEffect.StunStartAnimName = 'Stand2PushUp';
	StunnedEffect.StunStopAnimName = 'PushUp2Stand';
	StunnedEffect.CustomIdleOverrideAnim = 'Ex_PushUps_Normal_LO01';

	UnitPropCondition = new class'X2Condition_UnitProperty';
	UnitPropCondition.ExcludeFriendlyToSource = false;
	UnitPropCondition.FailOnNonUnits = true;
	UnitPropCondition.ExcludeAlien = true;
	UnitPropCondition.ExcludeRobotic = true;
	UnitPropCondition.ExcludeTurret = true;
	UnitPropCondition.ExcludePsionic = true;
	UnitPropCondition.ExcludeInStasis = true;
	UnitPropCondition.ExcludeAdvent = false;
	UnitPropCondition.ExcludeDead = true;
	UnitPropCondition.ExcludeCivilian = true;
	StunnedEffect.TargetConditions.AddItem(UnitPropCondition);
	return StunnedEffect;
}

static function string GetStunnedFlyoverText(XComGameState_Unit TargetState, bool FirstApplication)
{
	local XComGameState_Effect EffectState;
	
	local X2AbilityTag AbilityTag;
	local bool bRobotic;
	local string ExpandedString; // bsg-dforrest (7.27.17): need to clear out ParseObject

	bRobotic = TargetState.IsRobotic();
	EffectState = TargetState.GetUnitAffectedByEffectState('Stunned');
	if(FirstApplication || (EffectState != none && EffectState.GetX2Effect().IsTickEveryAction(TargetState)))
	{
		AbilityTag = X2AbilityTag(`XEXPANDCONTEXT.FindTag("Ability"));
		AbilityTag.ParseObj = TargetState;
		// bsg-dforrest (7.27.17): need to clear out ParseObject
		ExpandedString = `XEXPAND.ExpandString(default.StunnedPerActionFriendlyName);
		AbilityTag.ParseObj = none;
		return ExpandedString;
		// bsg-dforrest (7.27.17): end
	}
	else
	{
		return default.StunnedFriendlyName;
	}
}

static function StunnedVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local XComGameState_Unit TargetState;

	if( EffectApplyResult != 'AA_Success' )
	{
		return;
	}

	TargetState = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(ActionMetadata.StateObject_NewState.ObjectID));
	if (TargetState == none)
		return;
	
	class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(ActionMetadata, VisualizeGameState.GetContext(), GetStunnedFlyoverText(TargetState, true), '', eColor_Bad, class'UIUtilities_Image'.const.UnitStatus_Disoriented);
	class'X2StatusEffects'.static.AddEffectMessageToTrack(
		ActionMetadata,
		default.StunnedEffectAcquiredString,
		VisualizeGameState.GetContext(),
		class'UIEventNoticesTactical'.default.DisorientedTitle,
		"img:///UILibrary_PerkIcons.UIPerk_disoriented",
		eUIState_Bad);
	class'X2StatusEffects'.static.UpdateUnitFlag(ActionMetadata, VisualizeGameState.GetContext());
}

static function StunnedVisualizationTicked(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local XComGameState_Unit UnitState;
	local bool bRobotic;

	UnitState = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(ActionMetadata.StateObject_NewState.ObjectID));
	if (UnitState == none)
		return;

	// dead units should not be reported
	if( !UnitState.IsAlive() )
	{
		return;
	}

	bRobotic = UnitState.IsRobotic();

	class'X2StatusEffects'.static.AddEffectCameraPanToAffectedUnitToTrack(ActionMetadata, VisualizeGameState.GetContext());
	class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(ActionMetadata, VisualizeGameState.GetContext(), GetStunnedFlyoverText(UnitState, false), '', eColor_Bad, class'UIUtilities_Image'.const.UnitStatus_Disoriented);
	class'X2StatusEffects'.static.AddEffectMessageToTrack(
		ActionMetadata,
		default.StunnedEffectTickedString,
		VisualizeGameState.GetContext(),
		class'UIEventNoticesTactical'.default.DisorientedTitle,
		"img:///UILibrary_PerkIcons.UIPerk_disoriented",
		eUIState_Warning);
	class'X2StatusEffects'.static.UpdateUnitFlag(ActionMetadata, VisualizeGameState.GetContext());
}

static function StunnedVisualizationRemoved(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(ActionMetadata.StateObject_NewState);
	if (UnitState == none)
		return;

	// dead units should not be reported
	if( !UnitState.IsAlive() )
	{
		return;
	}

	class'X2StatusEffects'.static.AddEffectMessageToTrack(
		ActionMetadata,
		default.StunnedEffectLostString,
		VisualizeGameState.GetContext(),
		class'UIEventNoticesTactical'.default.DisorientedTitle,
		"img:///UILibrary_PerkIcons.UIPerk_disoriented",
		eUIState_Good);
	class'X2StatusEffects'.static.UpdateUnitFlag(ActionMetadata, VisualizeGameState.GetContext());
}

static function PushUpKineticSnap_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateVisualizationMgr VisMgr;
	local X2Action_ViperGetOverHere GetOverHereAction;
	local X2Action_ExitCover ExitCover;

	VisMgr = `XCOMVISUALIZATIONMGR;

	class'X2Ability'.static.TypicalAbility_BuildVisualization(VisualizeGameState);

	ExitCover = X2Action_ExitCover(VisMgr.GetNodeOfType(VisMgr.BuildVisTree, class'X2Action_ExitCover'));
	ExitCover.bUsePreviousGameState = true;

	GetOverHereAction = X2Action_ViperGetOverHere(VisMgr.GetNodeOfType(VisMgr.BuildVisTree, class'X2Action_ViperGetOverHere'));
	GetOverHereAction.StartAnimName = 'HL_KineticSnapStart'; 
	GetOverHereAction.StopAnimName = 'HL_KineticSnapStop'; 
}	

static function KineticDetonation_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateContext_Ability AbilityContext;	
	local VisualizationActionMetadata VisTrack;
	local X2Action_PlayEffect EffectAction;
	local X2Action_SpawnImpactActor ImpactAction;
	local X2Action_StartStopSound SoundAction;
	local Array<X2Action> ParentActions;
	local X2Action_MarkerNamed JoinAction;
	local XComGameStateHistory History;
	local X2Action_WaitForAbilityEffect WaitForFireEvent;
	local XComGameStateVisualizationMgr VisMgr;
	local Array<X2Action> NodesToParentToWait;
	local int ScanAction;

	VisMgr = `XCOMVISUALIZATIONMGR;
	History = `XCOMHISTORY;

	AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());	

	VisTrack.StateObjectRef = AbilityContext.InputContext.SourceObject;
	VisTrack.VisualizeActor = History.GetVisualizer(VisTrack.StateObjectRef.ObjectID);
	History.GetCurrentAndPreviousGameStatesForObjectID(VisTrack.StateObjectRef.ObjectID,
													   VisTrack.StateObject_OldState, VisTrack.StateObject_NewState,
													   eReturnType_Reference,
													   VisualizeGameState.HistoryIndex);	
	class'X2Ability'.static.TypicalAbility_BuildVisualization(VisualizeGameState);
	WaitForFireEvent = X2Action_WaitForAbilityEffect(class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(VisTrack, AbilityContext));
	//Camera comes first
	ImpactAction = X2Action_SpawnImpactActor( class'X2Action_SpawnImpactActor'.static.AddToVisualizationTree(VisTrack, AbilityContext, false, WaitForFireEvent) );
	ParentActions.AddItem(ImpactAction);

	ImpactAction.ImpactActorName = class'X2Ability_ReaperAbilitySet'.default.HomingMineImpactArchetype;
	ImpactAction.ImpactLocation = AbilityContext.InputContext.TargetLocations[0];
	ImpactAction.ImpactLocation.Z = `XWORLD.GetFloorZForPosition( ImpactAction.ImpactLocation );
	ImpactAction.ImpactNormal = vect(0, 0, 1);

	//Do the detonation
	EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(VisTrack, AbilityContext, false, WaitForFireEvent));
	ParentActions.AddItem(EffectAction);

	EffectAction.EffectName = "PushUpVest.fX.P_KineticDetonation_Explosion";
	`CONTENT.RequestGameArchetype(EffectAction.EffectName);
	EffectAction.EffectLocation = AbilityContext.InputContext.TargetLocations[0];
	EffectAction.EffectRotation = Rotator(vect(0, 0, 1));
	EffectAction.bWaitForCompletion = false;
	EffectAction.bWaitForCameraCompletion = false;

	SoundAction = X2Action_StartStopSound(class'X2Action_StartStopSound'.static.AddToVisualizationTree(VisTrack, AbilityContext, false, WaitForFireEvent));
	ParentActions.AddItem(SoundAction);
	SoundAction.Sound = new class'SoundCue';
	SoundAction.Sound.AkEventOverride = AkEvent'DLC_90_SoundCharacterFX.Bombard_Explode';	//	@TODO - update sound
	SoundAction.bIsPositional = true;
	SoundAction.vWorldPosition = AbilityContext.InputContext.TargetLocations[0];

	JoinAction = X2Action_MarkerNamed(class'X2Action_MarkerNamed'.static.AddToVisualizationTree(VisTrack, AbilityContext, false, None, ParentActions));
	JoinAction.SetName("Join");
	
	// Jwats: Reparent all of the apply weapon damage actions to the wait action since this visualization doesn't have a fire anim
	VisMgr.GetNodesOfType(VisMgr.BuildVisTree, class'X2Action_ApplyWeaponDamageToUnit', NodesToParentToWait);
	for( ScanAction = 0; ScanAction < NodesToParentToWait.Length; ++ScanAction )
	{
		VisMgr.DisconnectAction(NodesToParentToWait[ScanAction]);
		VisMgr.ConnectAction(NodesToParentToWait[ScanAction], VisMgr.BuildVisTree, false, WaitForFireEvent);
		VisMgr.ConnectAction(JoinAction, VisMgr.BuildVisTree, false, NodesToParentToWait[ScanAction]);
	}
	
	VisMgr.GetNodesOfType(VisMgr.BuildVisTree, class'X2Action_ApplyWeaponDamageToTerrain', NodesToParentToWait);
	for( ScanAction = 0; ScanAction < NodesToParentToWait.Length; ++ScanAction )
	{
		VisMgr.DisconnectAction(NodesToParentToWait[ScanAction]);
		VisMgr.ConnectAction(NodesToParentToWait[ScanAction], VisMgr.BuildVisTree, false, WaitForFireEvent);
		VisMgr.ConnectAction(JoinAction, VisMgr.BuildVisTree, false, NodesToParentToWait[ScanAction]);
	}		
}		

static function KineticLevitationProximityMineDetonation_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateContext_Ability AbilityContext;	
	local VisualizationActionMetadata VisTrack;
	local X2Action_PlayEffect EffectAction;
	local X2Action_SpawnImpactActor ImpactAction;
	local X2Action_StartStopSound SoundAction;
	local X2Action_Delay DelayAction;
	local X2Action_MarkerNamed JoinAction;
	local X2Action_WaitForAbilityEffect WaitForFireEvent;
	local Array<X2Action> ParentActions;
	local XComGameStateHistory History;
	local XComGameStateVisualizationMgr VisMgr;
	local Array<X2Action> NodesToParentToWait;
	local int ScanAction;
	
	VisMgr = `XCOMVISUALIZATIONMGR;
	History = `XCOMHISTORY;

	AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());	


	VisTrack.StateObjectRef = AbilityContext.InputContext.SourceObject;
	VisTrack.VisualizeActor = History.GetVisualizer(VisTrack.StateObjectRef.ObjectID);
	History.GetCurrentAndPreviousGameStatesForObjectID(VisTrack.StateObjectRef.ObjectID,
													   VisTrack.StateObject_OldState, VisTrack.StateObject_NewState,
													   eReturnType_Reference,
													   VisualizeGameState.HistoryIndex);	
	WaitForFireEvent = X2Action_WaitForAbilityEffect(class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(VisTrack, AbilityContext));
	//Camera comes first
	ImpactAction = X2Action_SpawnImpactActor( class'X2Action_SpawnImpactActor'.static.AddToVisualizationTree(VisTrack, AbilityContext, false, WaitForFireEvent) );
	ParentActions.AddItem(ImpactAction);

	ImpactAction.ImpactActorName = class'X2Ability_ReaperAbilitySet'.default.HomingMineImpactArchetype;
	ImpactAction.ImpactLocation = AbilityContext.InputContext.TargetLocations[0];
	ImpactAction.ImpactLocation.Z = `XWORLD.GetFloorZForPosition( ImpactAction.ImpactLocation );
	ImpactAction.ImpactNormal = vect(0, 0, 1);

	//Do the detonation
	EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(VisTrack, AbilityContext, false, WaitForFireEvent));
	ParentActions.AddItem(EffectAction);

	EffectAction.EffectName = "PushUpVest.fX.P_KineticMineDetonation_Explosion";
	`CONTENT.RequestGameArchetype(EffectAction.EffectName);
	EffectAction.EffectLocation = AbilityContext.InputContext.TargetLocations[0];
	EffectAction.EffectRotation = Rotator(vect(0, 0, 1));
	EffectAction.bWaitForCompletion = false;
	EffectAction.bWaitForCameraCompletion = false;

	SoundAction = X2Action_StartStopSound(class'X2Action_StartStopSound'.static.AddToVisualizationTree(VisTrack, AbilityContext, false, WaitForFireEvent));
	ParentActions.AddItem(SoundAction);
	SoundAction.Sound = new class'SoundCue';
	SoundAction.Sound.AkEventOverride = AkEvent'SoundX2GrenadeFX.EMP';	//	@TODO - update sound
	SoundAction.bIsPositional = true;
	SoundAction.vWorldPosition = AbilityContext.InputContext.TargetLocations[0];

	JoinAction = X2Action_MarkerNamed(class'X2Action_MarkerNamed'.static.AddToVisualizationTree(VisTrack, AbilityContext, false, None, ParentActions));
	JoinAction.SetName("Join");
	
	// Jwats: Reparent all of the apply weapon damage actions to the wait action since this visualization doesn't have a fire anim
	VisMgr.GetNodesOfType(VisMgr.BuildVisTree, class'X2Action_ApplyWeaponDamageToUnit', NodesToParentToWait);
	for( ScanAction = 0; ScanAction < NodesToParentToWait.Length; ++ScanAction )
	{
		VisMgr.DisconnectAction(NodesToParentToWait[ScanAction]);
		VisMgr.ConnectAction(NodesToParentToWait[ScanAction], VisMgr.BuildVisTree, false, WaitForFireEvent);
		VisMgr.ConnectAction(JoinAction, VisMgr.BuildVisTree, false, NodesToParentToWait[ScanAction]);
	}
	
	VisMgr.GetNodesOfType(VisMgr.BuildVisTree, class'X2Action_ApplyWeaponDamageToTerrain', NodesToParentToWait);
	for( ScanAction = 0; ScanAction < NodesToParentToWait.Length; ++ScanAction )
	{
		VisMgr.DisconnectAction(NodesToParentToWait[ScanAction]);
		VisMgr.ConnectAction(NodesToParentToWait[ScanAction], VisMgr.BuildVisTree, false, WaitForFireEvent);
		VisMgr.ConnectAction(JoinAction, VisMgr.BuildVisTree, false, NodesToParentToWait[ScanAction]);
	}	
	
	DelayAction = X2Action_Delay(class'X2Action_Delay'.static.CreateVisualizationAction(AbilityContext));
	DelayAction.Duration = 0.5;	

	class'X2Ability'.static.TypicalAbility_BuildVisualization(VisualizeGameState);
		
}

simulated function ClearHangs_MergeVisualization(X2Action BuildTree, out X2Action VisualizationTree)
{
	local XComGameState_CampaignSettings CampaignSettings;
	local XComGameStateHistory History;
    local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_Analytics AnalyticsState;
	local int ForceLevel;
	local float missions;
	

	History = `XCOMHISTORY;
	CampaignSettings = XComGameState_CampaignSettings(History.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings'));
	`RedScreen("DifficultySetting: "@CampaignSettings.DifficultySetting);
	`RedScreen("GetCampaignDifficultyFromSettings: "@CampaignSettings.GetCampaignDifficultyFromSettings);

	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	ForceLevel = AlienHQ.GetForceLevel();
    `Redscreen("ForceLevel:"@ForceLevel);

	AnalyticsState = XComGameState_Analytics(History.GetSingleGameStateObjectForClass(class'XComGameState_Analytics'));
	missions = AnalyticsState.GetFloatValue("BATTLES_WON") + AnalyticsState.GetFloatValue("BATTLES_LOST");
	`Redscreen("missions:"@missions); 
	
	`XCOMVISUALIZATIONMGR.DebugClearHangs();
}		