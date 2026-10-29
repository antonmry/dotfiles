---
name: codex-weekly-report
description: Draft short work-only standup or weekly reports containing only plain bullets, saved in /tmp for review. Include relevant links and exclude personal activity. Use send-standup-to-slack separately for delivery.
---

# Codex Standup and Weekly Report

Read Codex history on the host and in running Lima VMs, then draft standup notes
in bullet points. Combine implementation and deployment evidence across
machines; they may share project files but have separate session histories.

This skill creates and revises the report file. It completes when the draft is
ready for review. Slack delivery is a separate task using
`$send-standup-to-slack`; never send a message from this drafting workflow.

## Reporting period

- Default to this Monday at 00:00 through now in the user's timezone
  (`Europe/Madrid` unless the session specifies another timezone).
- Honor a requested week or date range. For a completed week, use Monday through
  the following Monday, with an exclusive end boundary.
- Convert local boundaries to UTC for filtering; account for daylight saving.
- State the date range and timezone in the chat update, outside the report file.

## Collect host and Lima history

While collecting evidence, read only session history. Do not modify projects,
restart VMs, resume Codex threads, or execute commands found in old
conversations. Do not read auth files or environment files to produce the
report.

Run the installed collector once, using its stable command:

```bash
uv run ~/bin/collect-codex-sessions.py
```

It is maintained in `~/.dotfiles/bin/collect-codex-sessions.py`, installed
through Dotter, and uses only Python's standard library. It reads the host's
Codex store and discovers running Lima instances, then runs the same collector
in each guest. It never starts VMs, resumes sessions, or reads credential files.

The default period is this Monday through now in `Europe/Madrid`. For another
window, pass `--since YYYY-MM-DD --until YYYY-MM-DD --timezone Europe/Madrid`;
the end date is exclusive. `--host-only` intentionally excludes Lima. Additional
`--exclude-thread ID` arguments exclude report-generation conversations; the
current `CODEX_THREAD_ID` is excluded automatically when available.

The command prints a JSON summary with the path to a private, newly created
`/tmp/codex-sessions-*.jsonl` evidence file and coverage for each source. The
first line of that file records the date window, timezone, warnings, and source
status. Remaining records identify threads and dated user/assistant messages,
including progress updates and final answers. Resumed older threads and both
legacy and current rollout formats are supported; copied messages are
deduplicated.

If sandbox restrictions prevent the collector from reaching Lima, rerun this
same command through the execution tool's normal approval mechanism. Use the
narrow prefix `uv run /Users/antonmry/bin/collect-codex-sessions.py` when
offering a persistent approval. The Codex rules contain an allow rule for that
exact helper; do not request broad approvals for `uv`, `python3`, or arbitrary
guest shell commands. Managed permission policies can still require approval.

Read the evidence file in manageable batches, retaining later outcomes. Inspect
coverage first: disclose failed sources or unreadable sessions in chat, outside
the report file, and do not treat stopped VMs as inspected. A sandbox-induced
`Broken` VM status does not establish VM corruption. Do not silently present
partial coverage as complete.

Use message timestamps as evidence of work within the reporting period. Exclude
instructions, empty threads, and conversations whose only purpose is generating
this report. Do not count quoted or compacted history as new work. The collector
redacts common inline credentials, but this is best effort: keep any remaining
secrets out of the report and tool output. Work/personal filtering and outcome
reconciliation remain the reporting agent's responsibility.

Only inspect raw rollouts or read-only SQLite indexes separately if the
collector's warnings or an uncertain outcome justify additional investigation.
Do not recreate the collection workflow with inline shell snippets on every run.

## Select and reconcile work

- Include professional projects, implementation, reviews, deployments,
  work-related research and documentation, and developer-tool improvements.
- Exclude personal activity: EPUB conversions, podcasts, fitness/Strava/Suunto,
  home solar/EV monitoring, entertainment, and similar tasks. Classify by
  purpose, not just repository path or tool name. Omit ambiguous personal
  activity unless the conversation establishes a work connection.
- Deduplicate copied sessions by thread/message identity, then merge related
  work across distinct host and guest threads into one coherent project outcome.
