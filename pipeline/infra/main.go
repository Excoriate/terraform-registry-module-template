package main

import (
	"context"
	"dagger/infra/internal/dagger"
	"fmt"
	"path/filepath"
	"strings"
	"time"

	"github.com/google/uuid"
)

const (
	// Default version for binaries
	defaultTerraformVersion = "1.12.0"
	defaultImage            = "hashicorp/terraform"
	defaultImageTag         = "1.12.0"
	defaultMntPath          = "/mnt"
	// Terraform tools
	defaultTFLintVersion        = "0.58.0"
	defaultTerraformDocsVersion = "0.20.0"
	// Default for AWS
	defaultAWSRegion              = "eu-west-1"
	defaultAWSOidcTokenSecretName = "AWS_OIDC_TOKEN"
	// Configuration
	configTerraformModulesRootPath = "modules"
	configTerraformModulesTestPath = "test/modules"
	configTerraformPluginCachePath = "/root/.terraform.d/plugin-cache"
	configTerraformDataDirPath     = "/root/.terraform.d"
	configNetrcRootPath            = "/root/.netrc"
)

// Infra represents a structure that encapsulates operations related to Terraform,
// the Infrastructure as Code tool. This struct can be extended with methods
// that perform various tasks such as executing commands in containers, managing directories,
// and other functionalities that facilitate the use of Terraform in a Dagger pipeline.
type Infra struct {
	// Ctr is a Dagger container that can be used to run Terraform commands
	Ctr *dagger.Container

	// Src is the source code for the Terraform project.
	Src *dagger.Directory
}

func New(
	// ctx is the context for the Dagger container.
	ctx context.Context,

	// imageURL is the URL of the image to use as the base container.
	// It should include tags. E.g. "hashicorp/terraform:1.11.3"
	// +optional
	imageURL string,

	// tfVersion is the Terraform version to use.
	//
	// +optional
	tfVersion string,

	// Ctr is the custom container to use for Terraform operations.
	//
	// +optional
	ctr *dagger.Container,

	// srcDir is the directory to mount as the source code.
	// +optional
	// +defaultPath="/"
	// +ignore=["*", "!**/*.tf", "!**/*.tfvars", "!**/.git/**", "!**/*.tfvars.json", "!*.env"]
	srcDir *dagger.Directory,

	// EnvVars are the environment variables that will be used to run the Terraform commands.
	//
	// +optional
	envVars []string,

	// UseHashicorpImage is a flag to use the Hashicorp image.
	// +optional
	useHashicorpImage bool,
) (*Infra, error) {
	// 1. If useHashicorpImage is true, override everything and use hashicorp image
	if useHashicorpImage {
		mod := &Infra{}
		if tfVersion == "" {
			tfVersion = defaultTerraformVersion
		}
		hashicorpImageWithTag := fmt.Sprintf("%s:%s", defaultImage, tfVersion)
		mod.Ctr = dag.Container().From(hashicorpImageWithTag)

		modWithSRC, modWithSRCError := mod.WithSRC(ctx, defaultMntPath, srcDir)
		if modWithSRCError != nil {
			return nil, WrapErrorf(modWithSRCError, "failed to initialise dagger module with source directory")
		}
		mod = modWithSRC

		mod, enVarError := mod.WithEnvVars(envVars)
		if enVarError != nil {
			return nil, WrapErrorf(enVarError, "failed to initialise dagger module with environment variables")
		}

		// For hashicorp image, terraform is already installed, so skip WithTerraform
		// and only do git installation and plugin cache setup
		mod = mod.
			WithGitPkgInstalled().
			WithTerraformPluginCache()

		return mod, nil
	}

	// 2. If ctr is passed, use that container (takes precedence over imageURL)
	if ctr != nil {
		mod := &Infra{Ctr: ctr}
		mod, enVarError := mod.WithEnvVars(envVars)
		if enVarError != nil {
			return nil, WrapErrorf(enVarError, "failed to initialise dagger module with environment variables")
		}

		modWithSRC, modWithSRCError := mod.WithSRC(ctx, defaultMntPath, srcDir)
		if modWithSRCError != nil {
			return nil, WrapErrorf(modWithSRCError, "failed to initialise dagger module with source directory")
		}

		mod = modWithSRC
		mod = mod.CommonSetup(tfVersion)

		return mod, nil
	}

	// 3. If imageURL is passed, use that image
	if imageURL != "" {
		mod := &Infra{}
		mod.Ctr = dag.Container().From(imageURL)
		modWithSRC, modWithSRCError := mod.WithSRC(ctx, defaultMntPath, srcDir)
		if modWithSRCError != nil {
			return nil, WrapErrorf(modWithSRCError, "failed to initialise dagger module with source directory")
		}

		mod = modWithSRC
		mod, enVarError := mod.WithEnvVars(envVars)

		if enVarError != nil {
			return nil, WrapErrorf(enVarError, "failed to initialise dagger module with environment variables")
		}

		mod = mod.CommonSetup(tfVersion)
		return mod, nil
	}

	// 4. Default: install binaries (use base image + install terraform)
	mod := &Infra{}
	if tfVersion == "" {
		tfVersion = defaultTerraformVersion
	}

	// Use alpine base image for binary installation
	mod.Ctr = dag.Container().From("alpine:latest")

	modWithSRC, modWithSRCError := mod.WithSRC(ctx, defaultMntPath, srcDir)
	if modWithSRCError != nil {
		return nil, WrapErrorf(modWithSRCError, "failed to initialise dagger module with source directory")
	}

	mod = modWithSRC
	mod, enVarError := mod.WithEnvVars(envVars)

	if enVarError != nil {
		return nil, enVarError
	}

	mod = mod.CommonSetup(tfVersion)

	return mod, nil
}

