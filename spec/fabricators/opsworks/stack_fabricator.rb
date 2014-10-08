Fabricator(:stack, from: OpsWorks::Stack) do
  id { SecureRandom.uuid }
  name { Fabricate.sequence(:name) { |i| "test-stack#{i}" } }
end
