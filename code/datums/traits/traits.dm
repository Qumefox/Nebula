/mob/living
	var/list/traits

/mob/living/proc/HasTrait(trait_type)
	SHOULD_NOT_OVERRIDE(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	return (trait_type in GetTraits())

/mob/living/proc/GetTraitLevel(trait_type)
	SHOULD_NOT_SLEEP(TRUE)
	var/traits = GetTraits()
	if(!traits)
		return null
	return traits[trait_type]

/mob/living/proc/GetTraits()
	SHOULD_NOT_SLEEP(TRUE)
	RETURN_TYPE(/list)
	return traits

/mob/living/carbon/human/GetTraits()
	if(traits)
		return traits
	return species.traits

/mob/living/proc/SetTrait(trait_type, trait_level)
	SHOULD_NOT_SLEEP(TRUE)
	var/decl/trait/T = GET_DECL(trait_type)
	if(!T.Validate(trait_level))
		return FALSE
	
	LAZYSET(traits, trait_type, trait_level)
	return TRUE

/mob/living/carbon/human/SetTrait(trait_type, trait_level)
	var/decl/trait/T = GET_DECL(trait_type)
	if(!T.Validate(trait_level))
		return FALSE
	
	if(!traits) // If traits haven't been setup before, check if we need to do so now
		var/species_level = species.traits[trait_type]
		if(species_level == trait_level) // Matched the default species trait level, ignore
			return TRUE
		traits = species.traits.Copy() // The setup is to simply copy the species list of traits

	return ..(trait_type, trait_level)

/mob/living/proc/RemoveTrait(trait_type)
	LAZYREMOVE(traits, trait_type)

/mob/living/carbon/human/RemoveTrait(trait_type)
	// If traits haven't been setup, but we're trying to remove a trait that exists on the species then setup traits
	if(!traits && (trait_type in species.traits))
		traits = species.traits.Copy()

	..(trait_type) // Could go through the trouble of nulling the traits list if it's again equal to the species list but eh
	traits = traits || list() // But we do ensure that humans don't null their traits list, to avoid copying from species again

/decl/trait
	abstract_type = /decl/trait
	var/name
	var/description
	var/list/levels = list(TRAIT_LEVEL_EXISTS) // Should either only contain TRAIT_LEVEL_EXISTS or a set of the other TRAIT_LEVEL_* levels

/decl/trait/proc/Validate(level)
	SHOULD_NOT_OVERRIDE(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_BE_PURE(TRUE)

	return (level in levels)
