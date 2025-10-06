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
- **calendar-with-gemini-notes**: Extract Google Calendar events with AI-generated Gemini meeting notes for meeting summaries and insights
- **slack-data-collector**: Planned agent for Slack communications analysis

Sub-agents are stored in `.claude/agents/` as markdown files with YAML frontmatter.

### MCP Integration
The system uses Model Context Protocol (MCP) servers for external system integration:

- **mcp-atlassian**: Configured in `.mcp.json` to connect to Red Hat Jira instance (https://issues.redhat.com)
- **google-workspace**: Configured in `.mcp.json` to connect to Google Calendar and Gmail APIs
- Uses podman containers for secure, isolated MCP server execution
- Authentication via OAuth (Google) and personal access tokens (Jira) stored in environment variables

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

## Google Workspace Integration Specifics

### calendar-with-gemini-notes agent
- Data sources: Google Calendar + Gmail (Gemini notes only)
- Time range: Defaults to last 7 days, user can specify single day or custom range
- Calendar data: All meetings with full event details (title, attendees, time, location)
- Gemini notes: AI-generated meeting summaries from gemini-notes@google.com
- Matching: Automatically matches Gemini notes to calendar events by title and date
- Meeting categorization: 1:1s, Team, Cross-functional, External, Planning/Strategy, Status/Updates, Technical, Other
- Output: Timestamped markdown file in `status/calendar-events-{timestamp}.md`
- Highlights: Aggregates decisions, action items, and identifies most important meetings
- Setup: Requires OAuth credentials configured in `.mcp.json` (see GOOGLE_WORKSPACE_SETUP.md)

## Usage Patterns

1. **Weekly Report Generation**: Use `weekly-report-orchestrator` agent to coordinate full report compilation
2. **Dashboard Feature Overview**: Use `jira-tracker` agent for multi-project dashboard feature/epic extraction
3. **Deep Feature Analysis**: Use `jira-deep-insights` agent for detailed RHOAISTRAT feature progress with child epic tracking
4. **Calendar with Meeting Notes**: Use `calendar-with-gemini-notes` agent to extract calendar events with AI-generated meeting summaries
5. **Status Tracking**: Generated reports stored in `status/` directory for historical reference

## Important Notes

- MCP server credentials are environment-based for security
- Sub-agent system requires proper YAML frontmatter formatting
- Report format follows specific executive structure requirements
- Jira queries target Red Hat internal instance with specific project scoping
- to memorize