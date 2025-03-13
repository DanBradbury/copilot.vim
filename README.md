<div align="center">

# Copilot Autocompletion and Chat for Vim

![copilotChat](https://github.com/user-attachments/assets/0cd1119d-89c8-4633-972e-641718e6b24b)

</div>
GitHub Copilot is an AI pair programmer tool that helps you write code faster
and smarter. Trained on billions of lines of public code, GitHub Copilot turns
natural language prompts including comments and method names into coding
suggestions across dozens of languages.

Copilot.vim is a Vim/Neovim plugin for GitHub Copilot.

To learn more, visit
[https://github.com/features/copilot](https://github.com/features/copilot).

## Requirements

-  [Vim][] (9.0.0185 or newer).

- [Node.js][].

- [NerdFonts][].

## Commands
| Command | Description |
| ------- | ----------- |
| `:CopilotChat` | Opens a new copilot window (default vsplit right) |
| X`:CopilotConfig` | Open `config.json` for plugin default settings |
| X`:CopilotPrompts` | View / select prompt templates |
| X`:CopilotModels` | View available modes / select active model |

## Key Mappings
| Location | Insert | Normal | Action |
| ---- | ---- | ---- |
| `global` | - | `<Leader-cc>` | Opens a new chat window `:CopilotChat` |
| `<buffer>` | - | `<CR>` | Submit current prompt |

## Installation

Using vim-plug, packer.nvim, or any other plugin manager. 

## Setup
1. Start Vim and invoke `:Copilot setup`. This will enable autocompletion
2. Run `:CopilotChat`

[Node.js]: https://nodejs.org/en/download/
[Neovim]: https://github.com/neovim/neovim/releases/latest
[Vim]: https://github.com/vim/vim
[NerdFonts]: https://www.nerdfonts.com

Suggestions are displayed inline and can be accepted by pressing the tab key.
See `:help copilot` for more information.
