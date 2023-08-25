{% if file_exists?("lib/imgui/") %}
  CRYSTAL2DAY_CONFIGS_IMGUI = true
  require "imgui"
  require "../glue/ImguiImplSDL.cr"
{% else %}
  CRYSTAL2DAY_CONFIGS_IMGUI = false
{% end %}
