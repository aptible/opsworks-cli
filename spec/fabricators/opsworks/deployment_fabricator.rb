Fabricator(:deployment, from: OpsWorks::Deployment) do
  initialize_with { @_klass.new(opsworks_stub) }
  id { SecureRandom.uuid }
  status 'running'
  created_at { Time.now }
end
