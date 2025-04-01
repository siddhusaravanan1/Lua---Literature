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
local dragginPresent = false
local setCard = false

local draggingCard = nil
local offsetX, offsetY = 0, 0

local life = 20
local baseValue = 15
local setupCard = 15
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
        distance = {}
        for i = 1, #randomCards do
            local dist = math.abs(draggingCard.x - randomCards[i].x)
            if dist > 0 then
                distance[i] = dist
            else
                distance[i] = math.huge
            end
        end
    end
end
function activeDragging()
    for i, card in ipairs(randomCards) do
        if card == draggingCard then
            local oldX, oldY = draggingCard.originalX, draggingCard.originalY
            table.remove(randomCards, i)
            local newCard = table.remove(deck)
            if newCard then
                newCard.x = oldX
                newCard.y = oldY
                newCard.originalX = oldX
                newCard.originalY = oldY
                newCard.width = 105
                newCard.height = 150
                newCard.xText = oldX + 5
                newCard.yText = oldY - 15
                table.insert(randomCards, i, newCard)
            else
                print("No more cards in the deck!")
            end
            --draggingCard = nil
            break
        end
    end
end

function addHealth()
    local heartsCheck = "hearts"
    if dragginPresent then
        if string.find(draggingCard.name, heartsCheck, 1, true) then
            life = life + draggingCard.value
            activeDragging()
        end
    end
end

function idealDamage()
    local checkClubDamage = "clubs"
    local checkSpadeDamage = "spades"
    if dragginPresent then
        if string.find(draggingCard.name, checkClubDamage, 1, true) or string.find(draggingCard.name, checkSpadeDamage, 1, true) then
            life = life - draggingCard.value
            activeDragging()
        end
    end
end


function battleCalc()
    local damage = 0
    local check = "diamonds"
    local heartsCheck = "hearts"
    if dragginPresent then
        for i = 1, #randomCards do
            if distance[i] and distance[i] <= 20 and baseValue >= randomCards[i].value then
                if string.find(draggingCard.name, check, 1, true) and not string.find(randomCards[i].name, heartsCheck, 1, true) and not string.find(randomCards[i].name, check, 1, true) then
                    baseValue = randomCards[i].value
                    if randomCards[i].value < draggingCard.value then
                        local oldX, oldY = randomCards[i].x, randomCards[i].y
                        table.remove(randomCards,i)
                        local newCard = table.remove(deck)
                        if newCard then
                            newCard.x = oldX
                            newCard.y = oldY
                            newCard.originalX = oldX
                            newCard.originalY = oldY
                            newCard.width = 105
                            newCard.height = 150
                            newCard.xText = oldX + 5
                            newCard.yText = oldY - 15
                            table.insert(randomCards, i, newCard)
                        else
                            print("No more cards in the deck!")
                        end
                        dragginPresent = false
                    else
                        --activeDragging()
                        damage = math.abs(randomCards[i].value - draggingCard.value)
                        local oldX, oldY = randomCards[i].x, randomCards[i].y
                        table.remove(randomCards,i)
                        local newCard = table.remove(deck)
                        if newCard then
                            newCard.x = oldX
                            newCard.y = oldY
                            newCard.originalX = oldX
                            newCard.originalY = oldY
                            newCard.width = 105
                            newCard.height = 150
                            newCard.xText = oldX + 5
                            newCard.yText = oldY - 15
                            table.insert(randomCards, i, newCard)
                        else
                            print("No more cards in the deck!")
                        end
                        print("working")
                    end
                    life = life - damage
                    damage = 0
                end
            end
        end
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
        baseValue = 15
        runAway()
        print("working")
    end
    if love.keyboard.isDown('r') and not canRunAway then
        canRunAway = true
    end
    if draggingCard then
        local mouseX, mouseY = love.mouse.getPosition()
        draggingCard.x = mouseX - offsetX
        draggingCard.y = mouseY - offsetY
    end
    if life > 20 then
        life = 20
    elseif life < 0 then
        life = 0
    end
    distanceCheck()
end

function love.draw()
    
    local yOffset = 20
    for i, card in ipairs(randomCards) do
        local cardImage = cardImages[card.name]
        love.graphics.draw(cardImage, card.x, card.y, nil, 3, 3)
        love.graphics.print(card.value, card.xText, card.yText)
        love.graphics.print("base value: " .. baseValue, 10, 100)
        love.graphics.print("setup value: " .. setupCard, 10, 115)
    end
    love.graphics.print('Life: ' .. life, 10, 10)
    if draggingCard then
        for i, distances in ipairs(distance) do
            love.graphics.print('distance = ' .. distances , 10, yOffset)
            yOffset = yOffset + 10
        end
    end
end
function love.mousepressed(x, y, button)
    if button == 1 then
        dragginPresent = true
        for _, card in ipairs(randomCards) do
            if x >= card.x and x <= card.x + card.width and y >= card.y and y <= card.y + card.height then
                local check = "diamonds"
                draggingCard = card
                offsetX = x - card.x
                offsetY = y - card.y
                if string.find(draggingCard.name, check, 1, true) and not setCard then
                    setupCard = draggingCard.value
                    setCard = true
                end
                if string.find(draggingCard.name, check, 1, true) and setCard then
                    --activeDragging()
                    setupCard = draggingCard.value
                    baseValue = 15
                end
                break
            end
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 and draggingCard then
        addHealth()
        idealDamage()
        battleCalc()
        draggingCard.x = draggingCard.originalX
        draggingCard.y = draggingCard.originalY
        draggingCard = nil
        --activeDragging()
        draggingCard = nil
        
    end
end
