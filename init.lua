-- ============================================-- 
-- Best neovim || by: Eduuu, the best
-- =============================================

-- =============================================
-- 1. PROTECTION AND INITIALIZATION CONFIGURATIONS
-- =============================================

vim.g.loaded_perl_provider = 0

-- Prevent errors during initialization
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      local mason_ok, _ = pcall(require, "mason")
      if mason_ok then
        --print("Mason loaded successfully")
      end
    end, 1000)
  end
})

-- Error silencing system
local function setup_error_handling()
  local original_notify = vim.notify
  local original_log_error = vim.lsp.log_error
  local original_echo = vim.api.nvim_echo
  local original_err_writeln = vim.api.nvim_err_writeln

  local function should_silence_message(msg)
    if type(msg) ~= "string" then return false end
    
    local silent_patterns = {
      "The `require%('lspconfig'%)`.*framework.*deprecated",
      "require%('lspconfig'%).*framework",
      "lspconfig%.lua.*__index",
      "stack traceback:",
      "Feature will be removed in nvim%-lspconfig v3%.0%.0",
      "see :help lspconfig%-nvim%-0%.11",
      
    }
    
    for _, pattern in ipairs(silent_patterns) do
      if msg:find(pattern) then
        return true
      end
    end
    return false
  end

  -- Replace logging functions
  vim.lsp.log_error = function(err, ...)
    if should_silence_message(err) then return end
    return original_log_error(err, ...)
  end

  vim.notify = function(msg, level, opts)
    if should_silence_message(msg) then return end
    return original_notify(msg, level, opts)
  end

  vim.api.nvim_err_writeln = function(msg)
    if should_silence_message(msg) then return end
    return original_err_writeln(msg)
  end

  vim.api.nvim_echo = function(chunks, history, opts)
    if type(chunks) == "table" then
      for _, chunk in ipairs(chunks) do
        if type(chunk) == "string" and should_silence_message(chunk) then
          return
        end
      end
    end
    return original_echo(chunks, history, opts)
  end
end

-- =============================================
-- 2. BASIC VIM CONFIGURATIONS
-- =============================================

local function setup_basic_config()
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  -- Disable netrw (we use neo-tree)
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  -- Optimized general options
  local options = {
    number = true,
    relativenumber = false,
    mouse = "a",
    clipboard = "unnamedplus",
    ignorecase = true,
    smartcase = true,
    hlsearch = false,
    incsearch = true,
    wrap = false,
    breakindent = true,
    tabstop = 2,
    shiftwidth = 2,
    expandtab = true,
    smartindent = true,
    signcolumn = "yes",
    cursorline = true,
    termguicolors = true,
    completeopt = "menuone,noselect",
    updatetime = 50,
    timeoutlen = 300,
    splitright = true,
    splitbelow = true,
    scrolloff = 8,
    sidescrolloff = 8,
    swapfile = false,
    backup = false,
    undofile = true,
  }

  for k, v in pairs(options) do
    vim.opt[k] = v
  end
end

-- =============================================
-- 3. UTILITY FUNCTIONS
-- =============================================

-- Cross-platform system
local function get_os()
  if vim.fn.has('win32') == 1 then
    return 'windows'
  elseif vim.fn.has('unix') == 1 then
    if vim.fn.has('mac') == 1 then
      return 'macos'
    else
      return 'linux'
    end
  else
    return 'unknown'
  end
end

-- Cross-platform process kill function
function _G.kill_process(process_name)
  local os = get_os()
  
  if os == 'linux' or os == 'macos' then
    vim.fn.system("pkill -f " .. vim.fn.shellescape(process_name))
  elseif os == 'windows' then
    vim.fn.system("taskkill /f /im " .. vim.fn.shellescape(process_name) .. " 2>nul")
  end
end

-- Terminal system
local function create_close_button(buf)
  vim.keymap.set('n', '<leader>cx', function()
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
      print(" Terminal closed")
    end
  end, { buffer = buf, desc = "Close this terminal" })
end

-- =============================================
-- 4. DIAGNOSTIC AND SYNTAX HIGHLIGHTING RESET
-- =============================================

