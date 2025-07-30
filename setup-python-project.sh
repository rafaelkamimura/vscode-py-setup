#!/bin/bash

# setup-python-project.sh
# Quick setup script for Python projects with VSCode configuration
# Usage: setup-python-project.sh [project-name] [project-type]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Template directory
TEMPLATE_DIR="$HOME/.vscode-templates"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [PROJECT_NAME] [PROJECT_TYPE]"
    echo ""
    echo "For NEW projects:"
    echo "PROJECT_TYPE options:"
    echo "  basic     - Basic Python project with pytest"
    echo "  web       - Web project with FastAPI/Flask dependencies"
    echo "  django    - Django project setup"
    echo "  cli       - CLI application with click"
    echo "  data      - Data science project with common packages"
    echo ""
    echo "For EXISTING projects:"
    echo "  Run from project directory: $0"
    echo "  Or specify existing directory: $0 existing-project"
    echo ""
    echo "Examples:"
    echo "  $0 my-api web              # Create new web project"
    echo "  $0 data-analysis data      # Create new data project"
    echo "  cd existing-project && $0  # Setup existing project"
    echo ""
    echo "If no arguments provided, interactive mode will be used."
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check dependencies
check_dependencies() {
    print_status "Checking dependencies..."

    if ! command_exists rye; then
        print_error "rye not found. Please install rye first:"
        echo "curl -sSf https://rye-up.com/get | bash"
        exit 1
    fi

    if ! command_exists code; then
        print_warning "VSCode 'code' command not found. Install VSCode or add it to PATH."
    fi

    if [ ! -d "$TEMPLATE_DIR" ]; then
        print_error "Template directory not found: $TEMPLATE_DIR"
        print_error "Please run the VSCode setup first."
        exit 1
    fi

    print_success "All dependencies found!"
}

# Interactive mode to get project details
interactive_setup() {
    echo ""
    print_status "🚀 Python Project Setup - Interactive Mode"
    echo ""

    # Check if we're in an existing project directory
    if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "setup.py" ]; then
        print_status "Detected existing Python project in current directory"
        read -p "Setup VSCode configuration for existing project? (y/n): " setup_existing
        if [ "$setup_existing" = "y" ] || [ "$setup_existing" = "Y" ]; then
            PROJECT_NAME=$(basename "$(pwd)")
            EXISTING_PROJECT=true
            return
        fi
    fi

    # Get project name
    while [ -z "$PROJECT_NAME" ]; do
        read -p "Enter project name: " PROJECT_NAME
        if [ -z "$PROJECT_NAME" ]; then
            print_warning "Project name cannot be empty!"
        fi
    done

    # Check if project directory exists
    if [ -d "$PROJECT_NAME" ]; then
        print_warning "Directory '$PROJECT_NAME' already exists!"
        read -p "Setup VSCode configuration for existing project? (y/n): " setup_existing
        if [ "$setup_existing" = "y" ] || [ "$setup_existing" = "Y" ]; then
            EXISTING_PROJECT=true
            return
        else
            print_error "Aborting setup."
            exit 1
        fi
    fi

    # Get project type for new projects
    echo ""
    echo "Select project type:"
    echo "1) basic     - Basic Python project with pytest"
    echo "2) web       - Web project with FastAPI/Flask"
    echo "3) django    - Django project"
    echo "4) cli       - CLI application with click"
    echo "5) data      - Data science project"
    echo ""

    while [ -z "$PROJECT_TYPE" ]; do
        read -p "Enter choice (1-5): " choice
        case $choice in
            1) PROJECT_TYPE="basic" ;;
            2) PROJECT_TYPE="web" ;;
            3) PROJECT_TYPE="django" ;;
            4) PROJECT_TYPE="cli" ;;
            5) PROJECT_TYPE="data" ;;
            *) print_warning "Invalid choice! Please enter 1-5." ;;
        esac
    done
}

