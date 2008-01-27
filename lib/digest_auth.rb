# Written by Eric Hodel <drbrain@segment7.net>
##
#  HTTP Digest Authentication

module DigestAuth
  @@nonce_count = -1
  @md5 = Digest::MD5.new
  CNONCE = @md5.hexdigest("%x" % (Time.now.to_i + rand(65535)))

  def self.gen_auth_header(uri, auth_header, is_IIS = false)
    @@nonce_count += 1

    user = CGI.unescape uri.user
    password = CGI.unescape uri.password

    auth_header =~ /^(\w+) (.*)/

    params = {}
    $2.gsub(/(\w+)="(.*?)"/) { params[$1] = $2 }

    a_1 = "#{user}:#{params['realm']}:#{password}"
    a_2 = "GET:#{uri.path}"
    request_digest = ''
    request_digest << @md5.hexdigest(a_1)
    request_digest << ':' << params['nonce']
    request_digest << ':' << ('%08x' % @@nonce_count)
    request_digest << ':' << CNONCE
    request_digest << ':' << params['qop']
    request_digest << ':' << @md5.hexdigest(a_2)

    header = ''
    header << "Digest username=\"#{user}\", "
    header << "realm=\"#{params['realm']}\", "
    if is_IIS then
      header << "qop=\"#{params['qop']}\", "
    else
      header << "qop=#{params['qop']}, "
    end
    header << "uri=\"#{uri.path}\", "
    header << "nonce=\"#{params['nonce']}\", "
    header << "nc=#{'%08x' % @@nonce_count}, "
    header << "cnonce=\"#{CNONCE}\", "
    header << "response=\"#{@md5.hexdigest(request_digest)}\""

    return header
  end
end

# if __FILE__ == $0 then
#   uri = URI.parse "http://user:password@www.example.com/"
#   header = "Digest qop=\"auth\", realm=\"www.example.com\", nonce=\"4107baa081a592a6021660200000cd6c5686ff5f579324402b374d83e2c9\""
# 
#   puts DigestAuth.gen_auth_header uri, header
# end
# 
