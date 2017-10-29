function love.keyreleased(key)
	if key == "left" then
		player.x = player.x - 1
		player.direction = "left"
	end
	if key == "up" then
		player.y = player.y - 1
		player.direction = "up"
	end
	if key == "right" then
		player.x = player.x + 1
		player.direction = "right"
	end
	if key == "down" then
		player.y = player.y + 1
		player.direction = "down"
	end
	if key == "return" then
		player = getRandomModel(models, 0, 0)
	end
end


function getRandomModel(modelArray, x, y)
	local model = modelArray[math.random(1, #modelArray)]
	local player = {
		model = model,
		x = x,
		y = y,
		rubbish = 0,
		direction = "down"
	}
	-- love.window.showMessageBox(model, coords)
	return player
end

function drawModel(player)
	-- local grid = {}

	-- for i = 1, player.model.length.y do
	-- 	grid[i] = {}
	-- 	for j = 1, player.model.length.x do
	-- 		-- love.window.showMessageBox(#player.model.shape, player.model.shape[(i - 1) * player.model.length.x + j])
	-- 		grid[i][j] = player.model.shape[(i - 1) * player.model.length.x + j]
	-- 	end
	-- end

	-- for i = 1, player.model.length.y do
	-- 	for j = 1, player.model.length.x do
	-- 		if grid[i][j] == 1 then
	-- 			love.graphics.rectangle("fill", (player.x + (j - 1)) * scale, (player.y + (i - 1)) * scale, scale, scale)
	-- 		end
	-- 	end
	-- end

	for i = 1, player.model.length.y do
		for j = 1, player.model.length.x do
			if player.model.shape[(i - 1) * player.model.length.x + j] == 1 then
				love.graphics.rectangle("fill", (player.x + (j - 1)) * scale, (player.y + (i - 1)) * scale, scale, scale)
			end
		end
	end
end

function playerToMap()
	player.rubbish = 1
	
	for i = 1, player.model.length.y do
		for j = 1, player.model.length.x do
			if player.model.shape[(i - 1) * player.model.length.x + j] == 1 then
				map[player.y + i][player.x + j] = 1
			end
		end
	end

	player = getRandomModel(models, 0, 0)
end


function collision()
	if player.x < 0 then
		player.x = 0
	end

	if player.y < 0 then
		player.y = 0
	end

	if player.x > field.x - player.model.length.x then
		player.x = field.x - player.model.length.x
	end

	if player.y > field.y - player.model.length.y then
		player.y = field.y - player.model.length.y

		playerToMap()
	end

	for i = 1, player.model.length.y do
		for j = 1, player.model.length.x do
			if player.model.shape[(i - 1) * player.model.length.x + j] == 1 then
				local x = player.x + j
				local y = player.y + i
				if map[y][x] == 1 then
					if player.direction == "down" then
						player.y = player.y - 1
						playerToMap()
					end
				end
			end
		end
	end
end


function createMap()
	local map = {}
	for i = 1, field.y do
		map[i] = {}
		for j = 1, field.x do
			map[i][j] = 0
		end
	end
	return map
end


function drawMap(map)
	for i = 1, #map do
		for j = 1, #map[i] do
			if map[i][j] == 1 then
				love.graphics.rectangle("fill", (j - 1) * scale, (i - 1) * scale, scale, scale)
			end
		end
	end
end


function love.load()
	scale = 32

	field = {
		x = 10,
		y = 15
	}

	models = {
		{ -- I
			name = "I",
			x = 0,
			y = 0,
			length = {
				x = 4,
				y = 1
				},
			shape = {1, 1, 1, 1}
		},
		{ -- T
			name = "T",
			x = 0,
			y = 0,
			length = {
				x = 3,
				y = 2
			},
			shape = {1, 1, 1, 0, 1, 0}
		},
		{ -- J
			name = "J",
			x = 0,
			y = 0,
			length = {
				x = 2,
				y = 3
			},
			shape = {1, 0, 1, 1, 0, 1}
		},
		{ -- L
			name = "L",
			x = 0,
			y = 0,
			length = {
				x = 2,
				y = 3
			},
			shape = {1, 0, 1, 0, 1, 1}
		},
		{ --Q
			name = "Q",
			x = 0,
			y = 0,
			length = {
				x = 2,
				y = 2
			},
			shape = {1, 1, 1, 1}
		}
	}

	map = createMap()

	math.randomseed(os.time())

	player = getRandomModel(models, 0, 0)

	-- player = {
	-- 	x = globalModel.x,
	-- 	y = globalModel.y,
	-- 	width = globalModel.length.x,
	-- 	height = globalModel.length.y
	-- }

	love.window.setMode(field.x * scale, field.y * scale)
end


function love.update(dt)
	collision()
end


function love.draw()
	love.graphics.setColor(255, 255, 255)
	drawModel(player)
	drawMap(map)
	-- love.graphics.rectangle("fill", player.x * scale, player.y * scale, (player.width) * scale, (player.height) * scale)
end