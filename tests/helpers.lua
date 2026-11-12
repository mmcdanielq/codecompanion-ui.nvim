local assert = require('luassert')

local M = {}

---Close every codecompanion chat, then close every window but one and wipe all buffers.
function M.reset_editor()
  local cc = require('codecompanion')
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == 'codecompanion' then
      local chat = cc.buf_get_chat(bufnr)
      if chat then
        pcall(chat.close, chat)
      end
    end
  end
  M.flush()
  vim.cmd('silent! only!')
  vim.cmd('silent! %bwipeout!')
  require('codecompanion-ui.state').sessions = {}
  require('codecompanion-ui.state').active_session_id = nil
end

---Let scheduled callbacks (vim.schedule / WinClosed handlers) run.
function M.flush()
  vim.wait(50, function()
    return false
  end)
end

---Toggle the chat open/closed and flush scheduled callbacks.
function M.toggle()
  require('codecompanion').toggle()
  M.flush()
end

---Number of windows in the current tab showing a buffer with the given filetype.
---@param ft string
---@return number
function M.count_wins(ft)
  local n = 0
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == ft then
      n = n + 1
    end
  end
  return n
end

---Number of valid buffers with the given filetype.
---@param ft string
---@return number
function M.count_bufs(ft)
  local n = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == ft then
      n = n + 1
    end
  end
  return n
end

---Assert exactly one chat window and one input window are visible.
function M.assert_open()
  assert.equals(1, M.count_wins('codecompanion'), 'expected one chat window')
  assert.equals(1, M.count_wins('codecompanion_input'), 'expected one input window')
end

---Assert neither the chat nor the input window is visible.
function M.assert_closed()
  assert.equals(0, M.count_wins('codecompanion'), 'expected no chat window')
  assert.equals(0, M.count_wins('codecompanion_input'), 'expected no input window')
end

---The active session, asserting one exists.
---@return CcuiSession
function M.session()
  local session = require('codecompanion-ui.state').active()
  assert.is_not_nil(session, 'expected an active session')
  return session --[[@as CcuiSession]]
end

---A window in the current tab that is neither the chat nor the input window.
---@param session CcuiSession
---@return number
function M.other_win(session)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= session.chat_winid and win ~= session.input_winid then
      return win
    end
  end
  error('no other window found')
end

---Run `:quit` in the given window and flush scheduled callbacks.
---@param win number
function M.quit_win(win)
  vim.api.nvim_set_current_win(win)
  vim.cmd('quit')
  M.flush()
end

return M
