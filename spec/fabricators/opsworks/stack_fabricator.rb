Fabricator(:stack, from: OpsWorks::Stack) do
  initialize_with { @_klass.new(opsworks_stub) }
  id { SecureRandom.uuid }
  name { Fabricate.sequence(:name) { |i| "test-stack#{i}" } }
  custom_json { { 'env' => { 'FOO' => 'bar' } } }
end
