# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions
  # @api private
  # @since 0.1.0
  module MetadataExtendable
    class << self
      # @param base_class [Class]
      #
      # @since 0.1.0
      def included(base_class)
        base_class.extend(ClassMethods)
      end
    end

    private

    # @return [Class{AbstractMetadata}]
    #
    # @since 0.1.0
    def build_metadata(**metadata_attributes)
      self.class.metadata_class.new(**metadata_attributes)
    end

    # @since 0.1.0
    module ClassMethods
      # @param child_class [Class]
      #
      # @since 0.1.0
      def inherited(child_class)
        child_class.const_set(:Metadata, Class.new(AbstractMetadata))
        super
      end

      # @return [Class{AbstractMetadata}]
      #
      # @since 0.2.0
      def metadata_class
        const_get(:Metadata)
      end

      # @param key [Symbol]
      # @param type [EvilEvents::Shared::Types::Any]
      # @param options [Hash]
      # @return void
      #
      # @since 0.1.0
      def metadata(key, type = EvilEvents::Types::Any, **options)
        if type.is_a?(Symbol)
          type = EvilEvents::Core::Bootstrap[:event_system].resolve_type(type, **options)
        end

        metadata_class.attribute(key, type)
      end

      # @return [Array<Symbol>]
      #
      # @since 0.1.0
      def metadata_fields
        metadata_class.attribute_names
      end
    end
  end
end
