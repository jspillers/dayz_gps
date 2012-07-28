Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?
    # make new key/secrets here:
    # https://code.google.com/apis/console/#project:682824374370:access
    provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET']
  else
    provider :developer
  end
end