// CommonSetup configures the Terraform container with common dependencies and settings.
// It installs Git, sets up specified Terraform version, and configures
// cache volumes for Terraform plugins and operations.
//
// Parameters:
//   - tfVersion: The version of Terraform to install.
//
// Returns:
//   - The updated Infra instance with common setup applied.
func (m *Infra) CommonSetup(tfVersion string) *Infra {
	m = m.
		WithGitPkgInstalled().
		WithTerraform(tfVersion).
		WithTerraformPluginCache()

	return m
}

// OpenTerminal returns a terminal
//
// It returns a terminal for the container.
// Arguments:
// - ctx: The context for the operation.
// - srcDir: The source directory to be mounted in the container. If nil, the default source directory is used.
// - loadEnvFiles: A boolean to load the environment files.
// Returns:
// - *dagger.Container: The terminal for the container.
func (m *Infra) OpenTerminal(
	// ctx is the context for the operation.
	// +optional
	ctx context.Context,
	// srcDir is the source directory to be mounted in the container.
	// +optional
	srcDir *dagger.Directory,
	// loadEnvFiles is a boolean to load the environment files.
	// +optional
	loadEnvFiles bool,
) *dagger.Container {
	if srcDir == nil {
		srcDir = m.Src
	}

	if loadEnvFiles {
		m.WithDotEnvFile(ctx, m.Src)
	}

	return m.
		Ctr.
		Terminal()
}

// WithSRC mounts a source directory into the Terraform container.
//
// This method sets the working directory and mounts the provided directory,
// preparing the container for source code operations.
//
// Parameters:
//   - dir: A Dagger directory to be mounted in the container
//
// Returns:
//   - The updated Infra instance with source directory mounted
func (m *Infra) WithSRC(
	// ctx is the context for the Dagger container.
	ctx context.Context,
	// workdir is the working directory to set in the container.
	// +optional
	workdir string,
	// dir is the directory to mount in the container.
	dir *dagger.Directory,
) (*Infra, error) {
	if workdir == "" {
		workdir = defaultMntPath
	} else {
		if workdir != defaultMntPath {
			workdir = filepath.Join(defaultMntPath, workdir)
		}
	}

	if err := isNonEmptyDaggerDir(ctx, dir); err != nil {
		return nil, WrapErrorf(err, "failed to validate the src/ directory passed")
	}

	m.Ctr = m.Ctr.
		WithWorkdir(workdir).
		WithMountedDirectory(workdir, dir)

	m.Src = dir

	return m, nil
}

// WithGitPkgInstalled installs the Git package in the container.
//
// This method adds the Git package to the container's package manager.
//
// Returns:
//   - The updated Infra instance with Git installed
func (m *Infra) WithGitPkgInstalled() *Infra {
	m.Ctr = m.Ctr.
		WithExec([]string{"apk", "add", "git"}).
		WithExec([]string{"apk", "add", "openssh"})

	return m
}

// WithTerraformPluginCache mounts a cache volume for Terraform plugins.
//
// This method sets up a cache directory for Terraform plugins and mounts it into the container.
// It sets the TF_PLUGIN_CACHE_DIR environment variable to enable plugin caching.
//
// Returns:
//   - The updated Infra instance with the plugin cache mounted
func (m *Infra) WithTerraformPluginCache() *Infra {
	m.Ctr = m.Ctr.
		WithExec([]string{"mkdir", "-p", configTerraformPluginCachePath}).
		WithExec([]string{"chmod", "755", configTerraformPluginCachePath}).
		WithMountedCache(configTerraformPluginCachePath, dag.CacheVolume("terraform-plugin-cache")).
		WithEnvVariable("TF_PLUGIN_CACHE_DIR", configTerraformPluginCachePath)

	return m
}

