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

### 1. Clone the repository

git clone https://github.com/your-username/my_neovim_config ~/.config/nvim

### 2. Install Neovim dependencies

**Ubuntu/Debian:**
sudo apt update && sudo apt install neovim git curl build-essential

**macOS:**
brew install neovim git curl

**Windows:**
Using Chocolatey (recommended)
choco install neovim git curl

Or using Winget
winget install Neovim.Neovim Git.Git

### 3. Start Neovim and let plugins auto-install

nvim

## 📋 Language Setup Guide

### Required Dependencies

**Ubuntu/Debian:**
Base development tools
sudo apt install gcc g++ make python3 python3-pip nodejs npm

Java
sudo apt install openjdk-17-jdk

C/C++
sudo apt install gdb cmake

PHP
sudo apt install php

Web tools
npm install -g live-server

**macOS:**
brew install gcc python node openjdk php
npm install -g live-server

**Windows:**
Using Chocolatey
choco install python nodejs openjdk php golang
choco install visualstudio2022buildtools --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools"

Install live-server globally
npm install -g live-server

Or using Winget
winget install Python.Python.3 Node.js OpenJS.NodeJS PHP

### ✅ Install All Language Servers at Once

After starting Neovim, run this command to install all LSP servers automatically:

:MasonInstall bash-language-server clangd css-lsp html-lsp intelephense jdtls json-lsp lua-language-server netcoredbg nimlsp omnisharp pyright yaml-language-server

Or use this shorter version:
:MasonInstall bashls clangd cssls html intelephense jdtls jsonls lua_ls netcoredbg nimls omnisharp pyright yamlls

### One-Command Installation

You can also run this single command to install everything:
:lua vim.cmd("MasonInstall bashls clangd cssls html intelephense jdtls jsonls lua_ls netcoredbg nimls omnisharp pyright yamlls")

## 🛠 Usage Examples

### Create and run a Python file:

print("Hello from Python!")

Press `<F6>` to execute

### Create and run a Java file:

public class Hello {
    public static void main(String[] args) {
        System.out.println("Hello from Java!");
    }
}

Press `<leader>jc` to compile and run with libraries, or `<F8>` for quick run

### Web Development:

Open any HTML file and use `<leader>lss` to start a live server

## 🆘 Troubleshooting

If you encounter issues:

1. **Check language installation:**
python3 --version
java -version
gcc --version

2. **Verify LSP servers in Neovim:**
:LspInfo
:Mason

3. **Update plugins:**
:Lazy update

## 📦 Integrated Technologies

- **Neovim ≥ 0.8** - Modern foundation
- **Lazy.nvim** - Plugin manager
- **Mason.nvim** - LSP management
- **Treesitter** - Syntax parsing
- **LSP Config** - Language server setup

---

**Ready to code in any language with professional efficiency!** 🚀

*Last updated: 11/05/2025*
