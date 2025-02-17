// Package tf_sources provides functionality to manage Terraform source directories.
package tf_sources

import "path/filepath"

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

// NewTFSourcesDir initializes a new TFSourcesDir with the given root directory.
// It returns a pointer to the TFSourcesDir instance.
func NewTFSourcesDir(rootDir string) *TFSourcesDir {
	absRootDir, _ := filepath.Abs(rootDir)
	return &TFSourcesDir{
		rootDir:     absRootDir,
		modulesDir:  filepath.Join(absRootDir, modulesDir),
		examplesDir: filepath.Join(absRootDir, examplesDir),
	}
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
