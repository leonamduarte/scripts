package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"sync"
	"time"

	tea "github.com/charmbracelet/bubbletea"
)

// Messages
type wslCheckMsg struct {
	installed bool
	err       error
}

type distroListMsg struct {
	distros []Distro
	err     error
}

type installCompleteMsg struct {
	success bool
	err     error
}

// getWorkingDir returns the scripts-wsl directory
// When running from bootstrap-go/, we need to go up one level
func getWorkingDir() string {
	wd, err := os.Getwd()
	if err != nil {
		return "."
	}

	// Get the base name of current directory (works on both Windows and Linux)
	baseName := filepath.Base(wd)

	// Check if we're in bootstrap-go/ and need to go up
	if baseName == "bootstrap-go" {
		return filepath.Dir(wd)
	}

	return wd
}

// Debug flag - set to true to enable debug output
const debugMode = false

// Regex to strip ANSI codes
var ansiRe = regexp.MustCompile("[\u001B\u009B][[\\]()#;?]*(?:(?:(?:[a-zA-Z\\d]*(?:;[a-zA-Z\\d]*)*)?\u0007)|(?:(?:\\d{1,4}(?:;\\d{0,4})*)?[\\dA-PRZcf-ntqry=><~]))")

// debugPrint prints debug information (only when debugMode is true)
func debugPrint(format string, args ...interface{}) {
	if debugMode {
		fmt.Printf("[DEBUG] "+format+"\n", args...)
	}
}

// getScriptPath returns the full path for a script
func getScriptPath(script string) string {
	if strings.HasPrefix(script, "./") {
		// Relative path - resolve from working directory
		workDir := getWorkingDir()
		relativePath := strings.TrimPrefix(script, "./")
		fullPath := filepath.Join(workDir, relativePath)

		// Debug info
		debugPrint("Script input: %s", script)
		debugPrint("WorkDir: %s", workDir)
		debugPrint("FullPath: %s", fullPath)

		if debugMode {
			if _, err := os.Stat(fullPath); os.IsNotExist(err) {
				debugPrint("WARNING: File does not exist: %s", fullPath)
			} else {
				debugPrint("File exists: %s", fullPath)
			}
		}

		return fullPath
	}
	return script
}

// stripAnsi removes ANSI escape codes from string
func stripAnsi(str string) string {
	return ansiRe.ReplaceAllString(str, "")
}

// streamOutput drains r line-by-line, sending each ANSI-stripped line to logChan.
func streamOutput(r io.Reader, logChan chan string, wg *sync.WaitGroup) {
	defer wg.Done()
	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		logChan <- stripAnsi(scanner.Text())
	}
}

// checkWSLInstalled checks if running inside WSL
func checkWSLInstalled() tea.Cmd {
	return func() tea.Msg {
		// Check if we're running in WSL by looking for /proc/version
		if _, err := os.Stat("/proc/version"); err == nil {
			// Read the version file
			content, _ := os.ReadFile("/proc/version")
			if strings.Contains(string(content), "microsoft") || strings.Contains(string(content), "WSL") {
				return wslCheckMsg{installed: true, err: nil}
			}
		}
		return wslCheckMsg{installed: false, err: fmt.Errorf("não está rodando no WSL")}
	}
}

// checkDistros lists installed distributions (always returns at least current distro)
func checkDistros() tea.Cmd {
	return func() tea.Msg {
		distros := []Distro{
			{
				Name:    "Ubuntu-22.04",
				State:   "Running",
				Version: 2,
				Default: true,
			},
		}
		return distroListMsg{distros: distros, err: nil}
	}
}

// runScript executes a script with live output
func runScript(item MenuItem) tea.Cmd {
	return func() tea.Msg {
		scriptPath := getScriptPath(item.Script)

		// Create command
		cmd := exec.Command("bash", scriptPath)

		// Set working directory
		cmd.Dir = getWorkingDir()

		// Get pipes for stdout and stderr
		stdout, err := cmd.StdoutPipe()
		if err != nil {
			return installCompleteMsg{success: false, err: err}
		}

		stderr, err := cmd.StderrPipe()
		if err != nil {
			return installCompleteMsg{success: false, err: err}
		}

		// Start command
		if err := cmd.Start(); err != nil {
			return installCompleteMsg{success: false, err: err}
		}

		var wg sync.WaitGroup
		wg.Add(2)
		go func() { defer wg.Done(); scanner := bufio.NewScanner(stdout); for scanner.Scan() {} }()
		go func() { defer wg.Done(); scanner := bufio.NewScanner(stderr); for scanner.Scan() {} }()
		err = cmd.Wait()
		wg.Wait()
		return installCompleteMsg{
			success: err == nil,
			err:     err,
		}
	}
}

// runScriptWithLogs executes a script and returns logs in real-time
func runScriptWithLogs(item MenuItem, logChan chan string) tea.Cmd {
	return func() tea.Msg {
		scriptPath := getScriptPath(item.Script)

		cmd := exec.Command("bash", scriptPath)
		cmd.Dir = getWorkingDir()

		stdout, err := cmd.StdoutPipe()
		if err != nil {
			return installCompleteMsg{success: false, err: err}
		}

		stderr, err := cmd.StderrPipe()
		if err != nil {
			return installCompleteMsg{success: false, err: err}
		}

		if err := cmd.Start(); err != nil {
			return installCompleteMsg{success: false, err: err}
		}

		var wg sync.WaitGroup
		wg.Add(2)
		go streamOutput(stdout, logChan, &wg)
		go streamOutput(stderr, logChan, &wg)
		err = cmd.Wait()
		wg.Wait()

		if err != nil {
			return installCompleteMsg{success: false, err: err}
		}
		return installCompleteMsg{success: true, err: nil}
	}
}

// runAllInstall installs all components with progress
func runAllInstall(logChan chan string) tea.Cmd {
	return func() tea.Msg {
		scripts := []string{
			"./install/base.sh",
			"./install/shell.sh",
			"./install/cli-tools.sh",
			"./install/dev-tools.sh",
			"./install/dotfiles.sh",
		}

		workDir := getWorkingDir()
		total := len(scripts)
		for i, script := range scripts {
			scriptPath := getScriptPath(script)
			scriptName := filepath.Base(script)

			logChan <- fmt.Sprintf("\n[ %d/%d ] Instalando: %s", i+1, total, scriptName)
			logChan <- strings.Repeat("-", 50)

			cmd := exec.Command("bash", scriptPath)
			cmd.Dir = workDir

			stdout, _ := cmd.StdoutPipe()
			stderr, _ := cmd.StderrPipe()

			if err := cmd.Start(); err != nil {
				logChan <- fmt.Sprintf("[ERRO] Falha ao iniciar %s: %v", scriptName, err)
				return installCompleteMsg{success: false, err: err}
			}

			var wg sync.WaitGroup
			wg.Add(2)
			go streamOutput(stdout, logChan, &wg)
			go streamOutput(stderr, logChan, &wg)

			if err := cmd.Wait(); err != nil {
				wg.Wait()
				logChan <- fmt.Sprintf("[ERRO] Falha em %s: %v", scriptName, err)
				return installCompleteMsg{success: false, err: err}
			}
			wg.Wait()

			logChan <- fmt.Sprintf("[OK] %s concluído!", scriptName)
			time.Sleep(500 * time.Millisecond)
		}

		return installCompleteMsg{success: true, err: nil}
	}
}
