# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

This repository contains a weekly report automation system that uses Claude Code sub-agents to gather data from multiple sources (Slack, Jira, Google Workspace) and compile comprehensive weekly director reports.

## Architecture

### Sub-Agent System
The project implements a multi-agent architecture for automated report generation:

- **weekly-report-orchestrator**: Master agent that coordinates data collection and compiles final reports
- **jira-tracker**: Specialized agent for extracting Jira updates from dashboard-related epics/features
- **slack-data-collector**: Planned agent for Slack communications analysis
- **google-workspace-collector**: Planned agent for Google Calendar/Docs/Gmail integration

Sub-agents are stored in `.claude/agents/` as markdown files with YAML frontmatter.

### MCP Integration
The system uses Model Context Protocol (MCP) servers for external system integration:

- **mcp-atlassian**: Configured in `.mcp.json` to connect to Red Hat Jira instance (https://issues.redhat.com)
- Uses podman containers for secure, isolated MCP server execution
- Authentication via personal access tokens stored in environment variables

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

The jira-tracker agent focuses on:
- Projects: RHAIENG, RHAOIENG, RHOAISTRAT
- Issue types: Epic, Feature
- Component filter: "Dashboard"
- Time range: Last 5 days only
- Output categorization: Completed Work, In Progress, Blocked/At Risk, New/Planning

## Usage Patterns

1. **Weekly Report Generation**: Use `weekly-report-orchestrator` agent to coordinate full report compilation
2. **Jira Status Updates**: Currently use general-purpose agent with MCP integration (jira-tracker sub-agent registration pending investigation)
3. **Status Tracking**: Generated reports stored in `status/` directory for historical reference

## Important Notes

- MCP server credentials are environment-based for security
- Sub-agent system requires proper YAML frontmatter formatting
- Report format follows specific executive structure requirements
- Jira queries target Red Hat internal instance with specific project scoping