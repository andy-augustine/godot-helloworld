# godot-helloworld

A Metroid-style 2D platformer built with Godot 4, powered by Claude Code + Opus 4.7.

---

## Stack Overview

| Tool | Purpose |
|---|---|
| Godot 4.6+ | Game engine and editor |
| Node.js 18+ | Required for MCP server |
| Claude Code CLI | AI code generation in terminal |
| VS Code + godot-tools | External script editor |
| VS Code Claude Code extension | Claude Code inside VS Code (optional — CLI is required for MCP) |
| godot-mcp-pro | Live editor control (Claude sees errors, runs game, reads scene state) |

**Why godot-mcp-pro over plain Claude Code?**
Without an MCP server, Claude writes files blind — no runtime feedback. godot-mcp-pro lets Claude launch the game, read debug output, inspect the scene tree, and iterate on real errors. Opus 4.7 is capable enough that you don't need Godogen on top of this.

---

## Prerequisites

> godot-mcp-pro is a paid tool ($5) and requires a manual download from itch.io. Everything else installs via brew or npm.

### Step 1: Install Godot
Download from [godotengine.org](https://godotengine.org/download/macos/) and drag `Godot.app` to `/Applications`.

> brew install --cask godot exists but lags behind the current release — use the direct download.

### Step 2: Install Node, VS Code, and Claude Code

```bash
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install node
brew install --cask visual-studio-code

# Install Claude Code (requires Node)
npm install -g @anthropic-ai/claude-code

# Verify
node --version        # should be 18.x+
claude --version

# Log in to Claude
claude login
```

### Step 3: Install VS Code extensions

First, add the `code` CLI to your PATH so you can run it from the terminal:
- Open VS Code → `Cmd+Shift+P` → **Shell Command: Install 'code' command in PATH**

Then install both extensions:
```bash
code --install-extension geequlim.godot-tools
code --install-extension anthropic.claude-code
```

- **godot-tools** — GDScript syntax highlighting and Godot LSP integration. On first use it will prompt for the Godot executable — select `/Applications/Godot.app`
- **Claude Code** — Claude Code inside VS Code (MCP servers only work via the terminal CLI, not this extension)

### Step 4: Purchase godot-mcp-pro (manual — paid)
Go to https://y1uda.itch.io/godot-mcp-pro and purchase ($5 one-time, lifetime updates).
This cannot be installed via brew or npm — it's a paid package distributed through itch.io.

> **We use GDScript, not C#.** GDScript has better AI tooling coverage and removes .NET SDK complexity for a weekend build.

---

## godot-mcp-pro Setup

### Step 1: Purchase and download
Go to https://y1uda.itch.io/godot-mcp-pro and purchase ($5 one-time, lifetime updates).
Unzip the package somewhere permanent — the MCP server runs from this folder:
```
~/code/tools/godot-mcp-pro/
```

The zip contains:
- `addons/godot_mcp/` — the Godot plugin
- `server/` — the Node.js MCP server

### Step 2: Build the MCP server
```bash
cd ~/code/tools/godot-mcp-pro/<version>/server
node build/setup.js install
```

This runs `npm install` and compiles the TypeScript server. Verify with:
```bash
node build/setup.js doctor
```

### Step 3: Copy the plugin and configure Claude Code
From your **Godot project directory**, run:
```bash
# Copy the plugin into your project
cp -r ~/code/tools/godot-mcp-pro/<version>/addons ./addons

# Auto-configure Claude Code (creates .mcp.json in the project)
node ~/code/tools/godot-mcp-pro/<version>/server/build/setup.js configure
```

This creates a `.mcp.json` in your project root that Claude Code picks up automatically. If the generated `.mcp.json` contains a `GODOT_MCP_PORT` entry, remove it — the server auto-scans ports 6505–6509 and a fixed port causes silent failures if a stale process is holding it.

### Step 4: Open the project in Godot and enable the plugin
The `project.godot` file is already in this repo. Open it:
- Launch Godot → **Import** → navigate to this folder → select `project.godot`

Then enable the plugin:
1. In the Godot menu bar: **Project → Project Settings → Plugins tab**
2. Find **Godot MCP Pro** → set to **Enable**
3. An "MCP Pro" panel appears at the bottom of the editor with a connection status dot

### Step 5: Set VS Code as your external script editor
In the **macOS menu bar** (not inside the Godot window): **Godot → Editor Settings**
- In the left sidebar search for **"external"**
- Enable **Use External Editor**
- Exec Path: `/Applications/Visual Studio Code.app/Contents/MacOS/Electron`
- Exec Flags: `{project} --goto {file}:{line}:{col}`

Now clicking a script in Godot opens it in VS Code.

### Step 6: Verify the connection
Restart Claude Code, then:
```bash
claude mcp list   # should show godot-mcp-pro
```

The MCP Pro panel in Godot shows a green dot when Claude Code is connected.

---

## Git Setup

Git is a save system for your code. Think of it like save states in a game — you can always go back to any previous save. GitHub is where those saves are stored in the cloud so both of you can work on the same project.

### Step 1: Tell Git who you are (for this project only)

Git needs to know your name and email so it can label your saves ("commits") with who made them.
Run these from inside the project folder — no `--global` flag, so your work identity on this
machine stays untouched everywhere else.

```bash
cd /Users/[you]/godot-helloworld

# No --global = applies to this repo only (stored in .git/config, not your global ~/.gitconfig)
git config user.email "Andy.Augustine@gmail.com"
git config user.name "Andrew Augustine"
```

### Step 2: Initialize Git in your project folder

```bash
# Navigate into the project folder
# "cd" means "change directory" — like opening a folder in Finder, but in the terminal
cd /Users/[you]/godot-helloworld

# Turn this folder into a Git repository (creates the hidden .git tracking folder)
# This only needs to be done once per project
git init

# Rename the default branch to "main" (modern standard name)
git branch -M main
```

### Step 3: Create a .gitignore file

A `.gitignore` tells Git "don't track these files." Godot generates a lot of temporary files we don't want to save — this keeps your repo clean.

```bash
# This creates the .gitignore file with all the right contents in one command
cat > .gitignore << 'EOF'
# Godot auto-generated files (recreated automatically, don't need saving)
.godot/
*.uid
export_presets.cfg

# Mac system files (irrelevant to the project)
.DS_Store
Thumbs.db

# VS Code local settings (personal to each machine)
.vscode/
EOF
```

### Step 4: Make your first save (commit)

In Git, saving is a two-step process:
1. **Stage** — tell Git which files you want to include in this save
2. **Commit** — actually create the save with a message describing what you did

```bash
# Stage ALL files in the current folder (the dot "." means "everything here")
git add .

# Create the save (commit) with a short message describing what changed
# The -m flag lets you write the message inline
git commit -m "Initial project setup"
```

> You'll do `git add .` + `git commit -m "message"` every time you want to save a checkpoint. Think of the message like a save slot name.

### Step 5: Connect to GitHub and upload

GitHub is the cloud backup. You create the empty repo on GitHub first, then link your local folder to it.

1. Go to github.com → click **New repository**
2. Name it `godot-helloworld`, set license to **MIT**, click **Create**
3. Copy the URL GitHub shows you, then run:

```bash
# Link your local folder to the GitHub repo
# "origin" is just a nickname for the GitHub URL — standard convention
git remote add origin https://github.com/[your-username]/godot-helloworld.git

# Upload your commits to GitHub for the first time
# -u sets "origin main" as the default so future pushes just need: git push
git push -u origin main
```

### Day-to-day Git (the only 3 commands you'll use all weekend)

```bash
# See what files have changed since your last save
git status

# Stage everything and commit in one go
git add .
git commit -m "describe what you just built"

# Upload your latest saves to GitHub
git push
```

> **Rule of thumb:** commit every time something works. Even if it's small. You'll thank yourself when something breaks later and you can roll back.

---

## Daily Workflow

```
┌─────────────────┐     WebSocket      ┌──────────────────┐
│   Claude Code   │ ◄────port 6505────► │   Godot Editor   │
│   (terminal)    │                    │  (plugin active) │
└────────┬────────┘                    └────────┬─────────┘
         │ edits files                          │ runs game
         ▼                                      ▼
    VS Code opens                       Output / Debug panel
    scripts on click
```

1. **Open Godot** with your project (plugin auto-starts the WebSocket server)
2. **Open terminal** in the project directory
3. **Start Claude Code**: `claude`
4. Give Claude a prompt like:
   > "Create a CharacterBody2D player scene with horizontal movement, variable jump height, coyote time, and wall sliding. Wire it up as the main scene."
5. Claude uses godot-mcp-pro tools to create scenes, write scripts, and run the game — reading real errors back
6. Godot hot-reloads changed files automatically

---

## Useful Claude Code Prompts to Start

**Scaffold the player:**
```
Create a Metroid-style player in GDScript with CharacterBody2D:
- 8-direction movement, variable jump, coyote time (0.15s), jump buffer (0.1s)
- Wall slide and wall jump
- Separate scenes for player body and camera follow
```

**Scaffold a room:**
```
Create a room scene using TileMapLayer with collision. 
Add a camera boundary that locks to the room edges Metroid-style.
```

**Wire up a simple state machine:**
```
Add a lightweight state machine to the player: Idle, Run, Jump, Fall, WallSlide.
Use an enum and match statement in _physics_process, no external plugin needed.
```

---

## Resources

- [Godot 4 Docs](https://docs.godotengine.org/en/stable/)
- [godot-mcp-pro on itch.io](https://y1uda.itch.io/godot-mcp-pro)
- [godot-mcp-pro GitHub](https://github.com/youichi-uda/godot-mcp-pro)
- [Godot Forum thread](https://forum.godotengine.org/t/godot-mcp-pro-162-tools-for-ai-powered-godot-development/135467)
- [Claude Code as a Godot Editor (dev blog)](https://vivecuervo7.github.io/dev-blog/p/claude-code-godot/)
- [Building a game — What if Claude writes ALL code? (DEV.to)](https://dev.to/datadeer/part-1-building-an-rts-in-godot-what-if-claude-writes-all-code-49f9)
- [Godot + Claude MCP Setup Tutorial (YouTube)](https://www.youtube.com/watch?v=qoVkETfryho)
- [AI Builds a Godot Game From Scratch (YouTube)](https://www.youtube.com/watch?v=THwZYWuOdZI)
- [Godogen (scaffold entire game from prompt)](https://github.com/htdt/godogen)
