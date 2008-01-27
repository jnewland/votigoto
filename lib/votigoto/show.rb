class Votigoto::Show
  PROPS = {
     :string => %w(title episode_title description source_station program_id series_id),
     :int => %w(source_size duration source_channel),
     :custom => %w(capture_date content_url details_url in_progress) 
  }  
  def initialize(hpricot)
    PROPS[:string].each do |property|
      eval(%Q[
          @#{property} = hpricot.at("details/#{property.gsub(/_/,'')}").inner_text rescue nil
      ])
    end
    PROPS[:int].each do |property|
      eval(%Q[
          @#{property} = hpricot.at("details/#{property.gsub(/_/,'')}").inner_text.to_i rescue nil
      ])
    end
    @capture_date = Time.at(hpricot.at("details/capturedate").inner_text.to_i(16)) rescue nil
    @content_url = hpricot.at("links/content/url").inner_text rescue nil
    @details_url = hpricot.at("links/tivovideodetails/url").inner_text rescue nil
    @in_progress = hpricot.at("details/inprogress").inner_text == "Yes" rescue false
  end
  
  (PROPS[:string]+PROPS[:int]+PROPS[:custom]).each do |property|
    class_eval "attr_reader :#{property}"
  end
  
  def to_s
    if self.episode_title.nil?
      return self.title
    else
      return self.title + " - " + self.episode_title
    end
  end
  
end