// WithTerraformDataDir sets a custom data directory for Terraform.
//
// This method sets the TF_DATA_DIR environment variable to specify where Terraform
// should store its internal data (plugins, modules, etc.).
//
// Parameters:
//   - dataDir: The path to the data directory
//
// Returns:
//   - The updated Infra instance with the custom data directory set
func (m *Infra) WithTerraformDataDir(dataDir string) *Infra {
	if dataDir == "" {
		dataDir = configTerraformDataDirPath
	}

	m.Ctr = m.Ctr.
		WithExec([]string{"mkdir", "-p", dataDir}).
		WithEnvVariable("TF_DATA_DIR", dataDir)

	return m
}

// WithCacheBuster enables the cache buster for the container.
//
// This method sets the environment variable DAGGER_APT_CACHE_BUSTER to a unique value based on the current time.
//
// Returns:
//   - The updated Infra instance with the cache buster enabled
func (m *Infra) WithCacheBuster() *Infra {
	m.Ctr = m.Ctr.
		WithEnvVariable("DAGGER_OPT_CACHE_BUSTER", fmt.Sprintf("%d", time.Now().Truncate(24*time.Hour).Unix()))

	return m
}

// WithSecrets mounts secrets into the container.
//
// This method mounts secrets into the container for use by Terraform.
//
// Parameters:
//   - ctx: The context for the operation
//   - secrets: A slice of dagger.Secret instances to be mounted
//
// Returns:
//   - The updated Infra instance with secrets mounted
func (m *Infra) WithSecrets(ctx context.Context, secrets []*dagger.Secret) *Infra {
	for _, secret := range secrets {
		// FIXME: This is suitable when secrets are created within dagger. Assumming there's a name set.
		secretName, _ := secret.Name(ctx)

		m.Ctr = m.
			Ctr.
			WithSecretVariable(secretName, secret)
	}

	return m
}

// WithEnvVars adds environment variables to the Terraform container.
//
// This method allows setting multiple environment variables in key=value format.
// It performs validation to ensure each environment variable is correctly formatted.
//
// Parameters:
//   - envVars: A slice of environment variables in "KEY=VALUE" format
//
// Returns:
//   - The updated Infra instance with environment variables set
//   - An error if any environment variable is incorrectly formatted
func (m *Infra) WithEnvVars(envVars []string) (*Infra, error) {
	envVarsDagger, err := getEnvVarsDaggerFromSlice(envVars)

	if err != nil {
		return nil, err
	}

	for _, envVar := range envVarsDagger {
		m.Ctr = m.Ctr.WithEnvVariable(envVar.Key, envVar.Value)
	}

	return m, nil
}

// WithToken adds a token to the Terraform container.
//
// This method adds a token to the container, making it available as an environment variable.
//
// Parameters:
//   - ctx: The context for the Dagger container.
//   - tokenValue: The value of the token to add to the container.
//
// Returns:
//   - The updated Infra instance with the token added
func (m *Infra) WithToken(ctx context.Context, tokenValue *dagger.Secret) *Infra {
	return m.WithSecrets(ctx, []*dagger.Secret{tokenValue})
}

// WithTerraform sets the Terraform version to use and installs it.
// It takes a version string as an argument and returns a pointer to a dagger.Container.
func (m *Infra) WithTerraform(version string) *Infra {
	tfInstallationCmd := getTFInstallCmd(version)
	m.Ctr = m.Ctr.
		WithExec([]string{"/bin/sh", "-c", tfInstallationCmd}).
		WithExec([]string{"terraform", "--version"})

	return m
}

// WithTFLint installs TFLint tool in the container.
//
// This method installs TFLint (a Terraform linter) using its installation method. If version is not specified, the latest version
// will be installed.
//
// Parameters:
//   - tflintVersion: The TFLint version to install (optional, defaults to latest)
//
// Returns:
//   - The updated Infra instance with TFLint installed
func (m *Infra) WithTFLint(tflintVersion string) *Infra {
	if tflintVersion == "" {
		tflintVersion = defaultTFLintVersion
	}

	// Install TFLint using the official installation script
	tflintInstallCmd := getTFLintInstallCmd(tflintVersion)

	m.Ctr = m.Ctr.
		// Install TFLint
		WithExec([]string{"/bin/sh", "-c", tflintInstallCmd}).
		WithExec([]string{"tflint", "--version"})

	return m
}

