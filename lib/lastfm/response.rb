require 'rubygems'
require 'xmlsimple'

class Lastfm
  class Response
    attr_reader :xml

    def initialize(body)
      @xml = XmlSimple.xml_in(body, 'ForceArray' => ['image', 'tag', 'user', 'event', 'correction'])
    rescue REXML::UndefinedNamespaceException
      @xml = XmlSimple.xml_in(body_with_opensearch_namespace(body), 'ForceArray' => ['image', 'tag', 'user', 'event', 'correction'])
    rescue REXML::ParseException
      @xml = XmlSimple.xml_in(body.encode(Encoding.find("ISO-8859-1"), :undef => :replace), 
                                          'ForceArray' => ['image', 'tag', 'user', 'event', 'correction'])
    end

    def success?
      @xml['status'] == 'ok'
    end

    def message
      @xml['error']['content']
    end

    def error
      @xml['error']['code'].to_i
    end

    private

    def body_with_opensearch_namespace(body)
      tags = body.split(">")
      invalid_tag_index = tags.find_index{ |t| t.match("results") }
      tags[invalid_tag_index] += opensearch_namespace
      tags.join(">")
    end

    def opensearch_namespace
      " xmlns:opensearch=\"http://a9.com/-/spec/opensearch/1.1/\">"
    end
  end
end
