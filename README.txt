README for votigoto
===================

>> require 'votigoto'
=> true
>> tivo = Votigoto::Base.new("10.0.0.148","SEKRET_MEDIA_ACCESS_KEY")
=> #<Votigoto::Base:0x14095d8 @mak="SEKRET_MEDIA_ACCESS_KEY", @ip="10.0.0.148">
>> tivo.shows.first.to_s
=> "The Daily Show With Jon Stewart - Senator Joe Biden (D-Del.)."