require 'spec_helper'

describe 'varnish' do
  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "varnish class with minimal parameters on #{osfamily}" do
        let(:params) {{ 
          :secret => 'foobar'
        }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        it { should contain_class('varnish::params') }

        it { should contain_class('varnish::repo::el6').that_comes_before('varnish::install') }
        it { should contain_class('varnish::secret') }
        it { should contain_class('varnish::install').that_comes_before('varnish::config') }
        it { should contain_class('varnish::config') }
        it { should contain_class('varnish::service').that_subscribes_to('varnish::config') }

        it { should contain_package('varnish') }
        it { should contain_file('/etc/varnish/secret') \
          .with_content("foobar\n") }
        it { should contain_file('/etc/sysconfig/varnish') }
        it { should contain_service('varnish') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'varnish class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { should }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end

  context 'lots of params' do
    describe 'varnish class with many params on RedHat' do
      let(:facts) {{
        :osfamily => 'RedHat'
      }}
      let(:params) {{
        :storage_size         => '50%',
        :listen_port          => 80,
        :runtime_params       => {
          'first_byte_timeout' => 10,
          'gzip_level'         => 9
        }
      }}

      it { should compile.with_all_deps }
      it { should contain_file('/etc/sysconfig/varnish') \
          .with_content(/-p first_byte_timeout=10/) }

    end
  end

  context 'varnish 4' do
    describe 'varnish 4 installation on RedHat' do
      let(:facts) {{
        :osfamily => 'RedHat'
      }}
      let(:params) {{
        :storage_size         => '50%',
        :listen_port          => 80,
        :varnish_version      => '4.0',
      }}

      it { should compile.with_all_deps }
      it { should contain_yumrepo('varnish-cache') \
        .with_baseurl(/4\.0/) }

    end
  end


end
