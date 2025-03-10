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

## Installation

Using vim-plug, packer.nvim, or any other plugin manager.  Or to install manually, run one of the following commands:

    * Vim, Linux/macOS:

          git clone https://github.com/github/copilot.vim.git \
            ~/.vim/pack/github/start/copilot.vim

    * Neovim, Linux/macOS:

          git clone https://github.com/github/copilot.vim.git \
            ~/.config/nvim/pack/github/start/copilot.vim

    * Vim, Windows (PowerShell command):

          git clone https://github.com/github/copilot.vim.git `
            $HOME/vimfiles/pack/github/start/copilot.vim

    * Neovim, Windows (PowerShell command):

          git clone https://github.com/github/copilot.vim.git `
            $HOME/AppData/Local/nvim/pack/github/start/copilot.vim

## Setup
1. Start Vim/Neovim and invoke `:Copilot setup`. This will enable autocompletion
2. Run `:CopilotChat`

[Node.js]: https://nodejs.org/en/download/
[Neovim]: https://github.com/neovim/neovim/releases/latest
[Vim]: https://github.com/vim/vim
[NerdFonts]: https://www.nerdfonts.com

Suggestions are displayed inline and can be accepted by pressing the tab key.
See `:help copilot` for more information.

## Troubleshooting

We’d love to get your help in making GitHub Copilot better!  If you have
feedback or encounter any problems, please reach out on our [Feedback
forum](https://github.com/orgs/community/discussions/categories/copilot).
