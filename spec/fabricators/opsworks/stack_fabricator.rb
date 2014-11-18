Fabricator(:stack, from: OpsWorks::Stack) do
  id { SecureRandom.uuid }
  name { Fabricate.sequence(:name) { |i| "test-stack#{i}" } }
  custom_json { { 'env' => { 'FOO' => 'bar' } } }
end