# Create project with rye or enter existing project
create_or_enter_project() {
    if [ "$EXISTING_PROJECT" = true ]; then
        print_status "Setting up existing project: $PROJECT_NAME"

        # If we specified a project name, enter that directory
        if [ "$PROJECT_NAME" != "$(basename "$(pwd)")" ] && [ -d "$PROJECT_NAME" ]; then
            cd "$PROJECT_NAME"
        fi

        # Verify this looks like a Python project
        if [ ! -f "pyproject.toml" ] && [ ! -f "requirements.txt" ] && [ ! -f "setup.py" ]; then
            print_warning "No Python project files found (pyproject.toml, requirements.txt, or setup.py)"
            read -p "Continue anyway? (y/n): " continue_setup
            if [ "$continue_setup" != "y" ] && [ "$continue_setup" != "Y" ]; then
                print_error "Aborting setup."
                exit 1
            fi
        fi

        print_success "Existing project directory confirmed!"
    else
        print_status "Creating new rye project: $PROJECT_NAME"

        if [ -d "$PROJECT_NAME" ]; then
            print_error "Directory $PROJECT_NAME already exists!"
            exit 1
        fi

        rye init "$PROJECT_NAME"
        cd "$PROJECT_NAME"

        print_success "Rye project created successfully!"
    fi
}

# Add dependencies based on project type
add_dependencies() {
    if [ "$EXISTING_PROJECT" = true ]; then
        print_status "Skipping dependency installation for existing project"
        print_status "You can manually add dependencies with: rye add <package>"
        return
    fi

    print_status "Adding dependencies for project type: $PROJECT_TYPE"

    # Common development dependencies
    rye add --dev pytest pytest-cov ruff mypy

    case $PROJECT_TYPE in
        "basic")
            # Just the dev dependencies
            ;;
        "web")
            rye add fastapi uvicorn[standard] httpx
            rye add --dev pytest-asyncio
            ;;
        "django")
            rye add django djangorestframework
            rye add --dev django-extensions
            ;;
        "cli")
            rye add click rich typer
            ;;
        "data")
            rye add pandas numpy matplotlib seaborn jupyter
            rye add --dev ipykernel
            ;;
        *)
            print_warning "Unknown project type: $PROJECT_TYPE"
            ;;
    esac

    print_success "Dependencies added!"
}

# Setup VSCode configuration
setup_vscode_config() {
    print_status "Setting up VSCode configuration..."

    # Create .vscode directory
    mkdir -p .vscode

    # Copy template files (always overwrite to ensure latest config)
    cp "$TEMPLATE_DIR/launch.json" .vscode/
    cp "$TEMPLATE_DIR/settings.json" .vscode/
    cp "$TEMPLATE_DIR/extensions.json" .vscode/

    # Copy .env template only if it doesn't exist
    if [ ! -f ".env" ]; then
        cp "$TEMPLATE_DIR/.env.template" .env
        print_status "Created .env file from template"
    else
        print_status ".env file already exists, skipping"
    fi

    print_success "VSCode configuration updated!"
}

# Create basic project structure
create_project_structure() {
    if [ "$EXISTING_PROJECT" = true ]; then
        print_status "Skipping project structure creation for existing project"
        return
    fi

    print_status "Creating project structure..."

    # Create source directory
    mkdir -p src/"$PROJECT_NAME"
    touch src/"$PROJECT_NAME"/__init__.py

    # Create tests directory
    mkdir -p tests
    touch tests/__init__.py
    touch tests/test_main.py

    # Create basic files based on project type
    case $PROJECT_TYPE in
        "web")
            cat > src/"$PROJECT_NAME"/main.py << 'EOF'
from fastapi import FastAPI

app = FastAPI(title="My API", version="0.1.0")

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/health")
async def health():
    return {"status": "healthy"}
EOF
            ;;
        "django")
            # Django will create its own structure
            ;;
        "cli")
            cat > src/"$PROJECT_NAME"/main.py << 'EOF'
import click

@click.command()
@click.option('--name', default='World', help='Name to greet')
def hello(name):
    """Simple CLI that greets NAME."""
    click.echo(f'Hello {name}!')

if __name__ == '__main__':
    hello()
EOF
            ;;
        *)
            cat > src/"$PROJECT_NAME"/main.py << 'EOF'
def main():
    """Main function."""
    print("Hello from your new Python project!")

if __name__ == "__main__":
    main()
EOF
            ;;
    esac

    # Create basic test
    cat > tests/test_main.py << EOF
import pytest
from src.${PROJECT_NAME} import main

def test_main():
    """Test main function exists."""
    assert callable(main.main)
EOF

    print_success "Project structure created!"
}

# Sync dependencies and create virtual environment
sync_project() {
    print_status "Syncing project dependencies..."

    rye sync

    print_success "Project dependencies synced!"
}

# Open in VSCode
open_vscode() {
    if command_exists code; then
        print_status "Opening project in VSCode..."
        code .
        print_success "Project opened in VSCode!"
    else
        print_warning "VSCode not found in PATH. Please open the project manually."
    fi
}

