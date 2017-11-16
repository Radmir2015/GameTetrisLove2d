function love.keyreleased(key)
	if key == "left" or key == "a" then
		player.x = player.x - 1
		player.direction = "left"
	end
	-- if key == "up" then
	-- 	player.y = player.y - 1
	-- 	player.direction = "up"
	-- end
	if key == "right" or key == "d" then
		player.x = player.x + 1
		player.direction = "right"
	end
	-- if key == "down" then
	-- 	player.y = player.y + 1
	-- 	player.direction = "down"
	-- end
	if key == "return" then
		player = getRandomModel(models, 0, 0)
	end
	if key == "down" or key == "s" then
		rotatePlayer(player, "-")
	end
	if key == "up" or key == "w" then
		rotatePlayer(player, "+")
	end
end


local function table_copy(t)
  local r = {}
  for k, v in next, t do
	 r[k] = v
  end
  return r
end


function getRandomModel(modelArray, x, y)
	local model = table_copy(modelArray)[math.random(1, #modelArray)]
	local player = {
		model = model,
		x = x,
		y = y,
		rubbish = 0,
		direction = "down",
		rotation = 0,
		xStart = 1,
		xEnd = #model.matrix[1],
		yEnd = #model.matrix,
		yStart = 1,
		speed = 1,
		color = {
			r = 255,
			g = 255,
			b = 255
		}
	}
	player = countBorders(player)
	player.x = x - (player.xStart - 1)
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

	for i = 1, #player.model.matrix do
		for j = 1, #player.model.matrix[i] do
			if player.model.matrix[i][j] == 1 then
				love.graphics.rectangle("fill", (player.x + (j - 1)) * scale, (player.y + (i - 1)) * scale, scale, scale)
			end
		end
	end
end

function playerToMap()
	player.rubbish = 1
	
	for i = 1, #player.model.matrix do
		for j = 1, #player.model.matrix[i] do
			if player.model.matrix[i][j] == 1 then
				-- showTable({{player.y, player.x, i, j}})
				if player.y + i >= 1 and player.x + j >= 1 then
					map[player.y + i][player.x + j] = 1
					colorMap[player.y + i][player.x + j] = {r = player.color.r, g = player.color.g, b = player.color.b}
				else
					love.window.showMessageBox("Game Over", tostring(player.y + i) .. " " .. tostring(player.x + j))
				end
			end
		end
	end
	

	player = getRandomModel(models, 0, 0)

	player.color = {r = math.random(0, 256), g = math.random(0, 256), b = math.random(0, 256)}

end


function collision()
	if player.x + (player.xStart - 1) < 0 then
		player.x = - (player.xStart - 1)
	end

	if player.y + (player.yStart - 1) < 0 then
		player.y = - (player.yStart - 1)
	end

	if player.x + (player.xStart - 1) > field.x - (player.xEnd - player.xStart + 1) then
		player.x = field.x - player.xEnd
	end

	if player.y + (player.yStart - 1) > field.y - (player.yEnd - player.yStart + 1) then
		player.y = field.y - player.yEnd

		playerToMap()
	end
	local br = false
	for i = 1, #player.model.matrix do
		for j = 1, #player.model.matrix[i] do
			if player.model.matrix[i][j] == 1 then
				local x = player.x + j
				local y = player.y + i
				if (x < 1 or y < 1) then
					showTable({{x, y}})
				end
				if map[y][x] == 1 then
					if player.direction == "down" then
						while (map[player.y + i][player.x + j] ~= 0) do
							player.y = player.y - 1
						end
						-- playerToMap()
						br = true
						-- break
					end
					if player.direction == "left" then
						while (map[player.y + i][player.x + j] ~= 0) do
							player.x = player.x + 1
						end
					end
					if player.direction == "right" then
						while (map[player.y + i][player.x + j] ~= 0) do
							player.x = player.x - 1
						end
					end
					if player.direction == "up" then
						while (map[player.y + i][player.x + j] ~= 0) do
							player.y = player.y + 1
						end
					end
				end
			end
		end
		-- if (br) then break end
	end
	if br then
		playerToMap() end
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


function table.slice(tbl, first, last, step)
	local sliced = {}

	for i = first or 1, last or #tbl, step or 1 do
  		sliced[#sliced + 1] = tbl[i]
	end

	return sliced
end


function getColumn(tbl, num)
	local array = {}
	if num < 0 then
		num = #tbl + num + 1
	end
	for t = 1, #tbl do
		table.insert(array, tbl[t][num])
	end
	return array
end


function table.sum(tbl)
	local sum = 0
	for i = 1, #tbl do
		sum = sum + tbl[i]
	end
	return sum
end


function showTable(tbl)
	local str = ""
	for i = 1, #tbl do
		for j = 1, #tbl[i] do
			str = str .. tostring(tbl[i][j]) .. " "
		end
		str = str .. "\n"
	end
	love.window.showMessageBox("NewGrid", str)
end


function countBorders(player)
	player.xStart = 1
	while (table.sum(getColumn(player.model.matrix, player.xStart)) == 0) do
		player.xStart = player.xStart + 1
	end
	player.xEnd = #player.model.matrix
	while (table.sum(getColumn(player.model.matrix, player.xEnd)) == 0) do
		player.xEnd = player.xEnd - 1
	end
	player.yEnd = #player.model.matrix
	while (table.sum(player.model.matrix[player.yEnd]) == 0) do
		player.yEnd = player.yEnd - 1
	end
	player.yStart = 1
	while (table.sum(player.model.matrix[player.yStart]) == 0) do
		player.yStart = player.yStart + 1
	end
	return player
end


function rotatePlayer(player, rotation)
	local grid = {}
	local newGrid = {}
	max = math.max(player.model.length.y, player.model.length.x)
	for i = 1, max do
		grid[i] = {}
		newGrid[i] = {}
	end
	local array = {}
	for i = 1, #player.model.matrix do
		for j = 1, #player.model.matrix[i] do
			if rotation == "+" then
				newGrid[i][j] = player.model.matrix[max - j + 1][i]
			elseif rotation == "-" then
				newGrid[i][j] = player.model.matrix[j][max - i + 1]
			end
		end
	end
	-- showTable(newGrid)
	player.model.matrix = newGrid
	countBorders(player)
end


function arrayToString(array)
	local str = ""
	for i = 1, #array do
		str = str .. array[i] .. " "
	end
	return str
end


function checkIfRow(map)
	for i = 1, #map do
		-- showTable({{table.sum(map[i])}})
		-- love.graphics.setFont(love.graphics.newFont(40))
		-- love.graphics.setColor(0, 0, 0)
		-- love.graphics.setBackgroundColor(0, 0, 0)
		-- love.graphics.print(table.sum(map[i]), 10, 10, 0, 10 * scale, 10 * scale)
		if (table.sum(map[i]) == #map[i]) then
			for j = i, 1, -1 do
				if j == 1 then
					for k = 1, #map[j] do
						map[j][k] = 0
						colorMap[j][k] = {r = 255, g = 255, b = 255}
					end
				else
					for k = 1, #map[j] do
						map[j][k] = map[j - 1][k]
						colorMap[j][k] = colorMap[j - 1][k]
					end
				end
			end
		end
	end
end


function love.load()
	love.keyboard.setKeyRepeat(true)
	love.graphics.setFont(love.graphics.newFont(40))

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
			shape = {1, 1, 1, 1},
			matrix = {
				{0, 1, 0, 0},
				{0, 1, 0, 0},
				{0, 1, 0, 0},
				{0, 1, 0, 0}
			}
		},
		{ -- T
			name = "T",
			length = {
				x = 3,
				y = 2
			},
			shape = {1, 1, 1, 0, 1, 0},
			matrix = {
				{0, 1, 0},
				{1, 1, 1},
				{0, 0, 0}
			}
		},
		{ -- J
			name = "J",
			length = {
				x = 2,
				y = 3
			},
			shape = {1, 0, 1, 1, 0, 1},
			matrix = {
				{1, 0, 0},
				{1, 1, 0},
				{0, 1, 0},
			}
		},
		{ -- L
			name = "L",
			length = {
				x = 2,
				y = 3
			},
			shape = {1, 0, 1, 0, 1, 1},
			matrix = {
				{0, 1, 0},
				{0, 1, 0},
				{0, 1, 1}
			}
		},
		{ --Q
			name = "Q",
			length = {
				x = 2,
				y = 2
			},
			shape = {1, 1, 1, 1},
			matrix = {
				{1, 1},
				{1, 1}
			}
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
	checkIfRow(map)
	collision()
	time = time + dt
	if love.keyboard.isDown("space") then
		player.speed = 4
	else
		player.speed = 1
	end
	if time > 1 / player.speed then
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