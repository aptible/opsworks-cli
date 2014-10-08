Fabricator(:app, from: OpsWorks::App) do
  id { SecureRandom.uuid }
  name { Fabricate.sequence(:name) { |i| "app#{i}" } }
  revision 'master'
end
