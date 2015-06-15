-- inspired by store.js https://github.com/marcuswestin/store.js/

local _ = require 'shim'
local json = require 'cjson'

-- https://github.com/openresty/lua-nginx-module/#lua_shared_dict
-- https://github.com/openresty/lua-nginx-module/#ngxshareddict
-- nginx -s reload won't clear the shared memory, start will

local cache = ngx.shared.store
assert(cache, 'Need to add `lua_shared_dict store 10m;` in nginx.conf http context first!')

local function decode(str)
	local ok, ret = pcall(json.decode, str)
	if ok then return ret end
	return str
end

local function encode(val)
	local ok, ret = pcall(json.encode, val)
	if ok then return ret end
	return tostring(val)
end

local function runInContext(ctx)
	ctx = ctx or {}
	local ns = ctx.namespace or ''

	local store = {}

	store.runInContext = runInContext

	store.get = function(key)
		key = ns .. key
		local val = cache:get(key)
		return decode(val)
	end

	store.set = function(key, val, expireSeconds)
		-- always overwrite if exist
		val = encode(val)
		key = ns .. key
		if expireSeconds then
			cache:set(key, val, expireSeconds)
		else
			cache:set(key, val)
		end
		return val -- store.js return val, not chain
	end

	store.incr = function(key, val)
		key = ns .. key
		local ret = cache:incr(key, val) -- return ret, err
		return ret -- always return one result
	end

	store.remove = function(key)
		key = ns .. key
		cache:delete(key)
	end

	store.clear = function()
		cache:flush_all()
	end

	store.keys = function(max)
		return cache:get_keys(max or 1024) -- default 1024, or crash
	end

	store.getAll = function()
		local keys = store.keys()
		return _.reduce(keys, function(ret, key)
			ret[key] = store.get(key)
			return ret
		end, {})
	end

	_.extend(store, ctx)

	return store
end


return runInContext()
