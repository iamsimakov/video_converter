# encoding: utf-8

module VideoConverter
  class Profile
    class << self
      attr_accessor :needed_params, :default_params
    end

    self.needed_params = [:bitrate]
    self.default_params = {:aspect => '4:3', :threads => 1}

    attr_accessor :params

    def initialize params
      self.class.needed_params.each do |needed_param|
        raise ArgumentError.new("#{needed_param} is needed") unless params[needed_param]
      end
      self.params = self.class.default_params.merge params
      raise ArgumentError.new("Output file or output dir is needed") unless params[:output_file] || params[:output_dir]
      self.params[:output_dir] = params[:output_dir] || File.dirname(params[:output_file])
      self.params[:output_file] = params[:output_file] || File.join(params[:output_dir], "#{object_id}.mp4")
      FileUtils.mkdir_p self.params[:output_dir]
      self.params[:bandwidth] = params[:bandwidth] || params[:bitrate]
    end

    def to_hash
      params
    end

    def self.groups profiles
      groups = profiles.is_a?(Array) ? profiles : [profiles]
      groups.map do |qualities|
        qualities.is_a?(Array) ? qualities : [qualities]
      end
    end
  end
end
