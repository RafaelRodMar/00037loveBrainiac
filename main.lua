require("vector2D")

function shuffle(array)
    -- fisher-yates
    local output = { }
    local random = math.random
    
    for index = 1, #array do
        local offset = index - 1
        local value = array[index]
        local randomIndex = offset*random()
        local flooredIndex = randomIndex - randomIndex%1
    
        if flooredIndex == offset then
            output[#output + 1] = value
        else
            output[#output + 1] = output[flooredIndex + 1]
            output[flooredIndex + 1] = value
        end
    end
    
    return output
end

function love.load()
    tileImage = {}
    for i = 0, 8 do
        tileImage[i] = love.graphics.newImage("assets/img/Tile" .. tostring(i) .. ".png")
    end

    --load font
    font = love.graphics.newFont("assets/fnt/sansation.ttf",25)
    love.graphics.setFont(font)

    --load sounds
    matchSound = love.audio.newSource("assets/snd/match.wav","static")
    mismatchSound = love.audio.newSource("assets/snd/mismatch.wav", "static") 
    selectSound = love.audio.newSource("assets/snd/select.wav", "static")
    winSound = love.audio.newSource("assets/snd/win.wav", "static")
    matchSound:setVolume(0.2)
    mismatchSound:setVolume(0.2)
    selectSound:setVolume(0.2)
    --winSound:setVolume(0.2)

    math.randomseed( os.time() )
    math.random() math.random() math.random()

    --initialize board and states to 0 / false
    tileStates = {}
    tiles = {}
    for i=0,3 do
        tileStates[i] = {}
        tiles[i] = {}

        for j=0,3 do
            tileStates[i][j] = false
            tiles[i][j] = 0
        end
    end

    --initialize the tile images randomly
    numbersTable = {}
    for i=1, 8 do
        table.insert(numbersTable, i)
        table.insert(numbersTable, i)
    end

    shuffleTable = shuffle(numbersTable)
    sindex = 1
    for i=0, 3 do
        for j=0, 3 do
            tiles[i][j] = shuffleTable[sindex]
            sindex = sindex + 1
        end
    end

    --initialize the tile selections and match/try count
    tile1 = Vector2D:new(-1,-1)
    tile2 = Vector2D:new(-1,-1)
    score = 0
    matches = 0
    tries = 0
    mouseClicked = false
    mousePos = Vector2D:new(0,0)

    gameWidth = 528
    gameHeight = 502

    love.window.setMode(gameWidth, gameHeight, {resizable=false, vsync=false})
    love.graphics.setBackgroundColor(1,1,1) --white

end

function love.keypressed(key)
end

function love.keyreleased(key)
end

function love.mousepressed(x,y,button, istouch)
	if button == 1 then
		mouseClicked = true
        mousePos.x = x
        mousePos.y = y
	end
end

function love.update(dt)
    if mouseClicked == true then
		--determine which tile was clicked
		local TileX = math.floor( mousePos.x / 132 ) --tilewidth
		local TileY = math.floor(mousePos.y / 127 ) --tileheight

		--make sure the tile hasn't already been matched
		if not tileStates[TileX][TileY] then
			--see if this is the first tile selected
			if tile1.x == -1 then
				--play sound for tile selection
				selectSound:play()

				--set the first tile selection
				tile1.x = TileX
				tile1.y = TileY
    		elseif ((TileX ~= tile1.x) or (TileY ~= tile1.y)) then
				if (tile2.x == -1) then
					--play a sound for the tile selection
					selectSound:play()

					--increase the number of tries
					tries = tries + 1

					--set the second tile selection
					tile2.x = TileX
					tile2.y = TileY

					--see if it's a match
					if (tiles[tile1.x][tile1.y] == tiles[tile2.x][tile2.y]) then
						--play a sound for the tile match
						matchSound:play()
						score = score + 100

						--set the tile state to indicate the match
						tileStates[tile1.x][tile1.y] = true
						tileStates[tile2.x][tile2.y] = true

						--clear the tile selections
						tile1.x, tile1.y, tile2.x, tile2.y = -1, -1, -1, -1

						--update the match count and check for winner
                        matches = matches + 1
						if matches == 8 then
							--play a victory sound
							winSound:play()
                            while winSound:isPlaying() do
                            end
                            love.timer.sleep(5)
                            love.event.quit() --exit game
                        end
					else
						--play a sound for the tile mismatch
						mismatchSound:play()
                    end
				else
					--clear the tile selections
					tile1.x, tile1.y, tile2.x, tile2.y = -1, -1, -1, -1
                end
            end
        end
		mouseClicked = false
    end
end

function love.draw()
    love.graphics.setBackgroundColor(1,1,1)
    love.graphics.setColor(1,1,1)

    --draw the tiles
    tileWidth = 132
    tileHeight = 127

    for i = 0, 3 do
        for j = 0, 3 do
            if (tileStates[i][j] or ((i == tile1.x) and (j == tile1.y)) or ((i == tile2.x) and (j == tile2.y))) then
                love.graphics.draw(tileImage[tiles[i][j]], i * 132, j * 127)
            else
                love.graphics.draw(tileImage[0], i * 132, j * 127)
            end
        end
    end

    --draw UI
    love.graphics.setColor(0,0,1)
    love.graphics.print("Matches: " .. matches .. "   Tries: " .. tries, 5, 10)
end
