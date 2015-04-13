settings = require '../settings'
flexgetConfig = require './flexget-config'
_ = require 'underscore'
BodyParser = require 'body-parser'

toShow = (series) ->
  name = _.keys(series)[0]
  data = series[name]
  matches = /^S(\d+)E(\d+)$/.exec data.begin
  
  show =
    name: name
    season: parseInt matches[1], 10
    episode: parseInt matches[2], 10

validate = (x) -> x?.name and x?.season > 0 and x?.episode > 0

toSeries = (show) ->
  episode = toDoubleDigits show.episode
  season = toDoubleDigits show.season
  series = {}
  
  series[show.name] =
    begin: "S#{season}E#{episode}",
    qualities: [
      'hdtv <720p !ac3 !dd5.1',
      'hdtv 720p !ac3 !dd5.1',
      'sdtv'
    ]

  series

toDoubleDigits = (x) ->
  x = parseInt x, 10
  return "0#{x}" if x < 10
  "#{x}"

parser = BodyParser.urlencoded {extended:no}

module.exports = (app) ->
  app.get '/', (req, res) ->
    config = flexgetConfig.load settings.yamlPath
    shows = _.map config.tasks.download_tv.series, (x) -> toShow x
    res.render 'index', {shows: shows}
    
  app.post '/add', parser, (req, res) ->
    return res.sendStatus 500 if not validate req.body
    req.body = _.pick req.body, 'name', 'season', 'episode'
    
    config = flexgetConfig.load settings.yamlPath
    series = config.tasks.download_tv.series
    hasSeries = _.find series, (x) -> _.keys(x)[0] is req.body.name
    return res.send null if hasSeries
    
    newSeries = toSeries req.body
    config.tasks.download_tv.series.push newSeries
    flexgetConfig.save settings.yamlPath, config
    
    res.render 'partials/show', req.body
    
  app.post '/delete', parser, (req, res) ->
    return res.sendStatus 500 if not req.body.name
    
    config = flexgetConfig.load settings.yamlPath
    series = config.tasks.download_tv.series
    target = _.find series, (x) -> _.keys(x)[0] is req.body.name
    return res.sendStatus 200 if not target?
    
    config.tasks.download_tv.series = _.without series, target
    flexgetConfig.save settings.yamlPath, config
    res.sendStatus 200