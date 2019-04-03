Fabricator(:instance, from: OpsWorks::Instance) do
  initialize_with { @_klass.new(opsworks_stub) }
  id { SecureRandom.uuid }
  hostname { Fabricate.sequence { |i| "test-instance#{i}" } }
  status { 'online' }
  service_errors { [] }
end
