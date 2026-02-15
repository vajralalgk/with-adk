# CLAUDE.md

## Project Overview

This is a **CopilotKit + Google ADK Starter** — a full-stack AI agent application that combines a Next.js frontend with a Python-based Google ADK (Agent Development Kit) backend agent. The demo app manages a list of proverbs via an AI-powered chat sidebar and includes a weather tool.

## Architecture

```
Frontend (Next.js 15, port 3000)
  └─► /api/copilotkit (API route)
        └─► CopilotKit Runtime (HttpAgent via @ag-ui/client)
              └─► Python ADK Agent (FastAPI, port 8000)
                    └─► Google Gemini 2.5 Flash
```

**Frontend** (`src/`): Next.js App Router with React 19, CopilotKit for AI chat UI, and Tailwind CSS 4 for styling.

**Backend** (`agent/`): Python FastAPI server running a Google ADK agent wrapped with `ag-ui-adk` middleware for CopilotKit compatibility.

**Communication**: The frontend sends requests to `/api/copilotkit`, which proxies them via CopilotKit Runtime to the Python agent at `http://localhost:8000/`. Shared state (proverbs list) is synchronized between the agent and frontend via CopilotKit's `useCoAgent` hook.

## Directory Structure

```
with-adk/
├── agent/
│   ├── agent.py              # ADK agent: tools, callbacks, FastAPI server
│   └── requirements.txt      # Python dependencies
├── scripts/
│   ├── setup-agent.sh/.bat   # Create venv and install Python deps
│   └── run-agent.sh/.bat     # Activate venv and start agent server
├── src/
│   └── app/
│       ├── layout.tsx         # Root layout with CopilotKit provider
│       ├── page.tsx           # Main UI: proverbs list, theme picker, chat sidebar
│       ├── globals.css        # Tailwind imports and CSS variables
│       └── api/copilotkit/
│           └── route.ts       # CopilotKit runtime API endpoint
├── public/                    # Static SVG assets
├── package.json
├── tsconfig.json
├── next.config.ts
├── eslint.config.mjs
└── postcss.config.mjs
```

## Key Files

| File | Purpose |
|------|---------|
| `src/app/page.tsx` | Main client component: proverbs list UI, theme color state, frontend actions (`setThemeColor`), shared agent state via `useCoAgent`, generative UI (`WeatherCard`), `CopilotSidebar` |
| `src/app/layout.tsx` | Root layout wrapping app in `<CopilotKit>` provider, connects to agent named `"my_agent"` |
| `src/app/api/copilotkit/route.ts` | POST endpoint bridging Next.js to the Python agent via `CopilotRuntime` and `HttpAgent` |
| `agent/agent.py` | Python agent: `ProverbsAgent` (Gemini 2.5 Flash), tools (`set_proverbs`, `get_weather`), callbacks for state initialization and system prompt injection, FastAPI server |

## Tech Stack

### Frontend
- **Next.js 15.3.2** (App Router, Turbopack dev server)
- **React 19**
- **CopilotKit 1.10.4** (`@copilotkit/react-core`, `@copilotkit/react-ui`, `@copilotkit/runtime`)
- **@ag-ui/client** — HTTP agent adapter for CopilotKit-to-ADK communication
- **Tailwind CSS 4** (via `@tailwindcss/postcss`)
- **Zod** — schema validation
- **TypeScript 5**

### Backend (Python)
- **FastAPI** + **Uvicorn** — HTTP server
- **google-adk** — Google Agent Development Kit
- **google-genai** — Google Generative AI (Gemini models)
- **ag-ui-adk** — AG-UI adapter for ADK agents
- **Pydantic** — state/data models
- **python-dotenv** — environment variable loading

## Development Commands

```bash
# Install all dependencies (Node + Python agent venv)
npm install                  # Also triggers postinstall → npm run install:agent

# Start both frontend and agent concurrently
npm run dev                  # UI on :3000, Agent on :8000

# Start individually
npm run dev:ui               # Next.js dev server with Turbopack
npm run dev:agent            # Python agent server

# Debug mode (verbose logging)
npm run dev:debug

# Production
npm run build                # Next.js production build
npm run start                # Start production server

# Linting
npm run lint                 # ESLint with next/core-web-vitals + next/typescript
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `GOOGLE_API_KEY` | Yes | Google Makersuite API key for Gemini model access |
| `PORT` | No | Agent server port (default: `8000`) |
| `LOG_LEVEL` | No | Set to `debug` for verbose logging |

Get a key from: https://makersuite.google.com/app/apikey

## Agent Architecture Details

The Python agent (`agent/agent.py`) uses these components:

- **`ProverbsState`** (Pydantic model): Shared state schema with a `proverbs: list[str]` field
- **Tools**:
  - `set_proverbs(new_proverbs)` — replaces the full proverbs list in agent state
  - `get_weather(location)` — returns mock weather data
- **Callbacks**:
  - `on_before_agent` — initializes empty proverbs state if missing
  - `before_model_modifier` — injects current proverbs list into the system prompt before each LLM call
  - `simple_after_model_modifier` — ends the agent invocation after a text model response (prevents consecutive tool calling loops)
- **ADK Middleware**: Wraps the agent in `ADKAgent` with in-memory session service (3600s timeout)

## Frontend Patterns

- **Client components** use the `"use client"` directive (page.tsx)
- **Shared state** managed via `useCoAgent<AgentState>({ name: "my_agent" })` — state syncs bidirectionally between the agent and UI
- **Frontend actions** defined with `useCopilotAction()` — e.g., `setThemeColor` lets the agent change UI theme
- **Generative UI** via `useCopilotAction` with `render` prop — e.g., `WeatherCard` renders inline in the chat
- **Path alias**: `@/*` maps to `./src/*` (configured in tsconfig.json)

## Conventions

- **Lock files are gitignored** — the project deliberately ignores `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, and `bun.lockb` to avoid conflicts across package managers
- **Python virtual environment** lives at `agent/.venv/` (gitignored)
- **No test framework** is currently configured
- **ESLint** uses flat config format (`eslint.config.mjs`) extending `next/core-web-vitals` and `next/typescript`
- **Tailwind CSS 4** uses the PostCSS plugin approach (no `tailwind.config.js`)
- **Cross-platform scripts** — shell scripts have both `.sh` (Linux/Mac) and `.bat` (Windows) variants

## Common Tasks

**Adding a new agent tool**: Define a Python function in `agent/agent.py` accepting `tool_context: ToolContext` as the first parameter, then add it to the `tools` list in the `LlmAgent` constructor.

**Adding a frontend action**: Use `useCopilotAction()` in `page.tsx` with a name, description, parameters (Zod schema), and handler function.

**Modifying shared state schema**: Update `ProverbsState` in `agent/agent.py` and the corresponding `AgentState` TypeScript type in `page.tsx`.

**Changing the AI model**: Update the `model` parameter in the `LlmAgent` constructor in `agent/agent.py`.
