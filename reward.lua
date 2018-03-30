local item_info = require "items"

local rewardscreen = {}

local reward = 0
local reward_type = ""
local items = {}
local item_target = 0
local stats = {}
local total_score = 0
local weaponscreen = {on = false, pos = -176, itempos = {200, 200}, target = 1, itemcanvas = {love.graphics.newCanvas(), love.graphics.newCanvas(), love.graphics.newCanvas()}, choice = 0, canvas = love.graphics.newCanvas(220, 176)}

rewardscreen.load = function()
end

rewardscreen.start = function(node, game_stats)
    reward = node
    reward_type = rewardscreen.get_type(reward)

    math.randomseed(os.time())
    items = {}
    if reward_type == "shop" then
      for i = 1, 3 do
        items[i] = rewardscreen.create(math.random(1, 4))
      end
    elseif reward_type ~= "none" then
      items[1] = rewardscreen.create(reward - 1)
    end
    for i, v in ipairs(items) do
      v.canvas = rewardscreen.draw_card(v.type, v.item, v.amount)
    end

    item_target = 1

    stats = {{str = "Kills:", num = game_stats.kills}, {str = "Shots:", num = game_stats.shots}, {str = "Accuracy:", num = math.floor(game_stats.hits/game_stats.shots*100), per = true}, {str = "Damage Taken:", num = game_stats.dmg}}
    total_score = math.ceil((stats[1].num*10-stats[4].num)/stats[2].num)
    if total_score < 1 then -- prevents negative score and bugged bonus
      total_score = 1
    elseif stats[2].num < 1 then -- prevents bugged bonus and NaN accuracy
      stats[3].num = 0
      total_score = 1
    end

    canvas.reward = rewardscreen.draw_card(5, 1, total_score)

    money = money + total_score
  end

rewardscreen.update = function(dt)
  for i, v in ipairs(items) do
    if v.bought then
      if v.anim > -1 then
        v.anim = v.anim - dt * 18
        if v.anim < -1 then
          v.anim = -1
        end
      end
    end
  end

  weaponscreen.pos = rewardscreen.zoom(weaponscreen.on, weaponscreen.pos, -176, 56, dt * 12)

  weaponscreen.itempos[1] = rewardscreen.zoom(not weaponscreen.on, weaponscreen.itempos[1], 348, 600, dt * 12)
  weaponscreen.itempos[2] = rewardscreen.zoom(not weaponscreen.on, weaponscreen.itempos[2], 440, 600, dt * 12)
end

rewardscreen.zoom = function(bool, num, min, max, scalar)
  if bool and num < max then
    if num + (max-num) * scalar > max then
      return max
    else
      return num + (max-num) * scalar
    end
  elseif not bool and num > min then
    return num + (min-num) * scalar
  else
    return num
  end
end

