-- Disable LSP warning for undefined global 'vim'
---@diagnostic disable: undefined-global

-- Creates an object for the module. All of the module's
-- functions are associated with this object, which is
-- returned when the module is called with `require`.
local M = {}

-- Helper function to read the output of a command
local function execute_command(cmd)
    local handle = io.popen(cmd)
    if handle == nil then
        return nil, "Failed to execute command: " .. cmd
    end
    local result = handle:read("*a")
    handle:close()
    return result
end

-- Show graph and open the file in Vim if one is returned
function M.show_graph()
    -- Run `zk graph --format=json` and capture the output
    local zk_graph_output = execute_command("zk graph --format=json")

    -- Pass the JSON output to the Python script and capture its output
    local python_script_path = "../../src/__init__.py"
    local python_command = "python3 " .. python_script_path
    local file = execute_command("echo '" .. zk_graph_output .. "' | " .. python_command)

    -- Check if a file was returned by the Python script
    if file and file ~= "" then
        -- Remove any trailing newline characters
        file = file:gsub("%s+$", "")
        -- Get ZK_NOTEBOOK_DIR from the environment variable
        local zk_notebook_dir = os.getenv("ZK_NOTEBOOK_DIR")

        if zk_notebook_dir and zk_notebook_dir ~= "" then
            -- Build the full path to the file
            local full_file_path = zk_notebook_dir .. "/" .. file

            -- Open the file in Neovim
            vim.api.nvim_command("edit " .. full_file_path)
        else
            print("ZK_NOTEBOOK_DIR is not set or is empty.")
        end
    else
        print("No file selected or returned.")
    end
end

return M
