package main

import (
	"fmt"
	"os"

	tea "github.com/charmbracelet/bubbletea"
)

func main() {
	model := NewModel()

	p := tea.NewProgram(
		model,
		// tea.WithAltScreen(), // Removido para permitir seleção de texto
	)

	if _, err := p.Run(); err != nil {
		fmt.Printf("Erro ao iniciar: %v\n", err)
		os.Exit(1)
	}
}
