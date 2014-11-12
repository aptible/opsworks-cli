Fabricator(:permission, from: OpsWorks::Permission) do
  id { SecureRandom.uuid }
  stack_id { SecureRandom.uuid }
  iam_user_arn { Fabricate.sequence(:iam) { |i| "iam::#{i}:user/bob" } }
  ssh true
  sudo true
end
