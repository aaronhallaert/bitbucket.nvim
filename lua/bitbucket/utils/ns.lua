local M = {}
M.global = vim.api.nvim_create_namespace("bitbucket")
M.thread = vim.api.nvim_create_namespace("bitbucket_thread")
return M
