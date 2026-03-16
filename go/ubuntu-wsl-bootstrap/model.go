package main

import (
	tea "github.com/charmbracelet/bubbletea"
)

// AppState represents the current state of the application
type AppState int

const (
	StateMenu AppState = iota
	StateInstalling
	StateDone
	StateError
	StateChecking
)

// Category represents menu categories
type Category int

const (
	CategoryInstall Category = iota
	CategorySystem
	CategoryUtils
)

const logChanSize = 100

// MenuItem represents a single menu item
type MenuItem struct {
	ID          string
	Title       string
	Description string
	Category    Category
	Script      string
	RunInWSL    bool
	RequiresWSL bool
}

// Distro represents a WSL distribution
type Distro struct {
	Name    string
	State   string
	Version int
	Default bool
}

// Model is the main application model
type Model struct {
	state           AppState
	selected        int
	menuItems       []MenuItem
	currentCategory Category
	progress        int
	logs            []string
	logChan         chan string
	installing      string
	wslInstalled    bool
	distros         []Distro
	err             error
	width           int
	height          int
	categoryOpen    map[Category]bool
}

// NewModel creates a new model with initial state
func NewModel() Model {
	return Model{
		state:           StateMenu,
		selected:        0,
		currentCategory: CategoryInstall,
		logs:            make([]string, 0),
		logChan:         make(chan string, logChanSize),
		categoryOpen: map[Category]bool{
			CategoryInstall: true,
			CategorySystem:  false,
			CategoryUtils:   false,
		},
		menuItems: []MenuItem{
			// Installation category
			{
				ID:          "bootstrap",
				Title:       "📦 Bootstrap Ubuntu WSL",
				Description: "Instalar Ubuntu 22.04 no WSL",
				Category:    CategoryInstall,
				Script:      "wsl --install -d Ubuntu-22.04",
				RunInWSL:    false,
				RequiresWSL: false,
			},
			{
				ID:          "install-all",
				Title:       "🚀 Instalação Completa",
				Description: "Instalar todos os pacotes de uma vez",
				Category:    CategoryInstall,
				Script:      "all",
				RunInWSL:    true,
				RequiresWSL: true,
			},
			{
				ID:          "install-base",
				Title:       "   Base",
				Description: "Pacotes essenciais",
				Category:    CategoryInstall,
				Script:      "./install/base.sh",
				RunInWSL:    true,
				RequiresWSL: true,
			},
			{
				ID:          "install-shell",
				Title:       "   Shell",
				Description: "Fish + Starship",
				Category:    CategoryInstall,
				Script:      "./install/shell.sh",
				RunInWSL:    true,
				RequiresWSL: true,
			},
			{
				ID:          "install-cli",
				Title:       "   CLI Tools",
				Description: "ripgrep, fd, bat, eza, fzf, etc",
				Category:    CategoryInstall,
				Script:      "./install/cli-tools.sh",
				RunInWSL:    true,
				RequiresWSL: true,
			},
			{
				ID:          "install-dev",
				Title:       "   Dev Tools",
				Description: "git, gh, fnm, neovim",
				Category:    CategoryInstall,
				Script:      "./install/dev-tools.sh",
				RunInWSL:    true,
				RequiresWSL: true,
			},
			{
				ID:          "install-dotfiles",
				Title:       "   Dotfiles",
				Description: "Clonar e configurar dotfiles",
				Category:    CategoryInstall,
				Script:      "./install/dotfiles.sh",
				RunInWSL:    true,
				RequiresWSL: true,
			},
			// System category
			{
				ID:          "system-update",
				Title:       "🔄 Atualizar Sistema",
				Description: "Atualizar pacotes",
				Category:    CategorySystem,
				Script:      "./system/update.sh",
				RunInWSL:    true,
				RequiresWSL: true,
			},
			{
				ID:          "system-clean",
				Title:       "🧹 Limpar Sistema",
				Description: "Limpar cache e pacotes órfãos",
				Category:    CategorySystem,
				Script:      "./system/clean.sh",
				RunInWSL:    true,
				RequiresWSL: true,
			},
			{
				ID:          "system-ports",
				Title:       "📡 Listar Portas",
				Description: "Mostrar portas abertas",
				Category:    CategorySystem,
				Script:      "./system/ports.sh",
				RunInWSL:    true,
				RequiresWSL: true,
			},
			// Utils category
			{
				ID:          "utils-explorer",
				Title:       "📂 Abrir Explorer",
				Description: "Abrir pasta atual no Windows Explorer",
				Category:    CategoryUtils,
				Script:      "explorer.exe",
				RunInWSL:    false,
				RequiresWSL: true,
			},
			{
				ID:          "utils-vscode",
				Title:       "📝 Abrir VSCode",
				Description: "Abrir VSCode no diretório atual",
				Category:    CategoryUtils,
				Script:      "code .",
				RunInWSL:    true,
				RequiresWSL: true,
			},
			{
				ID:          "check-distros",
				Title:       "🔍 Verificar Distros",
				Description: "Listar distribuições instaladas",
				Category:    CategoryUtils,
				Script:      "check",
				RunInWSL:    false,
				RequiresWSL: false,
			},
		},
	}
}

// Init is called when the program starts
func (m Model) Init() tea.Cmd {
	return tea.Batch(
		checkWSLInstalled(),
		checkDistros(),
	)
}
