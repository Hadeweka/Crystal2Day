{% if file_exists?("lib/anyolite/") %}
  CRYSTAL2DAY_CONFIGS_ANYOLITE = true
  require "anyolite"
  ANYOLITE_DEFAULT_OPTIONAL_ARGS_TO_KEYWORD_ARGS = true
  require "../scripting/Interpreter.cr"
  require "../scripting/Coroutine.cr"
  require "../scripting/Hook.cr"
{% else %}
  CRYSTAL2DAY_CONFIGS_ANYOLITE = false
{% end %}
