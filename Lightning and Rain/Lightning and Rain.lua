local tap = gui.Tab(gui.Reference("VISUALS"), "m3lesh.lua", "m3lesh.lua");
local gbox1 = gui.Groupbox(tap, "Lightning and Rain", 10, 10, 300, 0);  -- gbox1
local gbox2 = gui.Groupbox(tap, "    ", 315, 10, 320, 0);  -- gbox2

local Raindrops = gui.Slider(gbox1, "Number.of.raindrops", "Number of raindrops", 200, 10, 1000, 20)
local Speed = gui.Slider(gbox1, "Speed.of.raindrops", "Speed of raindrops", 1, 1, 10, 1)

local enable_sounds = gui.Checkbox(gbox1, "enable.sound", "Enable sound", true);
enable_sounds:SetDescription("Please make sure add a rain.vsnd_c");
local Volume = gui.Slider(gbox1, "volume", "Volume", 0.06, 0, 1.5, 0.01);



local previousMillis = 0

-- Define the size of the screen
local screenWidth, screenHeight = draw.GetScreenSize()

-- Background Color (dark sky)
local bgColor = { r = 0, g = 0, b = 0 }

-- Lightning color (bright white)
local lightningColor = { r = 255, g = 255, b = 255 }

-- Rain color (light gray)
local rainColor = { r = 180, g = 180, b = 180 }

-- Time between lightning flashes
local flashIntervalMin = 1.0 -- Minimum time between flashes
local flashIntervalMax = 3.0 -- Maximum time between flashes
local flashDuration = 0.1 -- Lightning flash duration
local nextFlashTime = 0
local flashTimeRemaining = 0

-- Rain configuration
local numRaindrops = 1000 -- Number of raindrops
local raindrops = {}

-- Initialize raindrops with random positions and speeds
for i = 1, numRaindrops do
    raindrops[i] = {
        x = math.random(0, screenWidth),
        y = math.random(0, screenHeight),
        speed = math.random(2, 5),
        length = math.random(5, 10)
    }
end

-- Callback function for rendering
function rendering()
    -- Get the current time
    local currentTime = globals.CurTime()



    -- Check if it's time for a lightning flash
    if currentTime >= nextFlashTime then
        -- Start a new flash
        flashTimeRemaining = flashDuration
        -- Randomize the next flash time
        nextFlashTime = currentTime + math.random(flashIntervalMin, flashIntervalMax)
    end

    -- If we are in the middle of a flash, draw the lightning
    if flashTimeRemaining > 0 then
        flashTimeRemaining = flashTimeRemaining - globals.FrameTime()

        -- Randomize starting point of lightning
        local startX = math.random(0, screenWidth)
        local startY = math.random(0, screenHeight / 2)

        -- -- Draw dark background
        -- draw.Color(bgColor.r, bgColor.g, bgColor.b, 150)
        -- draw.FilledRect(0, 0, screenWidth, screenHeight)


        -- Draw lightning strike
        draw.Color(lightningColor.r, lightningColor.g, lightningColor.b, 255)
        drawLightningStrike(startX, startY, 100, 3)
    end

    -- Draw rain
    drawRain()
end

-- Function to simulate a jagged lightning strike
function drawLightningStrike(x, y, length, thickness)
    -- Draw lightning with random jagged lines
    for i = 1, math.random(5, 10) do
        local endX = x + math.random(-length, length)
        local endY = y + math.random(10, length)
        draw.Line(x, y, endX, endY)
        x = endX
        y = endY
    end
end

-- Function to draw rain
function drawRain()

    if enable_sounds:GetValue() then
        Volume:SetInvisible(false)
        local g_flVolume = Volume:GetValue();
        client.SetConVar("snd_toolvolume", g_flVolume, true);
        local currentMillis = globals.CurTime()
        if currentMillis - previousMillis >= 14.5 then
            client.Command(("play sounds\\" .. "rain"), true)
            previousMillis = currentMillis;
        end
    else
        Volume:SetInvisible(true)
    end



    draw.Color(rainColor.r, rainColor.g, rainColor.b, 255) -- Set rain color

    -- Update and draw each raindrop
    for i = 1, Raindrops:GetValue() do
        local raindrop = raindrops[i]

        -- Draw the raindrop (a vertical line)
        draw.Line(raindrop.x, raindrop.y, raindrop.x, raindrop.y + raindrop.length)

        -- Update raindrop position (fall downwards)
        raindrop.y = raindrop.y + (math.random(2, 5) * Speed:GetValue())

        -- Reset raindrop if it falls off the screen
        if raindrop.y > screenHeight then
            raindrop.y = -raindrop.length -- Reset above the screen
            raindrop.x = math.random(0, screenWidth) -- Randomize horizontal position
        end
    end
end

-- Register the drawing callback
callbacks.Register("Draw", rendering)
