Fabricator(:app, from: OpsWorks::App) do
  initialize_with { @_klass.new(opsworks_stub) }
  id { SecureRandom.uuid }
  name { Fabricate.sequence(:name) { |i| "app#{i}" } }
  revision 'master'
end
