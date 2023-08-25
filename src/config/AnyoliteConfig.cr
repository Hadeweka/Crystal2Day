{% if file_exists?("lib/anyolite/") %}
  CRYSTAL2DAY_CONFIGS_ANYOLITE = true
  require "anyolite"
  ANYOLITE_DEFAULT_OPTIONAL_ARGS_TO_KEYWORD_ARGS = true
  require "../scripting/Interpreter.cr"
{% else %}
  CRYSTAL2DAY_CONFIGS_ANYOLITE = false
  # Add some fake annotations to prevent compiletime errors, while keeping code readable
  module Anyolite
    annotation Exclude; end
    annotation ExcludeInstanceMethod; end
    annotation ExcludeClassMethod; end
    annotation ExcludeConstant; end
    annotation Include; end
    annotation IncludeInstanceMethod; end
    annotation Specialize; end
    annotation SpecializeInstanceMethod; end
    annotation SpecializeClassMethod; end
    annotation Rename; end
    annotation RenameInstanceMethod; end
    annotation RenameClassMethod; end
    annotation RenameConstant; end
    annotation RenameClass; end
    annotation RenameModule; end
    annotation WrapWithoutKeywords; end
    annotation WrapWithoutKeywordsInstanceMethod; end
    annotation WrapWithoutKeywordsClassMethod; end
    annotation ReturnNil; end
    annotation ReturnNilInstanceMethod; end
    annotation ReturnNilClassMethod; end
    annotation SpecifyGenericTypes; end
    annotation AddBlockArg; end
    annotation AddBlockArgInstanceMethod; end
    annotation AddBlockArgClassMethod; end
    annotation StoreBlockArg; end
    annotation StoreBlockArgInstanceMethod; end
    annotation StoreBlockArgClassMethod; end
    annotation ForceKeywordArg; end
    annotation ForceKeywordArgInstanceMethod; end
    annotation ForceKeywordArgClassMethod; end
    annotation NoKeywordArgs; end
    annotation DefaultOptionalArgsToKeywordArgs; end
    annotation IgnoreAncestorMethods; end

    struct RbValue
      w : LibC::ULongLong
    end

    class RbRef
      @value : RbValue

      def initialize(value : RbCore::RbValue)
        @value = value
      end
    end
  end
{% end %}