function _G.diagnose_syntax_issues()
  print("Diagnosing syntax highlighting issues...")
  
  -- Check Treesitter
  local ts_ok = pcall(require, "nvim-treesitter")
  if ts_ok then
    local parsers = require("nvim-treesitter.parsers").get_parser_configs()
    local current_ft = vim.bo.filetype
    local has_parser = parsers[current_ft] ~= nil
    
    print("Treesitter: " .. (ts_ok and "Loaded" or "Failed"))
    print("Current filetype: " .. (current_ft or "None"))
    print("Parser available: " .. (has_parser and "Yes" or "No"))
    
    if has_parser then
      local parser_loaded = require("nvim-treesitter.parsers").has_parser(current_ft)
      print("Parser loaded: " .. (parser_loaded and "Yes" or "No"))
    end
  else
    print("Treesitter not loaded")
  end
  
  -- Check LSP
  local clients = vim.lsp.get_active_clients()
  print("\nActive LSPs (" .. #clients .. "):")
  for _, client in ipairs(clients) do
    print("  " .. client.name .. " - " .. (client.initialized and "Initialized" or "Not initialized"))
  end
  
  -- Check theme colors
  print("\nTheme: " .. (vim.g.colors_name or "Not defined"))
end

function _G.reset_syntax_highlighting()
  print("Resetting syntax highlighting...")
  
  -- Reload current file
  vim.cmd("edit!")
  
  -- Reload Treesitter if available
  local ts_ok = pcall(require, "nvim-treesitter")
  if ts_ok then
    vim.cmd("TSDisable highlight")
    vim.cmd("TSEnable highlight")
    print("Treesitter reloaded")
  end
  
  -- Reload LSP
  local clients = vim.lsp.get_active_clients()
  for _, client in ipairs(clients) do
    vim.lsp.stop_client(client.id)
  end
  
  vim.defer_fn(function()
    vim.cmd("LspRestart")
    print("LSP restarted")
    print("Syntax highlighting reset!")
  end, 500)
end

-- =============================================
-- 5. KEYBINDINGS SYSTEM
-- =============================================

local function setup_keymaps()
  -- Your jk to ESC shortcut
  vim.keymap.set("i", "jk", "<ESC>", { noremap = true, silent = true })

  -- Professional editing shortcuts
  local edit_keymaps = {
    { 'i', '<C-BS>', '<Esc>cvb>', { noremap = true, desc = 'Delete word backwards' } },
    { 'i', '<C-H>', '<C-w>', { noremap = true, desc = 'Delete word backwards' } },
    { "i", "<C-z>", "<cmd>undo<CR>" },
    { "n", "<C-z>", "<cmd>undo<CR>" },
    { "i", "<A-CR>", "<ESC>o" },
    { 'i', '<C-Enter>', '<Esc>$a<CR>', { noremap = true, desc = 'Always new line below' } },
    { "i", "<C-s>", "<ESC><cmd>w<CR>" },
    { "n", "<C-s>", "<cmd>w<CR>" },
  }

  for _, map in ipairs(edit_keymaps) do
    vim.keymap.set(unpack(map))
  end

  -- GENERAL
  vim.keymap.set("n", "<leader>dd", "<cmd>Alpha<CR>", { desc = "Open Dashboard" })
  vim.keymap.set("n", "<leader>df", "<cmd>lua diagnose_and_fix_lsp()<CR>", { desc = "Diagnose and fix LSP" })
  vim.keymap.set('n', '<leader>as', '<cmd>lua toggle_auto_save()<CR>', { desc = 'Toggle Auto-save' })
  vim.keymap.set("n", "<leader>cm", "<cmd>lua clear_messages()<CR>", { desc = "Clear messages" })
  vim.keymap.set("n", "<leader>ds", "<cmd>lua diagnose_syntax_issues()<CR>", { desc = "Diagnose syntax" })
  vim.keymap.set("n", "<leader>rs", "<cmd>lua reset_syntax_highlighting()<CR>", { desc = "Reset syntax" })

  -- WORKSPACE
  vim.keymap.set("n", "<leader>wo", "<cmd>lua focus_project_folder()<CR>", { desc = "Open folder selector" })
  vim.keymap.set("n", "<leader>wr", "<cmd>lua reset_folder_focus()<CR>", { desc = "Reset folder focus" })
  vim.keymap.set("n", "<leader>wp", "<cmd>lua show_focused_folder()<CR>", { desc = "Show focused folder" })
  vim.keymap.set("n", "<leader>wx", "<cmd>lua open_folder_in_explorer()<CR>", { desc = "Open folder in explorer" })

  -- TERMINALS
  vim.keymap.set("n", "<leader>th", function()
    vim.cmd("belowright split")
    vim.cmd("resize 12")
    vim.cmd("terminal")
    create_close_button(vim.api.nvim_get_current_buf())
    vim.cmd("startinsert")
  end, { desc = "Open horizontal terminal" })

  vim.keymap.set("n", "<leader>tv", function()
    vim.cmd("vsplit")
    vim.cmd("terminal")
    create_close_button(vim.api.nvim_get_current_buf())
    vim.cmd("startinsert")
  end, { desc = "Open vertical terminal" })

  vim.keymap.set("n", "<leader>tt", function()
    local buf_list = vim.api.nvim_list_bufs()
    local terminal_found = false
    
    for _, buf in ipairs(buf_list) do
      if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'buftype') == 'terminal' then
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_buf(win) == buf then
            vim.api.nvim_set_current_win(win)
            vim.cmd("startinsert")
            terminal_found = true
            break
          end
        end
        break
      end
    end
    
    if not terminal_found then
      vim.cmd("belowright split")
      vim.cmd("resize 12")
      vim.cmd("terminal")
      create_close_button(vim.api.nvim_get_current_buf())
      vim.cmd("startinsert")
    end
  end, { desc = "Toggle terminal" })

  vim.keymap.set("n", "<leader>tc", function()
    local buf_list = vim.api.nvim_list_bufs()
    local closed_count = 0
    
    for _, buf in ipairs(buf_list) do
      if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'buftype') == 'terminal' then
        vim.api.nvim_buf_delete(buf, { force = true })
        closed_count = closed_count + 1
      end
    end
    
    vim.g.python_terminal_buf = nil
    print("Closed " .. closed_count .. " terminals")
  end, { desc = "Close all terminals" })

  -- JAVA (SYSTEM FROM CODE 2)
  vim.keymap.set("n", "<leader>jc", "<cmd>lua smart_java_runner()<CR>", { desc = "Java with libraries" })
  vim.keymap.set("n", "<leader>jr", "<cmd>lua quick_java_runner()<CR>", { desc = "Fast Java (no libs)" })
  vim.keymap.set("n", "<leader>jp", "<cmd>lua show_java_classpath()<CR>", { desc = "View classpath" })
  vim.keymap.set("n", "<leader>jt", "<cmd>lua java_template()<CR>", { desc = "Java template" })

  -- PYTHON
  vim.keymap.set("n", "<leader>pr", "<cmd>lua run_python_quick()<CR>", { desc = "Run Python fast" })
  vim.keymap.set("n", "<leader>pc", "<cmd>lua close_python_terminal()<CR>", { desc = "Close Python terminal" })
  vim.keymap.set("n", "<leader>pk", "<cmd>lua run_python_keep()<CR>", { desc = "Run and keep terminal" })
  vim.keymap.set("n", "<leader>pt", "<cmd>lua python_template()<CR>", { desc = "Python template" })

  -- C/C++
  vim.keymap.set("n", "<leader>cc", function()
    local current_file = vim.fn.expand("%:p")
    if string.match(current_file, "%.c$") then
      _G.compile_c()
    elseif string.match(current_file, "%.cpp$") or string.match(current_file, "%.cc$") then
      _G.compile_cpp()
    else
      print("File is not C/C++!")
    end
  end, { desc = "Compile C/C++" })

  vim.keymap.set("n", "<leader>cr", "<cmd>lua run_executable()<CR>", { desc = "Run C/C++" })
  vim.keymap.set("n", "<leader>cd", "<cmd>lua debug_with_gdb()<CR>", { desc = "Debug with GDB" })
  vim.keymap.set("n", "<leader>cn", "<cmd>lua create_c_project()<CR>", { desc = "Create C project" })
  vim.keymap.set("n", "<leader>cN", "<cmd>lua create_cpp_project()<CR>", { desc = "Create C++ project" })
  vim.keymap.set("n", "<leader>ct", "<cmd>lua c_template()<CR>", { desc = "C template" })
  vim.keymap.set("n", "<leader>cT", "<cmd>lua cpp_template()<CR>", { desc = "C++ template" })

  -- C#
  vim.keymap.set("n", "<leader>#c", "<cmd>lua compile_csharp()<CR>", { desc = "Compile C#" })
  vim.keymap.set("n", "<leader>#r", "<cmd>lua run_csharp()<CR>", { desc = "Run C#" })
  vim.keymap.set("n", "<leader>#d", "<cmd>lua debug_csharp()<CR>", { desc = "Debug C#" })
  vim.keymap.set("n", "<leader>#n", "<cmd>lua create_csharp_project()<CR>", { desc = "Create C# project" })
  vim.keymap.set("n", "<leader>#t", "<cmd>lua csharp_template()<CR>", { desc = "C# template" })

  -- NIM
  vim.keymap.set("n", "<leader>nc", "<cmd>lua compile_nim()<CR>", { desc = "Compile Nim" })
  vim.keymap.set("n", "<leader>nr", "<cmd>lua run_nim()<CR>", { desc = "Run Nim" })
  vim.keymap.set("n", "<leader>ns", "<cmd>lua run_nim_script()<CR>", { desc = "Run Nim script" })
  vim.keymap.set("n", "<leader>nd", "<cmd>lua compile_and_run_nim()<CR>", { desc = "Compile+Run Nim" })
  vim.keymap.set("n", "<leader>nn", "<cmd>lua create_nim_project()<CR>", { desc = "Create Nim project" })
  vim.keymap.set("n", "<leader>nt", "<cmd>lua nim_template()<CR>", { desc = "Nim template" })

    -- PHP
  vim.keymap.set("n", "<leader>phr", "<cmd>lua run_php()<CR>", { desc = "Run PHP in terminal" })
  vim.keymap.set("n", "<leader>phs", "<cmd>lua run_php_server()<CR>", { desc = "PHP Server Fixed" })
  vim.keymap.set("n", "<leader>phS", "<cmd>lua run_php_simple()<CR>", { desc = "PHP Ultra-Simple" })
  vim.keymap.set("n", "<leader>phq", "<cmd>lua stop_php_server()<CR>", { desc = "Stop PHP server" })
  vim.keymap.set("n", "<leader>phd", "<cmd>lua debug_php_system()<CR>", { desc = "Debug PHP system" })
  vim.keymap.set("n", "<leader>pht", "<cmd>lua php_template()<CR>", { desc = "PHP template" })
  vim.keymap.set("n", "<leader>phn", "<cmd>lua create_php_project()<CR>", { desc = "Create PHP project" })

  -- LIVE SERVER
  vim.keymap.set("n", "<leader>lss", function()
    local current_dir = vim.fn.expand("%:p:h")
    local current_file = vim.fn.expand("%:t")
    
    print("Starting SAFE Live Server...")
    
    _G.kill_process("live-server")
    
    vim.defer_fn(function()
      local job_id = vim.fn.jobstart({
        "live-server",
        current_dir,
        "--port=5500",
        "--host=localhost",
        "--browser=brave-browser",
        "--wait=300",
        "--ignore=node_modules,.git",
        "--no-css-inject",
        "--quiet"
      }, {
        detach = true,
        on_stdout = function(_, data)
          if data then
            for _, line in ipairs(data) do
              if line and line ~= "" then
                print("Live Server: " .. line)
              end
            end
          end
        end,
        on_exit = function()
          print("Live Server stopped")
        end
      })
      
      if job_id <= 0 then
        print("Error starting Live Server")
        return
      end
      
      vim.defer_fn(function()
        vim.fn.jobstart({"brave-browser", "http://localhost:5500/" .. current_file}, { 
          detach = true 
        })
      end, 2000)
      
      print("SAFE Live Server started!")
      print("Folder: " .. current_dir)
      print("URL: http://localhost:5500")
      print("Use <leader>lsq to stop the server")
      
    end, 100)
  end, { desc = "Start safe Live Server" })

  vim.keymap.set("n", "<leader>lsq", function()
    _G.kill_process("live-server")
    if vim.v.shell_error == 0 then
      print("Live Server stopped successfully!")
    else
      print("No Live Server was running")
    end
  end, { desc = "Stop Live Server" })

  vim.keymap.set("n", "<leader>lsl", function()
    local result = vim.fn.system("pgrep -f live-server")
    if result ~= "" then
      print("Live Server RUNNING - http://localhost:5500")
      print("PIDs: " .. result)
    else
      print("Live Server STOPPED - Use <leader>lss to start")
    end
  end, { desc = "Check Live Server status" })

  -- FUNCTION KEYS
  vim.keymap.set("n", "<F5>", function()
    vim.cmd("belowright split")
    vim.cmd("resize 12")
    vim.cmd("terminal")
    
    local term_buf = vim.api.nvim_get_current_buf()
    
    vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { buffer = term_buf, desc = "Exit terminal mode" })
    vim.keymap.set('t', 'jk', '<C-\\><C-n>', { buffer = term_buf, desc = "Exit terminal mode" })
    vim.keymap.set('t', '<C-q>', '<C-\\><C-n>:q<CR>', { buffer = term_buf, desc = "Close terminal" })
    
    vim.keymap.set('n', '<leader>cx', function()
      if vim.api.nvim_buf_is_valid(term_buf) then
        vim.api.nvim_buf_delete(term_buf, { force = true })
      end
    end, { buffer = term_buf, desc = "Close this terminal" })
    
    vim.cmd("startinsert")
    print("Clean terminal opened (F5)")
  end, { desc = "Open clean terminal" })

  vim.keymap.set("n", "<F6>", "<cmd>lua run_python_quick()<CR>", { desc = "Run Python" })

  vim.keymap.set("n", "<F7>", function()
    local current_file = vim.fn.expand("%:p")
    
    if string.match(current_file, "%.c$") then
      _G.compile_and_run_c()
    elseif string.match(current_file, "%.cpp$") or string.match(current_file, "%.cc$") then
      _G.compile_and_run_cpp()
    else
      print("File is not C/C++! Use F5 for general terminal.")
    end
  end, { desc = "Compile + Run C/C++" })

  -- F8 NOW RUNS JAVA WITH LIBRARIES (FROM CODE 2)
  vim.keymap.set("n", "<F8>", "<cmd>lua smart_java_runner()<CR>", { desc = "Run Java (with libs)" })

  vim.keymap.set("n", "<F9>", function()
    local current_file = vim.fn.expand("%:p")
    if string.match(current_file, "%.nim$") then
      _G.compile_and_run_nim()
    else
      print("File is not Nim! Use F5 for general terminal.")
    end
  end, { desc = "Compile+Run Nim" })

  vim.keymap.set("n", "<F10>", function()
    local current_file = vim.fn.expand("%:p")
    if string.match(current_file, "%.cs$") then
      _G.compile_and_run_csharp()
    else
      print("File is not C#! Use F5 for general terminal.")
    end
  end, { desc = "Compile+Run C#" })
end

-- =============================================
-- 6. AUTO-SAVE SYSTEM
-- =============================================

