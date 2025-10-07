#!/bin/bash
set -e

tempdir=$(mktemp -d)
echo "Cloning google_workspace_mcp repository into $tempdir..."
git clone https://github.com/taylorwilsdon/google_workspace_mcp.git $tempdir/google_workspace_mcp

cd $tempdir/google_workspace_mcp

echo "Building podman container..."
podman build -t google-workspace-mcp .

echo "Container built successfully!"
echo ""
echo "Next steps:"
echo "1. Set up OAuth credentials in Google Cloud Console"
echo "2. Set environment variables:"
echo "   export GOOGLE_OAUTH_CLIENT_ID='your-client-id'"
echo "   export GOOGLE_OAUTH_CLIENT_SECRET='your-secret'"
echo "3. Update .mcp.json configuration"
