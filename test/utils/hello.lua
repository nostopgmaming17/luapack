local app = require"app"
local hello = {}

function hello:sayHello()
    print("Hello, World!",app.ver)
end

return hello