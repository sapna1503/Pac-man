# Pac-man
	1. The pac-man and ghosts speed might look slow in simulator, but that same works properly on actual device. The speed of player and ghost can be adjusted in file 	   GameScene.swift -:
      For actual device -:
        var currentSpeed: CGFloat = 4
            var ghostSpeed: CGFloat = 1
      For simulator -:
        var currentSpeed: CGFloat = 10
            var ghostSpeed: CGFloat = 5
	2. Pac-man is main player and it can be moved by swiping top, bottom, left, right.
	3. Pac-man will move along paths through the maze and collect all the coins, as it reaches to coins score will be updated.
	4. Four Ghosts will be chasing towards pac-man. As soon as pac-man touches any 1 of ghost the live of pac-man is decreased and updated in Lives left label.
	5. Total Lives of Pacman is 3. If all lives will end then Game will over.