// WithTerraformDocs installs terraform-docs tool in the container.
//
// This method installs terraform-docs (documentation generator) using its installation method. If version is not specified, the latest version
// will be installed.
//
// Parameters:
//   - terraformDocsVersion: The terraform-docs version to install (optional, defaults to latest)
//
// Returns:
//   - The updated Infra instance with terraform-docs installed
func (m *Infra) WithTerraformDocs(terraformDocsVersion string) *Infra {
	if terraformDocsVersion == "" {
		terraformDocsVersion = defaultTerraformDocsVersion
	}

	// Install terraform-docs using binary download
	terraformDocsInstallCmd := getTerraformDocsInstallCmd(terraformDocsVersion)

	m.Ctr = m.Ctr.
		// Install terraform-docs
		WithExec([]string{"/bin/sh", "-c", terraformDocsInstallCmd}).
		WithExec([]string{"terraform-docs", "--version"})

	return m
}

// WithNewNetrcFileGitHub creates a new .netrc file with the GitHub credentials.
//
// The .netrc file is created in the root directory of the container.
func (m *Infra) WithNewNetrcFileGitHub(
	username string,
	password string,
) *Infra {
	machineCMD := "machine github.com\nlogin " + username + "\npassword " + password + "\n"

	m.Ctr = m.Ctr.WithNewFile(configNetrcRootPath, machineCMD)

	return m
}

// WithNewNetrcFileAsSecretGitHub creates a new .netrc file with the GitHub credentials.
//
// The .netrc file is created in the root directory of the container.
// The argument 'password' is a secret that is not exposed in the logs.
func (m *Infra) WithNewNetrcFileAsSecretGitHub(username string, password *dagger.Secret) *Infra {
	passwordTxtValue, _ := password.Plaintext(context.Background())
	machineCMD := fmt.Sprintf("machine github.com\nlogin %s\npassword %s\n", username, passwordTxtValue)
	//nolint:exhaustruct // This is a method that is used to set the base image and version.
	m.Ctr = m.Ctr.WithNewFile(configNetrcRootPath, machineCMD)

	return m
}

// WithNewNetrcFileGitLab creates a new .netrc file with the GitLab credentials.
//
// The .netrc file is created in the root directory of the container.
func (m *Infra) WithNewNetrcFileGitLab(
	username string,
	password string,
) *Infra {
	machineCMD := "machine gitlab.com\nlogin " + username + "\npassword " + password + "\n"

	m.Ctr = m.Ctr.WithNewFile(configNetrcRootPath, machineCMD)

	return m
}

// WithNewNetrcFileAsSecretGitLab creates a new .netrc file with the GitLab credentials.
//
// The .netrc file is created in the root directory of the container.
// The argument 'password' is a secret that is not exposed in the logs.
func (m *Infra) WithNewNetrcFileAsSecretGitLab(username string, password *dagger.Secret) *Infra {
	passwordTxtValue, _ := password.Plaintext(context.Background())
	machineCMD := fmt.Sprintf("machine gitlab.com\nlogin %s\npassword %s\n", username, passwordTxtValue)

	//nolint:exhaustruct // This is a method that is used to set the base image and version.
	m.Ctr = m.Ctr.WithNewFile(configNetrcRootPath, machineCMD)

	return m
}

// WithSSHAuthSocket configures SSH authentication for Terraform modules with Git SSH sources.
//
// This function mounts an SSH authentication socket into the container, enabling Terraform to authenticate
// when fetching modules from Git repositories using SSH URLs (e.g., git@github.com:org/repo.git).
//
// Parameters:
//   - sshAuthSocket: The SSH authentication socket to mount in the container.
//   - socketPath: The path where the SSH socket will be mounted in the container.
//   - owner: Optional. The owner of the mounted socket in the container.
//
// Returns:
//   - *Infra: The updated Infra instance with SSH authentication configured for Terraform modules.
func (m *Infra) WithSSHAuthSocket(
	// sshAuthSocket is the SSH socket to use for authentication.
	sshAuthSocket *dagger.Socket,
	// socketPath is the path where the SSH socket will be mounted in the container.
	// +optional
	socketPath string,
	// owner is the owner of the mounted socket in the container. Optional parameter.
	// +optional
	owner string,
	// enableGitlabKnownHosts adds the Gitlab known hosts to the container.
	// +optional
	enableGitlabKnownHosts bool,
	// enableGithubKnownHosts adds the Github known hosts to the container.
	// +optional
	enableGithubKnownHosts bool,
) *Infra {
	// Default the socket path if not provided
	if socketPath == "" {
		socketPath = "/var/run/host.sock"
	}

	socketOpts := dagger.ContainerWithUnixSocketOpts{}

	if owner != "" {
		socketOpts.Owner = owner
	}

	// Ensure .ssh directory exists before running ssh-keyscan
	m.Ctr = m.Ctr.WithExec([]string{"mkdir", "-p", "/root/.ssh"})

	if enableGitlabKnownHosts {
		m.Ctr = m.Ctr.
			WithExec([]string{"sh", "-c", "ssh-keyscan gitlab.com >> /root/.ssh/known_hosts"})
	}

	if enableGithubKnownHosts {
		m.Ctr = m.Ctr.
			WithExec([]string{"sh", "-c", "ssh-keyscan github.com >> /root/.ssh/known_hosts"})
	}

	m.Ctr = m.Ctr.
		WithExec([]string{"chmod", "600", "/root/.ssh/known_hosts"})

	m.Ctr = m.Ctr.WithUnixSocket(socketPath, sshAuthSocket, socketOpts).
		WithEnvVariable("SSH_AUTH_SOCK", socketPath)

	return m
}

