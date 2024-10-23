-- Disable LSP warning for undefined global 'vim'
---@diagnostic disable: undefined-global

local M = {}

-- Helper function to run Python script synchronously and capture output
local function run_python_script(json_data)
    local python_script_path = "../../src/__init__.py"
    local python_cmd = "python3 " .. python_script_path

    -- Run the Python script synchronously and capture its output
    local handle = assert(io.popen(python_cmd, "w")) -- Open with write mode to pass data
    handle:write(json_data)
    handle:close()

    -- Capture and return the output from the Python script
    local result = handle:read("*a")
    return result
end

-- Show graph and open the file in Vim if one is returned
function M.show_graph()
    -- Start the zk graph command and capture the output
    local command = "zk graph --quiet --format=json"
    local result = vim.fn.system(command)

    -- Check for errors in the result
    if vim.v.shell_error ~= 0 then
        print("Error running zk graph: ", result)
        return
    end

    -- Process the result and pass it to the Python script
    local file = run_python_script(result)

    -- Check if a file was returned by the Python script
    if file and file ~= "" then
        -- Remove trailing newlines
        file = file:gsub("%s+$", "")

        -- Get ZK_NOTEBOOK_DIR from the environment variable
        local zk_notebook_dir = os.getenv("ZK_NOTEBOOK_DIR")

        if zk_notebook_dir and zk_notebook_dir ~= "" then
            -- Build the full file path and open it in Neovim
            local full_file_path = zk_notebook_dir .. "/" .. file
            vim.api.nvim_command("silent! edit " .. full_file_path)
        else
            print("ZK_NOTEBOOK_DIR is not set or is empty.")
        end
    else
        print("No file selected or returned.")
    end
end

return M
