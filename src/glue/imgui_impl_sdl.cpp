#include "SDL.h"
#include "imgui_impl_sdl2.h"
#include "imgui_impl_sdlrenderer2.h"

extern "C" {
  bool Extern_ImGui_ImplSDL2_ProcessEvent(const SDL_Event* event) {
    return ImGui_ImplSDL2_ProcessEvent(event);
  }

  bool Extern_ImGui_ImplSDL2_InitForSDLRenderer(ImGuiContext* ctx, SDL_Window* window, SDL_Renderer* renderer) {
    ImGui_ImplSDL2_InitForSDLRenderer(window, renderer);
    return ImGui_ImplSDLRenderer2_Init(renderer);
  }

  void Extern_ImGui_ImplSDL2_Shutdown() {
    ImGui_ImplSDLRenderer2_Shutdown();
    ImGui_ImplSDL2_Shutdown();
  }

  void Extern_ImGui_ImplSDL2_NewFrame() {
    ImGui_ImplSDLRenderer2_NewFrame();
    ImGui_ImplSDL2_NewFrame();
  }

  void Extern_Render() {
    ImGui_ImplSDLRenderer2_RenderDrawData(ImGui::GetDrawData());
  }
}
