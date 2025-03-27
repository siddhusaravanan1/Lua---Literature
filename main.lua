local suits = {"hearts", "diamonds", "clubs", "spades"}
local ranks = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}

local cardValues = {
    ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5, ["6"] = 6, ["7"] = 7,
    ["8"] = 8, ["9"] = 9, ["10"] = 10, ["J"] = 11, ["Q"] = 12, ["K"] = 13, ["A"] = 14
}

local deck = {}
local cardImages = {}

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
            local cardValue = cardValues[rank] -- Get value from lookup table
            table.insert(deck, {name = cardName, value = cardValue}) -- Store name and value
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
    for i = 1, 4 do
        table.insert(randomCards, table.remove(deck))
    end
end


function love.load()
    math.randomseed(os.time())
    loadCardImages()
    createDeck()
    shuffleDeck()
    pickUniqueCards()
end

function love.draw()

        local xOffset = 150
        local yOffset = 150
        local spacing = 150

        for _, card in ipairs(randomCards) do
            local cardImage = cardImages[card.name]
            love.graphics.draw(cardImage, xOffset, yOffset, nil, 3, 3)
            love.graphics.print(card.value, xOffset + 5, yOffset - 15)
            xOffset = xOffset + spacing
        end
end
