# 0028: Design docs live in the repo as Markdown

- **Status:** Accepted
- **Date:** 2026-10-13
- **Affects:** [docs README](../README.md)

## Decision

Design docs and decision records live in docs/ as Markdown, one file per module and one per decision. The Claude Docs page is a nicer view; the repo wins on conflicts.

## Why

Markdown displays on GitHub, diffs cleanly, is editable by anyone, and travels with the code.

## Not chosen

LaTeX (needs compiling, shows as raw source on GitHub); keeping docs only in the Claude Docs page.

## Revisit when

Docs need layout Markdown can't do.
