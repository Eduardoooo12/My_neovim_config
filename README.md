# My Neovim Config

Transform your Neovim into a complete IDE without the complexity of manual configurations!

## 🎯 Who Is This Configuration For?

- **Full-Stack Developers** working with multiple languages
- **Programming Students** needing a ready-to-use environment  
- **Professionals** who value productivity and efficiency
- **Vim Enthusiasts** wanting a modern experience

## ✨ Key Features

### 🎯 Maximum Productivity

- Smart dashboard with quick access to projects and settings
- Workspace system for focused folder management
- Intelligent auto-save that automatically preserves your work
- Intuitive keymaps designed for maximum efficiency

### 💻 Multi-Language Support

- ☕ **Java** - Smart compilation with automatic library detection
- 🐍 **Python** - Fast execution with dedicated terminal
- 🅒 **C/C++** - Complete compilation and debug system
- ⚡ **C#** - .NET integration and debugging
- 🐍 **Nim** - Optimized compilation and execution
- 🐘 **PHP** - Integrated web server and execution
- 🌐 **Web** - Live Server for HTML/CSS/JS

### 🛠 Professional Tools

- **LSP (Language Server Protocol)** - Intelligent auto-completion
- **Mason** - Universal manager for LSPs, linters, and formatters
- **Treesitter** - Advanced syntax highlighting
- **Telescope** - Fast file and content search
- **Neo-tree** - Modern and efficient file explorer
- **Integrated Debugger** - Debugging support with nvim-dap

### 🎨 Visual Experience

- **Catppuccin Theme** - Modern and elegant interface
- **Custom status bar** with lualine
- **Devicons** for better file identification
- **Bufferline** for efficient tab navigation

## 🎮 Complete Keybinding System

### ⌨️ Editing Shortcuts

| Shortcut | Mode | Description |
|----------|------|-------------|
| `jk` | Insert | Exit insert mode |
| `<C-BS>` | Insert | Delete previous word |
| `<C-H>` | Insert | Delete previous word |
| `<C-z>` | Insert/Normal | Undo |
| `<A-CR>` | Insert | New line below |
| `<C-Enter>` | Insert | Always new line below |
| `<C-s>` | Insert/Normal | Save file |

### 🏠 Navigation & Interface

| Shortcut | Description |
|----------|-------------|
| `<leader>dd` | Open Dashboard |
| `<leader>df` | Diagnose and fix LSP |
| `<leader>as` | Toggle Auto-save |
| `<leader>cm` | Clear messages |
| `<C-b>` | Toggle file explorer (Neo-tree) |
| `<leader>e` | Focus file explorer |
| `<Tab>` | Next buffer |
| `<S-Tab>` | Previous buffer |
| `<C-w>` | Safe buffer close |

### 📁 Workspace System

| Shortcut | Description |
|----------|-------------|
| `<leader>wo` | Open folder selector |
| `<leader>wr` | Reset folder focus |
| `<leader>wp` | Show focused folder |
| `<leader>wx` | Open folder in explorer |

### 🖥️ Terminal System

| Shortcut | Description |
|----------|-------------|
| `<leader>th` | Open horizontal terminal |
| `<leader>tv` | Open vertical terminal |
| `<leader>tt` | Toggle terminal |
| `<leader>tc` | Close all terminals |
| `<leader>cx` | Close current terminal |

### ☕ Java System

| Shortcut | Description |
|----------|-------------|
| `<leader>jc` | Compile/Run Java (with libs) |
| `<leader>jr` | Quick Java (no libs) |
| `<leader>jp` | Show classpath |
| `<leader>jd` | Compile for debug |
| `<leader>jn` | Create Java project |
| `<leader>jt` | Java template |
| `<F8>` | Quick Java test |

### 🐍 Python System

| Shortcut | Description |
|----------|-------------|
| `<leader>pr` | Quick Python execution |
| `<leader>pc` | Close Python terminal |
| `<leader>pk` | Run and keep terminal |
| `<leader>ps` | Run selected code |
| `<leader>pt` | Python template |
| `<F6>` | Run Python |

### 🅒 C/C++ System

| Shortcut | Description |
|----------|-------------|
| `<leader>cc` | Compile C/C++ |
| `<leader>cr` | Run C/C++ |
| `<leader>cd` | Debug with GDB |
| `<leader>cn` | Create C project |
| `<leader>cN` | Create C++ project |
| `<leader>ct` | C template |
| `<leader>cT` | C++ template |
| `<F7>` | Compile + Run C/C++ |

### ⚡ C# System

