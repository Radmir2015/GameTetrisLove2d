function love.keyreleased(key)
	if (key == "left" or key == "a") and not gameStopped then
		player.x = player.x - 1
		player.direction = "left"
	end
	-- if key == "up" then
	-- 	player.y = player.y - 1
	-- 	player.direction = "up"
	-- end
	if (key == "right" or key == "d") and not gameStopped then
		player.x = player.x + 1
		player.direction = "right"
	end
	-- if key == "down" then
	-- 	player.y = player.y + 1
	-- 	player.direction = "down"
	-- end
	if key == "tab" then
		-- player = getRandomModel(models, 0, 0)
		generateCycle()
	end
	if (key == "down" or key == "s") and not gameStopped then
		player = rotatePlayer(player, "-")
	end
	if (key == "up" or key == "w") and not gameStopped then
		player = rotatePlayer(player, "+")
	end
	if key == "return" then
		if gameStopped and gameOvered then
			colorMap = createColorMap()
			map = createMap()
			-- generateCycle()
			gameOvered = false
			score = 0
		end
		gameStopped = not gameStopped
	end
end


local function table_copy(t)
  local r = {}
  for k, v in next, t do
	 r[k] = v
  end
  return r
end


function gameOver()
	-- love.window.showMessageBox("Game Over!", "Do your wanna start next one?")
	-- love.graphics.printf("Game Over! Do your wanna start a new game? Click Enter to start a new game", field.xStart * scale, field.yStart * scale, field.x * scale, "center")
	gameStopped = true
	gameOvered = true
	-- gameStopped = false
	-- player = getRandomModel(models, 0, 0)
	-- generateCycle()
	time = 0

	-- colorMap = createColorMap()
	-- map = createMap()
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
	-- player.x = x - (player.xStart - 1)
	player.color = {r = math.random(0, 256), g = math.random(0, 256), b = math.random(0, 256)}
	if math.random(0, 2) == 1 then
		for i = 1, math.random(0, 3) do
			player = rotatePlayer(player, "+")
		end
	else
		for i = 1, math.random(0, 3) do
			player = rotatePlayer(player, "-")
		end
	end
	-- love.window.showMessageBox(model, coords)
	player = countBorders(player)
	-- player.x = field.x - player.xEnd
	player.x = math.floor(field.x / 2) - math.floor((player.xEnd - player.xStart + 1) / 2)
	player.y = 1 - player.yStart
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
	player = countBorders(player)
	if player.y + (player.yStart - 1) < 0 then
		player.y = - (player.yStart - 1)
	end -- need to edit, cuz shapes mustn't overrotate 

	for i = 1, #player.model.matrix do
		for j = 1, #player.model.matrix[i] do
			if player.model.matrix[i][j] == 1 then
				love.graphics.rectangle("fill", (player.x + (j - 1) + field.xStart - 1) * scale, (player.y + (i - 1) + field.yStart - 1) * scale, scale, scale)
			end
		end
	end
end