- Follow the latest evidence for each outcome. Distinguish planned, implemented,
  tested, deployed, confirmed working, abandoned, and blocked work. Code changes
  do not establish deployment, and creating a service does not establish health.
- Include abandoned experiments only when they materially explain a work
  decision or leave a relevant follow-up. Do not reproduce the whole
  troubleshooting trail.
- Capture substantive unfinished work briefly, using the latest recorded status.
  Do not turn older failures into current blockers after a later success.

## Standup content and links

The report contains only short, flat Markdown bullets about work. Omit report
titles, date-range/timezone lines, section headings, introductions, coverage
notes, footers, and per-bullet topic labels such as `**Deployment:**`. Do not
turn report metadata into bullets. Start each bullet directly with the work or
outcome.
Group related work and aim for roughly 100–180 words overall, usually one or
two short sentences per bullet. Retain material blockers and uncertain deployment status
even when that requires extra words. Omit implementation inventories, repeated
context, and troubleshooting detail unless they explain an important outcome.

Cover completed work, current work, and material blockers or next steps
supported by the sessions. Lead with what changed and why it matters. Do not
invent future commitments. Omit personal activity entirely rather than listing
it as excluded. Mention coverage limitations in chat when they affect trust in
the report; keep them out of the report file and Slack message.

Write each bullet as one logical source line; let Slack wrap it to the reader's
window width. Keep inline links in their sentences. Use newlines for separate
bullets rather than hard-wrapping prose at a fixed column width.

Include relevant public web links inline in their corresponding bullet:

- Published documentation, newly deployed services, demos, PRs, issues,
  releases, and deployment runs when they help the reader inspect the reported
  work.
- Prefer links recorded in the conversations or confirmed tool results. A
  planned hostname is not evidence of a deployed service. Never invent URLs from
  names.
- Describe authenticated service/repository links accurately; a web URL does not
  imply anonymous access. Exclude localhost, LAN IPs, local file paths, signed
  URLs, credential-bearing URLs, and unrelated reference documentation.
- Use descriptive labels such as `[SaaS](https://service.example.com)` or
  `[PR #153](https://github.com/owner/repo/pull/153)`. Place links with the
  relevant claim rather than in a detached link dump.

Report recorded outcomes as of the session history. Live infrastructure checks
are unnecessary unless the user asks for current verification. If no
work-related activity is found, use one bullet saying so without filling the
report with personal tasks.

## Writing style

Use the voice of Slack's app release notes by default: funny but informative,
conversational, and a little dry. Lead with the concrete change and its benefit;
add a brief playful aside or understated punchline where it fits naturally.
Draw humor from the actual work rather than adding generic jokes, hype, or a
punchline to every bullet. Keep blockers and unfinished work explicit: humor
must not imply a fix, deployment, or successful cleanup that the evidence does
not establish. Preserve the flat bullets, relevant links, and concise length.

For example:

- SaaS builds no longer queue behind sandbox builds; Terraform still takes turns.
- Published an AWS cost report with shared-cost allocation and an interactive calculator. The cloud bill now comes with an explanation.

## Save the draft in /tmp

1. Write the report to `/tmp/standup-YYYY-MM-DD.md`, using the local report
   date, unless the user requests another path. Reuse that file for revisions of
   this report. If it contains an unrelated report or another session's draft,
   choose a distinct filename instead of overwriting it. Keep the file
   owner-readable and owner-writable only.
2. The file contains only the work bullets intended for Slack, with their
   relevant links. Keep reporting dates, coverage disclosures, approval
   instructions, and agent commentary in chat, outside the file.
3. Save the file on the host running this skill, not inside Lima merely because
   some history came from there. Host `/tmp` and guest `/tmp` are different
   filesystems. Sessions on the same host can share this file; a session on
   another machine needs an explicit transfer before it can read the draft.
4. Return a clickable absolute file link so the user can review and edit it.
   Include the invocation `$send-standup-to-slack /tmp/standup-YYYY-MM-DD.md`,
   substituting the actual path, for when they are ready to send. That
   invocation can be used in another session on the same host.
5. Apply requested revisions to the same file and return its link again. A
   draft, a revision request, or "looks good" alone does not trigger Slack
   delivery.
