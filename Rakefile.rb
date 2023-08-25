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
  # TODO
end

task :install_sdl_libraries do
  # TODO
end
