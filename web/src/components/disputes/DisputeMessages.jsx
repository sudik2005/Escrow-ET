import {useState} from 'react'
import './DisputeMessages.css'
function DisputeMessages(){
    const [messages, setMessages] = useState([
  {
    id: 1,
    sender: 'Buyer',
    role: 'buyer',
    text: 'The website delivered does not match what we agreed on.',
    time: '10:30 AM',
  },
  {
    id: 2,
    sender: 'Seller',
    role: 'seller',
    text: 'I understand the concern. I am willing to fix the issues.',
    time: '10:42 AM',
  },
  {
    id: 3,
    sender: 'Admin',
    role: 'admin',
    text: 'Please provide any supporting evidence so we can review the dispute.',
    time: '11:05 AM',
  },
])
const [newMessage, setNewMessage] = useState('')
const [attachment, setAttachment] = useState(null)
const handleSendMessage = () =>{
    if(!newMessage.trim() && !attachment){
        return
    }
    const message = {
        id:Date.now(),
        sender:'You',
        role:'seller',
        text:newMessage,
        time:new Date().toLocaleTimeString([],{
            hour:'2-digit',
            minute:'2-digit',
        }),
        attachment: attachment? {
            name : attachment.name,
            type : attachment.type,
            size : attachment.size,
        } : null,
    }
    setMessages((previousMessages) => [...previousMessages, message])
    setNewMessage('')
    setAttachment(null)
}
const handleAttachmentChange = (e) =>{
    const file = e.target.files[0]
    if (file){
        setAttachment(file)
    }
}
const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftkey){
        e.preventDefault()
        handleSendMessage()
    }
}
    return(
        <div className="Dispute-message-page">
            <div className='message-header'>
                <div>
                    <h1>Dispute Messages</h1>
                    <p>Communicate with the buyer, seller, and dispute administrator.</p>
                </div>
                <span className='dispute-status'>Disputed</span>
            </div>
            <div className="messages-container">
                <div className="messages-list">
                    {messages.map((message) => (
                        <div key={message.id} className={`message message-${message.role}`}>
                            <div className='message-info'>
                                <strong>{message.sender}</strong>
                                <span>{message.time}</span>
                            </div>
                            <div className='message-bubble'>
                                {message.text &&(
                                    <p>{message.text}</p>
                                )}
                                {message.attachment &&(
                                    <div className='message-attachment'>
                                        <span className='attachment-icon'>&#128206;</span>
                                        <span className='attachment-name'>
                                            {message.attachment.name}
                                        </span>
                                    </div>
                                )}
                                
                            </div>
                        </div>
                    ))}
                </div>
            </div>
            <div className="message-composer">
                <div className='message-input-wrapper'>
                    <label className='attachment-button'>
                        &#128206;
                        <input type="file" onChange={handleAttachmentChange} hidden />
                    </label>
                    <textarea rows={1} value={newMessage} onChange={(e) => setNewMessage(e.target.value)} onKeyDown={handleKeyDown} placeholder='Type a message...' />
                    <button type='button' onClick={handleSendMessage}>
                        send
                    </button>
                </div>
                {attachment &&(
                    <div className='attachment-preview'>
                        <span>&#128206;{attachment.name}</span>
                        <button type='button' onClick={() => setAttachment(null)}>
                            ×
                        </button>
                    </div>
                )}
                
            </div>
        </div>
    )
}
export default DisputeMessages;