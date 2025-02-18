// Package tf_sources provides functionality to manage Terraform source directories.
package repo

import (
	"fmt"
	"os"
	"path/filepath"
)

// Constants representing directory names for examples and modules.
const (
	examplesDir = "examples"
	modulesDir  = "modules"
)

// TFSourcesDir represents the directory structure for Terraform sources.
type TFSourcesDir struct {
	rootDir     string // The root directory for Terraform sources.
	modulesDir  string // The directory for modules.
	examplesDir string // The directory for examples.
}

// GetGitRootDir returns the absolute path to the root directory of the git repository.
func GetGitRootDir() (string, error) {
	// Get the current working directory
	currentDir, err := filepath.Abs(".")
	if err != nil {
		return "", fmt.Errorf("failed to get absolute path: %w", err)
	}

	// Traverse up the directory tree to find the Git root
	for {
		// Check for .git directory or .git file (for submodules)
		gitDirPath := filepath.Join(currentDir, ".git")
		gitConfigPath := filepath.Join(currentDir, ".git", "config")

		// Check if .git directory or config exists
		if _, err := os.Stat(gitDirPath); err == nil {
			return currentDir, nil
		}
		if _, err := os.Stat(gitConfigPath); err == nil {
			return currentDir, nil
		}

		// Move up one directory
		parentDir := filepath.Dir(currentDir)

		// If we've reached the filesystem root without finding .git, return an error
		if parentDir == currentDir {
			return "", fmt.Errorf("could not find Git repository root starting from %s", currentDir)
		}

		currentDir = parentDir
	}
}

// NewTFSourcesDir initializes a new TFSourcesDir with the given root directory.
// It returns a pointer to the TFSourcesDir instance.
func NewTFSourcesDir() (*TFSourcesDir, error) {
	rootDir, err := GetGitRootDir()

	if err != nil {
		return nil, fmt.Errorf("failed to get Git repository root directory: %w", err)
	}

	return &TFSourcesDir{
		rootDir:     rootDir,
		modulesDir:  filepath.Join(rootDir, modulesDir),
		examplesDir: filepath.Join(rootDir, examplesDir),
	}, nil
}

// GetModulesDir returns the absolute path to the specified module's directory.
func (t *TFSourcesDir) GetModulesDir(moduleName string) string {
	return filepath.Join(t.modulesDir, moduleName)
}

// GetExamplesDir returns the absolute path to the specified example's directory.
func (t *TFSourcesDir) GetExamplesDir(exampleName string) string {
	return filepath.Join(t.examplesDir, exampleName)
}

// GetRootDir returns the absolute path to the root directory.
func (t *TFSourcesDir) GetRootDir() string {
	return t.rootDir
}