function playerToMap()
	player.rubbish = 1

	-- love.window.setTitle(tostring(#player.model.matrix[1]))
	
	for i = 1, #player.model.matrix do
		for j = 1, #player.model.matrix[i] do
			if player.model.matrix[i][j] == 1 then
				-- showTable({{player.y, player.x, i, j}})
				if (player.y + i >= 1 and player.x + j >= 1) and (player.y + i <= field.y and player.x + j <= field.x) then
					map[player.y + i][player.x + j] = 1
					colorMap[player.y + i][player.x + j] = {r = player.color.r, g = player.color.g, b = player.color.b}
				else
					gameOver()
					-- gameStopped = true
					-- love.window.showMessageBox("Game Over", tostring(player.y + i) .. " " .. tostring(player.x + j))
				end
			end
		end
	end
	

	-- player = getRandomModel(models, 0, 0)
	-- nextShape.field = player.model.matrix
	generateCycle()

	-- player.color = {r = math.random(0, 256), g = math.random(0, 256), b = math.random(0, 256)}
	-- nextShape.color = player.color

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
	local gameOverBreak = false
	for i = 1, #player.model.matrix do
		for j = 1, #player.model.matrix[i] do
			if player.model.matrix[i][j] == 1 then
				local x = player.x + j
				local y = player.y + i
				-- if (x < 1 or y < 1) then
				-- 	showTable({{x, y}})
				-- end
				if not (player.y + i >= 1 and player.x + j >= 1) or not (player.y + i <= #map and player.x + j <= #map[1]) then
					-- gameOver()
					gameOverBreak = true
					break
				end
				if map[y][x] == 1 then
					if player.direction == "down" then
						-- if not (player.y + i >= 1 and player.x + j >= 1) or not (player.y + i <= #map and player.x + j <= #map[1]) then
							-- love.window.setTitle(tostring(player.y + i) .. " " .. tostring(player.x + j))
						-- end
						if (player.y + i >= 1 and player.x + j >= 1) and (player.y + i <= #map and player.x + j <= #map[player.y + i]) then
							while (map[player.y + i][player.x + j] ~= 0) do 
								player.y = player.y - 1
								-- love.window.setTitle(tostring(getJoinTableOfTable(map)))
								-- showTable(map)
								if (player.y + i < 1 or player.x + j < 1) then
									-- gameOver()
									gameOverBreak = true
									break
								end
							end
						end
						-- playerToMap()
						br = true
						if (gameOverBreak) then br = false end
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
		if (gameOverBreak) then
			gameOver()
			break
		end
	end
	if br and not gameOverBreak then
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
				love.graphics.rectangle("fill", ((j - 1) + field.xStart - 1) * scale, ((i - 1) + field.yStart - 1) * scale, scale, scale)
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


function getJoinTable(tbl)
	local str = ""
	for i = 1, #tbl do
		str = str .. tostring(tbl[i]) .. " "
	end
	return str
end


function getJoinTableOfTable(tbl)
	local str = ""
	for i = 1, #tbl do
		for j = 1, #tbl[i] do
			str = str .. tostring(tbl[i][j]) .. " "
		end
		str = str .. "\n"
	end
	return str
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
	-- love.window.setTitle(tostring(getJoinTable({player.xStart, player.yStart, player.xEnd, player.yEnd})))
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
	player = countBorders(player)
	return player
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
				score = score + 20
			end
		end
	end
end


function drawNextShape(shape)
	love.graphics.setColor(shape.color.r, shape.color.g, shape.color.b)
	for i = 1, #shape.field do
		for j = 1, #shape.field[i] do
			if shape.field[i][j] == 1 then
				love.graphics.rectangle("fill", (0 + (j - 1) + nextShapeTable.xStart - 1) * scale, (0 + (i - 1) + nextShapeTable.yStart - 1) * scale, scale, scale)
			end
		end
	end
end


function generateCycle()
	player = nextShape.player

	nextShape.player = getRandomModel(models, 0, 0)
	nextShape.field = nextShape.player.model.matrix
	nextShape.color = nextShape.player.color
end


function addZeros(score)
	s = tostring(score)
	while (string.len(s) < 4) do
		s = "0" .. s
	end
	-- return "0" * (4 - string.len(s)) .. s
	-- return "---" + s
	-- end
	return s
end


function love.load()
	love.keyboard.setKeyRepeat(true)
	-- love.graphics.setFont(love.graphics.newFont(40))
	love.graphics.setFont(love.graphics.newFont("consola.ttf", 20))

	love.window.setTitle("The Tetris Game")

	scale = 32
	score = 0

	field = {
		x = 10,
		y = 15,
		xStart = 2,
		yStart = 2,
		xToEnd = 7,
		yToEnd = 2
	}

	field.xTotal = field.x + field.xStart + field.xToEnd - 2
	field.yTotal = field.y + field.yStart + field.yToEnd - 2

	nextShapeTable = {
		x = 4,
		y = 4,
		xStart = 13,
		yStart = 2,
	}

	nextShape = {field = {}, color = {}, player = {}}

	labelScore = {
		text = "Score: ",
		xStart = 12,
		xEnd = 16,
		yStart = 6,
		yEnd = 7
	}

	nextShape.color = {r = 255, g = 255, b = 255}
	for i = 1, nextShapeTable.x do
		nextShape.field[i] = {}
		for j = 1, nextShapeTable.y do
			nextShape.field[i][j] = 0
		end
	end

	models = {
		{ -- I
			name = "I",
			length = {
				x = 4,
				y = 1
				},
			-- shape = {1, 1, 1, 1},
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
			-- shape = {1, 1, 1, 0, 1, 0},
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
			-- shape = {1, 0, 1, 1, 0, 1},
			matrix = {
				{1, 0, 0},
				{1, 1, 0},
				{0, 1, 0},
			}
		},
		{ -- J
			name = "J",
			length = {
				x = 2,
				y = 3
			},
			-- shape = {1, 0, 1, 1, 0, 1},
			matrix = {
				{0, 0, 1},
				{0, 1, 1},
				{0, 1, 0},
			}
		},
		{ -- L
			name = "L",
			length = {
				x = 2,
				y = 3
			},
			-- shape = {1, 0, 1, 0, 1, 1},
			matrix = {
				{0, 1, 0},
				{0, 1, 0},
				{0, 1, 1}
			}
		},
		{ -- L
			name = "L",
			length = {
				x = 2,
				y = 3
			},
			-- shape = {1, 0, 1, 0, 1, 1},
			matrix = {
				{0, 1, 0},
				{0, 1, 0},
				{1, 1, 0}
			}
		},
		{ --Q
			name = "Q",
			length = {
				x = 2,
				y = 2
			},
			-- shape = {1, 1, 1, 1},
			matrix = {
				{1, 1},
				{1, 1}
			}
		}
	}

	map = createMap()
	colorMap = createColorMap()

	math.randomseed(os.time())

	gameStopped = true
	gameOvered = true

	-- love.graphics.setColor(255, 255, 255)

	-- player = getRandomModel(models, 0, 0)
	generateCycle()
	generateCycle()
	-- player.color = {r = 255, g = 255, b = 255}

	-- player = {
	-- 	x = globalModel.x,
	-- 	y = globalModel.y,
	-- 	width = globalModel.length.x,
	-- 	height = globalModel.length.y
	-- }

	time = 0

	love.window.setMode(field.xTotal * scale, field.yTotal * scale)
end


function love.update(dt)
	if not gameOvered then
		checkIfRow(map)
		if not gameStopped then
			collision()
		end
		time = time + dt
		if love.keyboard.isDown("space") then
			player.speed = 6
		else
			player.speed = 2
		end
		if (not gameStopped) and (time > 1 / player.speed) then
			player.y = player.y + 1
			player.direction = "down"
			time = 0
			collision()
		end
	end
end


function love.draw()
	love.graphics.setColor(player.color.r, player.color.g, player.color.b)
	drawModel(player)
	-- love.graphics.setColor(255, 255, 255)
	drawMap(map, colorMap)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("line", (field.xStart - 1) * scale - 2, (field.yStart - 1) * scale - 2, (field.x) * scale + 2, (field.y) * scale + 2)
	love.graphics.rectangle("line", (nextShapeTable.xStart - 1) * scale - 2, (nextShapeTable.yStart - 1) * scale - 2, nextShapeTable.x * scale + 2, nextShapeTable.y * scale + 2)
	drawNextShape(nextShape)
	love.graphics.printf(labelScore.text .. addZeros(score), labelScore.xStart * scale, labelScore.yStart * scale, (labelScore.xEnd - labelScore.xStart) * scale, "center")
	if gameOvered then
		love.graphics.setColor(255, 255, 255)
		love.graphics.printf("Game Over! Do your wanna start a new game? Click Enter to start a new game.", (field.xStart - 1) * scale, (field.yStart + 5) * scale, (field.x) * scale, "center")
	end
	-- love.graphics.rectangle("fill", player.x * scale, player.y * scale, (player.width) * scale, (player.height) * scale)
end