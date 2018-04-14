local pause = {}

local button = 1
local buttons = {{txt = "Resume", color = {64, 51, 102}, pos = 0, img = 4},
                 {txt = "Save to Menu", color = {64, 51, 102}, pos = 0, img = 5},
                 {txt = "Save and Quit", color = {204, 40, 40}, pos = 0, img = 3}}
local pos = -298
local on = true
local wait = 0

pause.start = function()
  on = true
  pos = -298
  button = 1
end

pause.load = function()
  canvas.pause = love.graphics.newCanvas(244, 298)
end

pause.update = function(dt)
  for i, v in ipairs(buttons) do
    v.pos = graphics.zoom(button == i, v.pos, 0, 32, dt * 12)
  end
  if wait <= 0 then
    pos = graphics.zoom(on, pos, -298, 51, dt * 12)
  else
    wait = wait - dt
  end
  if math.floor(pos) <= -298 then
    if button == 1 then
      state = oldstate
    elseif button == 2 then
      state = "main"
      mainmenu.start()
    end
  end
end

pause.draw = function()
  love.graphics.setCanvas(canvas.mainmenu)
  love.graphics.clear()

  -- basic stuff

  love.graphics.draw(img.notebook)
  love.graphics.setColor(64, 51, 102)
  love.graphics.print("Paused", 129-math.floor(font:getWidth("Paused")/2), 18)

  -- buttons
  for i, v in ipairs(buttons) do
    if button == i then
      love.graphics.setColor(0, 132, 204)
    else
      love.graphics.setColor(v.color)
    end
    love.graphics.draw(img.mainicons, quad.mainicons[v.img], 48+math.floor(v.pos), 68+i * 32)
    love.graphics.print(v.txt, 80+math.floor(v.pos), 80+i * 32)
  end

  love.graphics.setColor(255, 255, 255) -- reset color
  love.graphics.setCanvas(canvas.game)
  love.graphics.draw(canvas.mainmenu, 178, math.floor(pos))
end

pause.keypressed = function(key)
  if on == true then
    if key == "up" and button > 1 then
      button = button - 1
    elseif key == "down" and button < 3 then
      button = button + 1
    elseif key == "z" then
      if button == 1 then
        on = false
      elseif button == 2 then
        on = false
        mainmenu.save_game()
        mainmenu.score()
        if char.hp <= 0 then
          mainmenu.game_over()
        end
        wait = .2
      elseif button == 3 then
        love.event.quit()
      end
    elseif key == "x" or key == "escape" then
      on = false
    end
  end
end

return pause
