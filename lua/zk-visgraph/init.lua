-- Disable LSP warning for undefined global 'vim'
---@diagnostic disable: undefined-global

local M = {}

-- Helper function to run a command asynchronously and capture output
local function run_python_script_async(json_data, callback)
    -- Specify the path to your Python script
    local python_script_path = "../../src/__init__.py"
    local python_cmd = {"python3", python_script_path}

    -- Create a pipe for stdin to pass the JSON data
    local stdin = vim.loop.new_pipe(false)
    local stdout = vim.loop.new_pipe(false)
    local stderr = vim.loop.new_pipe(false)

    -- Buffer to capture the stdout output
    local result = {}

    -- Spawn the Python process
    local handle
    handle = vim.loop.spawn(python_cmd[1], {
        args = {python_script_path},
        stdio = {stdin, stdout, stderr},
    },
    function(code)
        -- Process exit, close the handles
        stdout:close()
        stderr:close()
        stdin:close()

        -- Invoke the callback with the result if successful
        if code == 0 then
            callback(table.concat(result, ""))
        else
            callback(nil, "Error: Python process exited with code " .. code)
        end

        handle:close()
    end)

    -- Write the JSON data to stdin and close the pipe
    stdin:write(json_data)
    stdin:close()

    -- Read from stdout
    stdout:read_start(function(err, data)
        assert(not err, err)
        if data then
            table.insert(result, data)
        end
    end)

    -- Read from stderr (optional, useful for debugging)
    stderr:read_start(function(err, data)
        assert(not err, err)
        if data then
            print("Python error: ", data)
        end
    end)
end

-- Show graph and open the file in Vim if one is returned
function M.show_graph()
    -- Run `zk graph --format=json` and capture the output synchronously
    local function execute_command(cmd)
      -- Redirect stderr to /dev/null as `zk` outputs the `Found * notes` to stderr
      local handle = io.popen(cmd .. " 2>/dev/null")
        if not handle then
            return nil, "Error: Unable to execute command: " .. cmd
        end
        local result = handle:read("*a")
        handle:close()
        return result
    end

    local zk_graph_output = execute_command("zk graph --format=json --quiet")

    -- Run the Python script asynchronously and wait for the output
    run_python_script_async(zk_graph_output, function(file, err)
        if err then
            print(err)
            return
        end

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
    end)
end

return M
