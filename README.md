<div align="center">

# Copilot Autocompletion and Chat for Vim

![copilotChat](https://github.com/user-attachments/assets/0cd1119d-89c8-4633-972e-641718e6b24b)

This is a fork of Copilot.vim to go beyond the LSP and provide Copilot Chat functionality without having to leave vim.

Nvim folks will be able to use [CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim) for a similar experience.
</div>

## Requirements

- [Vim][] (9.0.0185 or newer).

- [Node.js][].

- [NerdFonts][].

## Commands
| Command | Description |
| ------- | ----------- |
| `:CopilotChat` | Opens a new copilot window (default vsplit right) |
| `:CopilotConfig` | Open `config.json` for default settings when opening a new CopilotChat window |
| X`:CopilotPrompts` | View / select prompt templates |
| `:CopilotModels` | View available modes / select active model |

## Key Mappings
| Location | Insert | Normal | Action |
| ---- | ---- | ---- | ---- |
| `global` | - | `<Leader-cc>` | Opens a new chat window `:CopilotChat` |
| `<buffer>` | - | `<CR>` | Submit current prompt |
| `:CopilotModels` `<buffer>` | - | `<CR>` | Select the model on the current line for future chat use |

## Installation

Using vim-plug, Vundle, or any other plugin manager. 

## Setup
1. Run `:CopilotChat` to open a chat window. You will be prompted to setup your device on first use.
2. Write your prompt under the line separator and press `<Enter>` in normal mode / `:SubmitChatMessage`
3. You should see a `Waiting for response..` in the buffer to indicate work is being done in the background
4. 🎉!

[Node.js]: https://nodejs.org/en/download/
[Neovim]: https://github.com/neovim/neovim/releases/latest
[Vim]: https://github.com/vim/vim
[NerdFonts]: https://www.nerdfonts.com