
module RoziTestSuite
  class FileWrapperBaseTest < Minitest::Test
    def setup
      @subject = Class.new(Rozi::FileWrapperBase)
    end

    def test_open
      Rozi.expects(:open_file).with(:foo, "r").returns(:bar)

      wrapper = @subject.open(:foo)

      assert_same :bar, wrapper.file
    end

    def test_open_with_block
      file_mock = mock()
      file_mock.expects(:closed?).returns(false)
      file_mock.expects(:close)

      Rozi.expects(:open_file).with(:foo, "r").returns(file_mock)

      assert_same :pow, @subject.open(:foo) { |wrapper|
        assert_same file_mock, wrapper.file
        :pow
      }
    end
  end
end
