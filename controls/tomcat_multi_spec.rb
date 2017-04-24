only_if do
  node.content.appserver.run_single_instance == false
end

control 'Tomcat installation multi' do
  impact 0.7
  title 'Tomcat installation multi'
  desc 'Checks that templates have been correctly created'

  catalina_home = node.content.appserver.alfresco.home

  components = node.content.appserver.alfresco.components
  if components.include?('repo')
    index = components.index('repo')
    components[index] = 'alfresco'
  end

  components.each do |component|
    describe file("#{catalina_home}/#{component}/bin/setenv.sh") do
      it { should be_file }
      it { should exist }
      its('owner') { should eq 'tomcat' }
      its('content') { should match '\-XX:\+UseCompressedOops' }
      its('content') { should match '\-XX:\+DisableExplicitGC' }
      its('content') { should match '\-XX:\+PrintGCDetails' }
      its('content') { should match '\-verbose:gc' }
      its('content') { should match '\-Djava.net.preferIPv4Stack=true' }
      its('content') { should match '\-Djava.net.preferIPv4Addresses=true' }
      its('content') { should match '\-Dsun.net.inetaddr.ttl=0' }
      its('content') { should match '\-Dsun.net.inetaddr.negative.ttl=0' }
      its('content') { should match '\-Dsun.security.ssl.allowUnsafeRenegotiation=true' }
      its('content') { should match '\-Dhazelcast.logging.type=log4j' }
      its('content') { should match '\-Djava.library.path=/usr/lib64' }
      its('content') { should match '\-Djava.awt.headless=true' }
      its('content') { should match '\-Dcom.sun.management.jmxremote=true' }
      its('content') { should match '\-Dcom.sun.management.jmxremote.authenticate=true' }
      its('content') { should match '\-Dcom.sun.management.jmxremote' }
      its('content') { should match '\-Dcom.sun.management.jmxremote.ssl=false' }
      its('content') { should match "\-Dcom.sun.management.jmxremote.access.file=#{catalina_home}/conf/jmxremote.access" }
      its('content') { should match "\-Dcom.sun.management.jmxremote.password.file=#{catalina_home}/conf/jmxremote.password" }
      if component == 'alfresco'
        its('content') { should match "\-Dalfresco.home=#{catalina_home}/alfresco" }
        its('content') { should match '\-Djava.rmi.server.hostname=localhost' }
        its('content') { should match '\-XX:\+PrintGCTimeStamps' }
      end
      if component == 'solr'
        its('content') { should match "\-Dsolr.solr.home=#{catalina_home}/alf_data/solrhome" }
        its('content') { should match "\-Dsolr.solr.content.dir=#{catalina_home}/alf_data/solrContentStore" }
        its('content') { should match "\-Dsolr.solr.model.dir=#{catalina_home}/alf_data/newAlfrescoModels" }
      end
      its('content') { should match "\-Djava.util.logging.config.file=#{catalina_home}/#{component}/conf/logging.properties" }
      its('content') { should match '\-Dlog4j.configuration=alfresco/log4j.properties' }
      if component == 'alfresco' || component == 'share'
        its('content') { should match "\-Dlogfilename=#{catalina_home}/#{component}/logs/#{component}.log" }
      end
      its('content') { should match "\-XX:ErrorFile=#{catalina_home}/#{component}/logs/jvm_crash%p.log" }
      its('content') { should match "\-XX:HeapDumpPath=#{catalina_home}/#{component}/logs/" }
    end
  end

  folders = ["#{catalina_home}/share/", "#{catalina_home}/solr/", "#{catalina_home}/alfresco/", "#{catalina_home}/conf/", "#{catalina_home}/lib/", "#{catalina_home}/bin/"]
  folders.each do |folder|
    describe directory(folder) do
      it { should exist }
      it { should be_owned_by 'tomcat' }
    end
  end

  describe file(catalina_home) do
    it { should be_symlink }
    it { should exist }
    it { should be_linked_to "#{catalina_home}-7.0.59" }
    it { should be_owned_by 'tomcat' }
  end

  describe file("#{catalina_home}/bin/catalina.sh") do
    it { should be_file }
    it { should exist }
    it { should be_owned_by 'tomcat' }
  end

  folders = %w(bin conf lib logs temp webapps work )
  components.each do |component|
    folders.each do |folder|
      describe directory("#{catalina_home}/#{component}/#{folder}") do
        it { should exist }
        it { should be_owned_by 'tomcat' }
      end
    end
  end
end
