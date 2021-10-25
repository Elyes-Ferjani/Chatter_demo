import React, { useState, useEffect } from "react";
import queryString from 'query-string';
import io from "socket.io-client";
import Messages from '../Messages/Messages';
import InfoBar from '../InfoBar/InfoBar';
import Input from '../Input/Input';
import { dns_name } from '../../utils/endpoint'
import './Chat.css';

const port = 8080

const ENDPOINT = `${dns_name}:${port}`;

let socket;

const Chat = ({ location }) => {
  const [name, setName] = useState('');
  const [room, setRoom] = useState('');
  const [message, setMessage] = useState('');
  const [messages, setMessages] = useState([]);

  useEffect(() => {
    const { name, room } = queryString.parse(location.search);

    socket = io(ENDPOINT, {
      path: "/websockets",
      transports: ["polling", "websocket"],
      transportOptions: {
        polling: {

        }
      }
    });
    
    setRoom(room);
    setName(name)

    socket.emit('join', { name, room }, (data) => {
      if(data) {
   
        setMessages(messages=> [ ...data, ...messages]);
      }
    });
  }, [ENDPOINT, location.search]);
  
  useEffect(() => {
    socket.on('message', msg => {
      setMessages(messages => [ ...messages, msg ]);
    });
}, []);

  const sendMessage = (event) => {
    event.preventDefault();

    if(message) {
      socket.emit('sendMessage', { name, message, room }, () => setMessage(''));
    }
  }

  return (
    <div className="outerContainer">
      <div className="container">
          <InfoBar room={room} />
          <Messages messages={messages} name={name} />
          <Input message={message} setMessage={setMessage} sendMessage={sendMessage} />
      </div>
    </div>
  );
}

export default Chat;
