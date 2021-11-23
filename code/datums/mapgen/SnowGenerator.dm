//the random offset applied to square coordinates, causes intermingling at biome borders
//#define BIOME_RANDOM_SQUARE_DRIFT 2

/datum/map_generator/snow_generator
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/mudlands,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/snow/rocky,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/snow/rough,
		BIOME_HIGH_HUMIDITY = /datum/biome/water/ice/rough
		),

	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/snow/rocky,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/snow,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/snow/rough,
		BIOME_HIGH_HUMIDITY = /datum/biome/snow/rough
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/snow,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/snow/rough,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/snow/forest,
		BIOME_HIGH_HUMIDITY = /datum/biome/snow/forest/thick
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/plains,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/snow,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/snow/forest,
		BIOME_HIGH_HUMIDITY = /datum/biome/water/clear
		)
	)
	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 85

///Seeds the rust-g perlin noise with a random number.
/datum/map_generator/snow_generator/generate_terrain(var/list/turfs, var/reuse_seed)
	. = ..()

	for(var/t in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t

		var/height = 3


		var/datum/biome/selected_biome
		if(height <= 0.85) //If height is less than 0.85, we generate biomes based on the heat and humidity of the area.
			var/humidity = 2
			var/heat = 1
			var/heat_level //Type of heat zone we're in LOW-MEDIUM-HIGH
			var/humidity_level  //Type of humidity zone we're in LOW-MEDIUM-HIGH

			switch(heat)
				if(0 to 0.35)
					heat_level = BIOME_LOW_HEAT
				if(0.35 to 0.65)
					heat_level = BIOME_LOWMEDIUM_HEAT
				if(0.65 to 0.9)
					heat_level = BIOME_HIGHMEDIUM_HEAT
				if(0.9 to 1)
					heat_level = BIOME_HIGH_HEAT
			switch(humidity)
				if(0 to 0.20)
					humidity_level = BIOME_LOW_HUMIDITY
				if(0.20 to 0.5)
					humidity_level = BIOME_LOWMEDIUM_HUMIDITY
				if(0.5 to 0.75)
					humidity_level = BIOME_HIGHMEDIUM_HUMIDITY
				if(0.75 to 1)
					humidity_level = BIOME_HIGH_HUMIDITY
			selected_biome = possible_biomes[heat_level][humidity_level]
		else //Over 0.85; It's a mountain
			selected_biome = /datum/biome/mountain
		selected_biome = biomes[selected_biome]
		selected_biome.generate_turf(gen_turf)

		gen_turf.temperature = 235 // -38C and lowest breathable temperature with standard atmos

		if (current_state >= GAME_STATE_PLAYING)
			LAGCHECK(LAG_LOW)
		else
			LAGCHECK(LAG_HIGH)
