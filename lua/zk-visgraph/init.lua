-- Disable LSP warning for undefined global 'vim'
---@diagnostic disable: undefined-global

-- Creates an object for the module. All of the module's
-- functions are associated with this object, which is
-- returned when the module is called with `require`.
local M = {}

-- Helper function to run Python script with the JSON input
local function run_python_script(json_data)
    -- Specify the path to your Python script
    local python_script_path = "../../src/__init__.py"

    -- Open a process to run the Python script
    local python_cmd = "python3 " .. python_script_path
    local handle = assert(io.popen(python_cmd, "w")) -- Open with write mode to pass data

    -- Write the JSON data to the Python script's standard input
    handle:write(json_data)
    handle:close()

    -- Capture the Python script output
    local result = handle:read("*a")
    return result
end

-- Show graph and open the file in Vim if one is returned
function M.show_graph()
    -- Run `zk graph --format=json` and capture the output
    local zk_graph_output = execute_command("zk graph --format=json")

    -- Pass the JSON output to the Python script
    local file = run_python_script(zk_graph_output)

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
