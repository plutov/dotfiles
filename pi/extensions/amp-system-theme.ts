import { exec } from "node:child_process";
import { promisify } from "node:util";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const execAsync = promisify(exec);
const POLL_MS = 2000;

function canManageThemes(ctx: ExtensionContext): boolean {
  return ctx.hasUI && ctx.ui.getAllThemes().length > 0;
}

async function detectAppearance(): Promise<"dark" | "light"> {
  try {
    const { stdout } = await execAsync(
      "osascript -e 'tell application \"System Events\" to tell appearance preferences to return dark mode'",
      { timeout: 800 },
    );

    return stdout.trim() === "true" ? "dark" : "light";
  } catch {
    return "light";
  }
}

async function syncTheme(ctx: ExtensionContext): Promise<void> {
  if (process.platform !== "darwin" || !canManageThemes(ctx)) {
    return;
  }

  const appearance = await detectAppearance();
  const targetTheme = appearance === "dark" ? "amp-dark" : "amp-light";

  if (ctx.ui.theme.name === targetTheme) {
    return;
  }

  const result = ctx.ui.setTheme(targetTheme);
  if (!result.success) {
    console.warn(`[amp-system-theme] Failed to set theme \"${targetTheme}\": ${result.error ?? "unknown error"}`);
  }
}

export default function ampSystemTheme(pi: ExtensionAPI): void {
  let intervalId: ReturnType<typeof setInterval> | null = null;

  pi.on("session_start", async (_event, ctx) => {
    await syncTheme(ctx);

    if (intervalId) {
      clearInterval(intervalId);
    }

    intervalId = setInterval(() => {
      void syncTheme(ctx);
    }, POLL_MS);
  });

  pi.on("resources_discover", async (_event, ctx) => {
    await syncTheme(ctx);
  });

  pi.on("before_agent_start", async (_event, ctx) => {
    await syncTheme(ctx);
  });

  pi.on("session_shutdown", () => {
    if (!intervalId) {
      return;
    }

    clearInterval(intervalId);
    intervalId = null;
  });
}
