# Slack MCP Setup Guide

This guide walks you through setting up the Slack MCP server for the weekly update agent.

## Overview

The Slack MCP server enables Claude Code to interact with your Slack workspace, allowing automated extraction of messages, channel data, and communications for weekly report generation.

- **Upstream Repository**: https://github.com/korotovsky/slack-mcp-server
- **Package**: `slack-mcp-server` (npm)
- **Token Extractor**: https://github.com/maorfr/slack-token-extractor

## Available Features

The Slack MCP server provides these capabilities:
- **conversations_history**: Retrieve channel/DM messages
- **conversations_replies**: Fetch thread messages
- **conversations_search_messages**: Search across messages
- **channels_list**: List workspace channels
- Direct message and group DM support
- Smart history fetching with caching

## Prerequisites

- Node.js installed (for npx)
- Access to a Slack workspace
- Browser with extension support (Chrome or Firefox recommended)

## Step 1: Extract Slack Tokens

You need to extract two authentication tokens from your Slack session:
- `SLACK_XOXC_TOKEN` - Slack web token (starts with `xoxc-`)
- `SLACK_XOXD_TOKEN` - Slack cookie token (starts with `xoxd-`)

Alternatively, you can use an OAuth token (`SLACK_XOXP_TOKEN`), but the browser token method is simpler for personal use.

### Method 1: Automated Script from Slack Desktop App (macOS/Linux with Python 3.7-3.11)

This repository includes an automated script that extracts tokens directly from the Slack Desktop App's local storage.

**Requirements:**
- macOS or Linux
- Slack Desktop App installed
- Python 3.7 - 3.11 (NOT compatible with Python 3.12+)
- leveldb system library (installed automatically via homebrew on macOS)

**Important**: If you have Python 3.12 or 3.13, use Method 2 (Browser Extension) instead.

**Steps:**

1. Run the token extraction script:
   ```bash
   ./bin/extract-slack-tokens.sh
   ```

   The script will:
   - Check if Slack is running and offer to close it
   - Clone/update the slacktokens repository to `.slacktokens/`
   - Install required Python dependencies
   - Extract tokens from all your workspaces
   - Write tokens to `.slack-tokens.env` file
   - You may be prompted for your system password for cookie decryption

2. To extract tokens for a specific workspace:
   ```bash
   ./bin/extract-slack-tokens.sh --workspace-name "Your Workspace Name"
   ```

3. Load the extracted tokens:
   ```bash
   source .slack-tokens.env
   ```

4. (Optional) Add to your shell configuration for persistence:
   ```bash
   echo "source $(pwd)/.slack-tokens.env" >> ~/.zshrc
   # OR
   echo "source $(pwd)/.slack-tokens.env" >> ~/.bashrc
   ```

**Advantages:**
- Fully automated and idempotent
- Works directly with Slack Desktop App (no browser extensions needed)
- Extracts tokens for all workspaces at once
- Automatically manages dependencies
- No manual browser interaction required
- Safe: tokens stored locally in `.slack-tokens.env` (git-ignored)

### Method 2: Browser Extension (For Browser-Based Slack)

If you use Slack in a web browser instead of the desktop app:

#### Chrome:
1. Clone the token extractor repository:
   ```bash
   git clone https://github.com/maorfr/slack-token-extractor.git
   cd slack-token-extractor
   ```

2. Open Chrome and navigate to `chrome://extensions`

3. Enable "Developer mode" (toggle in top-right corner)

4. Click "Load unpacked" and select the `chrome` directory from the cloned repo

5. Navigate to your Slack workspace in the browser

6. Click the token extractor extension icon

7. Copy the displayed `xoxc-...` and `xoxd-...` tokens

#### Firefox:
1. Clone the token extractor repository (if not already done):
   ```bash
   git clone https://github.com/maorfr/slack-token-extractor.git
   cd slack-token-extractor
   ```

2. Open Firefox and navigate to `about:debugging#/runtime/this-firefox`

3. Click "Load Temporary Add-on"

4. Select the `manifest.json` file in the `firefox` directory

5. Navigate to your Slack workspace in the browser

