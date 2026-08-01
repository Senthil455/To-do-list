# Tasks

A minimal to-do list that runs entirely in the browser. No frameworks, no build step — just HTML, CSS, and vanilla JavaScript.

## Features

- **Add tasks** — type and press Enter, or click **+ Add**
- **Complete & delete** — click the circle to toggle done, click ✕ to remove
- **Filters** — view **All**, **Active**, or **Done** tasks
- **Remaining counter** — always shows how many tasks are left
- **Persistent** — tasks and the active filter survive page reloads via `localStorage`
- **Duplicate check** — the same task can't be added twice
- **Responsive** — works on mobile and desktop

## Getting started

No dependencies or tooling required:

1. Clone or download this repository
2. Open `index.html` in any modern browser
3. Start adding tasks

## Project structure

```
index.html   — page structure
style.css    — styling and responsive layout
script.js    — app logic (storage, filters, rendering)
```

## How it works

Tasks are stored in your browser's `localStorage` under the key `mytodos`, and the active filter under `todo_view`. Everything runs client-side — no server, no data ever leaves your machine.

## Browser support

Works in all modern browsers (Chrome, Firefox, Safari, Edge).
