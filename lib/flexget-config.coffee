Yaml = require 'js-yaml'
Q = require 'q'
Fs = require 'fs'


module.exports = {
  load: (path) ->
    contents = Fs.readFileSync path
    Yaml.safeLoad contents
    
  save: (path, yaml) ->
    contents = Yaml.safeDump yaml, {schema: Yaml.FAILSAFE_SCHEMA}
    Fs.writeFileSync path, contents
};