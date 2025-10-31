# CodeGatherer.sh

CodeGatherer.sh is a small, self-contained Bash utility that collects all source files from a specified directory and writes them into a single, labeled text file.  
It is useful for creating quick, readable snapshots of a codebase or for providing complete project context to tools like ChatGPT.

---

## Features

- Requires a directory argument (refuses to run without one)
- Supports optional recursive scanning (`--recursive`)
- Supports file pattern filtering (`--only "*.php"`)
- Captures:
  - Absolute file paths  
  - Last modification timestamps  
  - Full source contents
- Generates a visual directory structure at the top of the output
- Produces a single consolidated file named `gathered_code_compendium.txt`
- Optional prompt to display the gathered output immediately after completion

---

## Usage

```bash
./CodeGatherer.sh <directory> [--recursive] [--only "pattern"]
