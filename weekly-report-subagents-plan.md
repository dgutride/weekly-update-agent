# Weekly Report Sub-Agents Plan

## Overview
This document outlines the plan for creating specialized sub-agents to help automate weekly report generation by gathering data from various sources.

## Sub-Agent Architecture

### 1. Slack Sub-Agent
**Name:** `slack-data-collector`
**Purpose:** Extract relevant communications and updates from Slack channels
**Capabilities:**
- Search recent messages across relevant channels
- Identify key decisions and announcements
- Extract mentions of projects, issues, and deliverables
- Summarize team communications and status updates

**Data Sources:**
- Team channels
- Direct messages
- Project-specific channels
- Announcement channels

### 2. Jira Sub-Agent
**Name:** `jira-tracker`
**Purpose:** Gather project status and issue tracking data from Jira
**Capabilities:**
- Pull recently updated tickets and their status
- Identify blockers and risks from issue descriptions
- Extract progress on key initiatives
- Generate summaries of completed work and upcoming tasks

**Data Sources:**
- Sprint boards
- Issue tracking
- Project dashboards
- Epic progress

### 3. Google Sub-Agent
**Name:** `google-workspace-collector`
**Purpose:** Extract information from Google Workspace tools
**Capabilities:**
- Scan Google Calendar for important meetings and decisions
- Review Google Docs for project documentation updates
- Check Gmail for key communications and requests
- Extract action items and follow-ups

**Data Sources:**
- Google Calendar events
- Google Docs (shared documents)
- Gmail (filtered by importance/projects)
- Google Drive (recent activity)

## Integration Strategy

### Weekly Report Orchestrator
**Name:** `weekly-report-orchestrator`
**Purpose:** Coordinate all sub-agents and compile final report
**Workflow:**
1. Trigger all three data collection sub-agents in parallel
2. Gather and normalize data from each source
3. Categorize information into report sections:
   - Peer requests
   - Risks/Issues
   - Key Decisions
   - Key Initiatives
   - Customers & Partners
   - Associates
   - Weekly Updates
4. Generate formatted weekly report

### Data Flow
```
Slack Sub-Agent     ─┐
Jira Sub-Agent      ─┼─→ Weekly Report Orchestrator ─→ Final Report
Google Sub-Agent    ─┘
```

## Implementation Steps

1. Create individual sub-agent configurations for each data source
2. Develop the weekly report orchestrator sub-agent
3. Test data collection from each source
4. Refine categorization and formatting logic
5. Integrate with existing weekly report template

## Benefits

- **Automation:** Reduces manual data gathering time
- **Consistency:** Ensures all relevant sources are checked
- **Completeness:** Minimizes missed updates or communications
- **Efficiency:** Parallel data collection from multiple sources
- **Standardization:** Consistent report format and structure

## Configuration Files Location
- Project sub-agents: `.claude/agents/`
- Individual agent configs will be stored as separate markdown files