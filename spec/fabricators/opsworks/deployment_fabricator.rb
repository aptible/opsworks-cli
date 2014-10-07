Fabricator(:deployment, from: OpsWorks::Deployment) do
  id { SecureRandom.uuid }
  status 'running'
  created_at { Time.now }
end
