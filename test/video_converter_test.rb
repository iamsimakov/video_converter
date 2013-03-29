require 'test_helper'

class VideoConverterTest < Test::Unit::TestCase
  context 'run' do
    setup do
      @input = 'test/fixtures/test.mp4'
    end

    context 'with type mp4' do
      setup do
        @profiles = []
        @profiles << (@p11 = VideoConverter::Profile.new(:bitrate => 300, :output_file => 'tmp/test11.mp4'))
        @profiles << (@p12 = VideoConverter::Profile.new(:bitrate => 400, :output_file => 'tmp/test12.mp4'))
        @profiles << (@p21 = VideoConverter::Profile.new(:bitrate => 700, :output_file => 'tmp/test21.mp4'))
        @profiles << (@p22 = VideoConverter::Profile.new(:bitrate => 700, :output_file => 'tmp/test22.mp4'))
        @c = VideoConverter.new(:input => @input, :profile => [[@p11, @p12], [@p21, @p22]], :verbose => false, :log => 'tmp/test.log', :type => :mp4)
        @res = @c.run
      end
      should 'convert files' do
        4.times do |n|
          file = "tmp/test#{n / 2 + 1}#{n.even? ? 1 : 2}.mp4"
          assert File.exists?(file)
          assert File.size(file) > 0
        end
      end
      should 'return success convert process' do
        assert VideoConverter.find(@c.id)
        assert @res
        assert_equal 'convert_success', VideoConverter.find(@c.id).status
      end
      should 'write log file' do
        assert File.exists?('tmp/test.log')
        assert !File.read('tmp/test.log').empty?
      end
    end

    context 'with type hls' do
      setup do
        @profiles = []
        @profiles << (@p11 = VideoConverter::Profile.new(:bitrate => 300, :output_dir => 'tmp/test11'))
        @profiles << (@p12 = VideoConverter::Profile.new(:bitrate => 400, :output_dir => 'tmp/test12'))
        @profiles << (@p21 = VideoConverter::Profile.new(:bitrate => 700, :output_dir => 'tmp/test21'))
        @profiles << (@p22 = VideoConverter::Profile.new(:bitrate => 700, :output_dir => 'tmp/test22'))
        @c = VideoConverter.new(:input => @input, :profile => [[@p11, @p12], [@p21, @p22]], :verbose => false, :log => 'tmp/test.log', :type => :hls, :playlist_dir => 'tmp')
        @res = @c.run
      end
      should 'create chunks' do
        @profiles.each do |profile|
          assert File.exists?(File.join(profile.to_hash[:output_dir], 's-00001.ts'))
        end
      end
    end
  end
end
