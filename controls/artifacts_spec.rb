control 'artifact-existance' do
  impact 0.7
  title 'Artifact Existance'
  desc 'Checks that artifacts have been correctly downloaded and moved'

  catalina_home = node.content['appserver']['alfresco']['home']

  describe file("#{catalina_home}/lib/catalina-jmx.jar") do
    it { should exist }
    it { should be_owned_by 'tomcat' }
  end
end
