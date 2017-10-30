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
		direction = "down",
		color = {
			r = 255,
			g = 255,
			b = 255
		}
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
				colorMap[player.y + i][player.x + j] = {r = player.color.r, g = player.color.g, b = player.color.b}
			end
		end
	end
	

	player = getRandomModel(models, 0, 0)

	player.color = {r = math.random(0, 256), g = math.random(0, 256), b = math.random(0, 256)}

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
					if player.direction == "left" then
						player.x = player.x + 1
					end
					if player.direction == "right" then
						player.x = player.x - 1
					end
					if player.directoin == "up" then
						player.y = player.y + 1
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


function drawMap(map, colorMap)
	for i = 1, #map do
		for j = 1, #map[i] do
			if map[i][j] == 1 then
				love.graphics.setColor(colorMap[i][j].r, colorMap[i][j].g, colorMap[i][j].b)
				love.graphics.rectangle("fill", (j - 1) * scale, (i - 1) * scale, scale, scale)
			end
		end
	end
end


function createColorMap()
	local colorMap = {}
	for i = 1, field.y do
		colorMap[i] = {}
		for j = 1, field.x do
			colorMap[i][j] = {r = 255, g = 255, b = 255}
		end
	end
	return colorMap
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
			length = {
				x = 4,
				y = 1
				},
			shape = {1, 1, 1, 1}
		},
		{ -- T
			name = "T",
			length = {
				x = 3,
				y = 2
			},
			shape = {1, 1, 1, 0, 1, 0}
		},
		{ -- J
			name = "J",
			length = {
				x = 2,
				y = 3
			},
			shape = {1, 0, 1, 1, 0, 1}
		},
		{ -- L
			name = "L",
			length = {
				x = 2,
				y = 3
			},
			shape = {1, 0, 1, 0, 1, 1}
		},
		{ --Q
			name = "Q",
			length = {
				x = 2,
				y = 2
			},
			shape = {1, 1, 1, 1}
		}
	}

	map = createMap()
	colorMap = createColorMap()

	math.randomseed(os.time())

	-- love.graphics.setColor(255, 255, 255)

	player = getRandomModel(models, 0, 0)
	-- player.color = {r = 255, g = 255, b = 255}

	-- player = {
	-- 	x = globalModel.x,
	-- 	y = globalModel.y,
	-- 	width = globalModel.length.x,
	-- 	height = globalModel.length.y
	-- }

	time = 0

	love.window.setMode(field.x * scale, field.y * scale)
end


function love.update(dt)
	time = time + dt
	if time > 1 then
		player.y = player.y + 1
		player.direction = "down"
		time = 0
	end
	collision()
end


function love.draw()
	love.graphics.setColor(player.color.r, player.color.g, player.color.b)
	drawModel(player)
	-- love.graphics.setColor(255, 255, 255)
	drawMap(map, colorMap)
	-- love.graphics.rectangle("fill", player.x * scale, player.y * scale, (player.width) * scale, (player.height) * scale)
end