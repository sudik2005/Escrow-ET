import { useState } from 'react'
import { readQrFromFile } from '../../lib/readQrFromFile'

export default function FaydaQrInput({ value, onChange, label = 'Fayda QR' }) {
  const [fileError, setFileError] = useState(null)
  const [reading, setReading] = useState(false)

  async function handleFile(event) {
    const file = event.target.files?.[0]
    event.target.value = ''
    if (!file) return
    setFileError(null)
    setReading(true)
    try {
      onChange(await readQrFromFile(file))
    } catch (err) {
      setFileError(err.message || 'Could not read that image.')
    } finally {
      setReading(false)
    }
  }

  return (
    <div>
      <label className="block text-sm text-[var(--text)] mb-1.5">{label}</label>
      <p className="text-xs text-[var(--text-muted)] mb-2">
        Upload a photo of the QR on the back of your Fayda card, or paste the payload.
      </p>
      <input
        type="file"
        accept="image/*"
        onChange={handleFile}
        className="block w-full text-sm text-[var(--text)] mb-2 file:mr-3 file:rounded-lg file:border-0 file:bg-[var(--brand)] file:px-3 file:py-2 file:text-white file:font-semibold"
      />
      {reading && <p className="text-xs text-[var(--text-muted)] mb-2">Reading QR…</p>}
      {fileError && <p className="text-sm text-red-500 mb-2">{fileError}</p>}
      <textarea
        rows={3}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder="Or paste the Fayda QR payload here"
        className="w-full bg-[var(--input-bg)] border border-[var(--border)] rounded-xl px-4 py-3 text-[var(--text-h)] text-xs focus:outline-none focus:border-[var(--brand)]"
      />
    </div>
  )
}
