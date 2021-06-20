local vim = vim
local tmux = require("tmux.wrapper")

local function winnr(direction)
	return vim.api.nvim_call_function("winnr", { direction })
end

local function wincmd(direction)
	return vim.api.nvim_command("wincmd " .. direction)
end

local function is_only_window()
	return (winnr("1h") == winnr("1l")) == (winnr("1j") == winnr("1k"))
end

local function is_tmux_target(border)
	return tmux.is_tmux and tmux.has_neighbor(border) or is_only_window()
end

local function resize_to(direction)
	local current = winnr()
	if direction == "h" then
		local is_border = current == winnr("1l")
		if is_border and is_tmux_target("l") then
			tmux.resize("h")
		elseif is_border then
			wincmd(">")
		else
			wincmd("<")
		end
	elseif direction == "j" then
		local is_border = current == winnr("1j")
		if is_border and is_tmux_target("j") then
			tmux.resize("j")
		elseif is_border and current ~= winnr("1k") then
			wincmd("-")
		else
			wincmd("+")
		end
	elseif direction == "k" then
		local is_border = current == winnr("1j")
		if is_border and is_tmux_target("j") then
			tmux.resize("k")
		elseif is_border then
			wincmd("+")
		else
			wincmd("-")
		end
	elseif direction == "l" then
		local is_border = current == winnr("1l")
		if is_border and is_tmux_target("l") then
			tmux.resize("l")
		elseif is_border then
			wincmd("<")
		else
			wincmd(">")
		end
	end
end


local M = {}
M.to_left = function()
	resize_to("h")
end

M.to_bottom = function()
	resize_to("j")
end

M.to_top = function()
	resize_to("k")
end

M.to_right = function()
	resize_to("l")
end

return M
