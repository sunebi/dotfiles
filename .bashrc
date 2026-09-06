# oh-my-openagent
export OMO_DISABLE_POSTHOG=1
export OMO_SEND_ANONYMOUS_TELEMETRY=0

omo() {
  OPENCODE_CONFIG_CONTENT='{"plugin":["oh-my-openagent"]}' command opencode "$@"
}
