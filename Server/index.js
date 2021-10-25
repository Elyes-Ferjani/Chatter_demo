const http = require('http');
const express = require('express');
const socketio = require('socket.io');
const cors = require('cors');

const { getAllMessages } = require('./getMessages')
const { putMessage } = require('./putMessage')

const app = express();
app.use(cors());
const server = http.createServer(app);
const io = socketio(server, {
    cors: {
      origins: ["*"],
      handlePreflightRequest: (req,res) => {
        res.writeHead(200, {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET,POST"
        })
        res.end()
      }
    },
    path: '/websockets',
    maxHttpBufferSize: 1024,
    pingInterval: 60 * 1000,
    pingTimeout: 4 * 60 * 1000
});

app.get('/', (req, res) => {
  const serverHasCapacity = getAverageNetworkUsage() < 0.8;
  if (serverHasCapacity) res.status(200).send("ok");
  res.status(400).send("server is overloaded");
})


io.on('connect', (socket) => {
  try { 
  socket.on('join', async ({ name, room }, callback) => {


    socket.join(room);
    socket.emit('message', { user: 'admin', text: `${name}, welcome to room ${room}.`});
    socket.broadcast.to(room).emit('message', { user: 'admin', text: `${name} has joined!` });

    const messages = await getAllMessages()
    callback(messages)
  });

  socket.on('sendMessage', (data, callback) => {
    
    const {name: user, room, message } = data
    const msg = message ? message : ""

    io.to(room).emit('message', { user , text: msg });

    putMessage({room: room, user, text: msg})
    callback();
  });

  socket.on('disconnect', () => {
      console.log('User left')
  })
} catch(err){
  console.log(err)
}
});

server.listen(process.env.PORT || 5000, () => console.log(`Server Started!.`));