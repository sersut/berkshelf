module Berkshelf
  class CachedCookbook < Ridley::Chef::Cookbook
    class << self
      # @param [#to_s] path
      #   a path on disk to the location of a Cookbook downloaded by the Downloader
      #
      # @return [CachedCookbook]
      #   an instance of CachedCookbook initialized by the contents found at the
      #   given path.
      def from_store_path(path)
        path        = Pathname.new(path)
        cached_name = File.basename(path.to_s).slice(DIRNAME_REGEXP, 1)
        return nil if cached_name.nil?

        loaded_cookbooks[path.to_s] ||= from_path(path, name: cached_name)
      end

      private

        # @return [Hash<String, CachedCookbook>]
        def loaded_cookbooks
          @loaded_cookbooks ||= {}
        end
    end

    DIRNAME_REGEXP = /^(.+)-(.+)$/

    extend Forwardable
    def_delegator :metadata, :description
    def_delegator :metadata, :maintainer
    def_delegator :metadata, :maintainer_email
    def_delegator :metadata, :license
    def_delegator :metadata, :platforms

    # @return [Hash]
    def dependencies
      metadata.recommendations.merge(metadata.dependencies)
    end
  end
end
