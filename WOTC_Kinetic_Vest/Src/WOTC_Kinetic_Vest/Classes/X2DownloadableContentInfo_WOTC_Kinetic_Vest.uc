//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_WOTC_Kinetic_Vest.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_WOTC_Kinetic_Vest extends X2DownloadableContentInfo;

delegate ModifyTemplate(X2DataTemplate DataTemplate);

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{}

static event OnPostTemplatesCreated()
{
    local XComContentManager Content;
    local int i;
    Content = `CONTENT;
    Content.BuildPerkPackageCache();
    for(i=0;i<class'X2Ability_PushUpVest'.default.KineticEruptionAbilityNames.Length;++i)
	{	
		Content.CachePerkContent(class'X2Ability_PushUpVest'.default.KineticEruptionAbilityNames[i]);
		Content.CachePerkContent(class'X2Ability_PushUpVest'.default.KineticProtectionFieldAbilityNames[i]);
		Content.CachePerkContent(class'X2Ability_PushUpVest'.default.KineticContainmentFieldAbilityNames[i]);
		Content.CachePerkContent(class'X2Ability_PushUpVest'.default.KineticLevitatedAbilityNames[i]);

    }
    Content.CachePerkContent('PushUpKineticSnap');
    Content.CachePerkContent('PushUpKineticRoundsLevitate');
    Content.CachePerkContent('KineticLevitationProximityMineDetonation');
    ModifyTemplateAllDiff('ThrowGrenade', class'X2AbilityTemplate', PatchAbilityTemplate);
    ModifyTemplateAllDiff('LaunchGrenade', class'X2AbilityTemplate', PatchAbilityTemplate);
}

static function UpdateAnimations(out array<AnimSet> CustomAnimSets, XComGameState_Unit UnitState, XComUnitPawn Pawn)
{
    /*
    if(UnitState.IsSoldier()) 
    {
        CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("PushUpVest.Anim.AS_PushUpVest")));
    }
    */
    if (Pawn.DefaultUnitPawnAnimsets.Find(AnimSet(`CONTENT.RequestGameArchetype("AS_Archon"))) != INDEX_NONE )
    {
        CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("PushUpVest.Anim.AS_HumanoidLevitationSet")));
    }   

    else if (Pawn.DefaultUnitPawnAnimsets.Find(AnimSet(`CONTENT.RequestGameArchetype("AS_Sectoid"))) != INDEX_NONE )
    {
        CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("PushUpVest.Anim.HL_SectoidLevitationSet")));
    }   

    else if (Pawn.DefaultUnitPawnAnimsets.Find(AnimSet(`CONTENT.RequestGameArchetype("AS_Viper"))) != INDEX_NONE )
    {
        CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("PushUpVest.Anim.AS_ViperLevitationSet")));
    }   
    
    else if (Pawn.DefaultUnitPawnAnimsets.Find(AnimSet(`CONTENT.RequestGameArchetype("AS_Muton"))) != INDEX_NONE )
    {
        CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("PushUpVest.Anim.AS_MutonLevitationSet")));            
        if (Pawn.DefaultUnitPawnAnimsets.Find(AnimSet(`CONTENT.RequestGameArchetype("AS_Andromedon"))) != INDEX_NONE ) 
        {
            CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("PushUpVest.Anim.AS_AndromedonLevitationStop")));
        }
        else if (Pawn.DefaultUnitPawnAnimsets.Find(AnimSet(`CONTENT.RequestGameArchetype("AS_Berserker"))) != INDEX_NONE ) 
        {
            CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("PushUpVest.Anim.AS_BerserkerLevitationStop")));           
        }
        else
        {
            CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("PushUpVest.Anim.AS_MutonLevitationStop")));
        }
    }   
        
    else if (Pawn.DefaultUnitPawnAnimsets.Find(AnimSet(`CONTENT.RequestGameArchetype("AS_Faceless"))) != INDEX_NONE )
    {
        CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("PushUpVest.Anim.AS_FaceLessLevitationSet")));
    }   

    else if (Pawn.DefaultUnitPawnAnimsets.Find(AnimSet(`CONTENT.RequestGameArchetype("AS_CryssalidDefault"))) != INDEX_NONE )
    {
        CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("PushUpVest.Anim.AS_ChryssalidLevitationSet")));
    }  
        
    else if (Pawn.DefaultUnitPawnAnimsets.Find(AnimSet(`CONTENT.RequestGameArchetype("AS_AdventMec"))) != INDEX_NONE )
    {
        CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("PushUpVest.Anim.AS_AdventMecLevitationSet")));
    }     
    
    else if (Pawn.DefaultUnitPawnAnimsets.Find(AnimSet(`CONTENT.RequestGameArchetype("AS_Chosen"))) != INDEX_NONE )
    {
        CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("PushUpVest.Anim.AS_ChosenLevitationSet")));
    }   

    else
    {
        if (UnitState.GetMyTemplate().CharacterGroupName == 'Faceless')
        {
            CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("PushUpVest.Anim.AS_FaceLessLevitationSet")));
        }
        else
        {
            CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("PushUpVest.Anim.AS_HumanoidLevitationSet")));
            CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("PushUpVest.Anim.AS_PushUpVest")));
        }
    }
}

static function PatchEquipmentTemplates(X2DataTemplate DataTemplate)
{

}

static function PatchAbilityTemplate(X2DataTemplate DataTemplate)
{
   local X2AbilityTemplate                         Template;
   local X2Effect_KineticLevitationProximityMine   ProximityMineEffect;
   local X2Condition_AbilitySourceWeapon           ProximityMineCondition;

   Template = X2AbilityTemplate(DataTemplate);
   
	ProximityMineEffect = new class'X2Effect_KineticLevitationProximityMine';
	ProximityMineEffect.BuildPersistentEffect(1, true, false, false);
	ProximityMineCondition = new class'X2Condition_AbilitySourceWeapon';
	ProximityMineCondition.MatchGrenadeType = 'KineticLevitationProximityMine';
	ProximityMineEffect.TargetConditions.AddItem(ProximityMineCondition);
	Template.AddShooterEffect(ProximityMineEffect);
}

static private function IterateTemplatesAllDiff(class TemplateClass, delegate<ModifyTemplate> ModifyTemplateFn)
{
    local X2DataTemplate                                    IterateTemplate;
    local X2DataTemplate                                    DataTemplate;
    local array<X2DataTemplate>                             DataTemplates;
    local X2DownloadableContentInfo_WOTC_Kinetic_Vest       CDO;

    local X2ItemTemplateManager             ItemMgr;
    local X2AbilityTemplateManager          AbilityMgr;
    local X2CharacterTemplateManager        CharMgr;
    local X2StrategyElementTemplateManager  StratMgr;
    local X2SoldierClassTemplateManager     ClassMgr;

    if (ClassIsChildOf(TemplateClass, class'X2ItemTemplate'))
    {
        CDO = GetCDO();
        ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

        foreach ItemMgr.IterateTemplates(IterateTemplate)
        {
            if (!ClassIsChildOf(IterateTemplate.Class, TemplateClass)) continue;

            ItemMgr.FindDataTemplateAllDifficulties(IterateTemplate.DataName, DataTemplates);
            foreach DataTemplates(DataTemplate)
            {   
                CDO.CallModifyTemplateFn(ModifyTemplateFn, DataTemplate);
            }
        }
    }
    else if (ClassIsChildOf(TemplateClass, class'X2AbilityTemplate'))
    {
        CDO = GetCDO();
        AbilityMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

        foreach AbilityMgr.IterateTemplates(IterateTemplate)
        {
            if (!ClassIsChildOf(IterateTemplate.Class, TemplateClass)) continue;

            AbilityMgr.FindDataTemplateAllDifficulties(IterateTemplate.DataName, DataTemplates);
            foreach DataTemplates(DataTemplate)
            {
                CDO.CallModifyTemplateFn(ModifyTemplateFn, DataTemplate);
            }
        }
    }
    else if (ClassIsChildOf(TemplateClass, class'X2CharacterTemplate'))
    {
        CDO = GetCDO();
        CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
        foreach CharMgr.IterateTemplates(IterateTemplate)
        {
            if (!ClassIsChildOf(IterateTemplate.Class, TemplateClass)) continue;

            CharMgr.FindDataTemplateAllDifficulties(IterateTemplate.DataName, DataTemplates);
            foreach DataTemplates(DataTemplate)
            {
                CDO.CallModifyTemplateFn(ModifyTemplateFn, DataTemplate);
            }
        }
    }
    else if (ClassIsChildOf(TemplateClass, class'X2StrategyElementTemplate'))
    {
        CDO = GetCDO();
        StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
        foreach StratMgr.IterateTemplates(IterateTemplate)
        {
            if (!ClassIsChildOf(IterateTemplate.Class, TemplateClass)) continue;

            StratMgr.FindDataTemplateAllDifficulties(IterateTemplate.DataName, DataTemplates);
            foreach DataTemplates(DataTemplate)
            {
                CDO.CallModifyTemplateFn(ModifyTemplateFn, DataTemplate);
            }
        }
    }
    else if (ClassIsChildOf(TemplateClass, class'X2SoldierClassTemplate'))
    {

        CDO = GetCDO();
        ClassMgr = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();
        foreach ClassMgr.IterateTemplates(IterateTemplate)
        {
            if (!ClassIsChildOf(IterateTemplate.Class, TemplateClass)) continue;

            ClassMgr.FindDataTemplateAllDifficulties(IterateTemplate.DataName, DataTemplates);
            foreach DataTemplates(DataTemplate)
            {
                CDO.CallModifyTemplateFn(ModifyTemplateFn, DataTemplate);
            }
        }
    }    
}

static private function ModifyTemplateAllDiff(name TemplateName, class TemplateClass, delegate<ModifyTemplate> ModifyTemplateFn)
{
    local X2DataTemplate                                    DataTemplate;
    local array<X2DataTemplate>                             DataTemplates;
    local X2DownloadableContentInfo_WOTC_Kinetic_Vest       CDO;

    local X2ItemTemplateManager             ItemMgr;
    local X2AbilityTemplateManager          AbilityMgr;
    local X2CharacterTemplateManager        CharMgr;
    local X2StrategyElementTemplateManager  StratMgr;
    local X2SoldierClassTemplateManager     ClassMgr;

    if (ClassIsChildOf(TemplateClass, class'X2ItemTemplate'))
    {
        ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
        ItemMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
    }
    else if (ClassIsChildOf(TemplateClass, class'X2AbilityTemplate'))
    {
        AbilityMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
        AbilityMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
    }
    else if (ClassIsChildOf(TemplateClass, class'X2CharacterTemplate'))
    {
        CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
        CharMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
    }
    else if (ClassIsChildOf(TemplateClass, class'X2StrategyElementTemplate'))
    {
        StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
        StratMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
    }
    else if (ClassIsChildOf(TemplateClass, class'X2SoldierClassTemplate'))
    {
        ClassMgr = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();
        ClassMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
    }
    else return;

    CDO = GetCDO();
    foreach DataTemplates(DataTemplate)
    {
        CDO.CallModifyTemplateFn(ModifyTemplateFn, DataTemplate);
    }
}

static private function X2DownloadableContentInfo_WOTC_Kinetic_Vest GetCDO()
{
    return X2DownloadableContentInfo_WOTC_Kinetic_Vest(class'XComEngine'.static.GetClassDefaultObjectByName(default.Class.Name));
}

protected function CallModifyTemplateFn(delegate<ModifyTemplate> ModifyTemplateFn, X2DataTemplate DataTemplate)
{
    ModifyTemplateFn(DataTemplate);
}
