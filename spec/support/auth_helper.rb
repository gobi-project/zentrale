##
# Authhelper
# generates header for api requests
module AuthHelper
  def generate_header(token = nil)
    head = {}
    head['CONTENT_TYPE'] = 'application/json'
    head['ACCEPT'] = 'application/json'
    head['api.tilt.root'] = 'app/api/templates'
    head['Session'] = token unless token.nil?
    head
  end
end
