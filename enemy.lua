local ai = require "enemy_ai"

local enemy = {}

enemy.load = function()
  enemies = {}
  enemy_info = {}
  enemy_info.crosser = {ai = {1, 1, 1, 1}, atk_delay = 3, speed = 1, stop = 0.9, r = 16, hp = 1, score = 1, img = "biplane"}
  enemy_info.fly = {ai = {2, 2, 1, 1}, atk_delay = 2, speed = 2, stop = 0.9, r = 12, hp = 2, score = 2, img = "fly"}
  ship_width = {}
  for i, v in pairs(shipimg) do
    ship_width[i] = v:getHeight()
  end

  enemy_tier = {}
  enemy_tier[1] = {color = {205, 100, 25}}
  enemy_tier[2] = {color = {255, 50, 50}}
  enemy_tier[3] = {color = {255, 50, 150}}
  enemy_tier[4] = {color = {50, 185, 0}}
  enemy_tier[5] = {color = {255, 235, 235}}
  enemy_tier[6] = {color = {75, 75, 75}}
end

enemy.update = function(dt)
  for i, v in pairs(enemies) do
    -- move the ai
    ai.move[enemy_info[v.type].ai[2]](i, v, dt)

    -- adjust position and velocity
    v.p = vector.sum(v.p, v.d)
    v.d = vector.scale(enemy_info[v.type].stop, v.d)

    -- delete enemy if it has no health
    if v.hp <= 0 then
      -- drop
      for j = 1, math.random(0, enemy_info[v.type].score) do
        local chance = math.random(1, 100)
        if chance <= 10 then
          drop.new(2, v.p, math.random(4, 8)) -- ammo
        elseif chance <= 20 then
          drop.new(1, v.p, 1) -- hp
        else
          drop.new(3, v.p, 1) -- money
        end
      end

      stats.kills = stats.kills + 1 -- increase 'kills' stat
      enemies[i] = nil
    end

    -- delete enemy if off screen
    if v.p.x+v.r < 0 or v.p.x-v.r > screen.w or v.p.y+v.r < 0 or v.p.y-v.r > screen.h then
      enemies[i] = nil
    end

    ai.attack[enemy_info[v.type].ai[3]](i, v, dt) -- call attack AI

    -- update animation
    v.frame = v.frame + dt * 12
    if v.frame >= #shipquad[enemy_info[v.type].img]+1 then
      v.frame = 1
    end
  end
end

enemy.draw = function()
  for i, v in pairs(enemies) do
    local img = enemy_info[v.type].img
    love.graphics.draw(shipimg[img], shipquad[img][math.floor(v.frame)], math.floor(v.p.x), math.floor(v.p.y), math.atan2(v.a.y, v.a.x), 1, 1, ship_width[img]/2, ship_width[img]/2)
    love.graphics.setColor(enemy_tier[v.tier].color)
    love.graphics.draw(shipimg[img.."_overlay"], shipquad[img.."_overlay"][math.floor(v.frame)], math.floor(v.p.x), math.floor(v.p.y), math.atan2(v.a.y, v.a.x), 1, 1, ship_width[img]/2, ship_width[img]/2)
    love.graphics.setColor(255, 255, 255)
  end
end

enemy.new = function(type, tier) -- add enemy to open space in list
  local spot = opening(enemies)
  local info = enemy_info[type]
  enemies[spot] = {p = {x = 0, y = 0}, d = {x = 0, y = 0}, a = {x = 1, y = 0}, r = info.r, hp = info.hp, atk = 0, type = type, info = {}, frame = 1, tier = tier}
  -- do first-time setup for enemy
  ai.load[info.ai[1]](spot, enemies[spot])
end

return enemy
