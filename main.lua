I_1={
    [0]={[0]=0,0,0,0},
    {[0]=0,0,0,0},
    {[0]=1,1,1,1},
    {[0]=0,0,0,0}
}
I_2={
    [0]={[0]=0,0,1,0},
    {[0]=0,0,1,0},
    {[0]=0,0,1,0},
    {[0]=0,0,1,0}
}
I_3={
    [0]={[0]=0,1,0,0},
    {[0]=0,1,0,0},
    {[0]=0,1,0,0},
    {[0]=0,1,0,0}
}
O_1={
    [0]={[0]=1,1},
    {[0]=1,1}
}
L_1={
    [0]={[0]=0,0,0},
    {[0]=1,1,1},
    {[0]=1,0,0}
}
L_2={
    [0]={[0]=1,1,0},
    {[0]=0,1,0},
    {[0]=0,1,0}
}
L_3={
    [0]={[0]=0,0,0},
    {[0]=0,0,1},
    {[0]=1,1,1}
}
L4={
    [0]={[0]=1,0,0},
    {[0]=1,0,0},
    {[0]=1,1,0}
}
S_1={
    [0]={[0]=0,0,0},
    {[0]=0,1,1},
    {[0]=1,1,0}
}
S_2={
    [0]={[0]=0,1,0},
    {[0]=0,1,1},
    {[0]=0,0,1}
}
S_3={
    [0]={[0]=1,0,0},
    {[0]=1,1,0},
    {[0]=0,1,0}
}


pieces = {
    OBlock={
        rotation={
            [0]=O_1,O_1,O_1,O_1
        },
        color=3
    },
    IBlock={
        rotation={
            [0]=I_1,I_2,I_1,I_3
        },
        color=4
    },
    LBlock=
    {
        rotation={
            [0]=L_1,L_2,L_3,L4
        },
        color=1
    },
    SBlock={
        rotation={
            [0]=S_1,S_2,S_1,S_3
        },
        color=2
    }
}
colors={
    [1]={255,0,0},
    [2]={0,255,0},
    [3]={255,255,0},
    [4]={0,255,255}
}

background = {0,0,0}
border = {255,0,0}
blocksInARow=10

buttons={
    start = {
        x=350,
        y=250,
        hx=100,
        hy=50,
        text="START"
    },
    resume = {
        x=350,
        y=350,
        hx=100,
        hy=50,
        text="RESUME"
    },
    exitAndSave = {
        x=550,
        y=500,
        hx=200,
        hy=50,
        text="EXIT AND SAVE"
    }
}

dropSound = love.audio.newSource("sounds/drop_sound.wav", "static")
gameOverSound = love.audio.newSource("sounds/game_over_sound.wav", "static")
completeRowSound=love.audio.newSource("sounds/row_complete_sound.wav", "static")

function love.load()
    love.graphics.setBackgroundColor(background)
    windowWidth = love.graphics.getWidth()
    windowHeight = love.graphics.getHeight()
    topBorder = 50
    bottomBorder = windowHeight - 30
    boardHeight = bottomBorder - topBorder
    squareSize = boardHeight/(2*blocksInARow)
    blocksInAColumn = boardHeight/squareSize
    boardWidth=blocksInARow*squareSize
    leftBorder = (windowWidth - boardWidth)/2
    rightBorder = leftBorder + boardWidth
    count=0
    goDownWithBlock=false
    points=0
    gameOver=false
    newGameButtons()
    board={}
    for i=0,blocksInARow-1 do
        board[i]={}
        for j=0,blocksInAColumn-1 do
            board[i][j] = 0
        end
    end
    newPiece()
    continueGame=false
    animation = newAnimation(love.graphics.newImage("animations/stars.png"), 18, 18, 0.5)
    waitCount=0
end

