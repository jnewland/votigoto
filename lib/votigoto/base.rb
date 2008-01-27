class Votigoto::Base

  def initialize(ip,mak)
    @ip = ip
    @mak = mak
  end
  
  attr_reader :ip, :mak, :doc
  
  def last_changed_date(reload=false)
    load(reload)
    Time.at(@doc.at("/tivocontainer/details/lastchangedate").inner_text.to_i(16))
  end
  
  def shows(reload=false)
    load(reload)
    return @shows if @shows
    @shows = []
    @doc.search("tivocontainer/item").each do |show|
      @shows << Votigoto::Show.new(show)
    end
    @shows
  end
  alias_method :to_a, :shows
  
  def show(program_id,reload=false)
    show = shows(reload).select { |show| show.program_id == program_id.to_s }
    show.length == 1 ? show[0] : nil
  end
  
private

  def getxml(uri = "TiVoConnect?Command=QueryContainer&Container=%2FNowPlaying&Recurse=Yes")
    begin
      uri = URI.parse "https://tivo:#{@mak}@#{@ip}/#{uri}"
    rescue URI::InvalidURIError
     puts 'Invalid TiVo URI'
    end
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    xml = ''
    begin
      Timeout::timeout(Votigoto::TIMEOUT) do
        http.start do |http|
          response = http.head uri.request_uri
          authorization = DigestAuth.gen_auth_header uri, response['www-authenticate']
          response = http.get uri.request_uri, 'Authorization' => authorization
          xml = response.body
        end
      end 
    end
    Hpricot(xml)
  end
  
  def load(reload=false)
    if reload
      @doc = getxml()
      @shows = nil
    end
    @doc ||= getxml()
  end
  
end