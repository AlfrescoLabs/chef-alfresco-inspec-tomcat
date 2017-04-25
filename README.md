# chef-alfresco-inspec-tomcat Inspec Profile

Inspec profile for [chef-alfresco-appserver](https://github.com/Alfresco/chef-alfresco-appserver) cookbook

To use it in your Kitchen suite add:

```
verifier:
  inspec_tests:
    - name: chef-alfresco-inspec-tomcat
      git: https://github.com/Alfresco/chef-alfresco-inspec-tomcat
```

This Profile depends on [chef-alfresco-inspec-utils](https://github.com/Alfresco/chef-alfresco-inspec-utils) to import libraries and matchers
