local api = vim.api

local function getBufnrByPath(path)
  local bufnr = vim.fn.bufnr('^' .. path .. '$')

  return -1 ~= bufnr and bufnr or nil
end

local function getFirstWinIdByBufnr(bufNr)
  if nil == bufNr then
    return nil
  end

  local ids = vim.fn['win_findbuf'](bufNr)

  return ids[1] or nil
end

local function bufferIsFresh(bufNr)
  return '' == api.nvim_buf_get_name(bufNr) and api.nvim_buf_get_changedtick(bufNr) <= 2
end

local function tabDropPath(path, relativeWinId)
  local filename = vim.fn.fnamemodify(path, ':p')

  local bufNr = getBufnrByPath(filename) or vim.fn.bufadd(filename)
  local existingWinId = getFirstWinIdByBufnr(bufNr)

  if nil ~= existingWinId then
    api.nvim_set_current_win(existingWinId)

    return
  end

  relativeWinId = relativeWinId or vim.fn.win_getid()
  local relativeBufId = api.nvim_win_get_buf(relativeWinId)

  if bufferIsFresh(relativeBufId) then
    vim.bo[bufNr].buflisted = true
    api.nvim_win_set_buf(relativeWinId, bufNr)
    api.nvim_set_current_win(relativeWinId)
    api.nvim_buf_delete(relativeBufId, {})

    return
  end

  vim.cmd.tabedit(filename)
end

local function markAsPreviousPos()
  vim.cmd.normal({bang = true, args = {"m'"}})
end

local function addCurrentPosToTagstack()
  local curLine, curColumn = unpack(api.nvim_win_get_cursor(0))
  local from = {api.nvim_get_current_buf(), curLine, curColumn + 1, 0}
  local items = {{tagname = vim.fn.expand('<cword>'), from = from}}
  vim.fn.settagstack(api.nvim_get_current_win(), {items = items}, 't')
end

local function tabDrop(path, line, column, relativeWinId)
  markAsPreviousPos()
  addCurrentPosToTagstack()

  tabDropPath(path, relativeWinId)

  if nil == line then
    return
  end

  local ok, result = pcall(api.nvim_win_set_cursor, 0, {line, (column or 1) - 1})
  if not ok then
    vim.notify(('%s: line %s, col %s'):format(result, line, column), vim.log.levels.WARN, {title = 'tab drop'})
  end
end

return setmetatable({}, {
  __call = function (_, ...)
    return tabDrop(...)
  end,
})
