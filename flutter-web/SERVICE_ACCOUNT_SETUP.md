# Service Account Setup Guide

This guide explains how to set up Google Cloud service account authentication for your Flutter Web Docker container. Service accounts provide persistent, non-expiring authentication that's ideal for containers and CI/CD environments.

## Why Use Service Accounts?

- **No token expiration**: Unlike user credentials, service accounts don't expire
- **No interactive prompts**: Perfect for automated environments
- **Project isolation**: Each container can use its own service account
- **Works for both Google Cloud and Firebase**: One authentication method for all services
- **Secure**: Keys can be rotated and permissions limited

## Step 1: Create a Service Account

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your project
3. Navigate to **IAM & Admin** → **Service Accounts**
4. Click **Create Service Account**
5. Fill in the details:
   - **Name**: `flutter-dev-container` (or your preferred name)
   - **ID**: Will auto-generate
   - **Description**: "Service account for Flutter development container"
6. Click **Create and Continue**

## Step 2: Assign Permissions

Grant the necessary roles based on your needs:

### Basic Development
- `Firebase Admin` - Full Firebase access
- `Storage Admin` - For Firebase Storage
- `Cloud Datastore User` - For Firestore

### Advanced Usage
- `Project Editor` - Broad permissions (use cautiously)
- `Cloud Build Editor` - For CI/CD pipelines
- `App Engine Admin` - For deployments

Click **Continue** after selecting roles.

## Step 3: Create and Download Key

1. On the service account page, click **Done**
2. Find your service account in the list and click on it
3. Go to the **Keys** tab
4. Click **Add Key** → **Create new key**
5. Choose **JSON** format
6. Click **Create**
7. The key file will download automatically

## Step 4: Set Up the Container

1. **Create auth directory** in your project:
   ```bash
   mkdir -p ./auth
   ```

2. **Move the key file**:
   ```bash
   mv ~/Downloads/your-project-xxxxx.json ./auth/service-account-key.json
   ```

3. **Update .gitignore** (IMPORTANT):
   ```bash
   echo "auth/" >> .gitignore
   ```

4. **Configure .env file**:
   ```env
   # These are the defaults - no need to change if using standard setup
   USE_HOST_GCLOUD_AUTH=false
   GOOGLE_APPLICATION_CREDENTIALS=/home/developer/.gcloud/service-account-key.json
   
   # Optional: Set project ID (will be auto-detected from key)
   GOOGLE_CLOUD_PROJECT=your-project-id
   ```

## Step 5: Start the Container

```bash
./start.sh
```

The container will automatically:
- Detect the service account key
- Authenticate with Google Cloud
- Extract the project ID from the key
- Configure Firebase with the same credentials
- Set up Application Default Credentials

## Verification

Once the container starts, verify authentication:

```bash
docker exec -it flutter-web-dev bash -c "gcloud auth list"
```

You should see your service account email listed as ACTIVE.

## Troubleshooting

### "No service account found"
- Check that `./auth/service-account-key.json` exists
- Ensure the file is valid JSON
- Verify volume mount in docker-compose.yml

### "Invalid service account key"
- The JSON file may be corrupted
- Download a fresh key from GCP Console
- Check file permissions

### Project mismatch
- The service account key contains the project ID
- If you need a different project, create a service account in that project
- Or explicitly set `GOOGLE_CLOUD_PROJECT` in .env

## Security Best Practices

1. **Never commit keys**: Always add `auth/` to .gitignore
2. **Limit permissions**: Only grant necessary roles
3. **Rotate keys**: Regularly create new keys and delete old ones
4. **Use separate accounts**: Different service accounts for dev/staging/prod
5. **Monitor usage**: Check service account activity in GCP Console

## Alternative: Using Workload Identity (Advanced)

For production Kubernetes environments, consider Workload Identity instead of service account keys. This provides keyless authentication but requires more setup.

## Need Help?

If you encounter issues:
1. Check `~/.auth-status` inside the container for debugging info
2. Review container logs: `docker logs flutter-web-dev`
3. Ensure your service account has the necessary permissions
4. Verify the key file is valid JSON