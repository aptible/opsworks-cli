require 'opsworks/resource'
require 'opsworks/deployment'

module OpsWorks
  class App < Resource
    attr_accessor :id, :name, :revision

    def self.from_collection_response(response)
      response.data[:apps].map do |hash|
        revision = hash[:app_source][:revision] if hash[:app_source]
        new(id: hash[:app_id], name: hash[:name], revision: revision)
      end
    end

    def deployments
      @deployments ||= initialize_deployments
    end

    def last_deployment
      deployments.find(&:success?)
    end

    def update_revision(revision)
      self.class.client.update_app(
        app_id: id,
        app_source: { revision: revision }
      )

      self.revision = revision
    end

    private

    def initialize_deployments
      return [] unless id
      response = self.class.client.describe_deployments(app_id: id)
      Deployment.from_collection_response(response)
    end
  end
end
