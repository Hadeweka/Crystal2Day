class FeatureInstaller
  @cached_feature_checks : Hash(Symbol, Bool) = {} of Symbol => Bool

  FEATURE_CHECKS = {
    :git => "git --version",
    :shards => "shards --version",
    :cl => "cl",
    :gcc => "g++"
  }

  def initialize
  end

  def check_feature(name : Symbol)
    found = false
    if @cached_feature_checks[name]?
      if @cached_feature_checks[name]
        found = true
      else
        found = false
      end
    else
      if FEATURE_CHECKS[name]?
        begin
          run_command(FEATURE_CHECKS[name])
          puts "Feature #{name} is installed."
          found = true
        rescue
          found = false
        end
      else
        raise "Undefined feature: #{name}."
      end
    end
    raise "Feature #{name} is not installed." unless found
  end

  def run_command(cmd : String)
    # TODO: Maybe put error handling here?
    system(cmd)
  end

  def github_clone(repository_user : String, repository : String, branch : String = "main", target_directory : String = "", recursive : Bool = false)
    # TODO: Check features using annotations?
    check_feature(:git)
    run_command("git clone #{recursive ? "--recursive" : ""} --branch #{branch} https://github.com/#{repository_user}/#{repository} #{target_directory}")
  end

  def shards_install
    run_command("shards install")
  end

  def compile_cl(sources : Array(String), target : String, includes : Array(String) = [] of String, options : Array(String) = [] of String, compiler : String = "cl")
    include_string = includes.map {|include_file| "/I #{include_file}"}.join(" ")
    source_string = sources.map {|source_file| "/c #{source_file}"}.join(" ")
    option_string = options.join(" ")

    run_command("#{compiler} #{option_string} #{include_string} #{source_string} /Fo #{target}")
  end

  def compile_gcc(sources : Array(String), target : String, includes : Array(String) = [] of String, options : Array(String) = [] of String, compiler : String = "gcc")
    include_string = includes.map {|include_file| "-I #{include_file}"}.join(" ")
    source_string = sources.map {|source_file| "-c #{source_file}"}.join(" ")
    option_string = options.join(" ")

    run_command("#{compiler} #{option_string} #{include_string} #{source_string} -o #{target}")
  end
end

installer = FeatureInstaller.new
installer.check_feature(:git)
installer.check_feature(:shards)
installer.check_feature(:cl)
