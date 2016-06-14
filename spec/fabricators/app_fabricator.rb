class StubApp < OpenStruct
  def vhosts
    services.map(&:vhosts).flatten
  end
end

Fabricator(:app, from: :stub_app) do
  handle 'hello'
  status 'provisioned'
  account
  services { [] }

  after_create { |app| app.account.apps << app }
end