6. Click the token extractor extension icon

7. Copy the displayed `xoxc-...` and `xoxd-...` tokens

**Security Note**: Tokens are only stored locally and are never transmitted to external services. These tools are not endorsed or authorized by Slack Technologies LLC.

## Step 2: Set Environment Variables

If you used the automated script (Method 1), tokens are already in `.slack-tokens.env`. Just load them:

```bash
source .slack-tokens.env
```

If you used the browser extension method (Method 2), add the tokens manually to your shell configuration:

```bash
# Add to ~/.zshrc or ~/.bashrc
export SLACK_XOXC_TOKEN="xoxc-your-token-here"
export SLACK_XOXD_TOKEN="xoxd-your-token-here"
```

Then reload your shell configuration:
```bash
source ~/.zshrc  # or source ~/.bashrc
```

## Step 3: Verify Configuration

The Slack MCP server is already configured in `.mcp.json`:

```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": [
        "-y",
        "slack-mcp-server@latest",
        "--transport",
        "stdio"
      ],
      "env": {
        "SLACK_MCP_XOXC_TOKEN": "${SLACK_XOXC_TOKEN}",
        "SLACK_MCP_XOXD_TOKEN": "${SLACK_XOXD_TOKEN}"
      }
    }
  }
}
```

## Step 4: Test the Connection

After setting environment variables, restart Claude Code:

```bash
claude-code
```

The Slack MCP server will automatically start via npx when Claude Code launches. The first time it runs, it will download the latest version of `slack-mcp-server`.

## Verification

To verify the Slack MCP is working:

1. Start Claude Code with environment variables set
2. The MCP server should automatically connect
3. Test Slack functionality through sub-agents (e.g., `slack-data-collector`)

## Troubleshooting

### Server fails to start
- Verify Node.js/npx is installed: `npx --version`
- Check environment variables are set: `echo $SLACK_XOXC_TOKEN`
- Manually test the server: `npx -y slack-mcp-server@latest --transport stdio`

### Authentication errors
- Tokens may have expired - re-extract using the browser extension
- Ensure tokens are properly exported in your shell environment
- Verify no extra spaces or quotes in environment variables
- Check tokens start with `xoxc-` and `xoxd-` respectively

### MCP connection issues
- Ensure you've restarted Claude Code after setting environment variables
- Check Claude Code logs for error messages
- Verify `.mcp.json` is in the project root directory

## Token Security

- **Never commit tokens to version control**
- Tokens are stored in environment variables only
- Tokens grant full access to your Slack workspace - treat them like passwords
- Rotate tokens periodically by re-extracting
- Keep `.env` files secure and private

## Advanced Configuration

### Optional Environment Variables

You can set additional configuration in your shell environment:

```bash
export SLACK_MCP_HOST="127.0.0.1"        # Default host
export SLACK_MCP_PORT="13080"            # Default port
export SLACK_MCP_PROXY="http://proxy"    # Optional proxy
export SLACK_MCP_USERS_CACHE="/path"     # User cache location
export SLACK_MCP_CHANNELS_CACHE="/path"  # Channel cache location
```

### Using OAuth Token Instead

If you prefer to use an OAuth token:

```bash
export SLACK_MCP_XOXP_TOKEN="xoxp-your-token-here"
```

Then update `.mcp.json`:
```json
{
  "env": {
    "SLACK_MCP_XOXP_TOKEN": "${SLACK_MCP_XOXP_TOKEN}"
  }
}
```

## Next Steps

Once configured, the Slack MCP server will be available to:
- The `slack-data-collector` sub-agent for gathering weekly communications
- The `weekly-report-orchestrator` for compiling comprehensive reports
- Any custom agents that need Slack workspace access

## Additional Resources

- [Authentication Setup Guide](https://github.com/korotovsky/slack-mcp-server/blob/main/docs/01-authentication-setup.md)
- [Installation Guide](https://github.com/korotovsky/slack-mcp-server/blob/main/docs/02-installation.md)
- [Configuration and Usage](https://github.com/korotovsky/slack-mcp-server/blob/main/docs/03-configuration-and-usage.md)
