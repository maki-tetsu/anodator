require 'spec_helper'

require 'anodator/data_source'

RSpec.describe Anodator::DataSource, '.new' do
  context 'no parameters' do
    it 'raise argument error' do
      expect {
        Anodator::DataSource.new
      }.to raise_error ArgumentError
    end
  end

  context 'with 1 parameter' do
    it 'raise argument error' do
      expect {
        Anodator::DataSource.new('identifier')
      }.to raise_error ArgumentError
    end
  end

  context 'with 2 parameters without options' do
    context 'valid parameters' do
      it 'no exception' do
        expect {
          Anodator::DataSource.new('identifier', {})
        }.not_to raise_error
      end
    end

    context 'an invalid datas parameter' do
      it 'raise argument error' do
        expect {
          Anodator::DataSource.new('identifier', nil)
        }.to raise_error ArgumentError, 'datas must be respond to :[]'
      end
    end
  end

  context 'with 2 parameters with options' do
    context 'with :on_nil option' do
      context 'with :raise_error' do
        it 'no expection' do
          expect {
            Anodator::DataSource.new('identifier', {}, on_nil: :raise_error)
          }.not_to raise_error
        end
      end

      context 'with :nil' do
        it 'no exception' do
          expect {
            Anodator::DataSource.new('identifier', {}, on_nil: :nil)
          }.not_to raise_error
        end
      end

      context 'with :hoge (invalid)' do
        it 'raise ArgumentError' do
          expect {
            Anodator::DataSource.new('identifier', {}, on_nil: :hoge)
          }.to raise_error ArgumentError, %q[Invalid :on_nil option value ':hoge']
        end
      end
    end

    context 'with :on_exception option' do
      context 'with :raise_error' do
        it 'no expection' do
          expect {
            Anodator::DataSource.new('identifier', {}, on_exception: :raise_error)
          }.not_to raise_error
        end
      end

      context 'with :nil' do
        it 'no exception' do
          expect {
            Anodator::DataSource.new('identifier', {}, on_exception: :nil)
          }.not_to raise_error
        end
      end

      context 'with :hoge (invalid)' do
        it 'raise ArgumentError' do
          expect {
            Anodator::DataSource.new('identifier', {}, on_exception: :hoge)
          }.to raise_error ArgumentError, %q[Invalid :on_exception option value ':hoge']
        end
      end
    end

    context 'with :invalid_option option(invalid)' do
      it 'raise ArgumentError' do
        expect {
          Anodator::DataSource.new('identifier', {}, invalid_option: :hoge)
        }.to raise_error ArgumentError, %q[Invalid option ':invalid_option']
      end
    end
  end
end

