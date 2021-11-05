# frozen_string_literal: true

require_relative 'diseases'
require_relative 'news'

module Floofloo
  module Repository
    # Finds the right repository for an entity object or class
    module For
      ENTITY_REPOSITORY = {
        Entity::News => Floofloo::Repository::News,
        Entity::Disease => Floofloo::Repository::Diseases
      }.freeze

      def self.klass(entity_klass)
        ENTITY_REPOSITORY[entity_klass]
      end

      def self.entity(entity_object)
        ENTITY_REPOSITORY[entity_object.class]
      end
    end
  end
end