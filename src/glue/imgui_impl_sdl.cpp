#include "SDL.h"
#include "imgui_impl_sdl2.h"
#include "imgui_impl_sdlrenderer.h"

extern "C" {
  bool Extern_ImGui_ImplSDL2_ProcessEvent(const SDL_Event* event) {
    return ImGui_ImplSDL2_ProcessEvent(event);
  }

  bool Extern_ImGui_ImplSDL2_InitForSDLRenderer(ImGuiContext* ctx, SDL_Window* window, SDL_Renderer* renderer) {
    ImGui_ImplSDL2_InitForSDLRenderer(window, renderer);
    return ImGui_ImplSDLRenderer_Init(renderer);
  }

  void Extern_ImGui_ImplSDL2_Shutdown() {
    ImGui_ImplSDLRenderer_Shutdown();
    ImGui_ImplSDL2_Shutdown();
  }

  void Extern_ImGui_ImplSDL2_NewFrame() {
    ImGui_ImplSDLRenderer_NewFrame();
    ImGui_ImplSDL2_NewFrame();
  }

  void Extern_Render() {
    ImGui_ImplSDLRenderer_RenderDrawData(ImGui::GetDrawData());
  }
}
