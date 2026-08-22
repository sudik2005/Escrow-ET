import { useEffect, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import { useAuth } from '../../context/AuthContext'
import * as api from '../../lib/api'
import './DisputeMessages.css'

function roleClass(role) {
  const r = String(role || '').toLowerCase()
  if (r === 'admin') return 'admin'
  if (r === 'buyer') return 'buyer'
  return 'seller'
}

export default function DisputeMessages() {
  const { token, user } = useAuth()
  const [searchParams, setSearchParams] = useSearchParams()
  const focusId = searchParams.get('id')
  const [disputes, setDisputes] = useState([])
  const [selected, setSelected] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [newMessage, setNewMessage] = useState('')
  const [sending, setSending] = useState(false)

  useEffect(() => {
    if (!token) return
    api
      .listDisputes(token)
      .then((data) => {
        const list = Array.isArray(data) ? data : []
        setDisputes(list)
        const match = focusId
          ? list.find((d) => String(d.id) === focusId)
          : list[0]
        setSelected(match || null)
      })
      .catch((err) => setError(err.message || 'Could not load disputes.'))
      .finally(() => setLoading(false))
  }, [token, focusId])

  async function handleSendMessage() {
    if (!selected || !newMessage.trim()) return
    setSending(true)
    setError(null)
    try {
      const msg = await api.sendDisputeMessage(token, selected.id, {
        message: newMessage.trim(),
      })
      setSelected((prev) => ({
        ...prev,
        messages: [...(prev.messages || []), msg],
      }))
      setNewMessage('')
    } catch (err) {
      setError(err.message || 'Could not send message.')
    } finally {
      setSending(false)
    }
  }

  function handleKeyDown(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSendMessage()
    }
  }

  if (loading) {
    return (
      <div className="Dispute-message-page">
        <div className="flex justify-center py-12">
          <div className="w-8 h-8 border-2 border-[var(--brand)] border-t-transparent rounded-full animate-spin" />
        </div>
      </div>
    )
  }

  return (
    <div className="Dispute-message-page">
      <div className="message-header">
        <div>
          <h1>Dispute Messages</h1>
          <p>Talk with the other party and an admin on a live dispute.</p>
        </div>
        {selected && <span className="dispute-status">{selected.status}</span>}
      </div>

      {disputes.length > 1 && (
        <div className="mb-4 flex flex-wrap gap-2">
          {disputes.map((d) => (
            <button
              key={d.id}
              type="button"
              onClick={() => {
                setSelected(d)
                setSearchParams({ id: d.id })
              }}
              className={`rounded-full border px-3 py-1 text-xs ${
                selected?.id === d.id
                  ? 'border-[var(--brand)] text-[var(--brand)]'
                  : 'border-[var(--border)]'
              }`}
            >
              {d.item_name}
            </button>
          ))}
        </div>
      )}

      {error && <p className="text-sm text-red-500 mb-3">{error}</p>}

      {!selected && (
        <p className="text-[var(--text-muted)]">No disputes yet. Open one from a transaction.</p>
      )}

      {selected && (
        <>
          <p className="text-sm text-[var(--text-muted)] mb-3">
            {selected.item_name} — {Number(selected.amount).toFixed(2)} {selected.currency}
          </p>
          <div className="messages-container">
            <div className="messages-list">
              {(selected.messages || []).length === 0 && (
                <p className="text-sm text-[var(--text-muted)]">No messages yet. {selected.reason}</p>
              )}
              {(selected.messages || []).map((message) => (
                <div
                  key={message.id}
                  className={`message message-${roleClass(message.sender_role)}`}
                >
                  <div className="message-info">
                    <strong>
                      {message.sender === user?.id
                        ? 'You'
                        : message.sender_username || message.sender_role}
                    </strong>
                    <span>
                      {message.created_at
                        ? new Date(message.created_at).toLocaleTimeString([], {
                            hour: '2-digit',
                            minute: '2-digit',
                          })
                        : ''}
                    </span>
                  </div>
                  <div className="message-bubble">
                    {message.message && <p>{message.message}</p>}
                    {message.attachment_url && (
                      <div className="message-attachment">
                        <a href={message.attachment_url}>{message.attachment_url}</a>
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
          <div className="message-composer">
            <div className="message-input-wrapper">
              <textarea
                rows={1}
                value={newMessage}
                onChange={(e) => setNewMessage(e.target.value)}
                onKeyDown={handleKeyDown}
                placeholder="Type a message..."
              />
              <button type="button" onClick={handleSendMessage} disabled={sending}>
                {sending ? '…' : 'send'}
              </button>
            </div>
          </div>
        </>
      )}
    </div>
  )
}
