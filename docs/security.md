# Security Best Practices

This guide covers security considerations for using AI Agent Docker Environments.

## Credential Management

### Never Commit Secrets

The following should **never** be committed to version control:
- API keys (GitHub, Anthropic, OpenAI, etc.)
- Service account JSON files
- Private SSH keys
- Personal access tokens
- Database passwords
- Any `.env` files with real values

### Use Environment Variables

All sensitive configuration should use environment variables:
```bash
# Good - in .env file (git-ignored)
GITHUB_TOKEN=ghp_actualtoken123

# Bad - hardcoded in scripts
export TOKEN="ghp_actualtoken123"
```

### Service Account Security

When using service accounts:

1. **Limit permissions** to only what's needed
2. **Rotate keys** regularly (every 90 days)
3. **Use separate accounts** for different environments
4. **Monitor usage** in cloud console

## Container Security

### Read-Only Mounts

Sensitive host directories are mounted read-only:
```yaml
volumes:
  # Read-only mount prevents container from modifying host
  - ~/.config/gcloud:/home/developer/host-gcloud-config:ro
  - ~/.ssh:/home/developer/.ssh:ro
```

### Non-Root User

Containers run as non-root user `developer`:
- Limits potential damage from compromised container
- Follows principle of least privilege
- Sudo available for legitimate admin tasks

### Network Isolation

Each project uses its own Docker network:
- Containers can't access other project containers
- Host network not exposed by default
- Ports explicitly mapped as needed

## Authentication Security

### Host vs Service Account

**Host Authentication** (Development):
- Uses your existing gcloud credentials
- No keys stored in container
- Automatic credential refresh

**Service Account** (CI/CD):
- Isolated permissions
- Auditable access
- Can be revoked instantly

### Token Scopes

Limit token permissions:
```bash
# GitHub token - minimum required scopes:
- repo (for private repos)
- read:org (for org repos)
- workflow (if using Actions)
```

## Data Protection

### Persistent Volumes

Data in Docker volumes:
- Isolated per project
- Not accessible to other containers
- Cleaned up with container removal

### Workspace Mounting

Mount only required directories:
```bash
# Good - specific project
WORKSPACE_MOUNT=/home/user/my-project

# Bad - entire home directory
WORKSPACE_MOUNT=/home/user
```

## Monitoring & Auditing

### Container Logs

Review container activity:
```bash
# Check authentication attempts
docker logs container-name | grep -i auth

# Monitor file access
docker exec container-name ls -la /home/developer/
```

### Resource Limits

Consider adding resource constraints:
```yaml
services:
  app:
    mem_limit: 4g
    cpus: 2
```

## Incident Response

If credentials are compromised:

1. **Revoke immediately**:
   - GitHub: Settings → Developer settings → Personal access tokens
   - Google Cloud: IAM → Service accounts → Keys
   - Firebase: Project settings → Service accounts

2. **Rotate all related credentials**

3. **Review access logs** for unauthorized usage

4. **Update all environments** with new credentials

## Regular Maintenance

### Monthly Tasks
- Review and remove unused containers
- Update base images for security patches
- Audit environment variables
- Check for exposed ports

### Quarterly Tasks
- Rotate service account keys
- Review IAM permissions
- Update dependencies
- Security scan images

## Security Checklist

Before deploying:
- [ ] No secrets in code or configs
- [ ] `.env` file is git-ignored
- [ ] Service accounts have minimal permissions
- [ ] Tokens have appropriate scopes
- [ ] Sensitive mounts are read-only
- [ ] Container runs as non-root
- [ ] Logs don't contain secrets
- [ ] Documentation doesn't include real credentials

## Reporting Security Issues

If you discover a security vulnerability:
1. **Do not** open a public issue
2. Email security concerns to maintainers
3. Include steps to reproduce
4. Allow time for patch before disclosure