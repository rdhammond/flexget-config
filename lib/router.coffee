Settings = require '../settings'
_ = require 'underscore'
BodyParser = require 'body-parser'
FlexgetConfig = require './flexget-config'
Q = require 'q'

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
    upgrade: yes
    qualities: [
      'hdtv <720p !ac3 !dd5.1',
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
    promise = FlexgetConfig.load Settings.yamlPath

    promise = promise.then (config) ->
        shows = _.map config.tasks.download_tv.series, (x) -> toShow x
        res.render 'index', {shows: shows}

    promise = promise.catch (err) -> res.sendStatus 500
    promise.done()

  app.post '/add', parser, (req, res) ->
    return res.sendStatus 500 if not validate req.body
    req.body = _.pick req.body, 'name', 'season', 'episode'
    promise = FlexgetConfig.load Settings.yamlPath

    promise = promise.then (config) ->
        series = config.tasks.download_tv.series
        hasSeries = _.find series, (x) -> _.keys(x)[0] is req.body.name
        return res.send null if hasSeries

        newSeries = toSeries req.body
        config.tasks.download_tv.series.push newSeries
        FlexgetConfig.save Settings.yamlPath, config

    promise = promise.then () -> res.render 'partials/show', req.body
    promise = promise.catch (err) -> res.sendStatus 500
    promise.done()
    
  app.post '/delete', parser, (req, res) ->
    return res.sendStatus 500 if not req.body.name
    promise = FlexgetConfig.load Settings.yamlPath

    promise = promise.then (config) ->
        series = config.tasks.download_tv.series
        target = _.find series, (x) -> _.keys(x)[0] is req.body.name
        return res.sendStatus 200 if not target?

        config.tasks.download_tv.series = _.without series, target
        FlexgetConfig.save Settings.yamlPath, config

    promise = promise.then () -> res.sendStatus 200
    promise = promise.catch (err) ->
        console.log err
        res.sendStatus 500
    promise.done()
