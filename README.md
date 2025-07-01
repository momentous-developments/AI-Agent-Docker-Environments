# AI Agent Docker Environments

A collection of production-ready Docker containers optimized for AI agent development workflows. Each container provides a complete, isolated development environment with pre-configured authentication, tools, and AI integration support.

## 🚀 Available Environments

### [Flutter Web](./flutter-web/)
A Debian-based container optimized for Flutter Web development featuring:
- Flutter 3.32 SDK (Web-only, ~15.9GB)
- Google Chrome, Python tools, Node.js
- Pre-configured authentication for Google Cloud, Firebase, and GitHub
- AI agent integration with Claude Code

### Coming Soon
- **React Web** - Modern React development with TypeScript
- **Python FastAPI** - API development with async support
- **Node.js Express** - JavaScript backend development
- **Rust** - Systems programming environment

## 🎯 Key Features

- **🤖 AI Agent Ready**: Pre-configured for Claude Code, GitHub Copilot, and other AI assistants
- **🔐 Secure Authentication**: Built-in support for cloud services without embedding credentials
- **🛠️ Development Tools**: Language-specific tools, linters, and testing frameworks
- **🎨 Enhanced Terminal**: Oh My Zsh with Powerlevel10k theme
- **📦 Persistent Storage**: Separate volumes for dependencies and caches
- **🌐 Web Development**: Browsers and testing tools included

## 🏃 Quick Start

1. **Choose an environment:**
   ```bash
   cd flutter-web/  # or another environment
   ```

2. **Run setup:**
   ```bash
   ./setup.sh
   ```

3. **Configure `.env`:**
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

4. **Start container:**
   ```bash
   ./start.sh
   ```

## 🔧 Common Configuration

All environments share common configuration patterns:

### Authentication Options

1. **Host Credentials** (Recommended for local development):
   ```bash
   USE_HOST_GCLOUD_AUTH=true
   ```

2. **Service Account** (For CI/CD):
   ```bash
   USE_HOST_GCLOUD_AUTH=false
   GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json
   ```

### Required Environment Variables

```bash
PROJECT_NAME=your-project
WORKSPACE_MOUNT=/path/to/your/code
GITHUB_TOKEN=ghp_YOUR_TOKEN
GOOGLE_CLOUD_PROJECT=your-gcp-project
```

## 🤝 AI Agent Integration

These containers are designed for seamless AI agent workflows:

1. **Automatic Authentication**: Credentials are configured on startup
2. **Helper Scripts**: Common tasks are aliased for easy AI execution
3. **Status Checking**: Built-in commands to verify configuration
4. **Isolated Environment**: Each container is independent

### Example AI Agent Usage
```bash
# AI agent can run:
docker exec -it container-name zsh -c "flutter test"
docker exec -it container-name zsh -c "npm run build"
docker exec -it container-name zsh -c "python scraper.py"
```

## 📚 Documentation

- [Security Best Practices](./docs/security.md)
- [Authentication Guide](./docs/authentication.md)
- [AI Agent Guide](./docs/ai-agents.md)
- [Contributing Guidelines](./CONTRIBUTING.md)

## 🔒 Security

- **No credentials in images**: All secrets via environment variables
- **Read-only mounts**: Host credentials mounted read-only
- **Isolated environments**: Containers don't affect host system
- **Regular updates**: Base images updated monthly

## 🤲 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

### Adding a New Environment

1. Create a new directory with the environment name
2. Include: `Dockerfile`, `docker-compose.yml`, `.env.example`
3. Add setup and start scripts
4. Document in README.md
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see [LICENSE](./LICENSE) file.

## 🙏 Acknowledgments

- Flutter team for the excellent SDK
- Docker for containerization
- Open source community for the tools

---

Made with ❤️ by [Momentous Developments](https://github.com/momentous-developments)