if love.filesystem then
  require 'rocks' ()
end

function love.conf(t)
  t.identity = "bubbles"
  t.version = "11.1"
  t.dependencies = {
    'hump ~> 0.4'
  }
end