local function setup_auto_save()
  vim.g.auto_save_active = true

  function SaveIfModified()
    if vim.g.auto_save_active and vim.bo.modified then
      local filename = vim.fn.expand('%:t')
      local buftype = vim.bo.buftype
      
      -- Don't save if it's a special buffer
      if buftype ~= "" and buftype ~= "acwrite" then
        return
      end
      
      -- Don't save prompt or temporary buffers
      if string.match(filename, "java_import_prompt") or 
        vim.bo.buftype == "prompt" or 
        vim.bo.buftype == "nofile" or
        vim.bo.buftype == "nowrite" then
        return
      end
      
      if filename ~= "" then
        vim.cmd('silent write')
        print('Auto-save: ' .. filename)
      end
    end
  end

  vim.api.nvim_create_autocmd({"InsertLeave", "TextChanged", "TextChangedI"}, {
    pattern = "*",
    callback = function()
      vim.defer_fn(SaveIfModified, 500)
    end
  })

  function _G.toggle_auto_save()
    vim.g.auto_save_active = not vim.g.auto_save_active
    if vim.g.auto_save_active then
      print('Auto-save ENABLED')
    else
      print('Auto-save DISABLED')
    end
  end
end

-- =============================================
-- 7. WORKSPACE SYSTEM
-- =============================================

local function setup_workspace()
  vim.g.focused_folder = nil

  function _G.focus_project_folder()
    local os = get_os()
    local command
    
    if os == 'linux' then
      command = "zenity --file-selection --directory --title='Select a folder to focus'"
    elseif os == 'macos' then
      command = "osascript -e 'tell app \"Finder\" to choose folder with prompt \"Select a folder to focus\"'"
    elseif os == 'windows' then
      command = "powershell -Command \"Add-Type -AssemblyName System.Windows.Forms; $folder = New-Object System.Windows.Forms.FolderBrowserDialog; $folder.Description = 'Select a folder to focus'; if($folder.ShowDialog() -eq 'OK') { Write-Output $folder.SelectedPath }\""
    else
      print("Operating system not supported")
      return
    end
    
    local handle = io.popen(command)
    if handle then
      local folder_path = handle:read("*a")
      handle:close()
      
      folder_path = folder_path and vim.fn.trim(folder_path) or nil
      
      if folder_path and folder_path ~= "" then
        vim.g.focused_folder = folder_path
        vim.cmd("Neotree close")
        vim.cmd("cd " .. vim.fn.fnameescape(folder_path))
        vim.cmd("Neotree reveal filesystem " .. vim.fn.fnameescape(folder_path))
        
        print("Focused folder: " .. folder_path)
        print("Use <leader>wr to reset focus")
      else
        print("No folder selected")
      end
    else
      print("Error opening folder selector")
    end
  end

  function _G.reset_folder_focus()
    vim.g.focused_folder = nil
    local current_dir = vim.fn.getcwd()
    vim.cmd("Neotree close")
    vim.cmd("Neotree reveal")
    print("Focus reset to: " .. current_dir)
  end

  function _G.show_focused_folder()
    if vim.g.focused_folder then
      local folder_name = vim.fn.fnamemodify(vim.g.focused_folder, ":t")
      print("Focused folder: " .. vim.g.focused_folder)
      print("   Name: " .. folder_name)
    else
      print("Using current directory: " .. vim.fn.getcwd())
    end
  end

  function _G.open_folder_in_explorer()
    local os = get_os()
    local folder_to_open = vim.g.focused_folder or vim.fn.getcwd()
    
    local command
    if os == 'linux' then
      command = {"xdg-open", folder_to_open}
    elseif os == 'macos' then
      command = {"open", folder_to_open}
    elseif os == 'windows' then
      command = {"explorer", folder_to_open}
    else
      print("Operating system not supported")
      return
    end
    
    vim.fn.jobstart(command, { detach = true })
    print("Opening folder in file manager: " .. folder_to_open)
  end

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "neo-tree",
    callback = function()
      if vim.g.focused_folder then
        vim.cmd("cd " .. vim.fn.fnameescape(vim.g.focused_folder))
      end
    end
  })
end

-- =============================================
-- 8. BUFFER AND WINDOW SYSTEM
-- =============================================

local function setup_buffer_system()
  function _G.safe_buffer_close(bufnum)
    bufnum = bufnum or vim.api.nvim_get_current_buf()
    
    local current_buf = vim.api.nvim_get_current_buf()
    local buf_name = vim.api.nvim_buf_get_name(bufnum)
    
    if string.match(buf_name, "neo%-tree") then
      return
    end
    
    local valid_buffers = {}
    for _, buf in ipairs(vim.fn.getbufinfo({buflisted = 1})) do
      local name = vim.api.nvim_buf_get_name(buf.bufnr)
      if not string.match(name, "neo%-tree") and vim.api.nvim_buf_get_option(buf.bufnr, 'buftype') == '' then
        table.insert(valid_buffers, buf.bufnr)
      end
    end
    
    if #valid_buffers <= 1 then
      vim.cmd("enew")
      vim.cmd("bdelete " .. bufnum)
      return
    end
    
    if bufnum == current_buf then
      local target_buf = nil
      for _, buf in ipairs(valid_buffers) do
        if buf ~= bufnum then
          target_buf = buf
          break
        end
      end
      
      if target_buf then
        vim.api.nvim_set_current_buf(target_buf)
        vim.defer_fn(function()
          vim.cmd("bdelete " .. bufnum)
          vim.cmd("wincmd =")
        end, 20)
      end
    else
      vim.cmd("bdelete " .. bufnum)
    end
  end

  vim.keymap.set("n", "<C-w>", "<Cmd>lua safe_buffer_close()<CR>", { noremap = true, silent = true })
  vim.keymap.set("t", "<C-w>", "<C-\\><C-n><Cmd>lua safe_buffer_close()<CR>", { noremap = true, silent = true })
  vim.keymap.set("i", "<C-w>", "<Esc><Cmd>lua safe_buffer_close()<CR>", { noremap = true, silent = true })

  -- Anti-layout inversion system
  vim.api.nvim_create_autocmd("BufWinLeave", {
    callback = function(args)
      local buf = args.buf
      local buf_name = vim.api.nvim_buf_get_name(buf)
      
      if string.match(buf_name, "neo%-tree") then
        return
      end
      
      vim.defer_fn(function()
        local wins = vim.api.nvim_list_wins()
        if #wins > 1 then
          vim.cmd("wincmd =")
        end
      end, 20)
    end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    callback = function()
      vim.defer_fn(function()
        local has_neo_tree = false
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local buf_name = vim.api.nvim_buf_get_name(buf)
          if string.match(buf_name, "neo%-tree") then
            has_neo_tree = true
            break
          end
        end
        
        if not has_neo_tree then
          vim.cmd("wincmd =")
        end
      end, 10)
    end,
  })
end

-- =============================================
-- 9. LANGUAGE SYSTEMS
-- =============================================

-- Python System
local function setup_python_system()
  vim.opt.shell = "zsh"
  vim.g.python_terminal_buf = nil

  vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    callback = function(args)
      local buf = args.buf
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.opt_local.signcolumn = "no"
      vim.opt_local.cursorline = false
      
      if string.match(vim.api.nvim_buf_get_name(buf), "python") then
        vim.g.python_terminal_buf = buf
      end
      
      vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { buffer = buf, desc = "Exit terminal mode" })
      vim.keymap.set('t', 'jk', '<C-\\><C-n>', { buffer = buf, desc = "Exit terminal mode" })
      vim.keymap.set('t', '<C-q>', '<C-\\><C-n>:q<CR>', { buffer = buf, desc = "Close terminal" })
      vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>', { buffer = buf, desc = "Navigate between windows" })
    end
  })

  function _G.run_python_quick()
    local current_file = vim.fn.expand("%:p")
    
    if current_file == "" then
      print("Save the file first!")
      return
    end
    
    if not string.match(current_file, "%.py$") then
      print("This is not a Python file!")
      return
    end
    
    local python_cmd = vim.fn.executable("python3") == 1 and "python3" or "python"
    
    if vim.g.python_terminal_buf and vim.api.nvim_buf_is_valid(vim.g.python_terminal_buf) then
      vim.api.nvim_buf_delete(vim.g.python_terminal_buf, { force = true })
    end
    
    vim.cmd("belowright split")
    vim.cmd("resize 12")
    vim.cmd(string.format("terminal %s '%s'", python_cmd, current_file))
    
    local term_buf = vim.api.nvim_get_current_buf()
    vim.g.python_terminal_buf = term_buf
    create_close_button(term_buf)
    
    vim.cmd("startinsert")
    print("Running: " .. vim.fn.fnamemodify(current_file, ":t"))
  end

  function _G.close_python_terminal()
    if vim.g.python_terminal_buf and vim.api.nvim_buf_is_valid(vim.g.python_terminal_buf) then
      vim.api.nvim_buf_delete(vim.g.python_terminal_buf, { force = true })
      vim.g.python_terminal_buf = nil
      print("Python terminal closed")
    else
      print("No Python terminal open")
    end
  end

  function _G.run_python_keep()
    local current_file = vim.fn.expand("%:p")
    
    if current_file == "" then
      print("Save the file first!")
      return
    end
    
    local python_cmd = vim.fn.executable("python3") == 1 and "python3" or "python"
    
    vim.cmd("belowright split")
    vim.cmd("resize 12")
    vim.cmd(string.format("terminal %s '%s'; exec bash", python_cmd, current_file))
    
    local term_buf = vim.api.nvim_get_current_buf()
    create_close_button(term_buf)
    
    vim.cmd("startinsert")
    print("Python terminal opened: " .. vim.fn.fnamemodify(current_file, ":t"))
  end

  vim.keymap.set("v", "<leader>ps", function()
    local selected_text = vim.fn.getreg('"')
    selected_text = selected_text:gsub('\n', '\\n'):gsub('"', '\\"'):gsub('`', '\\`')
    
    vim.cmd("belowright split")
    vim.cmd("resize 8")
    vim.cmd("terminal")
    
    local python_cmd = vim.fn.executable("python3") == 1 and "python3" or "python"
    local full_cmd = string.format('%s -c "%s"', python_cmd, selected_text)
    
    vim.api.nvim_feedkeys(full_cmd, "n", false)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
    
    local term_buf = vim.api.nvim_get_current_buf()
    create_close_button(term_buf)
    
    vim.cmd("startinsert")
    print("Running selected code...")
  end, { desc = "Run selected code" })
