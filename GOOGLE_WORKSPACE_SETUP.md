# Google Workspace MCP Setup Guide

This guide walks through setting up the Google Workspace MCP server for the weekly report automation system.

## Prerequisites
- Podman installed and running
- Google account with Calendar and Gmail access
- Google Cloud Console access

## Step 1: Google Cloud OAuth Setup

1. **Create/Select Project**:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing one

2. **Enable APIs**:
   - Navigate to "APIs & Services → Library"
   - Search and enable:
     - Gmail API
     - Google Calendar API

3. **Create OAuth Credentials**:
   - Go to "APIs & Services → Credentials"
   - Click "Create Credentials" → "OAuth Client ID"
   - Application type: **Desktop Application**
   - Name: "Claude Code MCP"
   - Click "Create"
   - **Download the JSON** (you'll need client_id and client_secret)

4. **Configure OAuth Consent Screen** (if prompted):
   - User type: Internal (for Google Workspace) or External
   - Add your email as test user if using External
   - Scopes needed:
     - `https://www.googleapis.com/auth/gmail.readonly`
     - `https://www.googleapis.com/auth/calendar.readonly`

## Step 2: Build the Container

Run the build script:

```bash
./build-google-mcp.sh
```

This will:
- Clone the google_workspace_mcp repository
- Build the podman container as `google-workspace-mcp`
- Tag it as `localhost/google-workspace-mcp`

## Step 3: Configure Environment Variables

Update `.mcp.json` with your credentials:

```bash
# Edit .mcp.json and replace:
# - YOUR_CLIENT_ID_HERE → your OAuth client ID
# - YOUR_CLIENT_SECRET_HERE → your OAuth client secret
# - your.email@gmail.com → your Google account email
```

Or set as environment variables:

```bash
export GOOGLE_OAUTH_CLIENT_ID="your-client-id-here"
export GOOGLE_OAUTH_CLIENT_SECRET="your-client-secret-here"
export USER_GOOGLE_EMAIL="your.email@gmail.com"
```

## Step 4: Create Podman Volume

Create a persistent volume for OAuth tokens:

```bash
podman volume create google-mcp-creds
```

## Step 5: First Run (OAuth Flow)

The first time the container runs, it will need to authenticate:

1. The MCP server will start
2. Watch for OAuth URL in logs (if interactive mode)
3. Follow authentication flow in browser
4. Tokens will be saved to the `google-mcp-creds` volume

## Step 6: Test the Setup

Test using Claude Code:

```bash
# Start Claude Code
claude

# In Claude Code, test the agent:
/agents google-workspace-collector
```

Or test MCP tools directly:
```bash
# The MCP server should now be available via Claude Code
# You can use tools like:
# - List calendars
# - Search Gmail
# - Get calendar events
```

## Configuration Reference

### .mcp.json Structure

```json
{
  "mcpServers": {
    "google-workspace": {
      "command": "podman",
      "args": [
        "run",
        "--rm",
        "-i",
        "-p", "8000:8000",
        "-v", "google-mcp-creds:/app/store_creds",
        "-e", "GOOGLE_OAUTH_CLIENT_ID",
        "-e", "GOOGLE_OAUTH_CLIENT_SECRET",
        "-e", "USER_GOOGLE_EMAIL",
        "-e", "TOOL_TIER=core",
        "localhost/google-workspace-mcp"
      ],
      "env": {
        "GOOGLE_OAUTH_CLIENT_ID": "your-id",
        "GOOGLE_OAUTH_CLIENT_SECRET": "your-secret",
        "USER_GOOGLE_EMAIL": "you@gmail.com",
        "TOOL_TIER": "core"
      }
    }
  }
}
```

### Tool Tiers

- `core`: Essential tools (Calendar, Gmail basics) - **Recommended**
- `extended`: Core + management features
- `complete`: Full API access (all Google Workspace services)

## Troubleshooting

### OAuth Errors
- Verify APIs are enabled in Google Cloud Console
- Check client_id and client_secret are correct
- Ensure test user is added if using External OAuth

### Container Issues
```bash
# Check container logs
podman logs <container-id>

# Rebuild container
./build-google-mcp.sh

# Check volume
podman volume inspect google-mcp-creds
```

### Permission Errors
- Verify scopes in OAuth consent screen
- Re-authenticate by removing stored tokens:
```bash
podman volume rm google-mcp-creds
podman volume create google-mcp-creds
```

## Usage

### Run the Agent

```bash
# In Claude Code
/agents google-workspace-collector
```

This will:
1. Query Google Calendar for events from last 7 days
2. Search Gmail for important emails from last 7 days
3. Categorize data by weekly report sections
4. Generate `status/google-workspace-{timestamp}.md`

### Output

The agent creates a timestamped markdown file in `status/` directory with:
- Calendar summary (meetings, hours, attendees)
- Email summary (important threads, external comms)
- Categorized data for weekly report sections
- Actionable insights and follow-up items

## Security Notes

- OAuth tokens stored in podman volume (not in git)
- Client credentials should be kept secure
- Consider using Google Workspace internal app for production
- Tokens can be revoked in Google Account settings

## Next Steps

After setup:
1. Test the google-workspace-collector agent
2. Review generated status file
3. Integrate with weekly-report-orchestrator
4. Adjust categorization rules as needed
