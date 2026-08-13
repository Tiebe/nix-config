# Declarative source of truth for ~/.omp/agent/config.yml, ported from the
# machine's existing (manually onboarded) OMP configuration.
{
  setupVersion = 1;

  providers.webSearchOrder = [
    "perplexity"
    "gemini"
    "anthropic"
    "codex"
    "xai"
    "zai"
    "exa"
    "tinyfish"
    "jina"
    "kagi"
    "tavily"
    "firecrawl"
    "brave"
    "kimi"
    "parallel"
    "synthetic"
    "searxng"
    "startpage"
    "duckduckgo"
    "ecosia"
    "google"
    "mojeek"
    "public"
  ];

  modelRoles.default = "anthropic/claude-sonnet-5:high";

  modelProviderOrder = ["openai-codex" "agent"];

  computer.enabled = false;
  checkpoint.enabled = false;

  dev.autoqaConsent = "denied";

  task.agentModelOverrides = {
    librarian = "anthropic/claude-sonnet-5";
    reviewer = "anthropic/claude-sonnet-5";
    scout = "anthropic/claude-sonnet-5";
    sonic = "anthropic/claude-sonnet-5";
    task = "anthropic/claude-sonnet-5";
  };
}
