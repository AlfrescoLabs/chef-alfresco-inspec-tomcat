puts node.content.appserver.run_single_instance
only_if do
  node.content.appserver.run_single_instance
end

control 'Tomcat installation single' do
  impact 0.7
  title 'Tomcat installation multi'
  desc 'Checks that templates have been correctly created'

  catalina_home = node.content.appserver.alfresco.home

  describe file("#{catalina_home}/bin/setenv.sh") do
    it { should be_file }
    it { should exist }
    its('owner') { should eq 'tomcat' }
    its('content') { should match '\-Djava.awt.headless=true' }
    its('content') { should match "\-Dalfresco.home=#{catalina_home}" }
    its('content') { should match '\-Djava.rmi.server.hostname=localhost' }
    its('content') { should match "\-Dsolr.solr.home=#{catalina_home}/alf_data/solrhome" }
    its('content') { should match "\-Dsolr.solr.content.dir=#{catalina_home}/alf_data/solrContentStore" }
    its('content') { should match "\-Dsolr.solr.model.dir=#{catalina_home}/alf_data/newAlfrescoModels" }
    its('content') { should match "\-Djava.util.logging.config.file=#{catalina_home}/conf/logging.properties" }
    # its('content') { should match '\-Dlog4j.configuration=alfresco/log4j.properties' }
    # its('content') { should match "\-Dlogfilename=\"#{catalina_home}/logs/alfresco.log' }
    its('content') { should match "\-XX:ErrorFile=#{catalina_home}/logs/jvm_crash%p.log" }
    its('content') { should match "\-XX:HeapDumpPath=#{catalina_home}/logs/" }
  end

  describe file(catalina_home) do
    it { should be_symlink }
    it { should exist }
    it { should be_linked_to "#{catalina_home}-7.0.59" }
    # it { should be_owned_by 'tomcat' }
  end

  describe file("#{catalina_home}/bin/catalina.sh") do
    it { should be_file }
    it { should exist }
    # it { should be_owned_by 'tomcat' }
  end

  folders = %w(bin conf lib logs temp webapps work )
  folders.each do |folder|
    describe directory("#{catalina_home}/#{folder}") do
      it { should exist }
      # it { should be_owned_by 'tomcat' }
    end
  end
end
