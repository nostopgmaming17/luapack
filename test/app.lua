local hello = require"utils/hello"

local app = {ver = 1.1}

function app:init()
  print("RUNNING APP VER"..self.ver)
end
function app:start()
  hello:sayHello();
end

return app