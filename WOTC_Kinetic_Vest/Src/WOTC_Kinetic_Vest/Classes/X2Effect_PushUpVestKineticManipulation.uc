class X2Effect_PushUpVestKineticManipulation extends X2Effect_Persistent config(PushUpVestData);
var config array<name>	WeaponCategories;
var config array<name>	OutgoingDamageTypes;
var config array<name>	KineticDetonation;
var config array<name>	StandardShotCategories;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local XComGameState_Unit TargetUnit;
	local XComGameState_Item AbilityWeapon;
	local WeaponDamageValue BaseDamageValue;
	local X2Effect_ApplyWeaponDamage WeaponDamageEffect;
	local array<name> OutgoingTypes;
	local name DamageType;
	local int BounsDamge;

	BounsDamge = 0;
	TargetUnit = XComGameState_Unit(TargetDamageable);
	if (AbilityState.GetSourceWeapon() != none && class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult))
	{
		AbilityWeapon = AbilityState.GetSourceWeapon();
		if (AbilityWeapon != none)
		{
			if (class'X2Ability_PushUpVest'.default.KineticDetonationAbilityNames.Find(AbilityState.GetMyTemplateName()) != INDEX_NONE && TargetUnit.GetCurrentStat(eStat_ShieldHP) > 0)
			{
				BounsDamge = Attacker.GetCurrentStat(eStat_ShieldHP);
				BounsDamge += TargetUnit.GetCurrentStat(eStat_ShieldHP)/2;
			}	
			else
			{
				if (default.WeaponCategories.Find(AbilityWeapon.GetWeaponCategory()) != INDEX_NONE)
					BounsDamge += Attacker.GetCurrentStat(eStat_ShieldHP);
				else if (AbilityState.IsMeleeAbility())	
					BounsDamge += Attacker.GetCurrentStat(eStat_ShieldHP);
				else
				{
					WeaponDamageEffect.GetEffectDamageTypes(NewGameState, AppliedData, OutgoingTypes);
					foreach default.OutgoingDamageTypes(DamageType)
					{
						if (OutgoingTypes.find(DamageType)!=INDEX_NONE)
							BounsDamge += Attacker.GetCurrentStat(eStat_ShieldHP);
					}
				}		
			}		
		}
	}
	return BounsDamge;
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "KineticManipulationEffect"
	bDisplayInSpecialDamageMessageUI = true
}