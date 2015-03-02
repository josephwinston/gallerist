# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2015, Sebastian Staudt

require 'logger'
require 'sinatra/activerecord'
require 'sqlite3/database_force_readonly'

class Gallerist::App < Sinatra::Base

  register Sinatra::ActiveRecordExtension

  configure do
    enable :logging

    set :library_path, ENV['GALLERIST_LIBRARY']
    set :views, File.join(settings.root, '..', '..', 'views')
  end

  configure :development do
    set :logging, ::Logger::DEBUG
  end

  helpers Gallerist::Helpers

  def library
    unless settings.respond_to? :library
      settings.set :library, Gallerist::Library.new(self, settings.library_path)
      settings.set :database, {
        adapter: 'sqlite3',
        database: library.library_db
      }

      Gallerist::ImageProxyState.establish_connection({
        adapter: 'sqlite3',
        database: library.image_proxies_db
      })

      Gallerist::ModelResource.establish_connection({
        adapter: 'sqlite3',
        database: library.image_proxies_db
      })

      logger.debug "  Found #{library.albums.size} albums."
    end
    settings.library
  end

  def self.setup_default_middleware(builder)
    builder.use Sinatra::ExtendedRack
    builder.use Gallerist::ShowExceptions
    setup_logging    builder
  end

  get '/' do
    @albums = library.albums.visible.nonempty.order :date
    @title = library.name

    erb :index
  end

  get '/albums/:id' do
    @album = library.albums.find params[:id]
    @title = @album.name

    erb :album
  end

  get '/photos/:id' do
    begin
      photo = Gallerist::Photo.find params[:id]
    rescue ActiveRecord::RecordNotFound
      logger.error 'Could not find the photo with ID #%s.' % [ params[:id] ]
      halt 404
    end

    send_file File.join(library.path, photo.image_path),
      disposition: :inline,
      filename: photo.file_name
  end

  get '/thumbs/:id' do
    begin
      photo = Gallerist::Photo.find params[:id]
    rescue ActiveRecord::RecordNotFound
      logger.error 'Could not find the photo with ID #%s.' % [ params[:id] ]
      halt 404
    end

    send_file File.join(library.path, photo.small_thumbnail_path),
      disposition: :inline,
      filename: 'thumb_%s' % [ photo.file_name ]
  end

end
