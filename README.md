This is an open-source Godot project meant to be a great starting point
for those wanting to make their own remake of The World's Hardest Game.

Discord servers, recommended to join: 
	World's Hardest Game Official, the main server for everything WHG - http://twhg.info/discord
	PoeDev's Projects, PoeDev's server with channels about many things, including WHG. Discussion about the Remake Template happens here - https://discord.gg/zeaZYhuMes

This project currently only supports single area levels and doesn't have features from The World's Hardest Game 4.

Quick project overview:
	The "core" folder contains various resources that make the game function. It contains folders containing different types of objects:
		"game_objects" - Contains the objects which areas are made out of. 
			"collectables" - Contains the collectable objects (coins, keys, paints).
			"solids" - Contains the tile map, solids (separate wall objects), key and gold doors.
			"other" - Contains everything else which doesn't inherit from any parent class: checkpoints, circles, enemies, floors, teleporters, triggers, and turrets.
		
		"components" - Contains nodes which add functionality or modify game objects in some way.
			"colliders" - Contains custom circle, point and rectangle colliders.
			"velocity_component" - Contains the velocity component.
			"tick_based_animator.gd" - Custom timeline system which extends AnimationPlayer.
			"tick_based_timer.gd" - Custom timer.
		
		"custom_resources" - Contains custom resource classes.
			"color_tuple.gd" - Defines a pair of colors. Used by paint colors.
			"enemy_properties.gd" - Defines enemy properties. Mostly used by objects which instantiate other objects.
		
		"misc_assets" - Contains miscellaneous sprites, node icons, resource files and sound effects.
		
		"shaders" - Contains shaders, self-explanatory.
			"screen_gradient" - Overlays screen gradients on objects.
			"vignette" - Applies a vignette effect on the screen.
		
		"system" - Contains the most important scripts and scenes.
			"autoloads" - Contains all automatically loaded scripts. They contain properties, functions and signals, accessible from anywhere.
				"game_loop.gd" - Contains custom game loop functions which make the order of operations more consistent.
				"game_manager.gd" - Contains global properties about the game and player states.
				"global_signal.gd" - Contains global signals.
				"paint_manager.gd" and "paint_manager.tscn" - Contain settings, related to paints and player color.
				"save_file.gd" - Contains functions which handle progress saving and loading.
				"sfx.gd" and "sfx.tscn" - Handles sound effects. Contains the sounds enum and the play function.
			
			"interface" - Contains scenes and scripts which make up the UI.
				"interface.gd" and "interface.tscn" - The main interface which surrounds the game's viewport and displays stats.
				"pause_menu.gd" and "pause_menu.tscn" - The pause menu which appears when the game is paused and contains settings.
			
			"player" - Contains everything, related to the player object (player movement, collision with walls)
			
			"scene" - Contains the scripts of the scenes which make up the title screen and save select menus, the world and the areas inside it.
	
	
	The "game" folder contains the gameplay: Areas and levels.
