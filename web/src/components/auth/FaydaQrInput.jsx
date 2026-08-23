import { useState, useRef, useEffect, useCallback } from 'react'
import jsQR from 'jsqr'
import { readQrFromFile } from '../../lib/readQrFromFile'

const TABS = ['Scan', 'Upload', 'Paste']

export default function FaydaQrInput({ value, onChange, label = 'Fayda QR' }) {
  const [tab, setTab] = useState('Scan')
  const [fileError, setFileError] = useState(null)
  const [reading, setReading] = useState(false)
  const [scanning, setScanning] = useState(false)
  const [cameraError, setCameraError] = useState(null)
  const [scanned, setScanned] = useState(false)

  const videoRef = useRef(null)
  const canvasRef = useRef(null)
  const streamRef = useRef(null)
  const rafRef = useRef(null)

  const stopCamera = useCallback(() => {
    if (rafRef.current) cancelAnimationFrame(rafRef.current)
    if (streamRef.current) {
      streamRef.current.getTracks().forEach((t) => t.stop())
      streamRef.current = null
    }
    setScanning(false)
  }, [])

  const tick = useCallback(() => {
    const video = videoRef.current
    const canvas = canvasRef.current
    if (!video || !canvas || video.readyState !== video.HAVE_ENOUGH_DATA) {
      rafRef.current = requestAnimationFrame(tick)
      return
    }
    const ctx = canvas.getContext('2d')
    canvas.width = video.videoWidth
    canvas.height = video.videoHeight
    ctx.drawImage(video, 0, 0, canvas.width, canvas.height)
    const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height)
    const result = jsQR(imageData.data, imageData.width, imageData.height)
    if (result) {
      onChange(result.data)
      setScanned(true)
      stopCamera()
      return
    }
    rafRef.current = requestAnimationFrame(tick)
  }, [onChange, stopCamera])

  const startCamera = useCallback(async () => {
    setCameraError(null)
    setScanned(false)
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: 'environment' },
      })
      streamRef.current = stream
      if (videoRef.current) {
        videoRef.current.srcObject = stream
        await videoRef.current.play()
      }
      setScanning(true)
      rafRef.current = requestAnimationFrame(tick)
    } catch {
      setCameraError('Camera access denied or unavailable. Use Upload or Paste instead.')
    }
  }, [tick])

  // Stop camera when switching away from Scan tab
  useEffect(() => {
    if (tab !== 'Scan') stopCamera()
  }, [tab, stopCamera])

  // Clean up on unmount
  useEffect(() => () => stopCamera(), [stopCamera])

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

      {/* Tab bar */}
      <div className="flex gap-1 mb-3">
        {TABS.map((t) => (
          <button
            key={t}
            type="button"
            onClick={() => setTab(t)}
            className={`px-3 py-1.5 text-xs rounded-lg font-semibold transition-colors ${
              tab === t
                ? 'bg-[var(--brand)] text-white'
                : 'bg-[var(--input-bg)] text-[var(--text-muted)] border border-[var(--border)]'
            }`}
          >
            {t}
          </button>
        ))}
      </div>

      {/* Scan tab */}
      {tab === 'Scan' && (
        <div>
          <canvas ref={canvasRef} className="hidden" />
          {!scanning && !scanned && (
            <button
              type="button"
              onClick={startCamera}
              className="w-full py-3 rounded-xl bg-[var(--brand)] text-white text-sm font-semibold mb-2"
            >
              Open Camera
            </button>
          )}
          {scanning && (
            <div className="relative rounded-xl overflow-hidden mb-2">
              <video
                ref={videoRef}
                muted
                playsInline
                className="w-full rounded-xl"
              />
              <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                <div className="w-48 h-48 border-2 border-[var(--brand)] rounded-xl opacity-70" />
              </div>
              <button
                type="button"
                onClick={stopCamera}
                className="absolute top-2 right-2 bg-black/50 text-white text-xs px-2 py-1 rounded-lg"
              >
                Cancel
              </button>
            </div>
          )}
          {scanned && (
            <p className="text-sm text-green-500 mb-2">QR scanned successfully.</p>
          )}
          {cameraError && (
            <p className="text-sm text-red-500 mb-2">{cameraError}</p>
          )}
        </div>
      )}

      {/* Upload tab */}
      {tab === 'Upload' && (
        <div>
          <p className="text-xs text-[var(--text-muted)] mb-2">
            Upload a photo of the QR on the back of your Fayda card.
          </p>
          <input
            type="file"
            accept="image/*"
            onChange={handleFile}
            className="block w-full text-sm text-[var(--text)] mb-2 file:mr-3 file:rounded-lg file:border-0 file:bg-[var(--brand)] file:px-3 file:py-2 file:text-white file:font-semibold"
          />
          {reading && <p className="text-xs text-[var(--text-muted)] mb-2">Reading QR…</p>}
          {fileError && <p className="text-sm text-red-500 mb-2">{fileError}</p>}
        </div>
      )}

      {/* Paste tab */}
      {tab === 'Paste' && (
        <textarea
          rows={3}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          placeholder="Paste the Fayda QR payload here"
          className="w-full bg-[var(--input-bg)] border border-[var(--border)] rounded-xl px-4 py-3 text-[var(--text-h)] text-xs focus:outline-none focus:border-[var(--brand)]"
        />
      )}
    </div>
  )
}
