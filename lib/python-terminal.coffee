exec = require('child_process').exec
path = require('path')
platform = require('os').platform

###
   Opens a terminal in the given directory, as specefied by the config
###
open_terminal = (dirpath) ->

  # Save data
  atom.commands.add 'atom-text-editor', 'godep:save', =>
  sys = require('sys')
  exec = require('child_process').exec
  godep_save_cmd = "godep save -r"
  child = exec godep_save_cmd, (error, stdout, stderr) ->
    if error
      console.log('\ngodep save exec error: ' + error)

  # Figure out the app and the arguments
  app = atom.config.get('python-terminal.app')
  editor = atom.workspace.getActivePaneItem()
  file = editor?.buffer?.file
  filepath = file?.path

  # Python
  echo = "echo 'Press any key to continue ...'"
  args = '-e bash -c "python ' + filepath + ' ; ' + echo + ' ; read"'

  # Start assembling the command line
  cmdline = "\"#{app}\" #{args}"

  exec cmdline if dirpath?

module.exports =
    activate: ->
        atom.commands.add "atom-workspace", "python-terminal:open-project-root", => @open()

    open: ->
        open_terminal pathname for pathname in atom.project.getPaths()

# Set per-platform defaults
if platform() == 'darwin'
  # Defaults for Mac, use Terminal.app
  module.exports.config =
    app:
      type: 'string'
      default: 'Terminal.app'

else if platform() == 'win32'
  # Defaults for windows, use cmd.exe as default
  module.exports.config =
      app:
        type: 'string'
        default: 'C:\\Windows\\System32\\cmd.exe'

else
  # Defaults for all other systems (linux I assume), use xterm
  module.exports.config =
      app:
        type: 'string'
        default: '/usr/bin/x-terminal-emulator'
