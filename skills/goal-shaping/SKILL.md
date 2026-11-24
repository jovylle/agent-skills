---
name: goal-shaping
description: "Goal shaping: turn a rough idea or target into a goal, checkable done criteria, and an ordered to-do list, for research, personal, planning, or coding work. Use when the user wants help forming a plan or goal."
disable-model-invocation: true
---

Goal shaping turns a rough idea into a goal record the user approves. It stops at approval. Starting the work is a separate request.

## Steps

1. **Ask every question in one message.** Open with a one-sentence restatement of the goal and its type: research, personal, planning, or coding. Then list the questions from the bank below that fit this goal, usually 5 to 8, grouped under short headings. Tell the user they can answer "unknown" to any question. Done when that single message is sent. Never split the questions across several messages.

2. **Draft the goal record.** After the user answers, write the record in chat using the template below. Turn each unanswered question into a labeled assumption. Do not ask a second round. Done when every field is filled, or marked as an assumption or open question.

3. **Ask for approval.** End with "Approve this, or tell me what to change." Done when the user approves the record. If the user asks for changes, revise the record and ask again. Once approved, stop.

## Question bank

Pick only the questions that change the plan.

- **Outcome:** What does done look like, in a form someone else could check? Which result matters most?
- **Timing and effort:** When is it needed, and how much time or budget can it use?
- **Audience:** Who uses the result, and who approves it?
- **Starting point:** What is already known, tried, or owned?
- **Limits:** What must not change or be touched? Which steps need approval?
- **By type:**
  - Research: which sources count, how deep to go, and what form the answer takes.
  - Personal: available time, money, and resources, and any fixed dates.
  - Planning: which options to compare, and which criteria decide between them.
  - Coding: which repo or system, which tests or checks prove it works, and what stays out of scope.

## Goal record

Use this template, in this order:

**Goal:** One sentence, in the user's words where possible.
**Type:** research, personal, planning, or coding.
**Done when:** Numbered checks. Each one must be verifiable by someone who was not in this conversation.
**Scope:** In and out.
**Constraints:** Time, budget, access, and what must not change.
**Assumptions:** Anything accepted without confirmation, with the reason.
**Open questions:** Unanswered items, and why each one matters.
**To-do list:** Ordered steps. Each step ends with a completion check. Include only the steps the done criteria require.

## Rules

- Keep the record in chat. Do not write files.
- Keep the goal as the user stated it. Add scope only with the user's agreement.
- The done criteria are the test of completion. Later work is checked against them, not against a checklist the agent wrote itself.
