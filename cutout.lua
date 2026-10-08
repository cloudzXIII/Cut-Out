CUTOUT = SMODS.current_mod
CUTOUT.description_loc_vars = function()
  return { background_colour = G.C.CLEAR, text_colour = G.C.WHITE, scale = 1.2, shadow = true }
end

function CUTOUT.recursive_load(path)
  local files = NFS.getDirectoryItems(ASAS.path .. path)
  table.sort(files)
  for _, item in ipairs(files) do
    if string.sub(item, -4) == ".lua" then
      local f, err = SMODS.load_file(path .. "/" .. item)
      if err then
        error(err)
      elseif f then
        f()
      end
    elseif path:find("%.") == nil then
      CUTOUT.recursive_load(path .. "/" .. item)
    end
  end
end

--[[
Usage for the above function would be:
CUTOUT.recursive_load("content")
(loads everything including subfolders for any given directory)
]]
