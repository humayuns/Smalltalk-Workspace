# Smalltalk-Workspace

A collection of small Squeak Smalltalk scripts and experiments, organised by
the date they were written.

## Layout

```
YEAR/Month/N.st
```

Each `.st` file is a self-contained Workspace snippet — paste the file into a
Squeak Workspace, select all, press **Alt+D** (Do it).

## Contents

### 2017

- [October/2.st](2017/October/2.st) — "Hello, World!" and a random-quote
  picker printed to the Transcript.

### 2026

- [May/1.st](2026/May/1.st) — **GitHub user info form.** Opens a Morphic
  window with a username field and a Fetch button; calls
  `https://api.github.com/users/<name>` via `HTTPSocket` and displays the
  user's login, name, bio, company, location, blog, public-repo count,
  follower/following counts, creation date, and profile URL. JSON is parsed
  inline with a small extractor block so the script runs on a stock Squeak
  image without any extra packages.

## Running a script

1. Launch Squeak and open a Workspace (`World menu -> open... -> workspace`).
2. Open the `.st` file in any editor and copy its full contents.
3. Paste into the Workspace, select all (`Ctrl+A`), then **Do it**
   (`Alt+D` / `Cmd+D`).
4. For Transcript scripts, open the Transcript first
   (`World menu -> open... -> transcript`).

## Requirements

- [Squeak](https://squeak.org/) 5.x or later.
- Internet access for any script that talks to a remote API (e.g. the
  GitHub form).
