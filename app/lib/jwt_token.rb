class JwtToken
  class << self
    def encode(data, expires_at: 30.minutes.from_now)
      data_hash = data.is_a?(String) ? JSON.parse(data) : data rescue nil
      raise ArgumentError, "Data must be a `Hash` or a JSON string" unless data.is_a?(Hash)

      claims = {
        exp: expires_at.is_a?(Time) ? expires_at.to_i : expires_at,
        iat: Time.zone.now.to_i,
        iss: 'https://api.turtello.com',
        alg: 'HS256',
        typ: 'JWT',
        **data_hash
      }

      secret = Rails.application.secrets.secret_key_base
      JWT.encode(claims, secret, claims[:alg])
    end

    def decode(token)
      return if token.blank?

      decoded = begin
        secret = Rails.application.secrets.secret_key_base
        JWT.decode(token, secret, true, { algorithm: 'HS256' })
      rescue JWT::DecodeError => e
        Rails.logger.info("JWT error:")
        Rails.logger.info(e.inspect)
        Rails.logger.info(e.backtrace)
        []
      end

      data = decoded.first
      data.is_a?(Hash) ? HashWithIndifferentAccess.new(data) : data
    end
  end
end
