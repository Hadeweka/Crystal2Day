{% if file_exists?("lib/imgui/") %}
  CRYSTAL2DAY_CONFIGS_IMGUI = true
{% else %}
  CRYSTAL2DAY_CONFIGS_IMGUI = false
{% end %}