end

-- C/C++ System
local function setup_c_cpp_system()
  -- Indentation settings for C/C++
  vim.api.nvim_create_autocmd("FileType", {
    pattern = {"c", "cpp"},
    callback = function()
      vim.bo.tabstop = 4
      vim.bo.shiftwidth = 4
      vim.bo.expandtab = false
      vim.bo.smartindent = true
    end
  })

  -- Compile C
  function _G.compile_c()
    local current_file = vim.fn.expand("%:p")
    local output_name = vim.fn.expand("%:t:r")
    local file_dir = vim.fn.expand("%:p:h")
    
    if current_file == "" then
      print("Save the file first!")
      return
    end
    
    if not string.match(current_file, "%.c$") then
      print("This is not a C file!")
      return
    end
    
    local compile_cmd = string.format("cd %s && gcc -Wall -Wextra -std=c11 -g '%s' -o '%s'", 
      vim.fn.shellescape(file_dir),
      vim.fn.shellescape(vim.fn.expand("%:t")),
      vim.fn.shellescape(output_name)
    )
    
    print("Compiling " .. vim.fn.expand("%:t") .. "...")
    vim.cmd("!" .. compile_cmd)
    print("Executable created: " .. output_name)
  end

  -- Compile C++
  function _G.compile_cpp()
    local current_file = vim.fn.expand("%:p")
    local output_name = vim.fn.expand("%:t:r")
    local file_dir = vim.fn.expand("%:p:h")
    
    if current_file == "" then
      print("Save the file first!")
      return
    end
    
    if not string.match(current_file, "%.cpp$") and not string.match(current_file, "%.cc$") then
      print("This is not a C++ file!")
      return
    end
    
    local compile_cmd = string.format("cd %s && g++ -Wall -Wextra -std=c++17 -g '%s' -o '%s'", 
      vim.fn.shellescape(file_dir),
      vim.fn.shellescape(vim.fn.expand("%:t")),
      vim.fn.shellescape(output_name)
    )
    
    print("Compiling " .. vim.fn.expand("%:t") .. "...")
    vim.cmd("!" .. compile_cmd)
    print("Executable created: " .. output_name)
  end

  -- Run C/C++ program
  function _G.run_executable()
    local current_file = vim.fn.expand("%:p")
    local output_name = vim.fn.expand("%:t:r")
    local file_dir = vim.fn.expand("%:p:h")
    
    local executable_path = file_dir .. "/" .. output_name
    
    if vim.fn.filereadable(executable_path) == 0 then
      print("Executable not found! Compile first.")
      return
    end
    
    print("Running: " .. output_name)
    
    vim.cmd("belowright split")
    vim.cmd("resize 12")
    vim.cmd("terminal cd '" .. file_dir .. "' && ./'" .. output_name .. "'")
    
    local term_buf = vim.api.nvim_get_current_buf()
    create_close_button(term_buf)
    
    vim.cmd("startinsert")
  end

  -- Compile and run in one step
  function _G.compile_and_run_c()
    local current_file = vim.fn.expand("%:p")
    
    if not string.match(current_file, "%.c$") then
      print("This is not a C file!")
      return
    end
    
    _G.compile_c()
    
    vim.defer_fn(function()
      _G.run_executable()
    end, 500)
  end

  function _G.compile_and_run_cpp()
    local current_file = vim.fn.expand("%:p")
    
    if not string.match(current_file, "%.cpp$") and not string.match(current_file, "%.cc$") then
      print("This is not a C++ file!")
      return
    end
    
    _G.compile_cpp()
    
    vim.defer_fn(function()
      _G.run_executable()
    end, 500)
  end

  -- Debug with GDB
  function _G.debug_with_gdb()
    local current_file = vim.fn.expand("%:p")
    local output_name = vim.fn.expand("%:t:r")
    local file_dir = vim.fn.expand("%:p:h")
    
    local executable_path = file_dir .. "/" .. output_name
    
    if vim.fn.filereadable(executable_path) == 0 then
      print("Executable not found! Compile first with debug flags.")
      return
    end
    
    print("Starting debug with GDB...")
    
    vim.cmd("belowright split")
    vim.cmd("resize 15")
    vim.cmd("terminal cd '" .. file_dir .. "' && gdb '" .. output_name .. "'")
    
    local term_buf = vim.api.nvim_get_current_buf()
    create_close_button(term_buf)
    
    vim.cmd("startinsert")
  end

  -- Create basic C project
  function _G.create_c_project()
    local project_name = vim.fn.input("C project name: ")
    if project_name == "" then return end
    
    vim.fn.mkdir(project_name, "p")
    vim.fn.mkdir(project_name .. "/src", "p")
    vim.fn.mkdir(project_name .. "/include", "p")
    vim.fn.mkdir(project_name .. "/build", "p")
    
    -- Create main.c file
    local main_file = io.open(project_name .. "/src/main.c", "w")
    if main_file then
      main_file:write([[
#include <stdio.h>

int main() {
    printf("Hello, World!\n");
    return 0;
}
]])
      main_file:close()
    end
    
    -- Create basic Makefile
    local makefile = io.open(project_name .. "/Makefile", "w")
    if makefile then
      makefile:write(string.format([[
CC = gcc
CFLAGS = -Wall -Wextra -std=c11 -g
SRCDIR = src
INCDIR = include
BUILDDIR = build
SOURCES = $(wildcard $(SRCDIR)/*.c)
TARGET = $(BUILDDIR)/%s

all: $(TARGET)

$(TARGET): $(SOURCES)
\t$(CC) $(CFLAGS) -I$(INCDIR) -o $(TARGET) $(SOURCES)

clean:
\trm -f $(BUILDDIR)/*

run: all
\t./$(TARGET)

debug: all
\tgdb $(TARGET)

.PHONY: all clean run debug
]], project_name))
      makefile:close()
    end
    
    vim.cmd("cd " .. project_name)
    vim.cmd("edit src/main.c")
    
    print("C project created: " .. project_name)
  end

  -- Create basic C++ project
  function _G.create_cpp_project()
    local project_name = vim.fn.input("C++ project name: ")
    if project_name == "" then return end
    
    vim.fn.mkdir(project_name, "p")
    vim.fn.mkdir(project_name .. "/src", "p")
    vim.fn.mkdir(project_name .. "/include", "p")
    vim.fn.mkdir(project_name .. "/build", "p")
    
    -- Create main.cpp file
    local main_file = io.open(project_name .. "/src/main.cpp", "w")
    if main_file then
      main_file:write([[
#include <iostream>

int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}
]])
      main_file:close()
    end
    
    -- Create basic Makefile
    local makefile = io.open(project_name .. "/Makefile", "w")
    if makefile then
      makefile:write(string.format([[
CXX = g++
CXXFLAGS = -Wall -Wextra -std=c++17 -g
SRCDIR = src
INCDIR = include
BUILDDIR = build
SOURCES = $(wildcard $(SRCDIR)/*.cpp)
TARGET = $(BUILDDIR)/%s

all: $(TARGET)

$(TARGET): $(SOURCES)
\t$(CXX) $(CXXFLAGS) -I$(INCDIR) -o $(TARGET) $(SOURCES)

clean:
\trm -f $(BUILDDIR)/*

run: all
\t./$(TARGET)

debug: all
\tgdb $(TARGET)

.PHONY: all clean run debug
]], project_name))
      makefile:close()
    end
    
    vim.cmd("cd " .. project_name)
    vim.cmd("edit src/main.cpp")
    
    print("C++ project created: " .. project_name)
  end

  -- Quick template for C
  function _G.c_template()
    local template = [[
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    printf("Hello, World!\n");
    
    return 0;
}
]]
    vim.api.nvim_put(vim.split(template, "\n"), "l", true, true)
  end

  -- Quick template for C++
  function _G.cpp_template()
    local template = [[
#include <iostream>
#include <vector>
#include <string>

using namespace std;

int main(int argc, char *argv[]) {
    cout << "Hello, World!" << endl;
    
    return 0;
}
]]
    vim.api.nvim_put(vim.split(template, "\n"), "l", true, true)
  end
end

-- 9.3 SIMPLIFIED JAVA SYSTEM (FROM CODE 2)
local function setup_java_system()
  vim.g.java_projects_path = os.getenv("HOME") .. "/Desktop/tudo/projects/Java"

  -- DETECT JAVA LIBRARIES SIMPLY
  function _G.detect_java_libraries()
    local current_dir = vim.fn.expand("%:p:h")
    local lib_dirs = {
      os.getenv("HOME") .. "/java-libraries",
      current_dir .. "/lib",
      current_dir .. "/libs",
      current_dir,
    }
    
    local found_jars = {}
    
    for _, lib_dir in ipairs(lib_dirs) do
      if vim.fn.isdirectory(lib_dir) == 1 then
        local jars = vim.fn.globpath(lib_dir, "**/*.jar", 0, 1)
        for _, jar in ipairs(jars) do
          table.insert(found_jars, jar)
        end
      end
    end
    
    return found_jars
  end

  -- MAIN JAVA RUNNER (WITH LIBS) - NOW ON F8
  function _G.smart_java_runner()
    local current_file = vim.fn.expand("%:p")
    local file_dir = vim.fn.expand("%:p:h")
    local file_name = vim.fn.expand("%:t")
    local class_name = vim.fn.expand("%:t:r")
    
    if not current_file:match("%.java$") then
      print("This is not a Java file!")
      return
    end
    
    -- Detect libraries
    local libraries = _G.detect_java_libraries()
    local classpath_parts = {"."}
    
    for _, lib in ipairs(libraries) do
      table.insert(classpath_parts, lib)
    end
    
    local classpath = table.concat(classpath_parts, ":")
    
    if #libraries > 0 then
      print(" " .. #libraries .. " library(s) detected")
    else
      print(" No additional libraries detected")
    end
    
    -- Compile
    print("Compiling " .. file_name .. "...")
    
    local compile_cmd = string.format(
      "cd '%s' && javac -cp '%s' '%s'",
      file_dir,
      classpath,
      file_name
    )
    
    local compile_result = vim.fn.system(compile_cmd)
    
    if compile_result ~= "" then
      print("Compilation error:")
      print(compile_result)
      return false
    end
    
    -- Execute
    print("Compilation successful!")
    print("Running " .. class_name .. "...")
    
    local run_cmd = string.format(
      "cd '%s' && java -cp '%s' %s",
      file_dir,
      classpath,
      class_name
    )
    
    -- Open terminal for execution
    vim.cmd("belowright split")
    vim.cmd("resize 12")
    vim.cmd("terminal " .. run_cmd)
    
    local term_buf = vim.api.nvim_get_current_buf()
    
    -- Button to close terminal
    vim.keymap.set('n', '<leader>cx', function()
      if vim.api.nvim_buf_is_valid(term_buf) then
        vim.api.nvim_buf_delete(term_buf, { force = true })
        print("Terminal closed")
      end
    end, { buffer = term_buf, desc = "Close terminal" })
    
    vim.cmd("startinsert")
    return true
  end

  -- FAST JAVA RUNNER (NO LIBS)
  function _G.quick_java_runner()
    local current_file = vim.fn.expand("%:p")
    local file_dir = vim.fn.expand("%:p:h")
    local file_name = vim.fn.expand("%:t")
    local class_name = vim.fn.expand("%:t:r")
    
    if not current_file:match("%.java$") then
      print("This is not a Java file!")
      return
    end
    
    print("Compiling " .. file_name .. "...")
    
    local compile_cmd = string.format("cd '%s' && javac '%s'", file_dir, file_name)
    local compile_result = vim.fn.system(compile_cmd)
    
    if compile_result ~= "" then
      print("Compilation error:")
      print(compile_result)
      return
    end
    
    local run_cmd = string.format("cd '%s' && java %s", file_dir, class_name)
    
    vim.cmd("belowright split")
    vim.cmd("resize 10")
    vim.cmd("terminal " .. run_cmd)
    
    local term_buf = vim.api.nvim_get_current_buf()
    
    -- Button to close terminal
    vim.keymap.set('n', '<leader>cx', function()
      if vim.api.nvim_buf_is_valid(term_buf) then
        vim.api.nvim_buf_delete(term_buf, { force = true })
        print("Terminal closed")
      end
    end, { buffer = term_buf, desc = "Close terminal" })
    
    vim.cmd("startinsert")
    print("Java executed: " .. class_name)
  end

  -- VIEW CLASSPATH (OPTIONAL)
  function _G.show_java_classpath()
    local libraries = _G.detect_java_libraries()
    
    if #libraries > 0 then
      print(" JARs in classpath (" .. #libraries .. " found):")
      for _, jar in ipairs(libraries) do
        local jar_name = vim.fn.fnamemodify(jar, ":t")
        print("   " .. jar_name)
      end
    else
      print(" No additional JARs found")
    end
  end

  -- SIMPLE JAVA TEMPLATE
  function _G.java_template()
    local template = [[
public class Main {
    public static void main(String[] args) {
        System.out.println("Hello World!");
    }
}
]]
    vim.api.nvim_put(vim.split(template, "\n"), "l", true, true)
  end
end

-- Nim System
local function setup_nim_system()
  function _G.compile_nim()
    local current_file = vim.fn.expand("%:p")
    local output_name = vim.fn.expand("%:t:r")
    local file_dir = vim.fn.expand("%:p:h")
    
    if current_file == "" then
      print("Save the file first!")
      return
    end
    
    if not string.match(current_file, "%.nim$") then
      print("This is not a Nim file!")
      return
    end
    
    local compile_cmd = string.format("cd %s && nim c --hints:off --warnings:off '%s'", 
      vim.fn.shellescape(file_dir),
      vim.fn.shellescape(vim.fn.expand("%:t"))
    )
    
    print("Compiling " .. vim.fn.expand("%:t") .. "...")
    vim.cmd("!" .. compile_cmd)
    print("Executable created: " .. output_name)
  end

  function _G.run_nim()
    local current_file = vim.fn.expand("%:p")
    local output_name = vim.fn.expand("%:t:r")
    local file_dir = vim.fn.expand("%:p:h")
    
    local executable_path = file_dir .. "/" .. output_name
    
    if vim.fn.filereadable(executable_path) == 0 then
      print("Executable not found! Compile first.")
      return
    end
    
    print("Running: " .. output_name)
    
    vim.cmd("belowright split")
    vim.cmd("resize 12")
    vim.cmd("terminal cd '" .. file_dir .. "' && ./'" .. output_name .. "'")
    
    local term_buf = vim.api.nvim_get_current_buf()
    create_close_button(term_buf)
    
    vim.cmd("startinsert")
  end

  function _G.compile_and_run_nim()
    local current_file = vim.fn.expand("%:p")
    
    if not string.match(current_file, "%.nim$") then
      print("This is not a Nim file!")
      return
    end
    
    _G.compile_nim()
    
    vim.defer_fn(function()
      _G.run_nim()
    end, 1000)
  end

  function _G.run_nim_script()
    local current_file = vim.fn.expand("%:p")
    
    if current_file == "" then
      print("Save the file first!")
      return
    end
    
    if not string.match(current_file, "%.nim$") then
      print("This is not a Nim file!")
      return
    end
    
    print("Running Nim script...")
    
    vim.cmd("belowright split")
    vim.cmd("resize 12")
    vim.cmd("terminal nim e --hints:off " .. vim.fn.shellescape(current_file))
    
    local term_buf = vim.api.nvim_get_current_buf()
    create_close_button(term_buf)
    
    vim.cmd("startinsert")
  end

  function _G.create_nim_project()
    local project_name = vim.fn.input("Nim project name: ")
    if project_name == "" then return end
    
    vim.fn.mkdir(project_name, "p")
    vim.fn.mkdir(project_name .. "/src", "p")
    
    local main_file = io.open(project_name .. "/src/main.nim", "w")
    if main_file then
      main_file:write([[
# Hello World in Nim
echo "Hello, World!"

# Function example
proc soma(a, b: int): int =
  return a + b

echo "Sum of 2 + 3 = ", soma(2, 3)
]])
      main_file:close()
    end
    
    vim.cmd("cd " .. project_name)
    vim.cmd("edit src/main.nim")
    
    print("Nim project created: " .. project_name)
  end

  function _G.nim_template()
    local template = [[
# Nim Template
# 
# Compile: nim c --hints:off file.nim
# Run: ./file

import std/[strformat, os]

proc main() =
  echo "Hello from Nim!"
  echo &"Nim Version: {NimVersion}"
  echo &"Arguments: {commandLineParams()}"
  
  for i in 1..5:
    echo &"Count: {i}"

when isMainModule:
  main()
]]
    vim.api.nvim_put(vim.split(template, "\n"), "l", true, true)
  end
end

-- FIXED PHP SYSTEM
local function setup_php_system()
  -- Specific settings for PHP files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "php",
    callback = function()
      vim.bo.tabstop = 4
      vim.bo.shiftwidth = 4
      vim.bo.expandtab = true
      print("PHP mode activated! Use <leader>phr to run in terminal")
    end
  })

  -- Run PHP file in terminal
  function _G.run_php()
    local current_file = vim.fn.expand("%:p")
    
    if current_file == "" then
      print("Save the file first!")
      return
    end
    
    if not string.match(current_file, "%.php$") then
      print("This is not a PHP file!")
      return
    end
    
    print("Running PHP in terminal...")
    
    vim.cmd("belowright split")
    vim.cmd("resize 12")
    vim.cmd("terminal php '" .. current_file .. "'")
    
    local term_buf = vim.api.nvim_get_current_buf()
    create_close_button(term_buf)
    
    vim.cmd("startinsert")
    print("PHP executed: " .. vim.fn.fnamemodify(current_file, ":t"))
  end

  -- PHP system diagnostic function
  function _G.debug_php_system()
    print("Diagnosing PHP system...")
    
    -- Check if PHP is installed
    local php_check = vim.fn.system("php -v 2>/dev/null | head -1")
    if vim.v.shell_error ~= 0 then
      print("PHP not found or not installed")
      print("Install: sudo apt install php (Linux)")
    else
      print("PHP found: " .. vim.fn.trim(php_check))
    end
    
    -- Check running PHP process
    local php_process = vim.fn.system("pgrep -f 'php -S' 2>/dev/null")
    if php_process ~= "" then
      print("PHP server running - PIDs: " .. vim.fn.trim(php_process))
    else
      print("No PHP server running")
    end
    
    -- Check current file
    local current_file = vim.fn.expand("%:p")
    if current_file ~= "" and string.match(current_file, "%.php$") then
      print("PHP file loaded: " .. vim.fn.expand("%:t"))
    else
      print("No PHP file loaded")
    end
  end

  -- FIXED PHP SERVER - Working version
  function _G.run_php_server()
    local current_file = vim.fn.expand("%:p")
    local current_dir = vim.fn.expand("%:p:h")
    local file_name = vim.fn.expand("%:t")
    
    if current_file == "" then
      print("Save the file first!")
      return
    end
    
    if not string.match(current_file, "%.php$") then
      print("This is not a PHP file!")
      return
    end
    
    print("Starting FIXED PHP server...")
    print("File: " .. file_name)
    print("Directory: " .. current_dir)
    
    -- Stop previous servers
    _G.kill_process("php")
    
    -- Check if file exists
    if vim.fn.filereadable(current_file) == 0 then
      print("File does not exist: " .. current_file)
      return
    end
    
    vim.defer_fn(function()
      -- Start PHP server in file directory
      local php_job = vim.fn.jobstart({
        "php", "-S", "localhost:8000", "-t", current_dir
      }, {
        detach = true,
        cwd = current_dir,
        on_stdout = function(_, data)
          if data then
            for _, line in ipairs(data) do
              if line and line ~= "" then
                -- Filter PHP server logs
                if not line:match("^%[.*%]") then
                  print("PHP: " .. line)
                end
              end
            end
          end
        end,
        on_stderr = function(_, data)
          if data then
            for _, line in ipairs(data) do
              if line and line ~= "" then
                print("PHP Error: " .. line)
              end
            end
          end
        end
      })
      
      if php_job <= 0 then
        print("Failed to start PHP server")
        return
      end
      
      print("Waiting for server to start...")
      
      -- Wait for server to start completely
      vim.defer_fn(function()
        local url = "http://localhost:8000/" .. file_name
        
        print("")
        print("PHP SERVER STARTED SUCCESSFULLY!")
        print("Server running in: " .. current_dir)
        print("File URL: " .. url)
        print("Access: http://localhost:8000/")
        print("")
        print("Commands:")
        print("   <leader>phq - Stop server")
        print("   <leader>phd - System debug")
        print("")
        
        -- Test if server is responding
        vim.defer_fn(function()
          local test_cmd = string.format("curl -s -o /dev/null -w '%%{http_code}' http://localhost:8000/%s 2>/dev/null", file_name)
          local test_result = vim.fn.system(test_cmd)
          test_result = vim.fn.trim(test_result)
          
          if test_result == "200" then
            print("Connection test: SUCCESS (HTTP 200)")
          else
            print("Connection test: FAILED (Code: " .. (test_result == "" and "N/A" or test_result) .. ")")
            print("Try accessing manually: " .. url)
          end
        end, 1000)
        
        -- Open in browser
        local os = get_os()
        local browser_cmd
        
        if os == 'linux' then
          browser_cmd = {"xdg-open", url}
        elseif os == 'macos' then
          browser_cmd = {"open", url}
        elseif os == 'windows' then
          browser_cmd = {"cmd", "/c", "start", url}
        else
          print("System not identified, open manually:")
          print("   " .. url)
          return
        end
        
        print("Opening browser...")
        local browser_job = vim.fn.jobstart(browser_cmd, { 
          detach = true,
          on_exit = function()
            print("Browser started!")
          end
        })
        
        if browser_job <= 0 then
          print("Could not open browser automatically")
          print("Access manually: " .. url)
        end
        
      end, 2000) -- 2 seconds for server to start
      
    end, 500)
  end

  -- Stop PHP server
  function _G.stop_php_server()
    _G.kill_process("php")
    local result = vim.fn.system("pgrep -f 'php -S' 2>/dev/null")
    if result == "" then
      print("PHP server stopped successfully!")
    else
      print("No PHP server was running")
    end
  end

  -- ULTRA-SIMPLE PHP SERVER (for debugging)
  function _G.run_php_simple()
    local current_file = vim.fn.expand("%:p")
    local current_dir = vim.fn.expand("%:p:h")
    local file_name = vim.fn.expand("%:t")
    
    print("STARTING ULTRA-SIMPLE PHP...")
    print("File: " .. file_name)
    print("Folder: " .. current_dir)
    
    -- Command to execute in terminal
    local cmd = "cd '" .. current_dir .. "' && php -S localhost:8000"
    
    print("Command: " .. cmd)
    print("URL: http://localhost:8000/" .. file_name)
    print("")
    print("Starting server... (Ctrl+C to stop)")
    
    -- Open terminal with command
    vim.cmd("belowright split")
    vim.cmd("resize 8")
    vim.cmd("terminal " .. cmd)
    
    local term_buf = vim.api.nvim_get_current_buf()
    create_close_button(term_buf)
    
    vim.cmd("startinsert")
  end

  -- PHP template
  function _G.php_template()
    local template = [[
<?php
/**
 * PHP Template
 * 
 * @author Your Name
 * @version 1.0
 */

// Error display settings
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "Hello, World!\n";

// Function example
function soma($a, $b) {
    return $a + $b;
}

// Class example
class Pessoa {
    public $nome;
    
    public function __construct($nome) {
        $this->nome = $nome;
    }
    
    public function apresentar() {
        return "Hello, my name is " . $this->nome;
    }
}

// Use of functions and classes
echo "Sum: " . soma(5, 3) . "\n";

$pessoa = new Pessoa("John");
echo $pessoa->apresentar() . "\n";

// Loop example
for ($i = 1; $i <= 5; $i++) {
    echo "Count: $i\n";
}

?>
]]
    vim.api.nvim_put(vim.split(template, "\n"), "l", true, true)
  end

  -- Create basic PHP project
  function _G.create_php_project()
    local project_name = vim.fn.input("PHP project name: ")
    if project_name == "" then return end
    
    vim.fn.mkdir(project_name, "p")
    vim.fn.mkdir(project_name .. "/src", "p")
    vim.fn.mkdir(project_name .. "/public", "p")
    vim.fn.mkdir(project_name .. "/config", "p")
    
    -- Create index.php file
    local index_file = io.open(project_name .. "/public/index.php", "w")
    if index_file then
      index_file:write([[
<?php
require_once '../src/bootstrap.php';

echo "Welcome to project ]] .. project_name .. [[!\n";
?>
]])
      index_file:close()
    end
    
    -- Create bootstrap file
    local bootstrap_file = io.open(project_name .. "/src/bootstrap.php", "w")
    if bootstrap_file then
      bootstrap_file:write([[
<?php
/**
 * Project bootstrap
 */

// Settings
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Simple autoload
spl_autoload_register(function ($class_name) {
    $file = __DIR__ . '/' . $class_name . '.php';
    if (file_exists($file)) {
        require_once $file;
    }
});

echo "System initialized!\n";
?>
]])
      bootstrap_file:close()
    end
    
    vim.cmd("cd " .. project_name)
    vim.cmd("edit public/index.php")
    
    print("PHP project created: " .. project_name)
    print("Run 'composer install' to install dependencies")
  end
end

-- C# System
local function setup_csharp_system()
  function _G.compile_csharp()
    local current_file = vim.fn.expand("%:p")
    local file_dir = vim.fn.expand("%:p:h")
    local file_name = vim.fn.expand("%:t:r")
    
    if current_file == "" then
      print("Save the file first!")
      return
    end
    
    if not string.match(current_file, "%.cs$") then
      print("This is not a C# file!")
      return
    end
    
    local compile_cmd = string.format("cd %s && dotnet build", 
      vim.fn.shellescape(file_dir)
    )
    
    print("Compiling C# project...")
    vim.cmd("!" .. compile_cmd)
    print("C# project compiled!")
  end

  function _G.run_csharp()
    local current_file = vim.fn.expand("%:p")
    local file_dir = vim.fn.expand("%:p:h")
    
    if not string.match(current_file, "%.cs$") then
      print("This is not a C# file!")
      return
    end
    
    print("Running C# project...")
    
    vim.cmd("belowright split")
    vim.cmd("resize 12")
    vim.cmd("terminal cd '" .. file_dir .. "' && dotnet run")
    
    local term_buf = vim.api.nvim_get_current_buf()
    create_close_button(term_buf)
    
    vim.cmd("startinsert")
  end

  function _G.compile_and_run_csharp()
    local current_file = vim.fn.expand("%:p")
    
    if not string.match(current_file, "%.cs$") then
      print("This is not a C# file!")
      return
    end
    
    _G.compile_csharp()
    
    vim.defer_fn(function()
      _G.run_csharp()
    end, 1000)
  end

  function _G.create_csharp_project()
    local project_name = vim.fn.input("C# project name: ")
    if project_name == "" then return end
    
    local create_cmd = string.format("dotnet new console -n %s", project_name)
    vim.cmd("!" .. create_cmd)
    
    vim.cmd("cd " .. project_name)
    vim.cmd("edit Program.cs")
    
    print("C# project created: " .. project_name)
  end

  function _G.csharp_template()
    local template = [[
using System;

namespace HelloWorld
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!");
            
            for (int i = 1; i <= 5; i++)
            {
                Console.WriteLine($"Count: {i}");
            }
        }
    }
}
]]
    vim.api.nvim_put(vim.split(template, "\n"), "l", true, true)
  end

  function _G.debug_csharp()
    local current_file = vim.fn.expand("%:p")
    local file_dir = vim.fn.expand("%:p:h")
    
    if not string.match(current_file, "%.cs$") then
      print("This is not a C# file!")
      return
    end
    
    _G.compile_csharp()
    
    print("Starting C# debug...")
    require("dap").continue()
  end
end

-- =============================================
-- 10. DIAGNOSTIC AND UTILITY FUNCTIONS
-- =============================================

local function setup_utility_functions()
  function _G.diagnose_and_fix_lsp()
    print("Diagnosing LSP...")
    
    local clients = vim.lsp.get_active_clients()
    if #clients == 0 then
      print("No active LSP")
      print("Run :Mason to install LSPs")
      return
    end
    
    print("Active LSPs:")
    for _, client in ipairs(clients) do
      local status = client.initialized and "Initialized" or "Not initialized"
      print(string.format("  %s %s", status, client.name))
    end
    
    vim.cmd("messages clear")
    print("Messages cleared")
    
    for _, client in ipairs(clients) do
      if not client.initialized then
        vim.lsp.stop_client(client.id)
        print("Restarting: " .. client.name)
      end
    end
  end

  function _G.cleanup_lsp_errors()
    local clients = vim.lsp.get_active_clients()
    for _, client in ipairs(clients) do
      if client and (client.name == "" or not client.initialized) then
        vim.lsp.stop_client(client.id, true)
      end
    end
    print("LSP cleaned!")
  end

  function _G.check_mason_status()
    local mason_ok = pcall(require, "mason")
    local mason_lsp_ok = pcall(require, "mason-lspconfig")
    
    if mason_ok and mason_lsp_ok then
      print("Mason loaded successfully!")
      print("Use :Mason to manage LSPs")
    else
      print("Mason not loaded correctly")
    end
  end

  function _G.check_lsp_status()
    local clients = vim.lsp.get_active_clients()
    
    if #clients == 0 then
      print("NO ACTIVE LSP - Auto-completion broken!")
      print("Run :MasonInstallAll")
      return
    end
    
    print("Active LSPs:")
    for _, client in ipairs(clients) do
      local status = client.initialized and "Initialized" or "Not initialized"
      print(string.format("  %s %s", status, client.name))
    end
    
    print("\nTest these features:")
    print("  • gd - Go to definition")
    print("  • K - Hover information") 
    print("  • <leader>ca - Code actions")
    print("  • <leader>fm - Format code")
  end

  function _G.clear_messages()
    vim.cmd("messages clear")
    print("Messages cleared!")
  end

  function _G.python_template()
    local template = [[
def main():
    print("Hello World!")
    
    for i in range(1, 6):
        print(f"Count: {i}")

if __name__ == "__main__":
    main()
]]
    vim.api.nvim_put(vim.split(template, "\n"), "l", true, true)
  end
end

-- =============================================
-- 11. LAZY.NVIM - PLUGIN MANAGER (FIXED)
-- =============================================

local function setup_plugins()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)

  require("lazy").setup({
    -- FIXED THEME
    {
      "catppuccin/nvim",
      lazy = false,
      priority = 1000,
      name = "catppuccin",
      config = function()
        require("catppuccin").setup({
          flavour = "mocha",
          background = {
            light = "latte",
            dark = "mocha",
          },
          transparent_background = false,
          show_end_of_buffer = false,
          term_colors = true,
          dim_inactive = {
            enabled = false,
            shade = "dark",
            percentage = 0.15,
          },
          integrations = {
            cmp = true,
            gitsigns = true,
            nvimtree = true,
            treesitter = true,
            notify = false,
            mini = false,
            mason = true,
            which_key = true,
            telescope = true,
            neo_tree = true,
            lsp_trouble = true,
            indent_blankline = true,
          }
        })
        
        -- FORCE THEME LOADING
        vim.cmd.colorscheme("catppuccin")
        
        -- Additional settings to improve visualization
        vim.opt.termguicolors = true
        vim.opt.cursorline = true
        vim.opt.cursorlineopt = "number,line"
        
        -- Reset problematic highlights
        vim.api.nvim_set_hl(0, 'LineNr', { fg = '#8b949e', bold = false })
        vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#fffb00', bold = true })
        vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#2b3339' })
        vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
        vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
      end,
    },

    -- MASON - LSP MANAGER
    {
      "williamboman/mason.nvim",
      config = function()
        require("mason").setup({
          ui = {
            icons = {
              package_installed = "✓",
              package_pending = "➜",
              package_uninstalled = "✗"
            }
          }
        })
      end,
    },

    {
      "williamboman/mason-lspconfig.nvim",
      dependencies = { "williamboman/mason.nvim" },
      config = function()
        require("mason-lspconfig").setup({
          ensure_installed = {
            "lua_ls", "pyright", "html", "cssls", "jsonls", 
            "yamlls", "bashls", "clangd", "jdtls", "nimls",
            "omnisharp", "intelephense", "phpactor"
          },
          automatic_installation = false,
        })
      end,
    },

    -- LSPCONFIG
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
      },
      config = function()
        local capabilities = require('cmp_nvim_lsp').default_capabilities()
        
        local on_attach = function(client, bufnr)
          if client and client.name ~= "null-ls" then
            local opts = { buffer = bufnr, noremap = true, silent = true }
            
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
            vim.keymap.set('n', '<leader>fm', function() 
              vim.lsp.buf.format({ async = true }) 
            end, opts)
          end
        end

        local servers = {
          "lua_ls",
          "pyright", 
          "html",
          "cssls",
          "jsonls",
          "yamlls",
          "bashls",
          "clangd",
          "tsserver",
          "jdtls",
          "nimls",
          "omnisharp",
          "intelephense",
          "phpactor"
        }

        for _, server in ipairs(servers) do
          local ok, config = pcall(require, "lspconfig." .. server)
          if ok then
            config.setup({
              on_attach = on_attach,
              capabilities = capabilities,
              settings = server == "lua_ls" and {
                Lua = {
                  diagnostics = {
                    globals = { "vim" }
                  },
                  workspace = {
                    checkThirdParty = false
                  }
                }
              } or nil
            })
          end
        end

        require("lspconfig").nimls.setup({
          on_attach = on_attach,
          capabilities = capabilities,
          settings = {
            nim = {
              nimprettyEnabled = true,
              nimlangserver = {
                quickFix = true,
                autoImport = true
              }
            }
          }
        })

        require("lspconfig").omnisharp.setup({
          on_attach = on_attach,
          capabilities = capabilities,
          cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
          enable_editorconfig_support = true,
          enable_ms_build_load_projects_on_demand = false,
          enable_roslyn_analyzers = false,
          organize_imports_on_format = true,
          enable_import_completion = true,
          sdk_include_prereleases = true,
          analyze_open_documents_only = false,
        })

        -- PHP configuration (intelephense)
        require("lspconfig").intelephense.setup({
          on_attach = on_attach,
          capabilities = capabilities,
          settings = {
            intelephense = {
              files = {
                maxSize = 5000000
              },
              environment = {
                includePaths = {"./vendor", "./node_modules"},
                phpVersion = "8.1"
              },
              diagnostics = {
                enable = true,
                run = "onSave"
              },
              format = {
                enable = true
              }
            }
          }
        })

        vim.diagnostic.config({
          virtual_text = {
            prefix = "●",
            severity = { min = vim.diagnostic.severity.WARN }
          },
          signs = true,
          underline = true,
          update_in_insert = false,
          severity_sort = true,
        })

        local signs = { Error = "E ", Warn = "W ", Hint = "H ", Info = "I " }
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end
      end,
    },

    -- FIXED TREESITTER
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          highlight = { 
            enable = true,
            additional_vim_regex_highlighting = false,
          },
          indent = { enable = true },
          auto_install = true,
          ensure_installed = {
            "lua", "python", "html", "css", "javascript", "typescript",
            "cpp", "bash", "json", "yaml", "markdown", "vim",
            "java", "nim", "c_sharp", "php"
          },
        })
        
        -- ADD THESE LINES TO FORCE LOADING:
        vim.cmd("TSEnable highlight")
        vim.cmd("TSEnable indent")
      end,
    },

    -- STATUS BAR
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require('lualine').setup({
          options = {
            theme = 'catppuccin',
            icons_enabled = true,
            component_separators = { left = '|', right = '|'},
            section_separators = { left = '', right = ''},
          },
          sections = {
            lualine_a = {'mode'},
            lualine_b = {'branch', 'diff', 'diagnostics'},
            lualine_c = {'filename'},
            lualine_x = {'encoding', 'fileformat', 'filetype'},
            lualine_y = {'progress'},
            lualine_z = {'location'}
          },
          extensions = {'neo-tree', 'lazy'}
        })
      end,
    },

    -- DASHBOARD
    {
      "goolord/alpha-nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")
        
        dashboard.section.header.val = {
          "                                                   ",
          "                                                   ",
          "                                                   ",
          "   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗   ",
          "   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║   ",
          "   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║   ",
          "   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║   ",
          "   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║   ",
          "   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║   ",
          "   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝   ",
          "                                                   ",
        }

        dashboard.section.buttons.val = {
          dashboard.button("e", "New file", ":ene <BAR> startinsert <CR>"),
          dashboard.button("p", "Select folder", "<cmd>lua focus_project_folder()<CR>"),
          dashboard.button("f", "Find files", ":Telescope find_files <CR>"),
          dashboard.button("r", "Recent files", ":Telescope oldfiles <CR>"),
          dashboard.button("g", "Find text", ":Telescope live_grep <CR>"),
          dashboard.button("c", "Configuration", ":e ~/.config/nvim/init.lua <CR>"),
          dashboard.button("m", "Manage plugins", ":Lazy<CR>"),
          dashboard.button("l", "Manage LSPs", ":Mason<CR>"),
          dashboard.button("q", "Quit", ":qa<CR>"),
        }

        dashboard.section.footer.val = "> Perfect Neovim - Made by: Eduu! <"

        alpha.setup(dashboard.config)

        vim.api.nvim_create_autocmd("User", {
          pattern = "AlphaReady",
          callback = function()
            vim.wo.winfixwidth = true
          end,
        })
      end,
    },

    -- FILE EXPLORER
    {
      "nvim-neo-tree/neo-tree.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
      },
      config = function()
        require("neo-tree").setup({
          close_if_last_window = false,
          popup_border_style = "rounded",
          enable_git_status = true,
          enable_diagnostics = true,
          filesystem = {
            filtered_items = {
              visible = false,
              hide_dotfiles = true,
              hide_gitignored = true,
            },
            follow_current_file = { enabled = false },
            use_libuv_file_watcher = true,
            bind_to_cwd = false,
            group_empty_dirs = false,
            hijack_netrw_behavior = "open_default",
          },
          window = {
            position = "left",
            width = 35,
            mappings = {
              ["<C-b>"] = "close_window",
              ["o"] = "open",
              ["<CR>"] = "open",
              ["m"] = { "show_help", nowait = false, config = { title = " Action Menu " } },
              ["a"] = { 
                "add",
                config = {
                  show_path = "relative"
                }
              },
              ["d"] = "delete",
              ["r"] = "rename",
              ["c"] = "copy_to_clipboard",
              ["x"] = "cut_to_clipboard",
              ["p"] = "paste_from_clipboard",
              ["y"] = "copy", 
              ["?"] = "show_help",
              ["H"] = "toggle_hidden",
            },
          },
        })

        function _G.stable_neo_tree_toggle()
          local current_win = vim.api.nvim_get_current_win()
          
          local neo_tree_open = false
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if string.find(buf_name, "neo%-tree") then
              neo_tree_open = true
              break
            end
          end
          
          if neo_tree_open then
            vim.cmd("Neotree close")
          else
            vim.cmd("Neotree show")
            vim.defer_fn(function()
              if vim.api.nvim_win_is_valid(current_win) then
                vim.api.nvim_set_current_win(current_win)
              end
            end, 50)
          end
        end

        vim.keymap.set("n", "<C-b>", "<cmd>lua stable_neo_tree_toggle()<CR>", 
          { desc = "Open/close explorer (stable)" })
        vim.keymap.set("n", "<leader>e", "<cmd>Neotree focus<CR>", 
          { desc = "Focus file explorer" })
      end,
    },

    -- BUFFERLINE
    {
      "akinsho/bufferline.nvim",
      dependencies = "nvim-tree/nvim-web-devicons",
      config = function()
        require("bufferline").setup({
          options = {
            mode = "buffers",
            separator_style = "thin",
            always_show_bufferline = true,
            show_close_icon = true,
            color_icon = true,
            close_command = function(bufnum)
              _G.safe_buffer_close(bufnum)
            end,
            offsets = {
              {
                filetype = "neo-tree",
                text = "File Explorer",
                highlight = "Directory",
                text_align = "left",
                padding = 1,
              }
            },
          },
        })

        vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>")
        vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>")
      end,
    },

    -- ICONS
    {
      "nvim-tree/nvim-web-devicons",
      config = function()
        require("nvim-web-devicons").setup({
          override = {
            txt = {
              icon = "T",
              color = "#89e051",
              name = "Txt"
            },
            css = {
              icon = "C", 
              color = "#61afef",
              name = "Css"
            },
            py = {
              icon = "P",
              color = "#ffd43b",
              name = "Python"
            },
            java = {
              icon = "J",
              color = "#ff0000", 
              name = "Java"
            },
            c = {
              icon = "C",
              color = "#599eff",
              name = "C"
            },
            h = {
              icon = "H",
              color = "#599eff", 
              name = "H"
            },
            cpp = {
              icon = "C+",
              color = "#f34b7d",
              name = "Cpp"
            },
            hpp = {
              icon = "H",
              color = "#f34b7d",
              name = "Hpp"
            },
            js = {
              icon = "JS",
              color = "#f7df1e",
              name = "JavaScript"
            },
            html = {
              icon = "<>",
              color = "#e44d26",
              name = "HTML"
            },
            nim = {
              icon = "N",
              color = "#ffc200",
              name = "Nim"
            },
            cs = {
              icon = "C#",
              color = "#9b4993",
              name = "CSharp"
            },
            sln = {
              icon = "S",
              color = "#9b4993",
              name = "Solution"
            },
            csproj = {
              icon = "P",
              color = "#9b4993",
              name = "CSharpProject"
            },
            php = {
              icon = "PHP",
              color = "#8993be",
              name = "PHP"
            },
          },
          default = true
        })
      end,
    },

    -- WHICH-KEY
    {
      "folke/which-key.nvim",
      config = function()
        require("which-key").setup()
      end,
    },

    -- AUTO-COMPLETION
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
      },
      config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        cmp.setup({
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
          }),
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "buffer" },
            { name = "path" },
          }),
        })

        cmp.setup.cmdline(':', {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({
            { name = 'path' }
          }, {
            { name = 'cmdline' }
          })
        })
      end,
    },

    -- AUTOPAIRS
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = function()
        local Rule = require('nvim-autopairs.rule')
        local npairs = require("nvim-autopairs")
        
        npairs.setup({
          check_ts = true,
          ts_config = {
            lua = {'string'},
            javascript = {'template_string'},
            java = false,
            c_sharp = true,
          },
          disable_filetype = { "TelescopePrompt" , "vim" },
        })

        npairs.add_rule(Rule("<", ">", "-html"))
        npairs.add_rule(Rule("<!--", "-->", "html"))
        npairs.add_rule(Rule("/*", "*/", "css"))
      end,
    },

    -- SNIPPETS
    {
      "L3MON4D3/LuaSnip",
      dependencies = { "rafamadriz/friendly-snippets" },
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },

    -- TELESCOPE
    {
      "nvim-telescope/telescope.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        require("telescope").setup()
        
        vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
        vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Find text" })
        vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
        vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Find help" })
        vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })
      end,
    },

    -- INDENT GUIDES
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      opts = {
        indent = { char = "|" },
        scope = { 
          enabled = true,
          show_start = false,
          show_end = false,
        },
      },
    },

    -- DEBUGGER
    {
      "mfussenegger/nvim-dap",
      config = function()
        local dap = require("dap")
        
        dap.adapters.coreclr = {
          type = 'executable',
          command = 'netcoredbg',
          args = {'--interpreter=vscode'}
        }

        dap.configurations.cs = {
          {
            type = "coreclr",
            name = "launch - netcoredbg",
            request = "launch",
            program = function()
              return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
            end,
          },
        }
      end,
    },
  })