RSpec.describe Anodator::DataSource, '#[]' do
  context 'with array object' do
    let(:datas) { [1, 2, 3] }

    context 'without options' do
      subject { Anodator::DataSource.new('identifier', datas) }

      context 'with valid key[0]' do
        it { expect(subject[0]).to equal datas[0] }
      end

      context 'with invalid key[99]' do
        it { expect(subject[99]).to be_nil }
      end
    end

    context 'with on_nil: :raise_error' do
      subject { Anodator::DataSource.new('identifier', datas, on_nil: :raise_error)}

      context 'with valid key[0]' do
        it { expect(subject[0]).to equal datas[0] }
      end

      context 'with invalid key [99]' do
        it {
          expect {
            subject[99]
          }.to raise_error Anodator::UnknownKeyOnDataSourceError, 'DataSource nil'
        }
      end
    end

    context 'with on_nil: :nil' do
      subject { Anodator::DataSource.new('identifier', datas, on_nil: :nil)}

      context 'with valid key[0]' do
        it { expect(subject[0]).to equal datas[0] }
      end

      context 'with invalid key[99]' do
        it { expect(subject[99]).to be_nil }
      end
    end

    context 'with on_exception: :raise_error' do
      subject { Anodator::DataSource.new('identifier', datas, on_exception: :raise_error)}

      context 'with valid key[0]' do
        it { expect(subject[0]).to equal datas[0] }
      end

      context 'with invalid key[99]' do
        it { expect(subject[99]).to be_nil }
      end
    end

    context 'with on_exception: :nil' do
      subject { Anodator::DataSource.new('identifier', datas, on_exception: :nil)}

      context 'with valid key[0]' do
        it { expect(subject[0]).to equal datas[0] }
      end

      context 'with invalid key[99]' do
        it { expect(subject[99]).to be_nil }
      end
    end
  end

  context 'with hash object' do
    let(:datas) do
      {
        key1: {
          name: 'taro',
          sex: 'M',
          age: 20
        },
        key2: {
          name: 'jiro',
          sex: 'M',
          age: 35
        },
        key3: {
          name: 'hanako',
          sex: 'F',
          age: 25
        }
      }
    end

    context 'without options' do
      subject { Anodator::DataSource.new('identifier', datas) }

      context 'with valid key[:key1]' do
        it { expect(subject[:key1]).to equal datas[:key1] }
      end

      context 'with invalid key[:invalid_key]' do
        it { expect(subject[:invalid_key]).to be_nil }
      end
    end

    context 'with on_nil: :raise_error' do
      subject { Anodator::DataSource.new('identifier', datas, on_nil: :raise_error)}

      context 'with valid key[:key1]' do
        it { expect(subject[:key1]).to equal datas[:key1] }
      end

      context 'with invalid key [:invalid_key]' do
        it {
          expect {
            subject[:invalid_key]
          }.to raise_error Anodator::UnknownKeyOnDataSourceError, 'DataSource nil'
        }
      end
    end

    context 'with on_nil: :nil' do
      subject { Anodator::DataSource.new('identifier', datas, on_nil: :nil)}

      context 'with valid key[:key3]' do
        it { expect(subject[:key3]).to equal datas[:key3] }
      end

      context 'with invalid key[:invalid_key]' do
        it { expect(subject[:invalid_key]).to be_nil }
      end
    end

    context 'with on_exception: :raise_error' do
      subject { Anodator::DataSource.new('identifier', datas, on_exception: :raise_error)}

      context 'with valid key[:key1]' do
        it { expect(subject[:key1]).to equal datas[:key1] }
      end

      context 'with invalid key[:invalid_key]' do
        it { expect(subject[:invalid_key]).to be_nil }
      end
    end

    context 'with on_exception: :nil' do
      subject { Anodator::DataSource.new('identifier', datas, on_exception: :nil)}

      context 'with valid key[:key2]' do
        it { expect(subject[:key2]).to equal datas[:key2] }
      end

      context 'with invalid key[:invalid_key]' do
        it { expect(subject[:invalid_key]).to be_nil }
      end
    end
  end

  context 'with some object when unknown key raise KeyError' do
    let(:datas) do
      obj = {
        key1: {
          name: 'taro',
          sex: 'M',
          age: 20
        },
        key2: {
          name: 'jiro',
          sex: 'M',
          age: 35
        },
        key3: {
          name: 'hanako',
          sex: 'F',
          age: 25
        }
      }

      def obj.[](key)
        if self.key?(key)
          self.fetch(key)
        else
          raise KeyError, key
        end
      end

      obj
    end

    context 'without options' do
      subject { Anodator::DataSource.new('identifier', datas) }

      context 'with valid key[:key1]' do
        it { expect(subject[:key1]).to equal datas[:key1] }
      end

      context 'with invalid key[:invalid_key]' do
        it {
          expect {
            subject[:invalid_key]
          }.to raise_error Anodator::UnknownKeyOnDataSourceError
        }
      end
    end

    context 'with on_nil: :raise_error' do
      subject { Anodator::DataSource.new('identifier', datas, on_nil: :raise_error)}

      context 'with valid key[:key1]' do
        it { expect(subject[:key1]).to equal datas[:key1] }
      end

      context 'with invalid key [:invalid_key]' do
        it {
          expect {
            subject[:invalid_key]
          }.to raise_error Anodator::UnknownKeyOnDataSourceError
        }
      end
    end

    context 'with on_nil: :nil' do
      subject { Anodator::DataSource.new('identifier', datas, on_nil: :nil)}

      context 'with valid key[:key3]' do
        it { expect(subject[:key3]).to equal datas[:key3] }
      end

      context 'with invalid key[:invalid_key]' do
        it {
          expect {
            subject[:invalid_key]
          }.to raise_error Anodator::UnknownKeyOnDataSourceError
        }
      end
    end

    context 'with on_exception: :raise_error' do
      subject { Anodator::DataSource.new('identifier', datas, on_exception: :raise_error)}

      context 'with valid key[:key1]' do
        it { expect(subject[:key1]).to equal datas[:key1] }
      end

      context 'with invalid key[:invalid_key]' do
        it {
          expect {
            subject[:invalid_key]
          }.to raise_error Anodator::UnknownKeyOnDataSourceError
        }
      end
    end

    context 'with on_exception: :nil' do
      subject { Anodator::DataSource.new('identifier', datas, on_exception: :nil)}

      context 'with valid key[:key2]' do
        it { expect(subject[:key2]).to equal datas[:key2] }
      end

      context 'with invalid key[:invalid_key]' do
        it { expect(subject[:invalid_key]).to be_nil }
      end
    end
  end
end
