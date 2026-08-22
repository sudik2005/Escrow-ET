import { useEffect, useState } from 'react';
import {useNavigate, useSearchParams} from 'react-router-dom'
import { useAuth } from '../../context/AuthContext'
import * as api from '../../lib/api'
import './DisputeForm.css';
function DisputeForm({disputeId}){
    const { token } = useAuth()
    const navigate = useNavigate()
    const [searchParams] = useSearchParams()
    const [contracts, setContracts] = useState([])
    const [selectedId, setSelectedId] = useState(searchParams.get('id') || '')
    const [reason, setReason] = useState('')
    const [submitError, setSubmitError] = useState('')
    const [submitting, setSubmitting] = useState(false)
    const [evidence, setEvidence] = useState(null);
    const [uploadProgress, setUploadProgress] = useState(0);
    const [uploading, setUploading] = useState(false);
    const [uploadError, setUploadError] = useState('');
    const [uploadSuccess, setUploadSuccess] = useState(false)
    useEffect(() => {
        if (!token) return
        api.mineContracts(token)
            .then((data) => {
                const list = Array.isArray(data) ? data : []
                setContracts(list)
                if (!selectedId && list[0]) setSelectedId(list[0].id)
            })
            .catch(() => {})
    }, [token])

    const selected = contracts.find((c) => String(c.id) === String(selectedId))

    const handleSubmit = async (event) => {
        event.preventDefault()
        setSubmitError('')
        if (!selectedId) {
            setSubmitError('Choose a transaction first.')
            return
        }
        setSubmitting(true)
        try {
            await api.openDispute(token, selectedId, reason)
            navigate('/disputes/messages')
        } catch (err) {
            setSubmitError(err.message || 'Could not open the dispute.')
        } finally {
            setSubmitting(false)
        }
    }
    const uploadEvidence = () => {
                if(!evidence){
                    setUploadError('Please select a file first.')
                    return
                }
                setUploading(true);
        setUploadProgress(0);
        setUploadError('');
        setUploadSuccess(false)
        let progress = 0
        const interval = setInterval(() => {
            progress +=20
            setUploadProgress(progress)
            if(progress>=100){
                clearInterval(interval)
                setUploading(false)
                setUploadSuccess(true)
            }
        }, 500)
        // const formData = new FormData()
        // formData.append('evidence',evidence)
        // const xhr = new XMLHttpRequest()
        // xhr.open(
        //     'POST', `/api/v1/disputes/${disputeId}/evidence/`
        // )
        // xhr.upload.addEventListener('progress', (event) => {
        //     if (event.lengthComputable){
        //         const progress = Math.round(
        //             (event.loaded / event.total) * 100
        //         )
        //         setUploadProgress(progress)
        //     }
        // })
        // xhr.addEventListener('load', () => {
        //     setUploading(false)
        //     if (xhr.status >= 200 && xhr.status < 300){
        //         setUploadProgress(100)
        //         setUploadSuccess(true)
        //     }
        //     else{
        //         setUploadError('We could not upload your evidence. Please try again.')
        //     }
        // })
        // xhr.addEventListener('error', () => {
        //     setUploading(false)
        //     setUploadError('A network error occurred. Please check your connection and try again.')
        // })
        // xhr.addEventListener('abort', () => {
        //     setUploading(false)
        //     setUploadError('The upload was cancelled.')
        // })
        // xhr.send(formData)
    }
    const handleEvidenceChange = (event) => {
        const file = event.target.files[0]
        setUploadError('')
        setUploadSuccess(false)
        setUploadProgress(0)
        if (!file){
            setEvidence(null)
            return
        }
        const maxFileSize = 10*1024*1024
        if(file.size > maxFileSize){
            setEvidence(null)
            setUploadError('The file is too large. Please choose a file smaller than 10 MB.')
            return
        }
        setEvidence(file)

    }

    return(
        <div className="dispute-page">
            <h1>Report a Dispute</h1>
             <p>Tell us what went wrong with this transaction.</p>
            <div className="form-section">
                <label htmlFor="contract">Transaction</label>
                <select
                    id="contract"
                    value={selectedId}
                    onChange={(event) => setSelectedId(event.target.value)}
                    required
                >
                    <option value="">Select a contract</option>
                    {contracts.map((contract) => (
                        <option key={contract.id} value={contract.id}>
                            {contract.item_name} — {Number(contract.amount).toFixed(2)} ETB
                        </option>
                    ))}
                </select>
            </div>
            <div className="transaction-summary">
                <p>Transaction</p>
                <span>{selected ? `#ET-${selected.id}` : '—'}</span>
                <h2>{selected?.item_name || 'Choose a transaction'}</h2>
                <span>{selected ? `${Number(selected.amount).toFixed(2)} ETB` : ''}</span>
                
                    <div>
                        <div>
                            <span>Buyer</span>
                            <strong>{selected?.buyer_username || selected?.buyer_phone || '—'}</strong>
                        </div>
                        <div>
                            <span>Seller</span>
                            <strong>{selected?.seller_username || selected?.seller_phone || '—'}</strong>
                        </div>
                        <div>
                            <span>Status</span>
                            <strong>{selected?.status || '—'}</strong>
                        </div>
                    </div>
            </div>
            <form onSubmit={handleSubmit}>
            <div className='form-section'>
                <label htmlFor="reason">
                    Why are you disputing this transaction?
                </label>
                <p className='form-help'>Please explain what happened and why you believe this transaction should be disputed.</p>
                <textarea required name="reason" id="reason" placeholder='Describe what went wrong...' value={reason} onChange={(event) => setReason(event.target.value)} />
            </div>
           <div className='form-section'>
                <label htmlFor="evidence">
                    Evidence
                </label>
                <p className='form-help'>Upload photos, receipts, screenshots, or other files that support your dispute.</p>
                <label htmlFor="evidence" className='file-upload'>
                    <span className='file-upload-icon'>&#128206;</span>
                    <span className='file-upload-title'>Choose a file </span>
                    <span className='file-upload-types'> PNG, JPG, PDF</span>
                </label>
                <input type="file" id='evidence' accept='.png,.jpg,.jpeg,.pdf' onChange={handleEvidenceChange} />
                {evidence && (
                    <div className="selected-file">
                        <span>✓</span>
                        <div> <strong>{evidence.name}</strong>
                        <p>{(evidence.size / 1024 / 1024).toFixed(2)} MB</p>
                        </div>
                    </div>
                )}
                {uploading && (
                    <div className='upload-progress'>
                        <div className='upload-progress-header'>
                            <span>Uploading evidence...</span>
                            <span>{uploadProgress}%</span>
                        </div>
                        <div className='upload-progress-track'>
                            <div className='upload-progress-bar' style={{width:`${uploadProgress}%`}}></div>
                        </div>
                    </div>
                )}
                {uploadError &&(
                    <div className='upload-message upload-message-error'>
                        <strong>⚠ Upload failed</strong>
                        <p>{uploadError}</p>
                        {evidence &&(
                            <button type='button' className='retry-button' onClick={uploadEvidence}> 
                                Try Again
                            </button>
                        )}
                    </div>
                )}
                {evidence && !uploadSuccess &&(
                    <button type="button" className="upload-button" onClick={uploadEvidence} disabled={uploading}>
                        {uploading ? 'Uploading...' : 'Upload Evidence'}
                    </button>
                )}
                {uploadSuccess &&(
                    <div className='upload-message upload-message-success'>
                            ✓ Evidence uploaded successfully
                    </div>
                )}
                {/* if(!disputeId){
                    setUploadError('A dispute ID is required before uploading evidence.')
                } */}
                
            </div>
            <div className='freeze-warning'>
                <div className='freeze-warning-icon'>⚠</div>
                <div>
                    <h3>Funds will be frozen</h3>
                    <p>
                        Submitting this dispute will freeze the transaction funds until the dispute has been reviewed and resolved.
                    </p>
                </div>
            </div>
            {submitError && (
                <div className='upload-message upload-message-error'>
                    <strong>{submitError}</strong>
                </div>
            )}
            <div className='form-actions'>
                <button type='button' className='cancel-button' onClick={() => navigate('/transactions')}>
                    Cancel
                </button>
                <button type='submit' className='submit-button' disabled={submitting}>
                    {submitting ? 'Submitting…' : 'Submit Dispute'}
                </button>
            </div>
            </form>
        </div>
        
    )
    }

export default DisputeForm;