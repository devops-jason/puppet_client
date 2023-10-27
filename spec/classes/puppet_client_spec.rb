# frozen_string_literal: true

require 'spec_helper'

describe 'puppet_client' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:params) { { 'puppet_server' => 'puppet.local' } }

      it do
        is_expected.to contain_exec('add puppet-release').with({
          'command' => '/usr/bin/dnf install https://yum.puppetlabs.com/puppet-release-el-8.noarch.rpm',
          'unless'  => '/usr/bin/dnf list | grep puppet-release 2> /dev/null'
        })

        is_expected.to contain_package('puppet').with({
          'ensure'  => 'present',
          'require' => 'Exec[add puppet-release]'
        })

        is_expected.to contain_file('/etc/puppetlabs/').with({
          'ensure'  => 'directory',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0755',
          'require' => 'Package[puppet]'
        })

        is_expected.to contain_file('/etc/puppetlabs/puppet/').with({
          'ensure'  => 'directory',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0755',
          'require' => 'File[/etc/puppetlabs/]'
        })

        is_expected.to contain_file('/etc/puppetlabs/puppet/puppet.conf').with({
          'ensure'  => 'present',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'require' => 'File[/etc/puppetlabs/puppet/]',
        }).with_content(/(.*)puppet\.local(.*)/).that_notifies('Service[puppet]')

        is_expected.to contain_service('puppet').with({
          'ensure' => 'running',
          'enable' => true
        })

        end
        
      it { is_expected.to compile.with_all_deps }
      
    end
  end
end
