local template = {
	level = 1,
	experience = 0,

	credits = 0,

	progression = {
		arrow1 = false,
		arrow2 = false,
		arrow3 = false,
		melee1 = false,
		melee2 = false,
		melee3 = false,
		cloak1 = false,
		cloak2 = false,
		cloak3 = false,
		boots1 = false,
		boots2 = false,
		boots3 = false,
		-- Tech
		arena = false,
		invisibility = false,
		detector = false,
		energyShield = false,
		powerLeap = false,
		radar = false,
		teleport = false,
		turret = false,
		-- Tools
		bearTrap = false,
		cageTrap = false,
		glider = false,
		hook = false,
		riggedChest = false,
		smokeBomb = false,
		tripwire = false,
	},

	statistics = {
		player = {
			-- Match
			gamesPlayed = 0,
			gamesWon = 0,
			secondPlaceFinishes = 0,
			thirdPlaceFinishes = 0,
			totalPlacement = 0,
			bestRank = 0,
			bestWinStreak = 0,
			currentWinStreak = 0,
			-- Combat
			totalEliminations = 0,
			totalDamageDealt = 0,
			totalArrowsFired = 0,
			totalArrowsHit = 0,
			totalHeadshots = 0,
			totalHuntingTime = 0,
			totalFirstBloods = 0,
			totalLavaKills = 0,
			totalTrapKills = 0,
			totalManhuntKills = 0,
			totalManhuntSurvived = 0,
			-- Harvesting
			totalWoodHarvested = 0,
			maxWoodHarvested = 0,
			totalLeatherHarvested = 0,
			maxLeatherHarvested = 0,
			totalElectronics = 0,
			maxElectronicsHarvested = 0,
			totalChestsOpened = 0,
			maxChestsOpened = 0,
		},
		admin = {
			gamesPlayed = 0,
			fame = 0,
		},
	},
}

return template