function newPiece()
    local keyset = {}
    for k in pairs(pieces) do
        table.insert(keyset, k)
    end
    figureName=keyset[love.math.random(#keyset)]
    currFigure = pieces[figureName]["rotation"][0]
    color=pieces[figureName]["color"]
    curr_row=0
    count=0
    choosenColumn=blocksInARow/2-1
    currRotation=0
    destroyingRow=false
end

function updatePiece(figureName,row, column)
    currFigure = pieces[figureName]["rotation"][0]
    color=pieces[figureName]["color"]
    curr_row=row
    count=0
    choosenColumn=column
    currRotation=0
    destroyingRow=false
end

function newGameButtons()
    activeButtons={start=true,resume=true,restart=false}
end


function love.draw()
    if not hasCorrectPosition(currFigure) and not destroyingRow then
        gameOverAction()
        return
    end
    createButtons()
    if continueGame then
        for y=topBorder, bottomBorder, squareSize do
            love.graphics.setColor(border)
            for x=leftBorder, rightBorder, squareSize do
                love.graphics.line(x, topBorder, x, bottomBorder)
                love.graphics.line(leftBorder, y, rightBorder, y)
            end
        end
        drawBoardSquares()
        if destroyingRow then
            local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
            love.graphics.setColor({255,255,0})
            x,y=coordinates(choosenColumn, rowToDestroy)
            for i=leftBorder,rightBorder,boardWidth/18 do
                love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum],i,y)
            end
        else
            displayFigure(currFigure, choosenColumn, curr_row)
        end
        love.graphics.setColor(border)
        love.graphics.print("POINTS: " .. points, 100,100,0,2,2)
    end
end

function drawBoardSquares()
    for i=0,blocksInARow-1 do
        for j=0,blocksInAColumn-1 do
            if board[i][j] ~= 0 then
                love.graphics.setColor(colors[board[i][j]])
                x_j,y_i = coordinates(i,j)
                love.graphics.rectangle("fill", x_j, y_i, squareSize, squareSize)
            end
        end
    end
end

function gameOverAction()
    love.graphics.setColor({0,0,255}) 
    love.graphics.print("GAME OVER",leftBorder,windowHeight/2,0,4,4)
    if not gameOver then
        gameOverSound:play()
    end
    gameOver=true
    activeButtons={}
end

function coordinates(x, y)
    return leftBorder + x * squareSize, 
    topBorder + y * squareSize
end

function displayFigure(figure, column, row)
    love.graphics.setColor(colors[color]) 
    for i=0,#figure do
        for j=0,#figure[i] do
            if figure[i][j] == 1 then
                x_j,y_i = coordinates(column + j, row + i)
                love.graphics.rectangle("fill", x_j, y_i, squareSize, squareSize)
            end
        end
    end
end

function readFromFile()
    file = io.open("game_history.txt","r")
    for i=0,blocksInARow-1 do
        for j=0,blocksInAColumn-1 do
            el=file:read "*number"
            board[i][j]=el
        end
    end
    points=file:read "*number"
    local space=file:read(1)
    updatePiece(file:read(6),file:read "*number", file:read "*number")
    file:close()
end

function love.mousepressed( x, y, button, istouch, presses )
    for buttonName in pairs(buttons) do
        if activeButtons[buttonName] then
            if buttons[buttonName]["x"]<=x 
                and x<=buttons[buttonName]["x"] + buttons[buttonName]["hx"] 
                and buttons[buttonName]["y"]<=y 
                and y<=buttons[buttonName]["y"] + buttons[buttonName]["hy"] then
                
                if buttonName == "resume" then
                    readFromFile()
                    continueGame=true
                    activeButtons={exitAndSave=true}
                    break
                end
                if buttonName == "start" then
                    continueGame=true
                    activeButtons={exitAndSave=true}
                    break
                end
                if buttonName == "restart" then
                    readFromFile()
                    continueGame=false
                    activeButtons=newGameButtons()
                end
                if buttonName == "exitAndSave" then
                    saveGameExit()
                end
            end
        end
    end
end

function createButtons()
    for buttonName in pairs(buttons) do
        if activeButtons[buttonName] then
            love.graphics.setColor({255,255,255}) 
            love.graphics.rectangle("line", buttons[buttonName]["x"], buttons[buttonName]["y"], buttons[buttonName]["hx"], buttons[buttonName]["hy"])
            love.graphics.setColor({255,255,255})
            font = love.graphics.newFont(10)
            love.graphics.print(buttons[buttonName]["text"],
                buttons[buttonName]["x"] + (buttons[buttonName]["hx"] - font:getWidth(buttons[buttonName]["text"]))/2, 
                buttons[buttonName]["y"] + (buttons[buttonName]["hy"]- font:getHeight(buttons[buttonName]["text"]))/2 )
        end
    end
end

