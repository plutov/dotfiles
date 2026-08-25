import { existsSync } from "node:fs";
import { relative, resolve } from "node:path";
import { spawn } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { DynamicBorder } from "@earendil-works/pi-coding-agent";
import { Container, type SelectItem, SelectList, Text } from "@earendil-works/pi-tui";

type ChangedFile = {
	absolutePath: string;
	relativePath: string;
};

async function git(pi: ExtensionAPI, args: string[]) {
	return pi.exec("git", args, { timeout: 5000 });
}

function parsePaths(output: string): string[] {
	return output.split("\0").filter(Boolean);
}

async function changedFiles(pi: ExtensionAPI, cwd: string): Promise<ChangedFile[]> {
	const root = await git(pi, ["-C", cwd, "rev-parse", "--show-toplevel"]);
	if (root.code !== 0) throw new Error("Not inside a Git repository.");

	const repositoryRoot = root.stdout.trim();
	const diff = await git(pi, [
		"-C",
		repositoryRoot,
		"diff",
		"--name-only",
		"-z",
		"--diff-filter=ACMRTUXB",
		"HEAD",
		"--",
	]);

	let paths: string[];
	if (diff.code === 0) {
		paths = parsePaths(diff.stdout);
	} else {
		const [staged, unstaged] = await Promise.all([
			git(pi, ["-C", repositoryRoot, "diff", "--cached", "--name-only", "-z", "--diff-filter=ACMRTUXB"]),
			git(pi, ["-C", repositoryRoot, "diff", "--name-only", "-z", "--diff-filter=ACMRTUXB"]),
		]);
		paths = [...parsePaths(staged.stdout), ...parsePaths(unstaged.stdout)];
	}

	return [...new Set(paths)]
		.map((path) => ({ absolutePath: resolve(repositoryRoot, path), relativePath: path }))
		.filter(({ absolutePath }) => existsSync(absolutePath))
		.sort((a, b) => a.relativePath.localeCompare(b.relativePath));
}

function openInZed(filePath: string, onError: () => void): void {
	try {
		const zed = spawn("zed", [filePath], { detached: true, stdio: "ignore" });
		zed.once("error", onError);
		zed.unref();
	} catch {
		onError();
	}
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("diff", {
		description: "Browse changed Git files and open one in Zed",
		handler: async (_args, ctx) => {
			if (ctx.mode !== "tui") {
				ctx.ui.notify("/diff requires interactive TUI mode.", "error");
				return;
			}

			let files: ChangedFile[];
			try {
				files = await changedFiles(pi, ctx.cwd);
			} catch (error) {
				ctx.ui.notify(error instanceof Error ? error.message : "Failed to list changed files.", "error");
				return;
			}

			if (files.length === 0) {
				ctx.ui.notify("No changed files to open.", "info");
				return;
			}

			const items: SelectItem[] = files.map(({ absolutePath, relativePath }) => ({
				value: absolutePath,
				label: relativePath,
			}));
			const filePath = await ctx.ui.custom<string | null>((tui, theme, _keybindings, done) => {
				const container = new Container();
				container.addChild(new DynamicBorder((text: string) => theme.fg("accent", text)));
				container.addChild(new Text(theme.fg("accent", theme.bold("Changed files")), 1, 0));

				const list = new SelectList(items, Math.min(items.length, 15), {
					selectedPrefix: (text) => theme.fg("accent", text),
					selectedText: (text) => theme.fg("accent", text),
					scrollInfo: (text) => theme.fg("dim", text),
					noMatch: (text) => theme.fg("warning", text),
				});
				list.onSelect = (item) => done(item.value);
				list.onCancel = () => done(null);
				container.addChild(list);
				container.addChild(new Text(theme.fg("dim", "↑↓ navigate • enter open in Zed • esc cancel"), 1, 0));
				container.addChild(new DynamicBorder((text: string) => theme.fg("accent", text)));

				return {
					render: (width: number) => container.render(width),
					invalidate: () => container.invalidate(),
					handleInput: (data: string) => {
						list.handleInput(data);
						tui.requestRender();
					},
				};
			});

			if (!filePath) return;
			openInZed(filePath, () => ctx.ui.notify("Could not start Zed.", "error"));
			ctx.ui.notify(`Opening ${relative(ctx.cwd, filePath)} in Zed.`, "info");
		},
	});
}
