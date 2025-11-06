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

## 🎮 Smart Keybindings

- `<leader>jc` - Compile/Run Java (with libraries)
- `<leader>pr` - Quick Python execution
- `<F5>` - Open terminal
- `<F6>` - Run Python
- `<F7>` - Compile + Run C/C++
- `<F8>` - Compile + Run Java (without libraries)
- `<F9>` - Compile + Run Nim
- `<leader>lss` - Secure Live Server

## 🔧 Specialized Systems

- **Workspace Management** - Focus on specific project folders
- **Integrated Terminal** - Multiple terminals with intelligent management
- **Error Handling** - System to silence annoying errors
- **Buffer Management** - Safe closing without breaking layout

## 🚀 Quick Installation

### Step 1: Clone the repository
git clone https://github.com/Eduardoooo12/My_neovim_config ~/.config/nvim

### Step 2: Install system dependencies

**For Ubuntu/Debian:**
sudo apt update
sudo apt install neovim git curl build-essential

**For macOS:**
brew install neovim git curl

**For Windows:**
# Install Chocolatey first, then:
choco install neovim git curl

### Step 3: Start Neovim
nvim

Plugins will install automatically. Wait for the process to complete.

## 📋 Complete Language Setup

### Install Development Tools

**Ubuntu/Debian:**
sudo apt install gcc g++ make python3 python3-pip nodejs npm
sudo apt install openjdk-17-jdk gdb cmake php
npm install -g live-server

**macOS:**
brew install gcc python node openjdk php
npm install -g live-server

**Windows:**
choco install python nodejs openjdk php
choco install visualstudio2022buildtools
npm install -g live-server

### Step 4: Install Language Servers

After Neovim starts, run this single command:

:MasonInstall bashls clangd cssls html intelephense jdtls jsonls lua_ls netcoredbg nimls omnisharp pyright yamlls

## 🛠 Quick Start Examples

**Python:**
print("Hello from Python!")
# Press F6 to run

**Java:**
public class Test {
    public static void main(String[] args) {
        System.out.println("Hello from Java!");
    }
}
# Press <leader>jc to run

**Web Development:**
Open any HTML file and press <leader>lss to start live server

## 🆘 Troubleshooting

**Check installations:**
python3 --version
java -version
gcc --version

**In Neovim:**
:LspInfo
:Mason
:Lazy update

## 📦 Tech Stack

- Neovim ≥ 0.8
- Lazy.nvim - Plugin manager
- Mason.nvim - LSP manager
- Treesitter - Syntax parsing
- LSP Config - Language servers

---

**Ready to code in any language with professional efficiency!** 🚀

*Last updated: 11/05/2025*
