require 'presenters/v3/mixins/redactor'

module VCAP::CloudController
  class AppPresenter
    include Redactor

    attr_reader :app

    def initialize(app, show_secrets: true)
      @app = app
      @show_secrets = show_secrets
    end

    def to_hash
      {
        guid:                    app.guid,
        name:                    app.name,
        desired_state:           app.desired_state,
        total_desired_instances: app.processes.map(&:instances).reduce(:+) || 0,
        created_at:              app.created_at,
        updated_at:              app.updated_at,
        lifecycle: {
          type: app.lifecycle_type,
          data: app.lifecycle_data.to_hash
        },
        environment_variables:   redact(app.environment_variables || {}, @show_secrets),
        links:                   build_links
      }
    end

    private

    def build_links
      links = {
        self:                   { href: "/v3/apps/#{app.guid}" },
        space:                  { href: "/v2/spaces/#{app.space_guid}" },
        processes:              { href: "/v3/apps/#{app.guid}/processes" },
        route_mappings:         { href: "/v3/apps/#{app.guid}/route_mappings" },
        packages:               { href: "/v3/apps/#{app.guid}/packages" },
        droplet:                { href: "/v3/apps/#{app.guid}/droplets/current" },
        droplets:               { href: "/v3/apps/#{app.guid}/droplets" },
        tasks:                  { href: "/v3/apps/#{app.guid}/tasks" },
        start:                  { href: "/v3/apps/#{app.guid}/start", method: 'PUT' },
        stop:                   { href: "/v3/apps/#{app.guid}/stop", method: 'PUT' },
      }

      links.delete_if { |_, v| v.nil? }
    end
  end
end
