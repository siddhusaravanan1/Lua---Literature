local suits = {"hearts", "diamonds", "clubs", "spades"}
local ranks = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}

local cardValues = {
    ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5, ["6"] = 6, ["7"] = 7,
    ["8"] = 8, ["9"] = 9, ["10"] = 10, ["J"] = 11, ["Q"] = 12, ["K"] = 13, ["A"] = 14
}

local deck = {}
local cardImages = {}
local randomCards = {}

local canRunAway = true
local fillHand = false

local draggingCard = nil
local offsetX, offsetY = 0, 0

local life = 20
local distance = {}
love.graphics.setDefaultFilter("nearest", "nearest")

function loadCardImages()
    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            local cardName = rank .. suit 
            cardImages[cardName] = love.graphics.newImage("sprites/cardImages/" .. cardName .. ".png")
        end
    end
end

function createDeck()
    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            local cardName = rank .. suit
            local cardValue = cardValues[rank]
            table.insert(deck, {name = cardName, value = cardValue})
        end
    end
end

function shuffleDeck()
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
end

function pickUniqueCards()
    local xOffset = 150
    local yOffset = 150
    local spacing = 150
    local card
    for i = 1, 4 do
        card = table.remove(deck)
        card.x = xOffset
        card.y = yOffset
        card.originalX = xOffset
        card.originalY = yOffset
        card.width = 105
        card.height = 150
        card.xText = card.originalX + 5
        card.yText = card.originalY - 15
        table.insert(randomCards, card)
        xOffset = xOffset + spacing
        table.remove(card)
    end
end

function distanceCheck()
    if draggingCard then
        distance.a = draggingCard.x - randomCards[1].x
        distance.b = draggingCard.x - randomCards[2].x
        distance.c = draggingCard.x - randomCards[3].x
        distance.d = draggingCard.x - randomCards[4].x
        distance.a = math.abs(distance.a)
        distance.b = math.abs(distance.b)
        distance.c = math.abs(distance.c)
        distance.d = math.abs(distance.d)
    end
end

function battleCalc()
    local damage = 0
        if distance.a <= 20 then
            if randomCards[1].value >= draggingCard.value then
                table.remove(randomCards[2])
            elseif randomCards[1].value < draggingCard.value then
                damage = randomCards[1].value - draggingCard.value
                damage = math.abs(damage)
            end
            life = life - damage
        end
        if distance.b <= 20 then
            if randomCards[2].value >= draggingCard.value then
                table.remove(draggingCard)
            elseif randomCards[2].value < draggingCard.value then
                damage = randomCards[2].value - draggingCard.value
                damage = math.abs(damage)
            end
            life = life - damage
        end
        if distance.c <= 20 then
            if randomCards[3].value >= draggingCard.value then
                table.remove(draggingCard)
            elseif randomCards[3].value < draggingCard.value then
                damage = randomCards[3].value - draggingCard.value
                damage = math.abs(damage)
            end
            life = life - damage
        end
        if distance.d <= 20 then
            if randomCards[4].value >= draggingCard.value then
                table.remove(draggingCard)
            elseif randomCards[4].value < draggingCard.value then
                damage = randomCards[4].value - draggingCard.value
                damage = math.abs(damage)
            end
            life = life - damage
        end
end


function runAway()
    canRunAway = false
    for i = 1, 4 do
        table.insert(deck, table.remove(randomCards))
        shuffleDeck()
    end
    fillHand = true
    if fillHand then
        pickUniqueCards()
    end
end

function love.load()
    math.randomseed(os.time())
    loadCardImages()
    createDeck()
    shuffleDeck()
    pickUniqueCards()
end

function love.update(dt)
    if love.keyboard.isDown('s') and canRunAway then
        runAway()
    end
    if love.keyboard.isDown('r') and not canRunAway then
        canRunAway = true
    end
    if draggingCard then
        local mouseX, mouseY = love.mouse.getPosition()
        draggingCard.x = mouseX - offsetX
        draggingCard.y = mouseY - offsetY
    end
    distanceCheck()
end

function love.draw()
    
    local yOffset = 0
    for _, card in ipairs(randomCards) do
        local cardImage = cardImages[card.name]
        love.graphics.draw(cardImage, card.x, card.y, nil, 3, 3)
        love.graphics.print(card.value, card.xText, card.yText)
    end
    love.graphics.print('Life: ' .. life, 10, 10)
    if draggingCard then
        love.graphics.print('distance.a = ' .. distance.a , 10, 20)
        love.graphics.print('distance.b = ' .. distance.b , 10, 30)
        love.graphics.print('distance.c = ' .. distance.c , 10, 40)
        love.graphics.print('distance.d = ' .. distance.d , 10, 50)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        for _, card in ipairs(randomCards) do
            if x >= card.x and x <= card.x + card.width and y >= card.y and y <= card.y + card.height then
                draggingCard = card
                offsetX = x - card.x
                offsetY = y - card.y
                draggingCard.value = card.value
                break
            end
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 and draggingCard then
        battleCalc()
        draggingCard.x = draggingCard.originalX
        draggingCard.y = draggingCard.originalY
        draggingCard = nil
    end
end
