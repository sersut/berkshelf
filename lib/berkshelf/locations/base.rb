module Berkshelf
  class BaseLocation
    attr_reader :dependency
    attr_reader :options

    def initialize(dependency, options = {})
      @dependency = dependency
      @options    = options
    end

    def download(cookbook = nil)
      validate_cached!(cookbook)
      cookbook
    end

    # Ensure the given {CachedCookbook} is valid
    #
    # @param [CachedCookbook] cached_cookbook
    #   the downloaded cookbook to validate
    #
    # @raise [CookbookValidationFailure]
    #   if given CachedCookbook does not satisfy the constraint of the location
    #
    # @todo Change MismatchedCookbookName to raise instead of warn
    #
    # @return [true]
    def validate_cached!(cookbook)
      unless @dependency.version_constraint.satisfies?(cookbook.version)
        raise CookbookValidationFailure.new(dependency, cookbook)
      end

      unless @dependency.name == cookbook.cookbook_name
        message = MismatchedCookbookName.new(dependency, cookbook).to_s
        Berkshelf.ui.warn(message)
      end

      true
    end

    # Validate that the given path contains a valid Chef cookbook.
    #
    # @raise [CookbookNotFound]
    #   if the path does not appear to contain a cookbook
    #
    # @param [String] path
    #   the path to check if is a cookbook
    #
    # @return [true]
    def validate_cookbook!(path)
      unless File.cookbook?(path)
        raise CookbookNotFound, "#{dependency.name} not found at #{to_s}"
      end

      true
    end

    # Logic to determine if the current location is "valid". Subclasses should
    # override this method with magical logic.
    #
    # @return [Boolean]
    def valid?
      true
    end

    # Identifier to determine if this location is an SCM location (i.e. does
    # it consume external resources)
    #
    # @return [Boolean]
    def scm_location?
      false
    end

    # The lockfile representation of this location.
    #
    # @return [string]
    def to_lock
      raise AbstractFunction,
        "#to_lock must be implemented on #{self.class.name}!"
    end
  end
end
