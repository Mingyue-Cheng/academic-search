# academic-search

A Claude Code skill that gives your agent complete academic literature search capabilities.

Claude Code ships with WebSearch and WebFetch, but lacks academic-specific retrieval strategies, cross-platform metadata normalization, and browser automation for paywalled platforms. This skill fills the gap: **search strategy + structured metadata extraction + CDP browser automation + accumulated site knowledge**.

---

## v1.1.0 Capabilities

| Capability | Description |
|-----------|-------------|
| 7-platform coverage | arXiv / Semantic Scholar / Google Scholar / ACM DL / IEEE Xplore / PubMed / Papers with Code |
| API-first strategy | 6 platforms via open APIs — no browser required, fast and stable |
| CDP browser mode | Google Scholar and other anti-bot platforms via direct Chrome connection, inheriting your login session |
| Two-pass search | First pass outputs a lightweight summary table (citation count + venue tier); second pass deep-fetches full metadata only for confirmed core papers |
| Venue tier labels | CS conferences/journals automatically annotated with CCF ranking (A/B/C); ICLR labeled separately |
| Result filtering | Filter by citation count / year / venue tier / open access PDF / code availability |
| Structured metadata | Unified schema across all platforms; DOI as primary dedup key |
| PDF cascade | arXiv direct link → S2 OpenAccess → Unpaywall; no paywall bypass |
| BibTeX export | Platform-native export + field-assembly fallback |
| Citation graph | S2 citations/references API; Google Scholar citation counts as supplement |
| Parallel sub-agents | Independent targets dispatched to parallel sub-agents sharing one Proxy, tab-level isolation |
| Pre-seeded site knowledge | 7 platforms ship with verified operation patterns (URL structures, selectors, known pitfalls) |

<details>
<summary>v1.1.0 Changes</summary>

- **Two-pass search strategy** — Lightweight summary table first; deep fetch only after core papers are confirmed
- **Venue rankings reference** — New `references/venue-rankings.md` covering AI/ML/CV/NLP/Data Mining/IR/Systems/SE CCF tiers
- **Explicit filtering capability** — New filtering section with 5 dimensions and output template

</details>

---

## Installation

**Option 1: Let Claude install it automatically**

```
Install this skill for me: https://github.com/Mingyue-Cheng/PaperScout
```

**Option 2: Manual**

```bash
git clone https://github.com/Mingyue-Cheng/PaperScout ~/.claude/skills/academic-search
```

**Option 3: Local symlink (for development)**

```bash
# Run inside the academic-search/ directory
ln -sfn "$(pwd)" ~/.claude/skills/academic-search
```

---

## Prerequisites (CDP mode — only needed for Google Scholar)

arXiv, Semantic Scholar, PubMed, and other API-based platforms work out of the box with no setup.

CDP mode requires **Node.js 22+** and Chrome remote debugging:

1. Open `chrome://inspect/#remote-debugging` in Chrome's address bar
2. Check **Allow remote debugging for this browser instance** (browser restart may be required)

Environment check (the agent runs this automatically — no need to run manually):

```bash
bash ~/.claude/skills/academic-search/scripts/check-deps.sh
```

Local regression test:

```bash
cd academic-search
make test
```

---

## Usage

After installation, just ask Claude Code to perform academic search tasks — the skill takes over automatically:

```
Search for top-venue papers on graph neural networks published after 2023, give me the top 10
```

```
Find all papers by Yann LeCun on Semantic Scholar, sorted by citation count
```

```
Get the BibTeX for this paper: https://arxiv.org/abs/1706.03762
```

```
Look up BERT, GPT-3, and T5 in parallel — give me a comparison table with metadata and citation counts
```

```
Check Google Scholar for the citation count of "Attention Is All You Need"
```

---

## Platform Access Strategy

| Platform | Access Method | Requires Chrome Debugging |
|----------|--------------|:------------------------:|
| arXiv | REST API | No |
| Semantic Scholar | REST API | No |
| PubMed | NCBI E-utilities | No |
| Papers with Code | REST API | No |
| ACM DL | WebFetch + Jina | No |
| IEEE Xplore | WebFetch / Jina / Official API | No |
| Google Scholar | CDP browser | **Yes** |

---

## CDP Proxy API

The Proxy connects to Chrome via WebSocket (compatible with the `chrome://inspect` method — no command-line flags needed) and exposes an HTTP API:

```bash
# The agent manages the Proxy lifecycle automatically — no manual startup needed
bash ~/.claude/skills/academic-search/scripts/check-deps.sh

# Page operations
curl -s "http://localhost:3456/new?url=https://scholar.google.com"           # Open new tab
curl -s -X POST "http://localhost:3456/eval?target=ID" -d 'document.title'  # Execute JS
curl -s -X POST "http://localhost:3456/click?target=ID" -d 'button.submit'  # Click element
curl -s "http://localhost:3456/screenshot?target=ID&file=/tmp/shot.png"      # Screenshot
curl -s "http://localhost:3456/scroll?target=ID&direction=bottom"            # Scroll
curl -s "http://localhost:3456/close?target=ID"                              # Close tab
```

See `references/cdp-api.md` for the full API reference.

---

## Project Structure

```
academic-search/
├── Makefile                          # Standard test entry (make test)
├── SKILL.md                          # Main instruction (search philosophy + platform matrix + capabilities)
├── README.md                         # Chinese README
├── README.en.md                      # English README (this file)
├── scripts/
│   ├── cdp-proxy.mjs                 # CDP Proxy HTTP server (connects to user's Chrome)
│   ├── check-deps.sh                 # Environment check + auto-start Proxy
│   └── self-test.sh                  # Local regression test (requires Chrome remote debugging)
└── references/
    ├── api-cookbook.md               # 7-platform API call reference (curl examples + field mappings)
    ├── metadata-schema.md            # Cross-platform unified metadata schema + dedup rules + BibTeX templates
    ├── venue-rankings.md             # CS conference/journal CCF tier reference
    ├── cdp-api.md                    # CDP Proxy HTTP API complete reference
    └── site-patterns/
        ├── arxiv.org.md
        ├── semanticscholar.org.md
        ├── scholar.google.com.md
        ├── dl.acm.org.md
        ├── ieeexplore.ieee.org.md
        ├── pubmed.ncbi.nlm.nih.gov.md
        └── paperswithcode.com.md
```

---

## Design Philosophy

> Skill = philosophy + technical facts, not an operations manual. Explain the tradeoffs and let the AI decide — don't do its reasoning for it.

- **The bottleneck is filtering, not searching**: Output a lightweight summary table first; let the user identify core papers before deep-fetching — avoids redundant full metadata pulls
- **API-first**: Never simulate a browser for platforms that offer a public API — faster, more stable, no anti-bot exposure
- **CDP is the last resort, not the default**: Only used when no reliable API exists (Google Scholar)
- **Structured output**: All results converted to a unified schema, DOI as dedup key, directly exportable as BibTeX
- **Site knowledge reuse**: 7 platforms ship with pre-seeded operation experience; accumulated and updated across sessions

---

## License

MIT · Author: Mingyue Cheng
