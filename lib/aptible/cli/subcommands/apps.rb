module Aptible
  module CLI
    module Subcommands
      module Apps
        def self.included(thor)
          thor.class_eval do
            include Helpers::App
            include Helpers::Environment
            include Helpers::Token

            desc 'apps', 'List all applications'
            option :environment
            def apps
              scoped_environments(options).each do |env|
                say "=== #{env.handle}"
                env.apps.each do |app|
                  say app.handle
                end
                say ''
              end
            end

            desc 'apps:create HANDLE', 'Create a new application'
            option :environment
            define_method 'apps:create' do |handle|
              environment = ensure_environment(options)
              app = environment.create_app(handle: handle)

              if app.errors.any?
                fail Thor::Error, app.errors.full_messages.first
              else
                say "App #{handle} created!"
              end
            end

            desc 'apps:scale TYPE NUMBER', 'Scale app to NUMBER of instances'
            app_options
            define_method 'apps:scale' do |type, n|
              num = Integer(n)
              app = ensure_app(options)
              service = app.services.find { |s| s.process_type == type }
              op = service.create_operation(type: 'scale', container_count: num)
              attach_to_operation_logs(op)
            end

            desc 'apps:deprovision', 'Deprovision an app'
            app_options
            define_method 'apps:deprovision' do
              app = ensure_app(options)
              say "Deprovisioning #{app.handle}..."
              app.create_operation!(type: 'deprovision')
            end
          end
        end
      end
    end
  end
end
