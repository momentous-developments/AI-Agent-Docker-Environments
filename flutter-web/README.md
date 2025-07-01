# Flutter Web Docker Development Environment

A production-ready Docker container optimized for Flutter Web development with AI agent support. This container provides a complete development environment with authentication, testing tools, and AI integration capabilities.

## Features

- 🐳 **Debian 12 base** with Flutter 3.32 SDK (Web-only, no mobile SDKs)
- 🔐 **Secure authentication** for Google Cloud, Firebase, and GitHub
- 🤖 **AI agent ready** with Claude Code and Python web scraping tools
- 🌐 **Chrome browser** for web testing (not Chromium)
- 🛠️ **Development tools** including Node.js, Python, and testing frameworks
- 🎨 **Enhanced terminal** with Oh My Zsh and Powerlevel10k
- 📦 **Persistent volumes** for Flutter SDK, pub cache, and npm packages

## Quick Start

1. **Clone this repository:**
   ```bash
   git clone https://github.com/momentous-developments/AI-Agent-Docker-Environments.git
   cd AI-Agent-Docker-Environments/flutter-web
   ```

2. **Run the setup script:**
   ```bash
   ./setup.sh
   ```

3. **Configure your environment:**
   Edit the `.env` file with your settings:
   - Set your `PROJECT_NAME`
   - Add your `GITHUB_TOKEN`
   - Configure Google Cloud authentication
   - Set your `WORKSPACE_MOUNT` path

4. **Start the container:**
   ```bash
   ./start.sh
   ```

5. **Access the container:**
   ```bash
   docker exec -it flutter-web-dev zsh
   ```

## Configuration

### Environment Variables

Copy `.env.example` to `.env` and configure:

```bash
# Essential configuration
PROJECT_NAME=your-project-name
WORKSPACE_MOUNT=/path/to/your/flutter/project
GITHUB_TOKEN=ghp_YOUR_TOKEN_HERE
GOOGLE_CLOUD_PROJECT=your-gcp-project
```

### Authentication Methods

#### Option 1: Service Account Key (RECOMMENDED)
Service accounts provide persistent, non-expiring authentication ideal for containers.

**Quick Setup:**
1. Download service account key from GCP Console
2. Place in `./auth/service-account-key.json`
3. Start container - authentication is automatic!

See [SERVICE_ACCOUNT_SETUP.md](./SERVICE_ACCOUNT_SETUP.md) for detailed instructions.

#### Option 2: Host GCloud Credentials (Local development only)
```bash
# In .env file:
USE_HOST_GCLOUD_AUTH=true
GOOGLE_APPLICATION_CREDENTIALS=
```
⚠️ **Warning**: Host credentials may expire and cause authentication errors.

## Included Tools

### Development
- Flutter 3.32 (Web-only)
- Node.js 18 with npm
- Python 3.11 with pip
- Git with GitHub CLI
- Google Cloud SDK
- Firebase CLI

### Testing & Quality
- Google Chrome (official)
- Lighthouse
- Puppeteer & Playwright
- Jest
- Axe-core (accessibility)
- Web Vitals

### Python Packages
- BeautifulSoup4
- Requests
- Pillow (PIL)
- Selenium
- Pandas & NumPy

### AI Integration
- Claude Code CLI
- Anthropic API support
- OpenAI API support (configurable)
- MCP Servers:
  - Context7 (SSE transport)
  - Playwright (browser automation)

## Container Commands

### Helper Aliases
```bash
# Flutter shortcuts
flw         # Run Flutter web server
flb         # Flutter build
flt         # Flutter test
flc         # Flutter clean

# Quick commands
quick-serve # Run web server from current directory
quick-build # Build web app
quick-test  # Run tests
quick-fix   # Apply dart fixes

# Container info
container-status # Show full configuration status
```

### Working with AI Agents

The container is optimized for AI agent usage:

1. **Authentication is automatic** - credentials are set up on container start
2. **Python packages** are pre-installed for web scraping
3. **Helper scripts** streamline common tasks
4. **Status checking** with `container-status` command
5. **Working directory stability** - `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` prevents `cd` commands from permanently changing the directory, avoiding AI agent confusion

## Security Best Practices

1. **Never commit sensitive files:**
   - `.env` files
   - Service account JSON files
   - API keys or tokens

2. **Use environment variables** for all secrets

3. **Review `.gitignore`** before committing

4. **Rotate credentials** regularly

## Customization

### Adding Python Packages
Edit the Dockerfile:
```dockerfile
RUN pip3 install --user --break-system-packages \
    your-package-here
```

### Adding NPM Packages
Edit the Dockerfile:
```dockerfile
RUN npm install -g \
    your-package-here
```

### Changing Flutter Version
Update in `.env`:
```bash
FLUTTER_VERSION=3.33.0
```

## Troubleshooting

### Container won't start
- Check port conflicts: `docker ps`
- Review logs: `docker-compose logs`
- Ensure Docker daemon is running

### Playwright browser issues
If Playwright browsers fail to launch, try running the container with:
```bash
docker run --ipc=host --init --cap-add=SYS_ADMIN your-container
```
- `--ipc=host`: Prevents Chromium memory issues
- `--init`: Prevents zombie processes
- `--cap-add=SYS_ADMIN`: Required for Chromium sandbox

### Authentication issues
- For host auth: Run `gcloud auth login` on host
- For service account: Check JSON file in `./auth/`
- GitHub: Ensure token has correct permissions

### Permission errors
- Ensure workspace mount path exists
- Check file ownership matches container user

## Contributing

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see [LICENSE](../../LICENSE) file.