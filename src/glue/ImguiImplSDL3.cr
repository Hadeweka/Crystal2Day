{% if flag?(:win32) %}
  @[Link(ldflags: "\"#{__DIR__}/../../temp/imgui_impl_sdl3.lib\"")]
{% else %}
  @[Link(ldflags: "\"#{__DIR__}/../../temp/imgui_impl_sdl3.a\" -lstdc++")]
{% end %}
lib ImGuiImplSDL
  fun init = Extern_ImGui_ImplSDL3_InitForSDLRenderer(ctx : Void*, window : LibSDL::Window*, renderer : LibSDL::Renderer*)
  fun new_frame = Extern_ImGui_ImplSDL3_NewFrame()
  fun process_event = Extern_ImGui_ImplSDL3_ProcessEvent(event : LibSDL::Event*)
  fun shutdown = Extern_ImGui_ImplSDL3_Shutdown()
  fun render = Extern_Render(renderer : LibSDL::Renderer*)
end
