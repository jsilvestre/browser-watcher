# Handlers declaration

# Handler to display the test html file
handler = (req, res) ->
    data = fs.readFileSync('index.html');
    res.writeHead 200
    res.end data
# ./handler

# Command execution callback
puts = (error, stdout, sterr) ->
    console.log "Command executed"
    console.log stdout
    console.log sterr
    if error is null
        console.log "Command executed with success"
# ./puts

# Handle file changement
onFileChange = (socket, logFilePath, type) ->

    streamInput = fs.createReadStream(logFilePath);
    streamInput.setEncoding 'utf8'
    textInput = ''

    streamInput.on 'data', (data) ->
        textInput += data

    ###
    When the reading is done, we get the last line and emit it through the socket.
    This could be greatly improved with a data structure and timestamp discrimation.
    ###
    streamInput.on 'end', (close) ->
        splittedText = textInput.split String.fromCharCode(10)
        lastLine = splittedText[splittedText.length - 2]
        socket.emit "update-log",
            "type" : type
            "content" : lastLine
# ./onFileChange

# end/Handlers declration


# Quick declaration of the webserver
app = require("http").createServer(handler)
io = require("socket.io").listen(app)
io.set 'log level', 2 # disable heartbeat debug output
fs = require("fs")
exec = require('child_process').exec
app.listen 4568


# Path stuff to add more flexibility
logPath = '/log/'
logBrunchFilename = 'brunch.log'
logServerFilename = 'server.log'
logBrunchFilepath = __dirname + logPath + logBrunchFilename
logServerFilepath = __dirname + logPath + logServerFilename
brunchPath = __dirname  + '/project'
serverPath = __dirname

# Context of the "brunch w" command
brunchCmd =
    "cmd" : "brunch w > " + logBrunchFilepath + " 2>&1"
    "opts" :
        "cwd" : brunchPath

# Context of the execution of a node server
serverCmd =
    "cmd" : "coffee test.coffee > " + logServerFilepath + " 2>&1"
    "opts" :
        "cwd" : serverPath

io.sockets.on "connection", (socket) ->

    ###
    When a client connects, we start the "brunch w" and the node server
    /!\ Processes started in the command are not killed. Must be improved.
    ###
    exec(brunchCmd.cmd, brunchCmd.opts, puts)
    exec(serverCmd.cmd, serverCmd.opts, puts)

    # Then we watch the brunch output text file ...
    fs.watch logBrunchFilepath, (event) ->
        if event is "change"
            onFileChange(socket, logBrunchFilepath, 'brunch')

    # And the server output text file
    fs.watch logServerFilepath, (event) ->
        if event is "change"
            onFileChange(socket, logServerFilepath, 'server')

