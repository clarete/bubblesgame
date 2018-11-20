function tablekeys(t)
  local keyset = {}
  local n = 0
  for k,v in pairs(t) do
    n = n+1
    keyset[n] = k
  end
  return keyset
end

function tableprint(t)
  print("{")
  for k, v in pairs(t) do
    print((" %s: %s"):format(k, v))
  end
  print("}")
end

function tablecat(t1, t2)
  for _, v in ipairs(t2) do
    table.insert(t1, v)
  end
  return t1
end

local function startswith(s, start)
  return s:sub(1, #start) == start
end

return {
  tkeys=tablekeys,
  tprint=tableprint,
  tcat=tablecat,
  sswith=startswith,
}
