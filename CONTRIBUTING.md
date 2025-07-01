# Contributing to AI Agent Docker Environments

Thank you for your interest in contributing to AI Agent Docker Environments! This guide will help you get started.

## Code of Conduct

By participating in this project, you agree to be respectful, inclusive, and constructive in all interactions.

## How to Contribute

### Reporting Issues

1. Check existing issues to avoid duplicates
2. Use issue templates when available
3. Provide clear reproduction steps
4. Include environment details (OS, Docker version, etc.)

### Submitting Pull Requests

1. **Fork the repository** and create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following our standards:
   - Keep commits focused and atomic
   - Write clear commit messages
   - Update documentation as needed
   - Add tests if applicable

3. **Test your changes**:
   - Build the container successfully
   - Run the container and verify functionality
   - Ensure no sensitive data is included

4. **Submit the PR**:
   - Reference any related issues
   - Describe what changes you made and why
   - Include screenshots if relevant

### Adding New Environments

To add a new development environment:

1. **Create directory structure**:
   ```
   environment-name/
   ├── Dockerfile
   ├── docker-compose.yml
   ├── .env.example
   ├── README.md
   ├── setup.sh
   ├── start.sh
   ├── scripts/
   └── config/
   ```

2. **Follow existing patterns**:
   - Use similar authentication setup
   - Include AI agent support
   - Add comprehensive documentation

3. **Security requirements**:
   - No hardcoded credentials
   - Use environment variables
   - Include proper .gitignore

4. **Documentation**:
   - Explain the environment's purpose
   - List included tools and versions
   - Provide usage examples
   - Add troubleshooting section

## Development Guidelines

### Docker Best Practices

- Use specific base image versions (not `latest`)
- Minimize layers by combining RUN commands
- Order instructions from least to most frequently changing
- Clean up package manager caches
- Use non-root users when possible

### Security Standards

1. **Never commit**:
   - API keys or tokens
   - Service account files
   - Private keys or certificates
   - Personal information

2. **Always use**:
   - Environment variables for configuration
   - .env.example templates
   - Read-only mounts for sensitive directories

### Documentation Standards

- Use clear, concise language
- Include code examples
- Keep README files up to date
- Document all environment variables
- Add comments to complex scripts

### Testing

Before submitting:

1. **Build test**:
   ```bash
   docker-compose build --no-cache
   ```

2. **Run test**:
   ```bash
   ./setup.sh
   ./start.sh
   docker exec -it container-name /bin/bash
   ```

3. **Verify**:
   - Authentication works
   - Tools are accessible
   - No errors in logs
   - Documentation is accurate

## Style Guidelines

### Shell Scripts
- Use `#!/bin/bash` shebang
- Set `set -e` for error handling
- Use meaningful variable names
- Add comments for complex logic
- Include usage instructions

### Dockerfiles
- Add comments explaining complex steps
- Group related packages
- Use labels for metadata
- Pin versions where critical

### Documentation
- Use Markdown formatting
- Include table of contents for long docs
- Add code syntax highlighting
- Keep line length reasonable

## Getting Help

- Open an issue for questions
- Join discussions in existing issues
- Tag maintainers for urgent matters
- Check documentation first

## Recognition

Contributors will be acknowledged in:
- Release notes
- Contributors list
- Project documentation

Thank you for helping make AI Agent Docker Environments better!