// WithTerraformLogLevel sets the Terraform log level in the container.
//
// This method sets the TF_LOG environment variable to control Terraform's logging output.
// Valid levels: trace, debug, info, warn, error, or off
//
// Parameters:
//   - level: The log level to set (trace, debug, info, warn, error, off)
func (m *Infra) WithTerraformLogLevel(level string) *Infra {
	if level == "" {
		return m
	}

	level = strings.ToLower(level)

	m.Ctr = m.Ctr.WithEnvVariable("TF_LOG", level)

	return m
}

// WithTerraformLogPath sets the Terraform log output file path.
//
// This method sets the TF_LOG_PATH environment variable to specify where Terraform
// should write its log output. TF_LOG must also be set for logging to occur.
//
// Parameters:
//   - logPath: The path to the log file
func (m *Infra) WithTerraformLogPath(logPath string) *Infra {
	if logPath == "" {
		return m
	}

	m.Ctr = m.Ctr.WithEnvVariable("TF_LOG_PATH", logPath)

	return m
}

// WithTerraformInput controls whether Terraform prompts for input.
//
// This method sets the TF_INPUT environment variable to control interactive prompts.
// Setting to false prevents Terraform from prompting for input variables.
//
// Parameters:
//   - allowInput: Whether to allow Terraform to prompt for input (true/false)
func (m *Infra) WithTerraformInput(allowInput bool) *Infra {
	var inputValue string
	if allowInput {
		inputValue = "1"
	} else {
		inputValue = "0"
	}

	m.Ctr = m.Ctr.WithEnvVariable("TF_INPUT", inputValue)

	return m
}

// WithTerraformWorkspace sets the Terraform workspace.
//
// This method sets the TF_WORKSPACE environment variable to select a specific workspace.
//
// Parameters:
//   - workspace: The name of the workspace to select
func (m *Infra) WithTerraformWorkspace(workspace string) *Infra {
	if workspace == "" {
		return m
	}

	m.Ctr = m.Ctr.WithEnvVariable("TF_WORKSPACE", workspace)

	return m
}

// WithAWSCredentials sets the AWS credentials and region in the container.
//
// This method sets the AWS credentials and region in the container, making them available as environment variables.
// It also mounts the AWS credentials as secrets into the container.
//
// Parameters:
//   - ctx: The context for the Dagger container.
//   - awsAccessKeyID: The AWS access key ID.
//   - awsSecretAccessKey: The AWS secret access key.
//   - awsRegion: The AWS region.
//
// Returns:
//   - *Infra: The updated Infra instance with AWS credentials and region set
func (m *Infra) WithAWSKeys(
	// ctx is the context for the Dagger container.
	// +optional
	ctx context.Context,
	// awsAccessKeyID is the AWS access key ID.
	awsAccessKeyID *dagger.Secret,
	// awsSecretAccessKey is the AWS secret access key.
	awsSecretAccessKey *dagger.Secret,
	// awsRegion is the AWS region.
	// +optional
	awsRegion string,
	// awsSessionToken is the AWS session token.
	// +optional
	awsSessionToken *dagger.Secret,
) *Infra {
	awsRegion = getDefaultAWSRegionIfNotSet(awsRegion)

	m.Ctr = m.Ctr.
		WithEnvVariable("AWS_REGION", awsRegion).
		WithSecretVariable("AWS_ACCESS_KEY_ID", awsAccessKeyID).
		WithSecretVariable("AWS_SECRET_ACCESS_KEY", awsSecretAccessKey)

	if awsSessionToken != nil {
		m.Ctr = m.Ctr.
			WithSecretVariable("AWS_SESSION_TOKEN", awsSessionToken)
	}

	return m
}

