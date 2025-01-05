control 'Packages' do
  impact 1.0
  title 'Ensure .NET Core SDK versions, nginx, datadog are installed'
  
  packages = input('packages', value:[], description: 'List of packages to check')

  packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end
end

control 'nginx-port' do
    impact 1.0
    title 'Check nginx container'
    desc 'Check that nginx is listening on port 80'
    describe port(80) do
        it { should be_listening }
        its('processes') { should include 'nginx' }
      end
end

control 'limits.config file' do
  impact 1.0
  title 'Ensure Linux limits configuration'
  desc 'Check  limit.config file exists and resources are limited to users and groups'

  describe file('/etc/security/limits.conf') do
    it { should exist }
    it { should be_file }
    its('content') { should include('root soft nofile 65536') }
    its('content') { should include('root hard nofile 65536') }
  end
end

control 'Server Time Synchronization' do
  impact 1.0
  title 'Ensure NTP servers are running to keep EC2 instances in time sync'
  desc 'Check settings whether chrony and Amazon NTP server is running'

  describe command('sudo systemctl status chronyd') do
    its('stdout') { should match /active \(running\)/ }
  end

  describe file('/etc/chrony.d/ntp-pool.sources') do
    it { should exist }
    it { should be_file }
    its('content') { should include('pool 0.amazon.pool.ntp.org iburst maxsources 1') }
    its('content') { should include('pool 1.amazon.pool.ntp.org iburst maxsources 1') }
    its('content') { should include('pool 2.amazon.pool.ntp.org iburst maxsources 2') }
  end
end

control 'Iptatables-service' do
  impact 1.0
  title 'Ensure Iptables service'

  describe service('iptables') do
    it { should be_enabled }
    it { should be_running }
  end
end

control 'Iptables-rules-80' do
  impact 1.0
  title 'Ensure new iptables rules are applied'
  describe iptables do
    it { should have_rule('-A INPUT -p tcp -m tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT') }
    it { should have_rule('-A OUTPUT -p tcp -m tcp --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT') }
  end
end

control 'Iptables-rules-3000' do
  impact 1.0
  title 'Ensure new iptables rules are applied'
  describe iptables do
    it { should have_rule('-A INPUT -p tcp -m tcp --dport 3000 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT') }
    it { should have_rule('-A OUTPUT -p tcp -m tcp --sport 3000 -m conntrack --ctstate ESTABLISHED -j ACCEPT') }
  end
end

control 'Systemd services' do
  impact 1.0
  title 'Ensure that all systemd services are running'

  services = input('services', value:[], description: 'List of system services to check')
  services.each do |service|
    describe systemd_service(service) do
      it { should be_installed }
      it { should be_enabled }
      it { should be_running }
    end
  end
end
