local shader = {}
--
shader.cloud_shadow = love.graphics.newShader[[
    extern Image clouds;
    vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
      if(texture_coords.y-0.2 > 0.0){
        vec4 image_pixel = Texel(texture, vec2(texture_coords.x, texture_coords.y-0.2));
        vec4 cloud_pixel = Texel(clouds, texture_coords);
        if(image_pixel.a == 1.0 && cloud_pixel.a == 1.0){
          return color;
        }
      }
      return vec4(0.0, 0.0, 0.0, 0.0);
    }
  ]]

shader.shadow = love.graphics.newShader[[
    vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
      vec4 pixel = Texel(texture, texture_coords);
      if(pixel.a == 1.0){
        return color;
      }
      return vec4(0.0, 0.0, 0.0, 0.0);
    }
  ]]

return shader