// WithAWSOIDC sets the AWS OIDC credentials in the container.
//
// This method sets the AWS OIDC credentials in the container, making them available as environment variables.
// It also mounts the AWS OIDC credentials as secrets into the container.
func (m *Infra) WithAWSOIDC(
	// roleARN is the ARN of the IAM role to assume.
	roleARN string,
	// oidcToken is the Dagger Secret containing the OIDC JWT token from GitLab.
	oidcToken *dagger.Secret,
	// oidcTokenName is the name of the secret containing the OIDC JWT token from GitLab.
	// +optional
	oidcTokenName string,
	// awsRegion is the AWS region.
	// +optional
	awsRegion string,
	// awsRoleSessionName is an optional name for the assumed role session.
	// +optional
	awsRoleSessionName string,
) *Infra {
	awsRegion = getDefaultAWSRegionIfNotSet(awsRegion)

	if oidcTokenName == "" {
		oidcTokenName = defaultAWSOidcTokenSecretName
	}

	if awsRoleSessionName == "" {
		awsRoleSessionName = fmt.Sprintf("terragrunt-dagger-%s", uuid.New().String())
	}

	oidcTokenPath := "run/secrets/" + oidcTokenName

	m.Ctr = m.Ctr.
		WithEnvVariable("AWS_REGION", awsRegion).
		WithEnvVariable("AWS_ROLE_ARN", roleARN).
		WithEnvVariable("AWS_ROLE_SESSION_NAME", awsRoleSessionName).
		WithEnvVariable("AWS_WEB_IDENTITY_TOKEN_FILE", oidcTokenPath).
		// cleaning —if set— aws keys.
		WithoutEnvVariable("AWS_ACCESS_KEY_ID").
		WithoutEnvVariable("AWS_SECRET_ACCESS_KEY").
		WithoutEnvVariable("AWS_SESSION_TOKEN").
		WithSecretVariable(oidcTokenName, oidcToken)

	return m
}

// WithGitlabToken sets the GitLab token in the container.
//
// This method sets the GitLab token in the container, making it available as an environment variable.
//
// Parameters:
//   - ctx: The context for the Dagger container.
func (m *Infra) WithGitlabToken(ctx context.Context, token *dagger.Secret) *Infra {
	m.Ctr = m.Ctr.
		WithSecretVariable("GITLAB_TOKEN", token)

	return m
}

// WithGitHubToken sets the GitHub token in the container.
//
// This method sets the GitHub token in the container, making it available as an environment variable.
//
// Parameters:
//   - ctx: The context for the Dagger container.
func (m *Infra) WithGitHubToken(ctx context.Context, token *dagger.Secret) *Infra {
	m.Ctr = m.Ctr.
		WithSecretVariable("GITHUB_TOKEN", token)

	return m
}

// WithTerraformToken sets the Terraform token in the container.
//
// This method sets the Terraform token in the container, making it available as an environment variable.
//
// Parameters:
//   - ctx: The context for the Dagger container.
//   - token: The Terraform token to set.
func (m *Infra) WithTerraformToken(ctx context.Context, token *dagger.Secret) *Infra {
	m.Ctr = m.Ctr.
		WithSecretVariable("TF_TOKEN", token)

	return m
}

// WithTerraformRegistryClientTimeout sets the timeout for Terraform registry requests.
//
// This method sets the TF_REGISTRY_CLIENT_TIMEOUT environment variable to configure
// the timeout duration (in seconds) for requests to the Terraform Registry.
//
// Parameters:
//   - timeoutSeconds: The timeout in seconds (default is 10)
func (m *Infra) WithTerraformRegistryClientTimeout(timeoutSeconds int) *Infra {
	if timeoutSeconds <= 0 {
		timeoutSeconds = 10 // Default timeout
	}

	m.Ctr = m.Ctr.WithEnvVariable("TF_REGISTRY_CLIENT_TIMEOUT", fmt.Sprintf("%d", timeoutSeconds))

	return m
}

// WithTerraformStatePersistInterval sets the state persistence interval.
//
// This method sets the TF_STATE_PERSIST_INTERVAL environment variable to define
// the interval (in seconds) at which Terraform persists state to remote backend.
//
// Parameters:
//   - intervalSeconds: The interval in seconds (minimum 20)
func (m *Infra) WithTerraformStatePersistInterval(intervalSeconds int) *Infra {
	if intervalSeconds < 20 {
		intervalSeconds = 20 // Minimum interval
	}

	m.Ctr = m.Ctr.WithEnvVariable("TF_STATE_PERSIST_INTERVAL", fmt.Sprintf("%d", intervalSeconds))

	return m
}

// WithTerraformCLIConfigFile sets a custom CLI configuration file path.
//
// This method sets the TF_CLI_CONFIG_FILE environment variable to specify
// a non-default path for the Terraform CLI configuration file.
//
// Parameters:
//   - configPath: The path to the CLI configuration file
func (m *Infra) WithTerraformCLIConfigFile(configPath string) *Infra {
	if configPath == "" {
		return m
	}

	m.Ctr = m.Ctr.WithEnvVariable("TF_CLI_CONFIG_FILE", configPath)

	return m
}

