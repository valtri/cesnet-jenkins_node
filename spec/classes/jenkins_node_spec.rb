require 'spec_helper'

describe 'jenkins_node' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "jenkins_node class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('jenkins_node') }
          it { is_expected.to contain_class('jenkins_node::params') }

          it { is_expected.to contain_package('git') }
          it { is_expected.to contain_package('unzip') }

          it { is_expected.to contain_user('jenkins') }
        end

        if os =~ /^(debian|ubuntu).*/ then
          context "pbuilder installed" do
            it { is_expected.to contain_package('pbuilder') }
            it { is_expected.to contain_package('dpkg-dev') }
            it { is_expected.to contain_package('dput') }
            it { is_expected.to contain_package('mini-dinstall') }
          end
        else
          context "mock installed" do
            it { is_expected.to contain_package('mock') }
            it { is_expected.to contain_package('rpm-build') }
          end
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'jenkins_node class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_class('jenkins_node') }.to raise_error(Puppet::Error, /Solaris \(Nexenta\) not supported/) }
    end
  end
end
