control 'Templates Existance Multi Instance' do
  impact 0.7
  title 'Templates Existance Multi Instance'
  desc 'Checks that templates have been correctly created'
  only_if { !node.content['appserver']['run_single_instance'] }

  catalina_home = node.content['appserver']['alfresco']['home']
  ssl_enabled = node.content['tomcat']['ssl_enabled']

  alf_components = node.content['appserver']['alfresco']['components']
  components = []
  %w(share solr repo).each do | app |
    if alf_components.include?(app)
      if app == 'repo'
        components << 'alfresco'
      else
        components << app
      end
    end
  end

  components.each do |component|
    describe file("/etc/cron.d/#{component}-cleaner.cron") do
      it { should be_file }
      it { should exist }
      its('owner') { should eq 'root' }
      its('content') { should match "#{catalina_home}/#{component}/logs" }
    end
  end

  describe file("#{catalina_home}/conf/context.xml") do
    it { should be_file }
    it { should exist }
    its('owner') { should eq 'tomcat' }
  end

  components.each do |component|
    describe file("#{catalina_home}/#{component}/conf/context.xml") do
      it { should be_file }
      it { should exist }
      its('owner') { should eq 'tomcat' }
    end
  end

  describe file("#{catalina_home}/conf/jmxremote.access") do
    it { should be_file }
    it { should exist }
    its('owner') { should eq 'tomcat' }
    its('content') { should match 'systemsMonitorRole  readonly' }
    its('content') { should match 'systemsControlRole  readwrite create javax.management.monitor.*,javax.management.timer.* unregister' }
  end

  describe file("#{catalina_home}/conf/jmxremote.password") do
    it { should be_file }
    it { should exist }
    its('owner') { should eq 'tomcat' }
    its('content') { should match 'systemsMonitorRole   changeme' }
    its('content') { should match 'systemsControlRole   changeme' }
  end

  describe file("#{catalina_home}/conf/logging.properties") do
    it { should be_file }
    it { should exist }
    its('owner') { should eq 'tomcat' }
    its('content') { should match '.level = INFO' }
  end

  components.each do |component|
    describe file("#{catalina_home}/#{component}/conf/server.xml") do
      it { should be_file }
      it { should exist }
      its('owner') { should eq 'tomcat' }
      if ssl_enabled
        its('content') { should match 'secure=\"true\"' }
      end
      if component == 'alfresco'
        its('content') { should match 'Connector port=\"8070\"' }
        its('content') { should_not match 'Connector port=\"8081\"' }
        its('content') { should_not match 'Connector port=\"8090\"' }
      end
      if component == 'share'
        its('content') { should match 'Connector port=\"8081\"' }
        its('content') { should_not match 'Connector port=\"8070\"' }
        its('content') { should_not match 'Connector port=\"8090\"' }
      end
      if component == 'solr'
        its('content') { should match 'Connector port=\"8090\"' }
        its('content') { should_not match 'Connector port=\"8081\"' }
        its('content') { should_not match 'Connector port=\"8070\"' }
      end
    end
  end

  if !node.content['tomcat']['memcached_nodes'].empty? && node.content['appserver']['alfresco']['components'].include?('share')
    describe file("#{catalina_home}/share/conf/Catalina/localhost/share.xml") do
      it { should be_file }
      it { should exist }
      its('owner') { should eq 'tomcat' }
    end
  end

  describe file('/etc/security/limits.d/tomcat_limits.conf') do
    it { should be_file }
    it { should exist }
    its('owner') { should eq 'tomcat' }
  end
end