// WithDotEnvFile loads and processes environment variables from .env files in the provided directory.
//
// This method finds all .env files in the given directory, reads their contents, and sets
// environment variables in the Terraform container. Files containing "secret" in their name
// will have their values added as secret variables rather than regular environment variables.
//
// The method supports standard .env file formats with KEY=VALUE pairs on each line.
// Comments (lines starting with #) and empty lines are ignored. Values can be optionally
// quoted with single or double quotes, which will be automatically removed.
//
// Parameters:
//   - ctx: Context for the Dagger operations
//   - src: Directory containing the .env files to process
//
// Returns:
//   - *Infra: The updated Infra instance with environment variables set
//   - error: An error if file reading or parsing fails
func (m *Infra) WithDotEnvFile(ctx context.Context, src *dagger.Directory) (*Infra, error) {
	if src == nil {
		return nil, NewError("failed to load .env file, the source directory is nil")
	}

	// Check if there's any dotenv file on the source directory passed, or set.
	entries, err := src.Entries(ctx)
	if err != nil {
		return nil, WrapErrorf(err, "failed to list files in source directory")
	}

	foundDotEnvFiles := []string{}
	for _, entry := range entries {
		if strings.HasSuffix(entry, ".env") {
			foundDotEnvFiles = append(foundDotEnvFiles, entry)
		}
	}

	if len(foundDotEnvFiles) == 0 {
		return nil, NewError("No .env files found when inspecting the source directory")
	}

	dotEnvFilesInSrc, srcError := src.Glob(ctx, "*.env")

	if srcError != nil {
		return nil, WrapErrorf(srcError, "failed to glob dot env files")
	}

	ctrWithDotEnvFiles, dotEnvFilesParseErr := parseDotEnvFiles(ctx, m.Ctr, src, dotEnvFilesInSrc)

	if dotEnvFilesParseErr != nil {
		return nil, WrapErrorf(dotEnvFilesParseErr, "failed to parse dot env files")
	}

	m.Ctr = ctrWithDotEnvFiles

	return m, nil
}

// WithTerraformCLIArgs sets default command-line arguments for all Terraform commands.
//
// This method sets the TF_CLI_ARGS environment variable to specify additional
// command-line arguments that apply to all Terraform commands.
//
// Parameters:
//   - args: The command-line arguments to add to all Terraform commands
func (m *Infra) WithTerraformCLIArgs(args string) *Infra {
	if args == "" {
		return m
	}

	m.Ctr = m.Ctr.WithEnvVariable("TF_CLI_ARGS", args)

	return m
}

// WithTerraformCLIArgsForCommand sets command-specific arguments for a specific Terraform command.
//
// This method sets the TF_CLI_ARGS_<command> environment variable to specify additional
// command-line arguments for a specific Terraform command (e.g., plan, apply).
//
// Parameters:
//   - command: The Terraform command (e.g., "plan", "apply", "destroy")
//   - args: The command-line arguments to add to the specific command
func (m *Infra) WithTerraformCLIArgsForCommand(command, args string) *Infra {
	if command == "" || args == "" {
		return m
	}

	envVar := fmt.Sprintf("TF_CLI_ARGS_%s", command)
	m.Ctr = m.Ctr.WithEnvVariable(envVar, args)

	return m
}

// WithTerraformVariable sets a Terraform input variable using TF_VAR_ environment variables.
//
// This method sets a TF_VAR_<name> environment variable to provide input variables to Terraform.
// Terraform will use these environment variables when variable values are not specified elsewhere.
//
// Parameters:
//   - name: The variable name (will be prefixed with TF_VAR_)
//   - value: The variable value
func (m *Infra) WithTerraformVariable(name, value string) *Infra {
	if name == "" || value == "" {
		return m
	}

	envVar := fmt.Sprintf("TF_VAR_%s", name)
	m.Ctr = m.Ctr.WithEnvVariable(envVar, value)

	return m
}

// WithTerraformVariables sets multiple Terraform input variables at once.
//
// This method takes a slice of "KEY=VALUE" strings and sets them as TF_VAR_ environment variables.
// This approach works around Dagger's limitation with map arguments.
//
// Parameters:
//   - variables: A slice of strings in "KEY=VALUE" format (e.g., ["env=production", "region=us-west-2"])
//
// Returns:
//   - *Infra: The updated Infra instance with variables set
//   - error: An error if any variable string is malformed
func (m *Infra) WithTerraformVariables(variables []string) (*Infra, error) {
	if len(variables) == 0 {
		return m, nil
	}

	parsedVars, err := parseVariablesFromSlice(variables)
	if err != nil {
		return nil, WrapErrorf(err, "failed to parse terraform variables")
	}

	for name, value := range parsedVars {
		if name != "" && value != "" {
			envVar := fmt.Sprintf("TF_VAR_%s", name)
			m.Ctr = m.Ctr.WithEnvVariable(envVar, value)
		}
	}

	return m, nil
}