# Show next steps
show_next_steps() {
    echo ""
    if [ "$EXISTING_PROJECT" = true ]; then
        print_success "🎉 Existing project setup complete!"
        echo ""
        echo "📁 Project: $PROJECT_NAME (existing project)"
        echo "📍 Location: $(pwd)"
        echo ""
        echo "✅ What was updated:"
        echo "   • VSCode configuration (.vscode/ folder)"
        echo "   • Environment template (.env - if not existing)"
        echo "   • Dependencies synced with rye"
        echo ""
    else
        print_success "🎉 New project setup complete!"
        echo ""
        echo "📁 Project: $PROJECT_NAME ($PROJECT_TYPE)"
        echo "📍 Location: $(pwd)"
        echo ""
    fi

    echo "🚀 Next steps:"
    echo "   1. Edit .env file with your environment variables"
    if [ "$EXISTING_PROJECT" = false ]; then
        echo "   2. Start coding in src/$PROJECT_NAME/"
        echo "   3. Write tests in tests/"
    else
        echo "   2. Continue coding in your existing structure"
        echo "   3. Use the updated VSCode configuration"
    fi
    echo "   4. Use your VSCode keybindings:"
    echo "      • <Space>tt - Run all tests"
    echo "      • <Space>tf - Run current test file"
    echo "      • <Space>db - Toggle breakpoint"
    echo "      • <Space>ds - Start debugging"
    echo ""

    if [ "$EXISTING_PROJECT" = false ]; then
        case $PROJECT_TYPE in
            "web")
                echo "🌐 Web project commands:"
                echo "   • rye run python -m uvicorn src.$PROJECT_NAME.main:app --reload"
                echo "   • Visit http://localhost:8000"
                ;;
            "django")
                echo "🌐 Django project setup:"
                echo "   • rye run django-admin startproject mysite ."
                echo "   • rye run python manage.py runserver"
                ;;
            "cli")
                echo "🖥️  CLI project commands:"
                echo "   • rye run python src/$PROJECT_NAME/main.py --help"
                ;;
            "data")
                echo "📊 Data science commands:"
                echo "   • rye run jupyter lab"
                echo "   • rye run python -c 'import pandas as pd; print(pd.__version__)'"
                ;;
        esac
    fi

    echo ""
    echo "📖 Documentation:"
    echo "   • VSCode keybindings: ~/vscode-keybindings-cheatsheet.md"
    echo "   • Debugging guide: ~/python-debugging-guide.md"
    echo ""
}

# Main function
main() {
    echo "🐍 Python Project Setup Script"
    echo "==============================="

    # Initialize variables
    EXISTING_PROJECT=false
    PROJECT_NAME="$1"
    PROJECT_TYPE="$2"

    # Show help if requested
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_usage
        exit 0
    fi

    # Check dependencies
    check_dependencies

    # Check if we're running in an existing project directory (no arguments)
    if [ -z "$PROJECT_NAME" ] && [ -z "$PROJECT_TYPE" ]; then
        if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "setup.py" ]; then
            PROJECT_NAME=$(basename "$(pwd)")
            EXISTING_PROJECT=true
            print_status "Detected existing Python project: $PROJECT_NAME"
        else
            interactive_setup
        fi
    # Check if specified directory exists (existing project)
    elif [ -n "$PROJECT_NAME" ] && [ -z "$PROJECT_TYPE" ] && [ -d "$PROJECT_NAME" ]; then
        EXISTING_PROJECT=true
        print_status "Setting up existing project: $PROJECT_NAME"
    # Use interactive mode if incomplete arguments
    elif [ -z "$PROJECT_NAME" ] || [ -z "$PROJECT_TYPE" ]; then
        interactive_setup
    fi

    # Validate project type for new projects
    if [ "$EXISTING_PROJECT" = false ] && [ -n "$PROJECT_TYPE" ]; then
        case $PROJECT_TYPE in
            "basic"|"web"|"django"|"cli"|"data")
                ;;
            *)
                print_error "Invalid project type: $PROJECT_TYPE"
                show_usage
                exit 1
                ;;
        esac
    fi

    # Create and setup project
    create_or_enter_project
    add_dependencies
    setup_vscode_config
    create_project_structure
    sync_project
    open_vscode
    show_next_steps
}

# Run main function with all arguments
main "$@"
