# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2015, Sebastian Staudt

module Gallerist

  autoload :App, 'gallerist/app'
  autoload :Helpers, 'gallerist/helpers'
  autoload :Library, 'gallerist/library'
  autoload :LibraryInUseError, 'gallerist/errors'
  autoload :RaiseWarmupExceptions, 'gallerist/middleware/raise_warmup_exceptions'
  autoload :ShowExceptions, 'gallerist/middleware/show_exceptions'

  # Models

  MODELS = {}

  def self.model(name, file)
    autoload name, file

    MODELS[name] = file
  end

  def self.load_models
    MODELS.values.each { |file| require file }
  end

  model :AdminData, 'gallerist/models/admin_data'
  model :Album, 'gallerist/models/album'
  model :AlbumPhoto, 'gallerist/models/album_photo'
  model :BaseModel, 'gallerist/models/base_model'
  model :ImageProxiesModel, 'gallerist/models/image_proxies_model'
  model :ImageProxyState, 'gallerist/models/image_proxy_state'
  model :Master, 'gallerist/models/master'
  model :ModelResource, 'gallerist/models/model_resource'
  model :Photo, 'gallerist/models/photo'
  model :Tag, 'gallerist/models/tag'
  model :TagPhoto, 'gallerist/models/tag_photo'

end
