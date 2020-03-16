local lib={}

function lib.isKey(k, t)
  for n, v in pairs(t) do
    if n == k then return v end
  end
  return nil
end

return lib