| Shortcut | Description |
|----------|-------------|
| `<leader>#c` | Compile C# |
| `<leader>#r` | Run C# |
| `<leader>#d` | Debug C# |
| `<leader>#n` | Create C# project |
| `<leader>#t` | C# template |
| `<F10>` | Compile + Run C# |

### 🐍 Nim System

| Shortcut | Description |
|----------|-------------|
| `<leader>nc` | Compile Nim |
| `<leader>nr` | Run Nim |
| `<leader>ns` | Run Nim script |
| `<leader>nd` | Compile+Run Nim |
| `<leader>nn` | Create Nim project |
| `<leader>nt` | Nim template |
| `<F9>` | Compile+Run Nim |

### 🐘 PHP System

| Shortcut | Description |
|----------|-------------|
| `<leader>phr` | Run PHP in terminal |
| `<leader>phs` | Fixed PHP Server |
| `<leader>phS` | Ultra-Simple PHP |
| `<leader>phq` | Stop PHP server |
| `<leader>phd` | PHP system debug |
| `<leader>pht` | PHP template |
| `<leader>phn` | Create PHP project |

### 🌐 Live Server

| Shortcut | Description |
|----------|-------------|
| `<leader>lss` | Start secure Live Server |
| `<leader>lsq` | Stop Live Server |
| `<leader>lsl` | Check Live Server status |

### 🔍 Search & Navigation

| Shortcut | Description |
|----------|-------------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Help tags |
| `<leader>fr` | Recent files |

### 🛠️ LSP & Development

| Shortcut | Description |
|----------|-------------|
| `gd` | Go to definition |
| `K` | Hover information |
| `gr` | References |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename |
| `<leader>fm` | Format code |

### 🎯 Function Keys

| Key | Description |
|-----|-------------|
| `<F5>` | Open clean terminal |
| `<F6>` | Run Python |
| `<F7>` | Compile + Run C/C++ |
| `<F8>` | Quick Java test |
| `<F9>` | Compile+Run Nim |
| `<F10>` | Compile+Run C# |

## 🚀 Quick Installation

### Step 1:

**FOR LINUX OR MACOS**

```
# Create directory if it doesn't exist
mkdir -p ~/.config/nvim
```

Direct Clone (Recommended)
```
git clone https://github.com/Eduardoooo12/My_neovim_config ~/.config/nvim
```

**FOR WINDOWS**

```
# Clone to Neovim directory
git clone https://github.com/Eduardoooo12/My_neovim_config $env:LOCALAPPDATA\nvim
```


### Step 2: Install system dependencies

**For Ubuntu/Debian:**
```
sudo apt update
sudo apt install neovim git curl build-essential
```

**For macOS:**
```
brew install neovim git curl
```

**For Windows:**
**Install Chocolatey first, then:**
```
# Via Chocolatey
choco install neovim
```

```
# Or via Winget
winget install Neovim.Neovim
```

### Step 3: Start Neovim
```
nvim
```
Plugins will install automatically. Wait for the process to complete.

## 📋 Complete Language Setup

### Install Development Tools

**Ubuntu/Debian:**
```
sudo apt install gcc g++ make python3 python3-pip nodejs npm
sudo apt install openjdk-17-jdk gdb cmake php
npm install -g live-server
```

**macOS:**
```
brew install gcc python node openjdk php
npm install -g live-server
```

**Windows:**
```
choco install python nodejs openjdk php
choco install visualstudio2022buildtools
npm install -g live-server
```

### Step 4: Install Language Servers

After Neovim starts, run this single command:

press : in your neovim and paste this command:


```
:MasonInstall bashls clangd cssls html intelephense jdtls jsonls lua_ls netcoredbg nimls omnisharp pyright yamlls
```

## 🛠 Quick Start Examples

**Python:**
```
print("Hello from Python!")
```
# Press F6 to run

**Java:**
```
public class Test {
    public static void main(String[] args) {
        System.out.println("Hello from Java!");
    }
}
```
# Press <leader>jc to run

**Web Development:**
Open any HTML file and press <leader>lss to start live server

## 🆘 Troubleshooting

**Check installations:**
```
python3 --version
java -version
gcc --version
```

**In Neovim:**
```
:LspInfo
:Mason
:Lazy update
```

## 📦 Tech Stack

- Neovim ≥ 0.8
- Lazy.nvim - Plugin manager
- Mason.nvim - LSP manager
- Treesitter - Syntax parsing
- LSP Config - Language servers

---

**Ready to code in any language with professional efficiency!** 🚀

*Last updated: 12/nov/2025*

- Show/hide hidden files with Ctrl+H
