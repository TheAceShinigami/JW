local ai = require "bullet_ai"

local bullet = {}

bullet.load = function()
  bullets = {}
  bullet_info = {}
  bullet_info.basic = {ai = {1, 1}, speed = 6, dmg = 1, r = 4, img = "bullet"}
  bullet_info.weak = {ai = {1, 1}, speed = 4, dmg = .5, r = 3, img = "bullet"}
  bullet_info.beef = {ai = {1, 1}, speed = 8, dmg = 2, r = 5, img = "bullet"}

  weapon_info = {}
  weapon_info[1] = {bullet = "basic", ammo = 1, delay = .2}
  weapon_info[2] = {bullet = "weak", ammo = 1, delay = .1}
  weapon_info[3] = {bullet = "beef", ammo = 1, delay = .4}
end

bullet.update = function(dt)
  for i, v in pairs(bullets) do
    -- update per bullet ai
    ai.update[bullet_info[v.type].ai[2]](i, v, dt)

    -- do damage
    if v.side == 1 then -- check for collision with enemies
      for j, w in pairs(enemies) do
        if collision.overlap(v, w) then
          w.hp = w.hp - bullet_info[v.type].dmg*v.tier
          stats.hits = stats.hits + 1 -- increase 'hits' stat
          bullets[i] = nil
        end
      end
    else -- check for collision with player
      if collision.overlap(v, char) then
        if char.inv <= 0 then
          char.hp = char.hp - bullet_info[v.type].dmg*v.tier
          char.inv = char_info.inv_time
          stats.dmg = stats.dmg + 1 -- increase 'dmg' stat
        end
        bullets[i] = nil
      end
    end
    -- check if bullet is off screen
    if v.p.x < 0 or v.p.x > screen.w or v.p.y < 0 or v.p.y > screen.h then
      bullets[i] = nil
    end
  end
end

bullet.draw = function()
  for i, v in pairs(bullets) do
    love.graphics.draw(bulletimg[bullet_info[v.type].img], bulletquad[bullet_info[v.type].img][v.frame], math.floor(v.p.x), math.floor(v.p.y), v.angle, 1, 1, 16, 16)
    love.graphics.setColor(tiers[v.tier].color)
    love.graphics.draw(bulletimg[bullet_info[v.type].img.."_overlay"], bulletquad[bullet_info[v.type].img.."_overlay"][v.frame], math.floor(v.p.x), math.floor(v.p.y), v.angle, 1, 1, 16, 16)
    love.graphics.setColor(255, 255, 255)
  end
end

bullet.new = function(type, p, d, side, tier)
  local spot = opening(bullets)
  local info = bullet_info[type]
  bullets[spot] = {type = type, p = p, d = d, r = info.r, side = side, angle = math.atan2(d.y, d.x), frame = 1, tier = tier}
  -- perform first-time setup
  ai.load[info.ai[1]](spot, bullets[spot])
end

return bullet
