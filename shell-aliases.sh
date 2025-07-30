# VSCode Python Project Setup Alias
# Add this to your ~/.zshrc or ~/.bashrc

# Alias for quick Python project setup
alias new-python-project='~/.vscode-templates/setup-python-project.sh'

# Alternative shorter alias
alias pysetup='~/.vscode-templates/setup-python-project.sh'

# Usage examples:

# NEW PROJECTS:
# new-python-project my-api web
# pysetup data-analysis data
# new-python-project  # Interactive mode

# EXISTING PROJECTS:
# cd existing-project && pysetup  # Setup VSCode for current directory
# pysetup existing-project        # Setup VSCode for specified directory
# pysetup                         # Interactive mode (detects existing project)
