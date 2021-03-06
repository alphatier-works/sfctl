require 'sfctl/commands/account/info'

RSpec.describe Sfctl::Commands::Account::Info, type: :unit do
  let(:config_file) { '.sfctl' }
  let(:output_io) { StringIO.new }
  let(:options) do
    {
      'no-color' => true,
      'starfish-host' => 'https://app.starfish.team'
    }
  end
  let(:account_profile_url) { "#{options['starfish-host']}/api/v1/profile" }

  before do
    stub_const('Sfctl::Command::CONFIG_PATH', tmp_path(config_file))
  end

  it 'should do nothing if config file not exists' do
    expect(::File.file?(tmp_path(config_file))).to be_falsey

    command = described_class.new(options)
    command.execute(output: output_io)

    expect(output_io.string).to include('Please authentificate before continue.')
  end

  it 'should do nothing if profile could not be fetched' do
    config_path = fixtures_path(config_file)
    ::FileUtils.cp(config_path, tmp_path(config_file))
    expect(::File.file?(tmp_path(config_file))).to be_truthy

    stub_request(:get, account_profile_url).to_return(body: '{"error":"forbidden"}', status: 403)

    command = described_class.new(options)
    command.execute(output: output_io)

    expect(output_io.string).to include('Something went wrong. Unable to fetch account info')
  end

  it 'should print a profile' do
    config_path = fixtures_path(config_file)
    ::FileUtils.cp(config_path, tmp_path(config_file))
    expect(::File.file?(tmp_path(config_file))).to be_truthy

    email = 'test-user@mail.com'
    name = 'Test User'
    response_body = "{\"email\":\"#{email}\",\"name\":\"#{name}\"}"
    stub_request(:get, account_profile_url).to_return(body: response_body, status: 200)
    expected_table = <<~HEREDOC
      ┌────────────────────┬───────────┐
      │ email              │ name      │
      ├────────────────────┼───────────┤
      │ #{email} │ #{name} │
      └────────────────────┴───────────┘
    HEREDOC
    expect_any_instance_of(TTY::Table).to receive(:render).and_return(expected_table)

    described_class.new(options).execute(output: output_io)

    expect(output_io.string).to eq "#{expected_table}\n"
  end
end
