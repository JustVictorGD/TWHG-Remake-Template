This is an open-source Godot project meant to be a great starting point
for those wanting to make their own remake of The World's Hardest Game.

Discord server, recommended to join: http://twhg.info/discord

This project currently only supports single area levels and doesn't have features from The World's Hardest Game 4.

Quick project overview:
	The "core" folder contains various resources that make the game function. It contains folders containing different types of objects:
		"colliders" - Contains the AbstractCollider class and the 3 types of colliders which inherit from it: circle, point and rectangle colliders.
		"common_objects" - Contains the most commonly used objects.
			"collectables" - Contains the abstract Collectable class and the objects which inherit from it: coins, keys and paints.
			"solids" - Contains the Solid class, the tile map, the Door class which inherits Solid, and the key and gold door.
			"other" - Contains everything else which doesn't inherit from any parent class: checkpoints, circles, enemies, floors, teleporters, triggers, turrets and velocity components.
	
	The "game" folder contains the gameplay: Areas and levels.
