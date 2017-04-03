require 'faraday'
require 'faraday_middleware'

module OpenTable
  class Client
    API_BASE = 'http://opentable.herokuapp.com'.freeze

    def countries
      get 'countries'
    end

    def cities(options={})
      get 'cities', options
    end

    def restaurants(options={})
      get 'restaurants', options
    end

    def restaurant(id)
      get "restaurants/#{id}"
    end

    def get(path, params={})
      request(:get, path, params)
    end

  private

    def request(method, path, params={})
      path = "/api/#{path}"

      response = connection.send(method, path, params) do |request|
        request.url(path, params)
      end

      if [404, 403, 400].include?(response.status)
        raise response.body['error']
      end

      response.body
    end

    def connection
      @connection ||= Faraday.new(API_BASE) do |c|
        c.use(Faraday::Request::UrlEncoded)
        c.use(Faraday::Response::ParseJson)
        c.adapter(Faraday.default_adapter)
      end
    end
  end
end
