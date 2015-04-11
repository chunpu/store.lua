-- init_worker_by_lua_file lua/timer.lua;

-- do things like cron job, but ignore worker number

local store = require 'store'

local interval = 2

local function timer()
	local prev = store.get('prev') or 0
	local now = ngx.now()
	ngx.timer.at(interval, timer)

	if now - prev < interval - 0.01 then
		return
	end

	-- thing
	store.set('prev', now)
	ngx.log(ngx.ERR, 'master: timer run', ngx.worker.pid(), 'now', now)
end

timer()

local function setInterval(func, interval)
	-- TODO
end
