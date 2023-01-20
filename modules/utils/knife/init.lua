local PATH = (...):gsub('%.init$', '')
local knife = {}

knife.base = require(PATH..".base")
knife.behavior = require(PATH..".behavior")
knife.bind= require(PATH..".bind")
knife.chain = require(PATH..".chain")
knife.convoke = require(PATH..".convoke")
knife.event = require(PATH..".event")
--knife.gun = require(PATH..".gun")
knife.memoize = require(PATH..".memoize")
knife.serialize = require(PATH..".serialize")
knife.system = require(PATH..".system")
knife.test = require(PATH..".test")
knife.timer = require(PATH..".timer")

return knife