end

-- =============================================
-- 12. LANGUAGE SPECIFIC CONFIGURATIONS
-- =============================================

local function setup_language_specific()
  -- Specific settings for C#
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "cs",
    callback = function()
      vim.bo.tabstop = 4
      vim.bo.shiftwidth = 4
      vim.bo.expandtab = true
      print("C# mode activated! Use F10 for quick execution")
    end
  })

  -- Specific shortcuts for C
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "c",
    callback = function()
      print("C mode activated! Use F7 to compile and run")
    end
  })

  -- Specific shortcuts for C++
  vim.api.nvim_create_autocmd("FileType", {
    pattern = {"cpp", "cc"},
    callback = function()
      print("C++ mode activated! Use F7 to compile and run")
    end
  })

  -- Specific shortcuts for Java
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function()
      vim.bo.tabstop = 4
      vim.bo.shiftwidth = 4
      vim.bo.expandtab = true
      print("Java mode activated! Use F8 for execution with libraries")
    end
  })

  -- Specific shortcuts for Nim
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "nim",
    callback = function()
      vim.bo.tabstop = 2
      vim.bo.shiftwidth = 2
      vim.bo.expandtab = true
      print("Nim mode activated! Use F9 for quick execution")
    end
  })

  -- Specific shortcuts for PHP
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "php",
    callback = function()
      vim.bo.tabstop = 4
      vim.bo.shiftwidth = 4
      vim.bo.expandtab = true
      print("PHP mode activated! Use <leader>phr to run")
    end
  })
