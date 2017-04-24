control 'Tomcat Hardening Multi Instance' do
  impact 0.7
  title 'Tomcat Hardening Multi Instance'
  desc 'Following CIS_Apache_Tomcat_7_Benchmark_v1.1.0.pdf'
  only_if { !node.content['appserver']['run_single_instance'] }

  catalina_home = node.content['appserver']['alfresco']['home']

  components = node.content.appserver.alfresco.components
  if components.include?('repo')
    index = components.index('repo')
    components[index] = 'alfresco'
  end

  # 1.1 Remove extraneous files and directories

  components.each do |component|
    describe directory("#{catalina_home}/#{component}/webapps/js-examples") do
      it { should_not exist }
    end
    describe directory("#{catalina_home}/#{component}/webapps/servlet-example") do
      it { should_not exist }
    end
    describe directory("#{catalina_home}/#{component}/webapps/tomcat-docs") do
      it { should_not exist }
    end
    describe directory("#{catalina_home}/#{component}/webapps/balancer") do
      it { should_not exist }
    end
    describe directory("#{catalina_home}/#{component}/webapps/ROOT/admin") do
      it { should_not exist }
    end
    describe directory("#{catalina_home}/#{component}/webapps/examples") do
      it { should_not exist }
    end
    describe directory("#{catalina_home}/#{component}/server/webapps/host-manager") do
      it { should_not exist }
    end
    describe directory("#{catalina_home}/#{component}/server/webapps/manager") do
      it { should_not exist }
    end
    describe file("#{catalina_home}/#{component}/conf/Catalina/localhost/host-manager.xml") do
      it { should_not exist }
    end
    describe file("#{catalina_home}/#{component}/conf/Catalina/localhost/manager.xml") do
      it { should_not exist }
    end
  end

  # Limit Server Platform Information Leaks
  describe command('unzip -c /usr/share/tomcat/lib/catalina.jar org/apache/catalina/util/ServerInfo.properties') do
    its('stdout') { should match 'server.info=Apache Tomcat' }
    its('stdout') { should match 'server.number=0.0.0.0' }
    its('stdout') { should match 'server.built' }
  end

  components.each do |component|
    describe file("#{catalina_home}/#{component}/conf/server.xml") do
      its('content') { should_not match 'xpoweredBy="true"' }
      its('content') { should_not match 'server=" "' }
      its('content') { should_not match 'allowTrace="true"' }
      its('content') { should_not match 'allowTrace="true"' }
      its('content') { should match '<Server port="-1"' }
      its('content') { should match 'clientAuth="true' }
      its('content') { should match 'connectionTimeout="60000"' }
      its('content') { should match 'maxHttpHeaderSize="8192"' }
      its('content') { should match 'autoDeploy="false"' }
      its('content') { should_not match 'deployOnStartup' }
      its('content') { should_not match 'enableLookups' }
      its('content') { should match 'org.apache.catalina.core.JreMemoryLeakPreventionListener' }
    end
  end

  components.each do |component|
    describe file("#{catalina_home}/#{component}/conf/context.xml") do
      its('content') { should_not match 'allowLinking' }
      its('content') { should_not match 'privileged' }
      its('content') { should_not match 'crossContext' }
    end
  end

  components.each do |component|
    describe command("find #{catalina_home}/#{component} -follow -maxdepth 0 \( -perm /o+rwx,g=w -o ! -user tomcat -o ! -group tomcat \) -ls") do
      its('stdout') { should eq '' }
    end
    describe command("find #{catalina_home}/#{component}/conf -follow -maxdepth 0 \( -perm /o+rwx,g=w -o ! -user tomcat -o ! -group tomcat \) -ls") do
      its('stdout') { should eq '' }
    end
    describe command("find #{catalina_home}/#{component}/logs -follow -maxdepth 0 \( -perm /o+rwx,g=w -o ! -user tomcat -o ! -group tomcat \) -ls") do
      its('stdout') { should eq '' }
    end
    describe command("find #{catalina_home}/#{component}/temp -follow -maxdepth 0 \( -perm /o+rwx,g=w -o ! -user tomcat -o ! -group tomcat \) -ls") do
      its('stdout') { should eq '' }
    end
    describe command("find #{catalina_home}/#{component}/bin -follow -maxdepth 0 \( -perm /o+rwx,g=w -o ! -user tomcat -o ! -group tomcat \) -ls") do
      its('stdout') { should eq '' }
    end
    describe command("find #{catalina_home}/#{component}/webapps -follow -maxdepth 0 \( -perm /o+rwx,g=w -o ! -user tomcat -o ! -group tomcat \) -ls") do
      its('stdout') { should eq '' }
    end
    describe command("find #{catalina_home}/#{component}/conf/catalina.policy -follow -maxdepth 0 \( -perm /o+rwx,g=w -o ! -user tomcat -o ! -group tomcat \) -ls") do
      its('stdout') { should eq '' }
    end
    describe command("find #{catalina_home}/#{component}/conf/catalina.properties -follow -maxdepth 0 \( -perm /o+rwx,g=w -o ! -user tomcat -o ! -group tomcat \) -ls") do
      its('stdout') { should eq '' }
    end
    describe command("find #{catalina_home}/#{component}/conf/context.xm -follow -maxdepth 0 \( -perm /o+rwx,g=w -o ! -user tomcat -o ! -group tomcat \) -ls") do
      its('stdout') { should eq '' }
    end
    describe command("find #{catalina_home}/#{component}/conf/logging.properties -follow -maxdepth 0 \( -perm /o+rwx,g=w -o ! -user tomcat -o ! -group tomcat \) -ls") do
      its('stdout') { should eq '' }
    end
    describe command("find #{catalina_home}/#{component}/conf/server.xml -follow -maxdepth 0 \( -perm /o+rwx,g=w -o ! -user tomcat -o ! -group tomcat \) -ls") do
      its('stdout') { should eq '' }
    end
    describe command("find #{catalina_home}/#{component}/conf/tomcat-users.xml -follow -maxdepth 0 \( -perm /o+rwx,g=w -o ! -user tomcat -o ! -group tomcat \) -ls") do
      its('stdout') { should eq '' }
    end
    describe command("find #{catalina_home}/#{component}/conf/web.xml -follow -maxdepth 0 \( -perm /o+rwx,g=w -o ! -user tomcat -o ! -group tomcat \) -ls") do
      its('stdout') { should eq '' }
    end
    describe command("grep 'Realm className' #{catalina_home}/#{component}/conf/server.xml grep | MemoryRealm") do
      its('stdout') { should eq '' }
    end
    describe command("grep 'Realm className' #{catalina_home}/#{component}/conf/server.xml | grep JDBCRealm") do
      its('stdout') { should eq '' }
    end
    # describe command("grep 'Realm className' #{catalina_home}/#{component}/conf/server.xml grep UserDatabaseRealm") do
    #   its('stdout') { should eq '' }
    # end
    describe command("grep 'Realm className' #{catalina_home}/#{component}/conf/server.xml | grep JAASRealm") do
      its('stdout') { should eq '' }
    end
    describe command("grep 'LockOutRealm' #{catalina_home}/#{component}/conf/server.xml") do
      its('stdout') { should eq '' }
    end
  end

  components.each do |component|
    describe file("#{catalina_home}/#{component}/conf/logging.properties") do
      its('content') { should match '.handlers = 1catalina.org.apache.juli.FileHandler, java.util.logging.ConsoleHandler' }
      its('content') { should match '1catalina.org.apache.juli.FileHandler.level = FINE' }
      its('content') { should match '2localhost.org.apache.juli.FileHandler.level = FINE' }
      its('content') { should match 'java.util.logging.ConsoleHandler.level = FINE' }
      its('content') { should match '.level = INFO' }
    end
  end

  components.each do |component|
    describe directory("#{catalina_home}/#{component}/logs") do
      it { should exist }
      it { should be_directory }
      its('mode') { should cmp '0750' }
      it { should be_owned_by 'tomcat' }
    end
  end

  components.each do |component|
    describe file("#{catalina_home}/#{component}/bin/setenv.sh") do
      it { should exist }
      it { should be_file }
      its('content') { should match '-Dorg.apache.catalina.connector.RECYCLE_FACADES=true' }
      its('content') { should match '-Dorg.apache.coyote.USE_CUSTOM_STATUS_MSG_IN_HEADER=false' }
    end
  end
end
