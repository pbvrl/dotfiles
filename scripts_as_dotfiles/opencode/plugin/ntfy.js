// Work in progress

const ENDPOINT = "http://vps";
const TOPIC = "notifications";

const MAX_BODY_BYTES = 3500;

// ntfysh priorities, tags
const ROUTINE = 2;
const DONE = 3;
const ATTENTION = 4;
const STICKY = "sticky";

function truncate(body) {
	const encoded = Buffer.from(body, "utf8");
	if (encoded.length <= MAX_BODY_BYTES) return body;
	const clipped = encoded.subarray(0, MAX_BODY_BYTES).toString("utf8");
	const cut = clipped.lastIndexOf("\n");
	return (cut === -1 ? clipped : clipped.slice(0, cut)) + "\n[truncated]";
}

async function publish(message, title, priority = ROUTINE, sticky = false) {
	try {
		await fetch(ENDPOINT, {
			method: "POST",
			body: JSON.stringify({
				topic: TOPIC,
				title: title || "opencode",
				message: truncate(message || "(empty)"),
				priority,
				tags: sticky ? ["opencode", STICKY] : ["opencode"],
			}),
		});
	} catch {}
}

// fnott decodes HTML
const escape = (text) =>
	String(text)
		.replace(/&/g, "&amp;")
		.replace(/</g, "&lt;")
		.replace(/>/g, "&gt;");

const ADDED = "\u{1F7E9}"; // green square
const REMOVED = "\u{1F7E5}"; // red square
const GUTTER = " ";
const markup = (lines) =>
	lines
		.map((line) => {
			const rest = escape(line.slice(1));
			if (line.startsWith("+")) return `${ADDED} ${rest}`;
			if (line.startsWith("-")) return `${REMOVED} ${rest}`;
			return `${GUTTER} ${escape(line)}`;
		})
		.join("\n");

const TOOLS = {
	apply_patch: (a) => {
		const lines = String(a.patchText ?? "").split("\n");
		const file = lines.find((l) => l.includes("File: "))?.split("File: ")[1];
		return [
			markup(lines.filter((l) => !l.startsWith("*** ") && l !== "@@")),
			file,
		];
	},
};

const CODE_CHANGE = new Set([
	"apply_patch",
	"patch",
	"edit",
	"write",
	"multiedit",
]);

export const NtfyPlugin = async () => ({
	"tool.execute.after": async (input) => {
		if (!CODE_CHANGE.has(input.tool)) return;
		const format = TOOLS[input.tool];
		const args = input.args ?? {};
		if (format) {
			const [message, title] = format(args);
			await publish(message, title, ROUTINE, true);
		} else {
			await publish(
				`${input.tool} - ${JSON.stringify(args)}`,
				null,
				ROUTINE,
				true,
			);
		}
	},

	event: async ({ event }) => {
		if (event.type === "session.idle") await publish("Finished", null, DONE);
		else if (event.type === "session.error") {
			const error = event.properties?.error;
			const detail =
				`${error?.name ?? "unknown"} ${error?.data?.message ?? ""}`.trim();
			await publish(`Error: ${detail}`, null, ATTENTION);
		}
	},
});
