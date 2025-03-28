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
local draggingCard = nil
local offsetX, offsetY = 0, 0

local cardPositions = {}

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
    randomCards = {}
    local xOffset = 150
    local yOffset = 150
    local spacing = 150

    for i = 1, 4 do
        local card = table.remove(deck)
        card.x = xOffset
        card.y = yOffset
        card.width = 105  -- Adjust based on actual card image size
        card.height = 150 -- Adjust based on actual card image size
        table.insert(randomCards, card)
        xOffset = xOffset + spacing
    end
end

function runAway()
    for i = 1, 4 do
        table.insert(deck, table.remove(randomCards))
    end
    for i = 1, 4 do
        shuffleDeck()
        table.insert(randomCards, table.remove(deck))
    end
    canRunAway = false
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

    -- Move the dragged card with the mouse
    if draggingCard then
        local mouseX, mouseY = love.mouse.getPosition()
        draggingCard.x = mouseX - offsetX
        draggingCard.y = mouseY - offsetY
    end
end

function love.draw()
    for _, card in ipairs(randomCards) do
        local cardImage = cardImages[card.name]
        love.graphics.draw(cardImage, card.x, card.y, nil, 3, 3)
        love.graphics.print(card.value, card.x + 5, card.y - 15)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        for _, card in ipairs(randomCards) do
            if x >= card.x and x <= card.x + card.width and 
               y >= card.y and y <= card.y + card.height then
                draggingCard = card
                offsetX = x - card.x
                offsetY = y - card.y
                break
            end
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        draggingCard = nil -- Stop dragging when mouse is released
    end
end
