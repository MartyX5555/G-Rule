if CLIENT then

	-- Honestly, the localization should be passed to the client just like what the lua files are sent. Sadly, its not..... Dam

	local AddLanguage = language.Add

	------------------------------- Units -------------------------------

	AddLanguage( "tool.gruletool.unit.unit", "Hammer Unit (unit)" )
	AddLanguage( "tool.gruletool.unit.sunit", "unit" )
	AddLanguage( "tool.gruletool.unit.lunit", "hammer units" )

	AddLanguage( "tool.gruletool.unit.inch", "Inch (in)" )
	AddLanguage( "tool.gruletool.unit.sinch", "in" )
	AddLanguage( "tool.gruletool.unit.linch", "inches" )

	AddLanguage( "tool.gruletool.unit.yard", "Yard (yd)" )
	AddLanguage( "tool.gruletool.unit.syard", "yd" )
	AddLanguage( "tool.gruletool.unit.lyard", "yards" )


	AddLanguage( "tool.gruletool.unit.feet", "Foot (ft)" )
	AddLanguage( "tool.gruletool.unit.sfeet", "ft" )
	AddLanguage( "tool.gruletool.unit.lfeet", "feet" )

	AddLanguage( "tool.gruletool.unit.millimeter", "Millimeter (mm)" )
	AddLanguage( "tool.gruletool.unit.smillimeter", "mm" )
	AddLanguage( "tool.gruletool.unit.lmillimeter", "millimeters" )

	AddLanguage( "tool.gruletool.unit.centimeter", "Centimeter (cm)" )
	AddLanguage( "tool.gruletool.unit.scentimeter", "cm" )
	AddLanguage( "tool.gruletool.unit.lcentimeter", "centimeters" )

	AddLanguage( "tool.gruletool.unit.decimeter", "Decimeter (dm)" )
	AddLanguage( "tool.gruletool.unit.sdecimeter", "dm" )
	AddLanguage( "tool.gruletool.unit.ldecimeter", "decimeters" )

	AddLanguage( "tool.gruletool.unit.meter", "Meter (m)" )
	AddLanguage( "tool.gruletool.unit.smeter", "m" )
	AddLanguage( "tool.gruletool.unit.lmeter", "meters" )


	AddLanguage( "tool.gruletool.unit.kilometer", "Kilometer (km)" )
	AddLanguage( "tool.gruletool.unit.skilometer", "km" )
	AddLanguage( "tool.gruletool.unit.lkilometer", "kilometers" )

	AddLanguage( "tool.gruletool.unit.megameter", "Megameter (Mm)" )
	AddLanguage( "tool.gruletool.unit.smegameter", "Mm" )
	AddLanguage( "tool.gruletool.unit.lmegameter", "megameters" )

	AddLanguage( "tool.gruletool.unit.gigameter", "Gigameter (Gm)" )
	AddLanguage( "tool.gruletool.unit.sgigameter", "Gm" )
	AddLanguage( "tool.gruletool.unit.lgigameter", "gigameters" )

	AddLanguage( "tool.gruletool.unit.terameter", "Terameter (Tm)" )
	AddLanguage( "tool.gruletool.unit.sterameter", "Tm" )
	AddLanguage( "tool.gruletool.unit.lterameter", "terameters" )

	AddLanguage( "tool.gruletool.unit.astrounit", "Astronomical Unit (AU)" )
	AddLanguage( "tool.gruletool.unit.sastrounit", "AU" )
	AddLanguage( "tool.gruletool.unit.lastrounit", "astronomical units" )

	AddLanguage( "tool.gruletool.unit.lightyear", "Light-year (ly)" )
	AddLanguage( "tool.gruletool.unit.slightyear", "ly" )
	AddLanguage( "tool.gruletool.unit.llightyear", "light-years" )


	AddLanguage( "tool.gruletool.unit.parsec", "Parsec (pc)" )
	AddLanguage( "tool.gruletool.unit.sparsec", "pc" )
	AddLanguage( "tool.gruletool.unit.lparsec", "parsecs" )

	AddLanguage( "tool.gruletool.unit.kiloparsec", "Kiloparsec (kpc)" )
	AddLanguage( "tool.gruletool.unit.skiloparsec", "kpc" )
	AddLanguage( "tool.gruletool.unit.lkiloparsec", "kiloparsecs" )

	AddLanguage( "tool.gruletool.unit.megaparsec", "Megaparsec (Mpc)" )
	AddLanguage( "tool.gruletool.unit.smegaparsec", "Mpc" )
	AddLanguage( "tool.gruletool.unit.lmegaparsec", "megaparsecs" )

	AddLanguage( "tool.gruletool.unit.gigaparsec", "Gigaparsec (Gpc)" )
	AddLanguage( "tool.gruletool.unit.sgigaparsec", "Gpc" )
	AddLanguage( "tool.gruletool.unit.lgigaparsec", "gigaparsecs" )

	AddLanguage( "tool.gruletool.unit.teraparsec", "Teraparsec (Tpc)" )
	AddLanguage( "tool.gruletool.unit.steraparsec", "Tpc" )
	AddLanguage( "tool.gruletool.unit.lteraparsec", "teraparsecs" )

	AddLanguage( "tool.gruletool.unit.mile", "Mile (mi)" )
	AddLanguage( "tool.gruletool.unit.smile", "mi" )
	AddLanguage( "tool.gruletool.unit.lmile", "miles" )

	AddLanguage( "tool.gruletool.unit.naumile", "Nautic Mile (nm)" )
	AddLanguage( "tool.gruletool.unit.snaumile", "nm" )
	AddLanguage( "tool.gruletool.unit.lnaumile", "nautic miles" )


	------------------------------- TOOL -------------------------------
	AddLanguage( "tool.gruletool.name", "G-Rule" )
	AddLanguage( "tool.gruletool.desc", "A tool used for measuring purposes." )

	AddLanguage( "tool.gruletool.left_1", "Set the Point 1" )
	AddLanguage( "tool.gruletool.right_1", "Set the Point 2" )

	AddLanguage( "tool.gruletool.left_2", "Set the Point to start the backtrace." )

	AddLanguage( "tool.gruletool.left_3", "Set the Point 1 and the Normal where the direction will be perpendicular to" )
	AddLanguage( "tool.gruletool.right_3", "Set the Point 2 and Magnitude" )

	AddLanguage( "tool.gruletool.left_4", "Sets the Point at a specific position" )
	AddLanguage( "tool.gruletool.right_4", "Sets the Point at origin vector." )

	AddLanguage( "tool.gruletool.reload", "Clear selection." )

	------------------------------- TOOL PANEL -------------------------------
	AddLanguage( "tool.gruletool.roundslider", "Decimal count." )
	AddLanguage( "tool.gruletool.roundtip", "Rounds the distances according to the decimal count." )

	AddLanguage( "tool.gruletool.mapscalebox", "Map Scale" )
	AddLanguage( "tool.gruletool.mapscaleboxtip", "Uses the Architecture scale factor (1 unit = 0.75 inch)" )

	AddLanguage( "tool.gruletool.fullnamebox", "Full name" )
	AddLanguage( "tool.gruletool.fullnameboxtip", "Should the measure unit be fully displayed or not?" )

	AddLanguage( "tool.gruletool.posparentbox", "Attach points to props" )
	AddLanguage( "tool.gruletool.posparentboxtip", "If applied on a prop, the point will be attached." )

	AddLanguage( "tool.gruletool.unitcombotip", "Choose the unit. Hammer Units are not affected by the current unit scale." )
	AddLanguage( "tool.gruletool.modecombotip", "Choose the mode this tool will operate." )

	AddLanguage( "tool.gruletool.documentation", "Documentation about this tool can be found here." )
	AddLanguage( "tool.gruletool.documentation.button", "See documentation" )

	------------------------------- TOOL SCREEN  -------------------------------

	AddLanguage( "tool.gruletool.currentmode", "Current mode" )
	AddLanguage( "tool.gruletool.currentscale", "Scale" )

	AddLanguage( "tool.gruletool.signalmap", "Map Scale" )
	AddLanguage( "tool.gruletool.signalplayer", "Player Scale" )
	AddLanguage( "tool.gruletool.signalnoscale", "Not applicable" )
	AddLanguage( "tool.gruletool.distancenotify", "Distance" )

	AddLanguage( "tool.gruletool.overlay.angle", "Angle" )
	AddLanguage( "tool.gruletool.overlay.hitplane", "HitPlane" )
	AddLanguage( "tool.gruletool.overlay.endpoint", "End Point!" )

	------------------------------- MODES -------------------------------

	-- Basic
	AddLanguage( "tool.gruletool.basic.name", "Basic" )
	AddLanguage( "tool.gruletool.basic.desc", "Performs a measure between 2 points. Becomes very useful if paired with SmartSnap" )

	-- Basic - Snap to prop
	AddLanguage( "tool.gruletool.basicsnap.name", "Basic - Snap to prop")
	AddLanguage( "tool.gruletool.basicsnap.desc", "Performs a measure between 2 points, using a PA like snap on props." )

	-- HitPlane - between 2 walls
	AddLanguage( "tool.gruletool.hitplane.name", "HitPlane - between 2 walls")
	AddLanguage( "tool.gruletool.hitplane.desc", "The measure is performed between the position where you did hit, and a perpendicular generated position behind of it, where did hit." )

	-- Entity to Entity
	AddLanguage( "tool.gruletool.enttoent.name", "Entity to Entity")
	AddLanguage( "tool.gruletool.enttoent.desc", "Chosen entities are the points. Measures data are updated on the fly." )

	-- HitPlane - Normalized Rect
	AddLanguage( "tool.gruletool.hitplane2.name", "HitPlane - Normalized Rect")
	AddLanguage( "tool.gruletool.hitplane2.desc", "The measure is done between point 1 and point 2, in one direction which is perpendicular to the normal of the 1st point." )

	-- Space Mode
	AddLanguage( "tool.gruletool.space.name", "Space Mode")
	AddLanguage( "tool.gruletool.space.desc", "Gets the measure either from an arbitrary position or vector origin to the player. Useful for space measurement tasks in infinite maps.\n\n" )

	AddLanguage( "tool.gruletool.space.subpanel.title", "Manual controls")
	AddLanguage( "tool.gruletool.space.subpanel.desc", "If you are too far and the traces of the tool dont work, you can set the points here, based at your current position.")
	AddLanguage( "tool.gruletool.space.subpanel.button.1", "Set Point 1")
	AddLanguage( "tool.gruletool.space.subpanel.button.2", "Set Point 2")
	AddLanguage( "tool.gruletool.space.subpanel.button.follow.1", "Point 1 follow Player")
	AddLanguage( "tool.gruletool.space.subpanel.button.follow.2", "Point 2 follow Player")
	AddLanguage( "tool.gruletool.space.subpanel.button.clear", "Clear Points")
end