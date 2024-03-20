# This plugin uses https://github.com/jwt/ruby-jwt (MIT license) to parse a JWT from the provided field, extract claim 
# data and insert this data in the record. If the provided field is empty or doesn't contain a valid JWT then no
# data is inserted and a warning is logged. Basic tokens are silently ignored, but this can be disabled
# 
# @author Patrick Ehlert
#
# Example usage:
#
#     <filter *>
#         @type jwt
#         token_key authorization_header
#         remove_token_key true
#         skip_basic_token true
#         <record>
#             algorithm        header.alg
#             subject          payload.sub
#             expiration_time  payload.exp
#         </record>
#     </filter>
#

require 'fluent/plugin/filter'
require 'jwt'

module Fluent::Plugin
    class JwtFilter < Filter
        Fluent::Plugin.register_filter('jwt', self)

        BEARER_TOKEN_PREFIX = "Bearer "
        BASIC_TOKEN_PREFIX  = "Basic "

        JWT_COMPONENTS = ["payload", "header"]

        config_set_default :@log_level, "warn"

        # See also https://docs.fluentd.org/plugin-helper-overview/api-plugin-helper-record_accessor
        # and https://docs.fluentd.org/plugin-helper-overview/api-plugin-helper-inject
        helpers :record_accessor, :inject

        # Plugin parameters
        desc 'Specify the field name that contains the JWT to parse.'
        config_param :token_key, :string, default: nil
        desc 'Remove the "token_key" field from the record when parsing was successful (default = false)'
        config_param :remove_token_key, :bool, default: false
        desc 'Silently skip "Basic" base64 encoded tokens (default = true). If false it will generate an error for each basic token'
        config_param :skip_basic_token, :bool, default: true

        def configure(conf)
            super

            if @token_key.nil?
                raise Fluent::ConfigError, "Please set the token_key parameter."
            end
            log.info("[jwt] - token key = " + @token_key)
            @token_accessor = record_accessor_create('$.' + @token_key)

            @fields_map = {}
            conf.elements.select { |element| element.name == 'record' }.each {
                |element| element.each_pair { |k, v|
                    element.has_key?(k) # to suppress unread configuration warning

                    # validate that each value starts with a valid JWT component and then a period
                    if (v.start_with?(*JWT_COMPONENTS.map { |c| c + "." })) then
                        @fields_map[k] = v
                        log.info("[jwt] - field "+ k + ", value "+ v)
                    else
                        raise Fluent::ConfigError, "Unsupported JWT component: " + v 
                    end
                }
            }
        end

        def filter(tag, time, record)
            filtered_record = add_fields(record)
            if filtered_record
                record = filtered_record
            end
            record = inject_values_to_record(tag, time, record)
            record
        end

        def add_fields(record)
            # get token
            token = @token_accessor.call(record).to_s
            log.trace("[jwt] - token = " + token.to_s)
            return record if !token || token.empty? ||
                (@skip_basic_token && token.start_with?(BASIC_TOKEN_PREFIX))

            begin
                # "Bearer" is case-sensitive according to specs https://datatracker.ietf.org/doc/html/rfc6750#section-2.1
                token = token.delete_prefix(BEARER_TOKEN_PREFIX)
                decoded_token = JWT_COMPONENTS.zip(JWT.decode(token, nil, false)).to_h
                log.trace("[jwt] - decoded token = " + decoded_token.to_s)

                # insert requested data
                @fields_map.each do |key_to_add, path|
                    p = path.split(".")
                    value_to_add = decoded_token[p[0]][p[1]].to_s
                    log.trace("[jwt] - adding " + key_to_add + " with value " + value_to_add)
                    record[key_to_add] = value_to_add
                end

                @token_accessor.delete(record) if @remove_token_key
            rescue JWT::DecodeError => e
                log.error("[jwt] - error decoding token: " + token.to_s)
            end

            record
        end

    end
end