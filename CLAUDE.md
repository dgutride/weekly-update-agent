# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

This repository contains a weekly report automation system that uses Claude Code sub-agents to gather data from multiple sources (Slack, Jira, Google Workspace) and compile comprehensive weekly director reports.

## Architecture

### Sub-Agent System
The project implements a multi-agent architecture for automated report generation:

- **weekly-report-orchestrator**: Master agent that coordinates data collection and compiles final reports
- **jira-tracker**: Extract dashboard Features (RHOAISTRAT) and Initiatives (RHOAIENG) organized by scrum teams for executive reporting
- **jira-deep-insights**: Extract RHOAISTRAT features with AI Core Dashboard component in active statuses (In Progress, Refinement) with child progress tracking
- **slack-data-collector**: Planned agent for Slack communications analysis
- **google-workspace-collector**: Planned agent for Google Calendar/Docs/Gmail integration

Sub-agents are stored in `.claude/agents/` as markdown files with YAML frontmatter.

### MCP Integration
The system uses Model Context Protocol (MCP) servers for external system integration:

- **mcp-atlassian**: Jira/Confluence integration
  - Upstream: https://github.com/wonkothesanest/mcp-atlassian
  - Configured in `.mcp.json` to connect to Red Hat Jira instance (https://issues.redhat.com)
  - Authentication: JIRA_API_TOKEN environment variable

- **slack-mcp**: Slack workspace integration
  - Upstream: https://github.com/redhat-community-ai-tools/slack-mcp
  - Runs via podman container (quay.io/redhat-ai-tools/slack-mcp)
  - Authentication: SLACK_XOXC_TOKEN and SLACK_XOXD_TOKEN environment variables
  - Requires LOGS_CHANNEL_ID for operational logging
  - Token extraction: https://github.com/maorfr/slack-token-extractor

- **gmail**: Gmail integration
  - Upstream: https://github.com/PaulFidika/gmail-mcp-server
  - Requires configuration with your own OAuth2 client credentials [help](https://github.com/PaulFidika/gmail-mcp-server?tab=readme-ov-file#1-get-google-authentication)
  - Authentication: GMAIL_CLIENT_ID and GMAIL_CLIENT_SECRET environment variables
  - Supports email search, draft creation, and attachment extraction


### Data Flow
```
Slack/Jira/Google APIs → MCP Servers → Sub-Agents → Report Orchestrator → Weekly Report
```

## Key Components

### Configuration Files
- `.mcp.json`: MCP server configurations for external system connections
- `.claude/agents/*.md`: Sub-agent definitions with specialized prompts and tool access
- `.claude/settings.local.json`: Claude Code permissions and allowed tools
- `weekly-report-subagents-plan.md`: Architecture documentation and implementation roadmap

### Output Structure
- `status/`: Generated status reports and data extracts
- Weekly reports follow director-specified format with sections:
  - Peer Requests
  - Risks/Issues
  - Key Decisions
  - Key Initiatives
  - Customers & Partners
  - Associates
  - Weekly Updates

## Jira Integration Specifics

### jira-tracker agent
- Projects: RHAIENG, RHAOIENG, RHOAISTRAT
- Issue types: Epic, Feature
- Component filter: "Dashboard"
- Time range: Last 5 days only
- Output categorization: Completed Work, In Progress, Blocked/At Risk, New/Planning

### jira-deep-insights agent
- Project: RHOAISTRAT only
- Issue type: Feature
- Component filter: "AI Core Dashboard" (exact match)
- Status filter: In Progress, Refinement (excludes New, Resolved, Closed)
- Time range: All matching features (no time limit)
- Child progress tracking: Uses customfield_12317141 (Hierarchy Progress Bar) for child epic rollup
- Output: Timestamped markdown file in `status/` directory with progress analysis

## Usage Patterns

1. **Weekly Report Generation**: Use `weekly-report-orchestrator` agent to coordinate full report compilation
2. **Dashboard Feature Overview**: Use `jira-tracker` agent for multi-project dashboard feature/epic extraction
3. **Deep Feature Analysis**: Use `jira-deep-insights` agent for detailed RHOAISTRAT feature progress with child epic tracking
4. **Status Tracking**: Generated reports stored in `status/` directory for historical reference

## Important Notes

- MCP server credentials are environment-based for security
- Sub-agent system requires proper YAML frontmatter formatting
- Report format follows specific executive structure requirements
- Jira queries target Red Hat internal instance with specific project scoping
- to memorize