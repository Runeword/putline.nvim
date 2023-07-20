local vim = vim

local M = {}

local function getRegister(command)
  local register = {}
  register.name = command:match('^"(.)') or vim.v.register
  register.contents = vim.fn.getreg(register.name)
  register.type = vim.fn.getregtype(register.name)
  return register
end

local function putLinewise(command)
  local register = getRegister(command)
  local str = register.contents

  vim.fn.setreg(register.name, str, "V")                                        -- Set register linewise
  vim.fn.execute("normal! " .. vim.v.count1 .. '"' .. register.name .. command) -- Put register
  vim.fn.setreg(register.name, register.contents, register.type)                -- Restore register
end

local function putCharwise(command)
  local register = getRegister(command)
  local str

  -- If register type is blockwise-visual then put as usual
  if register.type ~= "V" and register.type ~= "v" then
    vim.fn.execute("normal! " .. vim.v.count1 .. '"' .. register.name .. command)
    return
  end

  -- If register type is linewise then remove spaces at both extremities
  if register.type == "V" then
    str = register.contents:gsub("^%s*(.-)%s*$", "%1")
  else
    str = register.contents
  end

  vim.fn.setreg(register.name, str, "v")                                        -- Set register charwise
  vim.fn.execute("normal! " .. vim.v.count1 .. '"' .. register.name .. command) -- Put register
  vim.fn.setreg(register.name, register.contents, register.type)                -- Restore register
end

function M.putCharwise(command)
  return function() putCharwise(command) end
end

function M.putLinewise(command)
  return function() putLinewise(command) end
end

return M