// WithoutTracingToDagger disables tracing to Dagger in the container.
//
// This method disables tracing to Dagger in the container, making it available as an environment variable.
func (m *Infra) WithoutTracingToDagger() *Infra {
	m.Ctr = m.Ctr.
		WithEnvVariable("NOTHANKS", "1")

	return m
}

// WithTerraformCloudOrganization sets the Terraform Cloud organization via environment variable.
//
// This method sets the TF_CLOUD_ORGANIZATION environment variable for Terraform Cloud configuration.
//
// Parameters:
//   - organization: The Terraform Cloud organization name
func (m *Infra) WithTerraformCloudOrganization(organization string) *Infra {
	if organization == "" {
		return m
	}

	m.Ctr = m.Ctr.WithEnvVariable("TF_CLOUD_ORGANIZATION", organization)

	return m
}

// WithTerraformRegistryGitlabToken sets the Terraform Gitlab token in the container.
//
// This method sets the Terraform Gitlab token in the container, making it available as an environment variable.
//
// Parameters:
//   - ctx: The context for the Dagger container.
func (m *Infra) WithTerraformRegistryGitlabToken(ctx context.Context, token *dagger.Secret) *Infra {
	m.Ctr = m.Ctr.
		WithSecretVariable("TF_TOKEN_gitlab_com", token)

	return m
}

// WithTerraformCloudHostname sets the Terraform Cloud hostname via environment variable.
//
// This method sets the TF_CLOUD_HOSTNAME environment variable for custom Terraform Cloud instances.
//
// Parameters:
//   - hostname: The Terraform Cloud hostname (defaults to app.terraform.io)
func (m *Infra) WithTerraformCloudHostname(hostname string) *Infra {
	if hostname == "" {
		return m
	}

	m.Ctr = m.Ctr.WithEnvVariable("TF_CLOUD_HOSTNAME", hostname)

	return m
}

// WithTerraformLogLevelWithValidation sets the Terraform log level with validation.
//
// This method sets the TF_LOG environment variable with validation of log levels.
// Valid levels: trace, debug, info, warn, error, off
//
// Parameters:
//   - level: The log level to set
func (m *Infra) WithTerraformLogLevelWithValidation(level string) (*Infra, error) {
	validLevels := map[string]bool{
		"trace": true,
		"debug": true,
		"info":  true,
		"warn":  true,
		"error": true,
		"off":   true,
	}

	if level == "" {
		level = "info"
	}

	level = strings.ToLower(level)

	if !validLevels[level] {
		return nil, NewError(fmt.Sprintf("Invalid Terraform log level: %s. Must be one of: trace, debug, info, warn, error, off", level))
	}

	m.Ctr = m.Ctr.WithEnvVariable("TF_LOG", level)

	return m, nil
}

// WithTerraformParallelism sets the parallelism level for Terraform operations.
//
// This method sets the -parallelism flag value via TF_CLI_ARGS.
// This controls the number of concurrent operations during apply/plan.
//
// Parameters:
//   - parallelism: The number of concurrent operations to allow
func (m *Infra) WithTerraformParallelism(parallelism int) *Infra {
	if parallelism <= 0 {
		parallelism = 10 // Default parallelism
	}

	args := fmt.Sprintf("-parallelism=%d", parallelism)
	m.Ctr = m.Ctr.WithEnvVariable("TF_CLI_ARGS", args)

	return m
}

// WithTerraformNoInput ensures Terraform doesn't prompt for input.
//
// This is a convenience method that sets TF_INPUT=false to prevent
// interactive prompts during Terraform operations.
func (m *Infra) WithTerraformNoInput() *Infra {
	m.Ctr = m.Ctr.WithEnvVariable("TF_INPUT", "0")

	return m
}

// WithDotTerraformVersionFileGeneration generates a .terraform-version file with the specified version.
//
// This method creates a new file named "TF_VERSION_FILE" and writes the specified Terraform version into it.
// If the provided version string is empty, the method does nothing and returns the current Infra instance.
//
// Parameters:
//   - tfVersion: The version of Terraform to be written into the file
//
// Returns:
//   - The current Infra instance
func (m *Infra) WithDotTerraformVersionFileGeneration(tfVersion string) *Infra {
	if tfVersion == "" {
		return m
	}

	versionFileContent := fmt.Sprintf("%s", tfVersion)

	m.Ctr = m.Ctr.WithNewFile("TF_VERSION_FILE", versionFileContent)

	return m
}
