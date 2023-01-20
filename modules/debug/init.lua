local debug = {}

local libPath = (...):gsub('%.init$', '')
debug = require(libPath ..".debug");



return debug