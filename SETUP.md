# Setup

End-to-end install for both **macOS** and **Windows**. Most steps are identical — OS-specific commands are split into side-by-side blocks where they differ.

> godot-mcp-pro is a paid tool ($5, manual download from itch.io). Everything else is free.

---

## Prerequisites at a glance

| Tool | Purpose | Install via |
|---|---|---|
| Godot 4.6+ | Game engine | Direct download (don't use brew/winget — they lag) |
| Node.js 18+ | Runs the MCP server | brew (Mac) / winget (Windows) |
| VS Code | Script editor | brew / winget |
| Claude Code CLI | AI in the terminal | `npm install -g @anthropic-ai/claude-code` |
| godot-mcp-pro | Live editor control | Paid, itch.io ($5) |
| Git | Version control | Pre-installed (Mac) / winget (Windows) |

---

## Step 1: Install Godot

Direct download from [godotengine.org/download](https://godotengine.org/download/) — package managers (brew, winget, choco) lag behind current releases, and the MCP plugin sometimes needs the latest editor.

### macOS
- Download the `.dmg`, open it, drag `Godot.app` to `/Applications`.

### Windows
- Download the `.exe` (Standard 64-bit), run it, choose where to install (e.g. `C:\Program Files\Godot`).
- Optionally pin it to the Start menu — there is no installer that does this for you.

> **GDScript, not C#.** Both versions ship a separate "Mono" build for C#. Pick the standard (non-Mono) build. GDScript has better AI tooling coverage and skips .NET SDK setup.

---

## Step 2: Install Node, VS Code, and Claude Code

### macOS

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

### Windows

`winget` ships with Windows 10/11 — open **PowerShell** (not cmd) as Administrator:

```powershell
winget install OpenJS.NodeJS.LTS
winget install Microsoft.VisualStudioCode
winget install Git.Git

# Restart PowerShell so PATH refreshes, then:
npm install -g @anthropic-ai/claude-code

# Verify
node --version        # should be 18.x+
claude --version

# Log in to Claude
claude login
```

> If `winget` is missing, install **App Installer** from the Microsoft Store, or use direct installers from [nodejs.org](https://nodejs.org/), [code.visualstudio.com](https://code.visualstudio.com/), and [git-scm.com](https://git-scm.com/).

---

## Step 3: Install VS Code extensions

The `code` CLI lets you install extensions and open files from the terminal.

### macOS
Open VS Code → `Cmd+Shift+P` → **Shell Command: Install 'code' command in PATH**.

### Windows
The Windows installer adds `code` to `PATH` automatically. If `code --version` fails, re-run the installer and check the "Add to PATH" option.

### Both OSes — install both extensions

```bash
code --install-extension geequlim.godot-tools
code --install-extension anthropic.claude-code
```

- **godot-tools** — GDScript syntax + Godot LSP. On first use it asks for the Godot executable; point it at your install (`/Applications/Godot.app` on Mac, `C:\Program Files\Godot\Godot_v4.x.exe` on Windows).
- **Claude Code** extension — Claude Code inside VS Code. The MCP server still requires the **terminal CLI**, not this extension.

---

## Step 4: Purchase godot-mcp-pro (paid, manual)

Go to [y1uda.itch.io/godot-mcp-pro](https://y1uda.itch.io/godot-mcp-pro) and purchase ($5 one-time, lifetime updates). This step has no automation — itch.io doesn't expose a CLI for paid downloads.

Unzip somewhere permanent — the MCP server runs from this folder:

| OS | Suggested location |
|---|---|
| macOS | `~/code/tools/godot-mcp-pro/` |
| Windows | `C:\Users\<you>\code\tools\godot-mcp-pro\` |

The zip contains:
- `addons/godot_mcp/` — the Godot plugin
- `server/` — the Node.js MCP server

---

## Step 5: Build the MCP server

### macOS
```bash
cd ~/code/tools/godot-mcp-pro/<version>/server
node build/setup.js install
node build/setup.js doctor   # verifies install
```

### Windows (PowerShell)
```powershell
cd C:\Users\<you>\code\tools\godot-mcp-pro\<version>\server
node build/setup.js install
node build/setup.js doctor
```

`install` runs `npm install` and compiles the TypeScript server. `doctor` confirms it's runnable.

---

## Step 6: Wire the plugin into your Godot project

From the Godot project directory:

### macOS
```bash
cp -r ~/code/tools/godot-mcp-pro/<version>/addons ./addons
node ~/code/tools/godot-mcp-pro/<version>/server/build/setup.js configure
```

### Windows (PowerShell)
```powershell
Copy-Item -Recurse C:\Users\<you>\code\tools\godot-mcp-pro\<version>\addons .\addons
node C:\Users\<you>\code\tools\godot-mcp-pro\<version>\server\build\setup.js configure
```

`configure` writes a `.mcp.json` in the project root that Claude Code picks up automatically.

> If the generated `.mcp.json` contains a `GODOT_MCP_PORT` entry, **remove it**. The server auto-scans ports 6505–6509; pinning a port causes silent failures when a stale process holds it.

---

## Step 7: Open the project in Godot, enable the plugin

1. Launch Godot → **Import** → select the `project.godot` file in this repo.
2. **Project → Project Settings → Plugins tab** → find **Godot MCP Pro** → set to **Enable**.
3. An "MCP Pro" panel appears at the bottom of the editor with a connection status dot.

---

## Step 8: Set VS Code as the external script editor

Open Godot's editor settings:

- **macOS**: top menu bar → **Godot → Editor Settings**
- **Windows**: top menu bar → **Editor → Editor Settings**

Search for **"external"** in the left sidebar, then:

- Enable **Use External Editor**
- Set the exec path:

| OS | Exec Path |
|---|---|
| macOS | `/Applications/Visual Studio Code.app/Contents/MacOS/Electron` |
| Windows | `C:\Users\<you>\AppData\Local\Programs\Microsoft VS Code\Code.exe` |

- Exec Flags (both OSes): `{project} --goto {file}:{line}:{col}`

Now clicking a script in Godot opens it in VS Code at the right line.

---

## Step 9: Verify the connection

Restart Claude Code from the project directory:

```bash
claude mcp list   # should show godot-mcp-pro
```

The MCP Pro panel in Godot shows a **green dot** when Claude Code is connected.

---

## Step 10: Git setup (first time on a new machine)

The repo already has a `.gitignore` and a Git history, so cloning is the simple path:

```bash
git clone https://github.com/<your-username>/godot-helloworld.git
cd godot-helloworld
```

Set your identity **for this repo only** (no `--global`, so your other machines/projects stay untouched):

```bash
git config user.email "you@example.com"
git config user.name "Your Name"
```

Day-to-day commands:

```bash
git status                           # see what changed
git add .                            # stage everything
git commit -m "describe the change"  # save a checkpoint
git push                             # upload to GitHub
```

> **Rule of thumb:** commit every time something works. Small commits are easy to roll back; big commits are not.

---

## Step 11: Launching Claude on this project

Once everything's installed, working with Claude is just one terminal command — but there's nuance around model selection and parallel sessions worth knowing.

### Default launch

```bash
cd /Users/[you]/godot-helloworld
claude
```

This opens a Claude Code session **in the project root**. Crucial — Claude needs to be in the project folder so it can read `ROADMAP.md`, `CLAUDE.md`, etc., and so MCP can find the Godot editor on the same machine.

### Picking a model

Claude Code uses Opus 4.7 by default — the most capable model. But Opus is overkill (and pricier) for mechanical execution work. Pick the right tool:

| Model | When to use | Launch command |
|---|---|---|
| **Opus 4.7** | New subsystems, architecture decisions, planning, debugging hairy issues, anything requiring real reasoning | `claude` (default) |
| **Sonnet 4.6** | Executing a self-contained plan, mechanical multi-file edits, doc writing, refactors with clear specs | `claude --model claude-sonnet-4-6` |
| **Haiku 4.5** | Trivial tasks (simple grep, single-file tweak, format change). Risky on multi-file work. | `claude --model claude-haiku-4-5-20251001` |

You can also **switch models mid-session** with `/model`. The model isn't locked once chosen.

> **Why model choice matters:** Sonnet is meaningfully faster and cheaper than Opus, with no quality loss on well-specified mechanical work. If you hand off `plans/<feature>.md` to a side-Claude that just needs to execute the plan, Sonnet is the right pick. Reserve Opus for work where the model needs to make real decisions.

### Running a side-Claude session in parallel

When you want a long mechanical task (executing a fully-specced plan) to run while you continue other work, spawn a second Claude in a new terminal:

```bash
# In a NEW terminal window
cd /Users/[you]/godot-helloworld          # same project folder
claude --model claude-sonnet-4-6
```

Then paste the task brief, e.g.:

> *"Read `plans/audio-foundations.md` and execute it end to end. Confirm before starting. Don't push without showing me."*

**Important constraints when running parallel Claudes on one machine:**

- **Only one Claude can use the Godot MCP at a time.** Both can write GDScript files freely, but if both try `play_scene` or `add_node` simultaneously, they'll conflict. Coordinate: one is the "MCP session" (running game, scene-editing), the others are "script-only sessions" (file edits only).
- **Both share the git working tree.** If they both touch the same file, last write wins. Use feature branches (`git checkout -b feature/<name>`) for the side-Claude when in doubt — see `ROADMAP.md` Phase B for the full team-mode workflow.
- **For different developers on different laptops, this isn't a concern** — each has their own Godot + MCP + working tree.

### Verifying Claude is connected to MCP

After Claude launches:

```bash
claude mcp list                        # in another terminal — should show godot-mcp-pro
```

Or in Claude itself, ask it to read editor errors — if it can call `get_editor_errors`, MCP is connected.

The MCP Pro panel inside Godot shows a **green dot** when a Claude session is connected, **red** when not.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `claude mcp list` shows nothing | Started Claude before opening Godot, or wrong directory | `cd` into the project, then `claude` |
| MCP Pro panel red dot | Plugin disabled, or Claude Code isn't running | Project Settings → Plugins → enable; start `claude` from the project root |
| `node build/setup.js doctor` fails | Node version too old | Need 18+; check with `node --version` |
| Godot doesn't open scripts in VS Code | Exec path wrong | Re-check Step 8 — full path to the binary, not just the app folder |
| Port 6505 errors after a crash | Stale process holding the port | Quit Godot fully, kill any lingering Node processes, reopen |

---

## What's next

Once everything's installed and Claude is connected:

- **[ROADMAP.md](ROADMAP.md)** — current state of the project, active plans, what to pick up next.
- **[STRUCTURE.md](STRUCTURE.md)** — folder layout and how the pieces talk to each other.
- **[GODOT_PRIMER.md](GODOT_PRIMER.md)** — Godot/GDScript Rosetta stone. **Read this first if you're coming from Unreal or Unity** — it maps every Godot construct used in this codebase to its Unreal/Unity equivalent so you can read the rest without stalling on syntax.
- **[CLAUDE.md](CLAUDE.md)** — the rules every Claude session follows, including the `/orient` and `/wrapup` session bookends.