end

-- =============================================
-- 13. INTELLIGENT DASHBOARD (FIXED)
-- =============================================

local function setup_dashboard()
  -- Variable to control if dashboard was already opened
  vim.g.dashboard_opened = false
  
  vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    callback = function()
      -- Only open if no arguments and dashboard hasn't been opened yet
      if vim.fn.argc() == 0 and not vim.g.dashboard_opened then
        vim.g.dashboard_opened = true
        
        -- Wait for plugins to load completely
        vim.defer_fn(function()
          -- Check if there are real buffers open
          local has_real_buffers = false
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted') then
              local buf_name = vim.api.nvim_buf_get_name(buf)
              if buf_name ~= "" and not string.match(buf_name, "^term://") and not string.match(buf_name, "alpha") then
                has_real_buffers = true
                break
              end
            end
          end
          
          -- Only open dashboard if no real buffers
          if not has_real_buffers then
            -- Close any empty buffers that might interfere
            local empty_buffers = {}
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted') then
                local buf_name = vim.api.nvim_buf_get_name(buf)
                if buf_name == "" then
                  table.insert(empty_buffers, buf)
                end
              end
            end
            
            -- Keep only one empty buffer if necessary
            for i, buf in ipairs(empty_buffers) do
              if i < #empty_buffers then
                vim.api.nvim_buf_delete(buf, { force = true })
              end
            end
            
            -- Open dashboard
            vim.cmd("Alpha")
            
            -- Confirm dashboard is open
            vim.defer_fn(function()
              local current_buf = vim.api.nvim_get_current_buf()
              local buf_name = vim.api.nvim_buf_get_name(current_buf)
              if not string.match(buf_name, "alpha") then
                vim.cmd("Alpha")
              end
            end, 100)
          end
        end, 100) -- Increased delay to 100ms
      end
    end
  })

  -- Simpler autocommand for when closing all buffers
  vim.api.nvim_create_autocmd("BufDelete", {
    callback = function()
      vim.defer_fn(function()
        -- Count only "real" buffers (with files)
        local real_buffers = 0
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted') then
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if buf_name ~= "" and 
               not string.match(buf_name, "^term://") and 
               not string.match(buf_name, "alpha") and
               not string.match(buf_name, "neo%-tree") then
              real_buffers = real_buffers + 1
            end
          end
        end
        
        -- If no real buffers, open dashboard
        if real_buffers == 0 and not vim.g.dashboard_opened then
          vim.g.dashboard_opened = true
          vim.cmd("Alpha")
        end
      end, 50)
    end
  })
  
  -- Reset flag when dashboard is manually closed
  vim.api.nvim_create_autocmd("BufWinLeave", {
    pattern = "*",
    callback = function(args)
      local buf_name = vim.api.nvim_buf_get_name(args.buf)
      if string.match(buf_name, "alpha") then
        vim.g.dashboard_opened = false
      end
    end
  })
end

-- =============================================
-- 14. FILETYPES DEBUG
-- =============================================

-- Filetypes debug (optional - disable if not needed)
vim.api.nvim_create_autocmd({"BufEnter", "FileType"}, {
  callback = function(args)
    local ft = vim.bo.filetype
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    
    -- Only show debug for real files (not temporary)
    if bufname ~= "" and not string.match(bufname, "^term://") then
      -- Comment line below if debug is too verbose
      -- print("File: " .. vim.fn.fnamemodify(bufname, ":t") .. " | Filetype: " .. ft)
    end
  end,
})

-- =============================================
-- MAIN INITIALIZATION
-- =============================================

local function init()
  setup_error_handling()
  setup_basic_config()
  setup_keymaps()
  setup_auto_save()
  setup_workspace()
  setup_buffer_system()
  setup_python_system()
  setup_c_cpp_system()
  setup_java_system()
  setup_nim_system()
  setup_php_system()
  setup_csharp_system()
  setup_utility_functions()
  setup_plugins()
  setup_language_specific()
  setup_dashboard()

end

init()
