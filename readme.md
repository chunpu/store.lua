store.lua
===

Store lib for [lua-nginx](https://github.com/openresty/lua-nginx-module/) like openresty

Use it like localStorage in browser, and never to care multi workers thing in nginx, store.lua is **uniq** and **global**

inspired by [store.js](https://github.com/marcuswestin/store.js/)

Usage
---

Add `lua_shared_dict store 10m;` in nginx.conf http context first

```lua
local store = require 'store'

store.set('foo', {
	key = 'bar'
})

store.get('foo')
-- => {key = 'bar'}
```

Api
---

- `store.set(key, value[, expire])` value can be table, json, num, string ...
- `store.get(key)`
- `store.remove(key)`
- `store.clear()` clear all
- `store.keys()` get all keys in store
- `store.getAll()` return a table, get all in store

TODO
---

- [] add getter and setter for store
