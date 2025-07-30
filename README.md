# VSCode Python Project Templates

![Python](https://img.shields.io/badge/python-3.8+-blue.svg)
![VSCode](https://img.shields.io/badge/VSCode-templates-blue.svg)
![Rye](https://img.shields.io/badge/rye-supported-green.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

🐍 Complete VSCode Python development templates with automated project setup. Supports rye/ruff/uv toolchain, Vim keybindings, 9 debug configurations, and dual-mode operation for new & existing projects.

This directory contains templates and scripts for quickly setting up Python projects with your preferred VSCode configuration.

## 📁 Files Overview

- **`launch.json`** - Debug configurations for all Python project types
- **`settings.json`** - Python-specific VSCode settings (rye/ruff/pytest)
- **`extensions.json`** - Recommended extensions for Python development
- **`.env.template`** - Environment variables template
- **`setup-python-project.sh`** - Main setup script
- **`shell-aliases.sh`** - Shell aliases for easy access

## 🚀 Quick Start

1. **Add aliases to your shell** (one time setup):
   ```bash
   echo 'source ~/.vscode-templates/shell-aliases.sh' >> ~/.zshrc
   source ~/.zshrc
   ```

2. **Create a new project**:
   ```bash
   # Interactive mode
   new-python-project

   # Direct mode - NEW projects
   new-python-project my-api web
   pysetup data-analysis data
   ```

3. **Setup existing project**:
   ```bash
   # From within existing project directory
   cd my-existing-project
   pysetup

   # Or specify project directory
   pysetup my-existing-project
   ```## 📋 Project Types

| Type | Dependencies | Use Case |
|------|-------------|----------|
| **basic** | pytest, ruff, mypy | Simple Python projects |
| **web** | FastAPI, uvicorn, httpx | REST APIs, web services |
| **django** | Django, DRF | Full web applications |
| **cli** | click, rich, typer | Command-line tools |
| **data** | pandas, numpy, jupyter | Data analysis, ML |

## � **What Gets Created**

### For NEW Projects
Each new project includes:

#### VSCode Configuration
- **Debug configs**: 9 different debugging scenarios
- **Settings**: Optimized for rye/ruff/pytest workflow
- **Extensions**: Auto-suggests required extensions
- **Keybindings**: Works with your custom Vim setup

#### Project Structure
```
my-project/
├── .vscode/
│   ├── launch.json
│   ├── settings.json
│   └── extensions.json
├── src/
│   └── my_project/
│       ├── __init__.py
│       └── main.py
├── tests/
│   ├── __init__.py
│   └── test_main.py
├── .env
├── pyproject.toml
└── README.md
```

#### Environment
- **rye** managed dependencies
- **Virtual environment** automatically created
- **Environment variables** template
- **Testing** ready with pytest

### For EXISTING Projects
When run on existing projects, the script will:

#### Always Update
- **VSCode configuration** (.vscode/ folder - always refreshed)
- **Dependencies** (runs `rye sync`)
- **Opens in VSCode** with your keybindings ready

#### Conditionally Add
- **.env template** (only if .env doesn't exist)
- **Project structure** (skipped for existing projects)
- **Dependencies** (manual - suggests `rye add` commands)

## 🚀 **Usage**

### For New Projects
Create and set up a new Python project:
```bash
pysetup my-new-project
```

### For Existing Projects
Set up VSCode configuration on an existing project:
```bash
cd /path/to/existing/project
pysetup
```

The script automatically detects whether you're in an existing project directory and adapts accordingly.

### Quick Help
Get usage information:
```bash
pysetup --help
```

## ⚡ **Usage Examples**

### Web API Project
```bash
new-python-project my-api web
cd my-api
rye run uvicorn src.my_api.main:app --reload
# Visit http://localhost:8000
```

### Data Science Project
```bash
pysetup analysis data
cd analysis
rye run jupyter lab
```

### CLI Tool
```bash
new-python-project mytool cli
cd mytool
rye run python src/mytool/main.py --help
```

## 🔧 Customization

### Modify Templates
Edit files in `~/.vscode-templates/` to customize:
- Add new debug configurations to `launch.json`
- Adjust Python settings in `settings.json`
- Update environment template in `.env.template`

### Add New Project Types
Edit `setup-python-project.sh` and add new cases in the `add_dependencies()` function.

### Custom Dependencies
The script automatically adds project-type specific dependencies, but you can modify these in the script or add more after project creation with:
```bash
rye add your-package
rye sync
```

## 🎯 Integration with Your Setup

This template system is designed to work seamlessly with your existing configuration:

- **Vim keybindings**: All your `<Space>` commands work immediately
- **Debugging**: Full debug support with your custom keybinds
- **Terminal**: Uses your zsh/Ghostty setup
- **Formatting**: Automatic ruff formatting on save
- **Testing**: pytest integration with `<Space>tt` and `<Space>tf`

## 📚 Related Documentation

- **Main cheatsheet**: `~/vscode-keybindings-cheatsheet.md`
- **Debugging guide**: `~/python-debugging-guide.md`
- **VSCode settings**: `~/Library/Application Support/Code/User/settings.json`

## 🔄 Updates

To update templates for existing projects:
```bash
# Copy updated configs to existing project
cp ~/.vscode-templates/launch.json .vscode/
cp ~/.vscode-templates/settings.json .vscode/
```

---

Happy coding! 🐍✨
