module Utils
  def self.compile_imgui_backend(source, target)
    if ENV["OS"] == "Windows_NT"
      system("cl /I \"lib/imgui/cimgui/imgui/backends\" /I \"temp/SDL/include\" /I \"lib/imgui/cimgui/imgui\" /c \"#{source}\" /Fo\"#{target}.obj\"")
    else
      # TODO
    end
  end
end

task :add_feature_anyolite do
  system("git clone --branch main https://github.com/Anyolite/anyolite lib/anyolite")
  Dir.chdir("lib/anyolite")
  system("crystal install.cr")
  Dir.chdir("../..")
  if File.exist?("lib/anyolite/build/mruby/lib/libmruby.lib")
    puts "Anyolite was successfully installed."
  else
    raise "Could not install Anyolite."
  end
end

task :add_feature_imgui do
  system("git clone --recursive https://github.com/oprypin/crystal-imgui lib/imgui")
  Dir.chdir("lib/imgui/cimgui")
  system("cmake -DCMAKE_CXX_FLAGS='-DIMGUI_USE_WCHAR32' .")
  system("cmake --build .")
  Dir.chdir("../../..")
  FileUtils.cp("lib/imgui/cimgui/Debug/cimgui.lib", "./cimgui.lib")
  if ENV["OS"] == "Windows_NT"
    FileUtils.cp("lib/imgui/cimgui/Debug/cimgui.dll", "./cimgui.dll")
  else
    FileUtils.cp("lib/imgui/cimgui/Debug/cimgui.so", "./cimgui.so")
  end
  Dir.mkdir("temp") if !Dir.exist?("temp")
  system("git clone --branch SDL2 https://github.com/libsdl-org/SDL temp/SDL")
  Utils.compile_imgui_backend("lib/imgui/cimgui/cimgui.cpp", "temp/cimgui")
  Utils.compile_imgui_backend("src/glue/imgui_impl_sdl.cpp", "temp/imgui_impl_sdl")
  Utils.compile_imgui_backend("lib/imgui/cimgui/imgui/backends/imgui_impl_sdl2.cpp", "temp/imgui_impl")
  Utils.compile_imgui_backend("lib/imgui/cimgui/imgui/backends/imgui_impl_sdlrenderer.cpp", "temp/imgui_impl_renderer")
  ["imgui", "imgui_draw", "imgui_widgets", "imgui_tables", "imgui_demo"].each do |name|
    Utils.compile_imgui_backend("lib/imgui/cimgui/imgui/#{name}.cpp", "temp/#{name}")
  end
  if ENV["OS"] == "Windows_NT"
    system("lib /OUT:\"temp/imgui_impl_sdl.lib\" \"temp/imgui_impl_sdl.obj\" \"temp/imgui_impl_renderer.obj\" \"temp/cimgui.obj\" \"temp/imgui_impl.obj\" \"temp/imgui.obj\" \"temp/imgui_draw.obj\" \"temp/imgui_widgets.obj\" \"temp/imgui_tables.obj\" \"temp/imgui_demo.obj\"")
  else
    # TODO
  end
end

task :install_sdl_libraries do
  # TODO
end
