# Generates modules.lua for intellua
# Run this from the Repository directory

for dir in *; do
	if [ -d $dir ]; then
		cd $dir
		git fetch -a >/dev/null 2>&1
		git checkout Windows-x86 >/dev/null 2>&1
		cd ..
	fi
done

find . -type f | grep lib/lua | lua -e '
local modules = {}
for f in io.lines() do
	-- parse [package]/lib/lua/[file] to module name
	local package, mod = f:match("./([^/]+)/lib/lua/(.+)$")
	if package then
		mod = mod:gsub("/", "."):gsub(".lua", ""):gsub(".dll", "")
		if modules[mod] then
			if type(modules[mod])=="string" then
				modules[mod] = {modules[mod]}
			end
			table.insert(modules[mod], package)
		else
			modules[mod] = package
		end
	end
end

local w = io.write
local keys = {}
for k in pairs(modules) do keys[#keys + 1] = k end
table.sort(keys)

w"-- This file is automatically generated\n"
w"return {\n"
for _,k in ipairs(keys) do
	if not k:match("^[a-zA-Z]+$") then w("[\"",k,"\"] = ") else w(k, " = ") end
	local package = modules[k]
	if type(package) == "string" then
		w("\"", package, "\",\n")
	else
		for i=1,#package do package[i] = string.format("%q", package[i]) end
		w("{ ", table.concat(package, ", "), " },\n")
	end
end
w"}\n"
' > modules.lua