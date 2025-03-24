local suits = {"hearts", "diamonds", "clubs", "spades"}
local ranks = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}

local deck = {}
local cardImages = {}
local randomCards = {}

love.graphics.setDefaultFilter("nearest", "nearest")

function loadCardImages()
    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            local cardName = rank .. "" .. suit 
            cardImages[cardName] = love.graphics.newImage("sprites/cardImages/" .. cardName .. ".png")
        end
    end
end

function createDeck()
    deck = {} 
    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            local cardName = rank .. "" .. suit
            table.insert(deck, cardName)
        end
    end
end

function shuffleDeck()
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
end

function pickThreeUniqueCards()
    randomCards = {}
    for i = 1, 3 do
        table.insert(randomCards, table.remove(deck))
    end
end

function love.load()
    math.randomseed(os.time())
    loadCardImages()
    createDeck()
    shuffleDeck()
    pickThreeUniqueCards()
end

function love.draw()

    local xOffset = 200
    local yOffset = 150
    local spacing = 150

    for _, cardName in ipairs(randomCards) do
        local cardImage = cardImages[cardName]
        love.graphics.draw(cardImage, xOffset, yOffset, nil, 3, 3)
        xOffset = xOffset + spacing
        yOffset = yOffset + spacing
    end
end
