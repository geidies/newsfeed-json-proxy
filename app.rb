require 'sinatra'
require 'net/http'
require 'xmlsimple'
require 'json'

get '/*' do |path|
  content_type :json
  unless validate? path
    status 401
  end
  STDERR.puts "Transforming #{path}"
  source = Net::HTTP.get URI('http://meltwaternews.com/' + path)
  raw_doc = XmlSimple.xml_in( source )
  # return JSON.pretty_generate raw_doc['feed'][0]['documents'][0]['document']
  # STDERR.puts JSON.pretty_generate raw_doc
  out_doc = {
    :documents => []
  }
  raw_doc['feed'][0]['documents'][0]['document'].each do |document|
    doc = {
      :title => document['title'][0],
      :url   => document['url'][0],
    }
    out_doc[:documents] << doc
  end
  out_doc.to_json
end

def validate? path
  # /magenta/xml/html/12/77/73074.html.XML
  path.match( /magenta\/xml\/html\/\d{1,2}\/\d{2}\/\d+\.html\.XML/ )
end
