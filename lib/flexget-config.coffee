Yaml = require 'js-yaml'
Fs = require 'fs'
Q = require 'q'

module.exports =
  load: (path) ->
    promise = Q.nfcall Fs.readFile, path
    promise.then (contents) -> Yaml.safeLoad contents
    
  save: (path, yaml) ->
    contents = Yaml.safeDump yaml
    Q.nfcall Fs.writeFile, path, contents
