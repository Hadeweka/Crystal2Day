#include "SDL3/SDL.h"
#include "imgui_impl_sdl3.h"
#include "imgui_impl_sdlrenderer3.h"

extern "C" {
  bool Extern_ImGui_ImplSDL3_ProcessEvent(const SDL_Event* event) {
    return ImGui_ImplSDL3_ProcessEvent(event);
  }

  bool Extern_ImGui_ImplSDL3_InitForSDLRenderer(ImGuiContext* ctx, SDL_Window* window, SDL_Renderer* renderer) {
    ImGui_ImplSDL3_InitForSDLRenderer(window, renderer);
    return ImGui_ImplSDLRenderer3_Init(renderer);
  }

  void Extern_ImGui_ImplSDL3_Shutdown() {
    ImGui_ImplSDLRenderer3_Shutdown();
    ImGui_ImplSDL3_Shutdown();
  }

  void Extern_ImGui_ImplSDL3_NewFrame() {
    ImGui_ImplSDLRenderer3_NewFrame();
    ImGui_ImplSDL3_NewFrame();
  }

  void Extern_Render(SDL_Renderer* renderer) {
    ImGui_ImplSDLRenderer3_RenderDrawData(ImGui::GetDrawData(), renderer);
  }
}
