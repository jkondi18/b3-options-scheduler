const DISPATCH_URL =
  "https://api.github.com/repos/jkondi18/b3-options-scheduler/actions/workflows/daily-monitor.yml/dispatches";

async function dispatchGitHubWorkflow(env, cronExpression) {
  if (!env.GITHUB_TOKEN) {
    throw new Error("GITHUB_TOKEN nao foi configurado no Cloudflare.");
  }

  let lastFailure = "falha desconhecida";

  for (let attempt = 1; attempt <= 3; attempt += 1) {
    const response = await fetch(DISPATCH_URL, {
      method: "POST",
      headers: {
        Accept: "application/vnd.github+json",
        Authorization: `Bearer ${env.GITHUB_TOKEN}`,
        "Content-Type": "application/json",
        "User-Agent": "b3-options-clock",
        "X-GitHub-Api-Version": "2026-03-10"
      },
      body: JSON.stringify({ ref: "main" })
    });

    if (response.ok) {
      console.log(
        JSON.stringify({
          dispatched: true,
          cron: cronExpression,
          attempt,
          status: response.status
        })
      );
      return;
    }

    const responseText = await response.text();
    lastFailure = `GitHub respondeu ${response.status}: ${responseText.slice(0, 300)}`;

    if (response.status === 401 || response.status === 403) {
      break;
    }

    await new Promise((resolve) => setTimeout(resolve, attempt * 500));
  }

  throw new Error(lastFailure);
}

export default {
  async scheduled(controller, env, ctx) {
    ctx.waitUntil(dispatchGitHubWorkflow(env, controller.cron));
  }
};
