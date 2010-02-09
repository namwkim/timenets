# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_familystory_session',
  :secret      => '65521dd40c49ba823c00521940cdb5fe007ace540e6e270b979a2c7866e5864bbd1eccdbe2c7136c78cca48ee045993f84767e4f8f816de1d3d112fa9ae94778'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