rewardscreen.draw = function()
  local report_pos = 64

  -- reward side
  if reward_type ~= "none" then
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(img.sign, 426-48, 56)
    love.graphics.print("Reward", 426-math.floor(font:getWidth("Reward")/2), 66)

    -- items for sale
    for i, v in ipairs(items) do
      if i == item_target and weaponscreen.on == false then -- draw highlight
        love.graphics.draw(img.cardborder, 314 + i*78-#items*39+39, 134)
      end
      if v.anim > 0 then -- determine which side of card to show
        love.graphics.draw(v.canvas, 348 + i*78-#items*39+39, 136, 0, v.anim, 1, 32, 0)
      else
        love.graphics.draw(img.cardback, 348 + i*78-#items*39+39, 136, 0, v.anim, 1, 32, 0)
      end
    end
    -- draw info
    love.graphics.draw(img.infobox, 316, 248)
    love.graphics.setColor(64, 51, 102)
    rewardscreen.draw_info(items[item_target])
  else
    report_pos = 188
  end

  -- weapon screen
  if weaponscreen.on then
    love.graphics.setCanvas(weaponscreen.canvas)
    love.graphics.clear()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(img.blueprint, 0, 0)
    love.graphics.print("Weaponry", 110 - math.floor(font:getWidth("Weaponry")/2), 14)
    love.graphics.print("z", 64 - math.floor(font:getWidth("z")/2), 154)
    love.graphics.print("x", 156 - math.floor(font:getWidth("x")/2), 154)
    love.graphics.draw(img.cardborder, -62 + weaponscreen.target*92, 38)

    love.graphics.setCanvas(canvas.game)

    -- draw info
    love.graphics.draw(img.infobox, 316, 248)
    if char.weapons[weaponscreen.target] > 0 then
      love.graphics.setColor(64, 51, 102)
      rewardscreen.draw_info({price = 0, bought = false, type = 1, item = char.weapons[weaponscreen.target]})
    else
      love.graphics.setColor(204, 40, 40)
      love.graphics.print("Empty", 320, 252)
    end
  end
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(weaponscreen.canvas, 316, math.floor(weaponscreen.pos))
  -- weapons
  love.graphics.draw(weaponscreen.itemcanvas[1], weaponscreen.itempos[1], 95)
  love.graphics.draw(weaponscreen.itemcanvas[2], weaponscreen.itempos[2], 95)
  if weaponscreen.choice > 0 then
    love.graphics.draw(weaponscreen.itemcanvas[3], 856+weaponscreen.choice*92-weaponscreen.itempos[weaponscreen.choice], 95)
  end




  -- report side
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(img.report, report_pos, 56)
  love.graphics.draw(canvas.reward, report_pos+78, 200)

  -- text
  love.graphics.setColor(64, 51, 102)
  love.graphics.print("Report", report_pos+110-math.floor(font:getWidth("Report")/2), 62)
  for i, v in ipairs(stats) do
    love.graphics.print(v.str, report_pos+8, 64+i*16)
    if v.per then
      love.graphics.print(tostring(v.num).."%", report_pos+212-font:getWidth(tostring(v.num).."%"), 64+i*16)
    else
      love.graphics.print(v.num, report_pos+212-font:getWidth(tostring(v.num)), 64+i*16)
    end
  end
  love.graphics.line(report_pos+8, 144, report_pos+212, 144)
  love.graphics.print("Total Score:", report_pos+8, 150)
  love.graphics.print(total_score, report_pos+212-font:getWidth(tostring(total_score)), 150)
  love.graphics.line(report_pos+8, 164, report_pos+212, 164)
  love.graphics.print("Bonus", report_pos+110-math.floor(font:getWidth("Bonus")/2), 178)



  love.graphics.setColor(255, 255, 255)
  -- draw bottom instructions
  if weaponscreen.on then
    love.graphics.print("[z] Replace   [x] Exit", 300 - math.floor(font:getWidth("[z] Replace   [x] Exit")/2), 350)
  elseif reward_type == "shop" then
    love.graphics.print("[z] Buy   [x] Continue", 300 - math.floor(font:getWidth("[z] Buy   [x] Continue")/2), 350)
  elseif reward_type == "none" then
    love.graphics.print("[x] Continue", 300 - math.floor(font:getWidth("[x] Continue")/2), 350)
  else
    love.graphics.print("[z] Take   [x] Continue", 300 - math.floor(font:getWidth("[z] Take   [x] Continue")/2), 350)
  end
end

rewardscreen.keypressed = function(key)
  if weaponscreen.on then
    if key == "right" and weaponscreen.target < 2 then
      weaponscreen.target = 2
    elseif key == "left" and weaponscreen.target > 1 then
      weaponscreen.target = 1
    elseif key == "z" and weaponscreen.choice == 0 then
      weaponscreen.choice = weaponscreen.target -- weapon has been placed
      items[item_target].bought = true -- weapon has been purchased
      money = money - items[item_target].price -- adjust funds
      char.weapons[weaponscreen.target] = items[item_target].item -- correct player's inventory
      weaponscreen.itemcanvas[3] = weaponscreen.itemcanvas[weaponscreen.target] -- set old card canvas to card being replaced
      weaponscreen.itemcanvas[weaponscreen.target] = rewardscreen.draw_card(1, items[item_target].item, 1) -- redraw weapon card
      weaponscreen.itempos[weaponscreen.target] = 600 -- reset animation
    elseif key == "x" then
      weaponscreen.on = false
      weaponscreen.choice = 0
    end
  else
    if key == "right" and item_target < #items then
      item_target = item_target + 1
    elseif key == "left" and item_target > 1 then
      item_target = item_target - 1
    elseif key == "z" and reward_type ~= "none" and items[item_target].bought == false and items[item_target].price <= money then
      if items[item_target].type == 1 then -- prompt and set up weapon replacement screen
        weaponscreen.on = true
        weaponscreen.itemcanvas[1] = rewardscreen.draw_card(1, char.weapons[1], 1)
        weaponscreen.itemcanvas[2] = rewardscreen.draw_card(1, char.weapons[2], 1)
        weaponscreen.pos = -176
      else
        items[item_target].bought = true
        money = money - items[item_target].price
      end
    elseif key == "x" then
      state = "map"
    end
  end
end

rewardscreen.get_type = function(reward)
  if reward == 1 then
    return "none"
  elseif reward == 2 then
    return "weapon"
  elseif reward == 3 then
    return "upgrade"
  elseif reward == 7 then
    return "shop"
  else
    return "resource"
  end
end

rewardscreen.create = function(type)
  local item = 1
  local amount = 1
  local price = 0
  if type < 3 then
    item = math.random(1, #item_info[type])
  elseif type == 3 then
    amount = math.random(1, 3)
  elseif type == 4 then
    amount = math.random(5, 25)
  else
    amount = math.random(2, 10)
  end
  if reward_type == "shop" then
    if type > 2 then
      price = math.ceil(amount * item_info[type].price)
    else
      price = item_info[type][item].price
    end
  end
  return {type = type, item = item, amount = amount, bought = false, anim = 1, price = price}
end


rewardscreen.draw_card = function(type, item, amount)
  local canvas = love.graphics.newCanvas(64, 96)
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  if item > 0 then
    love.graphics.draw(img.card)
    love.graphics.draw(img.cardicons, quad.cardicons[type], 4, 4)
    love.graphics.draw(img.cardicons, quad.cardicons[type], 60, 92, math.pi)
    love.graphics.draw(img.cardimgs, quad.cardimgs[type], 8, 24)
    if amount and amount > 1 and type > 2 then
      love.graphics.setColor(204, 40, 40)
      love.graphics.print("x"..tostring(amount), 20, 9)
      love.graphics.print("x"..tostring(amount), 44, 87, math.pi)
      love.graphics.setColor(255, 255, 255)
    end
  end
  love.graphics.setCanvas()
  return canvas
end

rewardscreen.draw_info = function(item)
  local info = nil
  if item.type > 2 then
    info = item_info[item.type]
  else
    info = item_info[item.type][item.item]
  end
  if item.bought then
    love.graphics.setColor(204, 40, 40)
    love.graphics.print("Out of stock", 320, 252)
  else
    love.graphics.setColor(64, 51, 102)
    if item.amount and item.amount > 1 and item.type > 2 then
      love.graphics.print(info.name.." x"..item.amount, 320, 252)
    else
      love.graphics.print(info.name, 320, 252)
    end

    love.graphics.printf(info.disc, 320, 268, 212)

    if item.price > 0 then
      if item.price > money then
        love.graphics.setColor(204, 40, 40)
      end
      love.graphics.print(item.price.."$", 532-font:getWidth(item.price.."$"), 252)
    end
  end
end

return rewardscreen