function saveGameExit()
    file = io.open("game_history.txt", "w")
    io.output(file)
    for i=0,blocksInARow-1 do
        for j=0,blocksInAColumn-1 do
            io.write(board[i][j].." ")
        end
    end
    io.write(points.." ")
    io.write(figureName.." ")
    io.write(curr_row.." ")
    io.write(choosenColumn.." ")
    io.close(file)
    love.event.quit()
end

function love.keypressed(key, unicode, isrepeat)
    if key == 'right' then
        choosenColumn = choosenColumn + 1
        if not hasCorrectPosition(currFigure) then
            choosenColumn = choosenColumn - 1
        end
    end
    if key == 'left' then
        choosenColumn = choosenColumn - 1
        if not hasCorrectPosition(currFigure) then
            choosenColumn = choosenColumn + 1
        end
    end
    if key == 'down' then
        goDownWithBlock=true
    end
    if key == 'up' then
        local newRotation=(currRotation+1)%4
        local newFigure=pieces[figureName]["rotation"][newRotation]
        if hasCorrectPosition(newFigure) then
            currRotation=newRotation
            currFigure=newFigure
        end
    end
end

function hasCorrectPosition(figureToCheck)
    for i=0,#figureToCheck do
        for k=0,#figureToCheck[i] do
            if figureToCheck[i][k]== 1 and 
            (choosenColumn + k >= blocksInARow 
                or choosenColumn + k < 0
                or curr_row + i >= blocksInAColumn
                or curr_row + i < 0
                or board[choosenColumn + k][curr_row + i] ~= 0) then
                return false
            end
        end
    end
    return true
end


function love.update(dt)
    animation.currentTime = animation.currentTime + dt
    if animation.currentTime >= animation.duration then
        animation.currentTime = animation.currentTime - animation.duration
    end

    if gameOver or not continueGame then
        return
    end

    count = count + dt
    waitCount = waitCount + dt
    local canMoveLower = true

    if not destroyingRow then
        if goDownWithBlock then
            curr_row=findDropLevel()
            canMoveLower=false
            goDownWithBlock=false
            waitCount=0
        else
            canMoveLower = canDropOneLower()
            if count > 0.5 and canMoveLower then
                curr_row=curr_row+1
                count=0
                waitCount=0
            end 
        end
        if not canMoveLower then
            updateWithBlock()
            updateOneRow()
        end
    end

    if destroyingRow and waitCount >0.5 then
        waitCount=0
        destroyingRow=false
        updateOneRow()
    end
end

function updateOneRow()
    rowToDestroy=destroyFullRows()
    drawBoardSquares()
    if rowToDestroy~=nil then
        destroyingRow = true
        if dropSound:isPlaying() then
            dropSound:stop()
        end
        if completeRowSound:isPlaying() then
            completeRowSound:stop()
        end
        completeRowSound:play()
    else
        destroyingRow=false
        if dropSound:isPlaying() then
            dropSound:stop()
        end
        dropSound:play()
        newPiece()
    end
end

function updateWithBlock()
    for i=0,#currFigure do
        for j=0,#currFigure[i] do
            if currFigure[i][j] == 1 then
                board[choosenColumn + j][curr_row + i]=color
            end
        end
    end
end

function findDropLevel()
    for j=curr_row, blocksInAColumn - 1 do
        for i=#currFigure,0,-1 do
            for k=0,#currFigure[i] do
                if currFigure[i][k]== 1 and board[choosenColumn + k][j + 1 + i] ~= 0 then
                    return j
                end
            end
        end
    end
end

function canDropOneLower()
    for i=#currFigure,0,-1 do
        for k=0,#currFigure[i] do
            if currFigure[i][k] == 1 and 
            (curr_row + 1 + i >= blocksInAColumn 
            or board[choosenColumn + k][curr_row + 1 + i] ~= 0 ) then
                return false
            end
        end
    end
    return true
end

function destroyFullRows()
    for i=blocksInAColumn - 1,0,-1 do
        local all_filled=true
        for j=0,blocksInARow - 1 do
            if board[j][i]==0 then
                all_filled=false
                break
            end
        end
        if all_filled then
            for j=0,blocksInARow - 1 do
                for k=i,1,-1 do
                    board[j][k]=board[j][k-1]
                end
                board[j][0]=0
            end
            points=points+1
            return i
        end
    end
    return nil
end

function newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    animation.duration = duration or 1
    animation.currentTime = 0

    return animation
end