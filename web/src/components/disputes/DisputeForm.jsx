import { useState } from 'react';
import {useNavigate} from 'react-router-dom'
import './DisputeForm.css';
function DisputeForm({disputeId}){
    const [evidence, setEvidence] = useState(null);
    const [uploadProgress, setUploadProgress] = useState(0);
    const [uploading, setUploading] = useState(false);
    const [uploadError, setUploadError] = useState('');
    const [uploadSuccess, setUploadSuccess] = useState(false)
    const handleSubmit = (event) => {
        event.preventDefault()
        window.alert("Dispute submitted")
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

    const navigate = useNavigate()
    return(
        <div className="dispute-page">
            <h1>Report a Dispute</h1>
             <p>Tell us what went wrong with this transaction.</p>
            <div className="transaction-summary">
                <p>Transaction</p>
                <span>#ET-10292</span>
                <h2>Website Design</h2>
                <span>3,000 ETB</span>
                
                    <div>
                        <div>
                            <span>Buyer</span>
                            <strong>[Buyer name]</strong>
                        </div>
                        <div>
                            <span>Seller</span>
                            <strong>[Seller name]</strong>
                        </div>
                        <div>
                            <span>Opened</span>
                            <strong>[opened date and time]</strong>
                        </div>
                    </div>
            </div>
            <form onSubmit={handleSubmit}>
            <div className='form-section'>
                <label htmlFor="reason">
                    Why are you disputing this transaction?
                </label>
                <p className='form-help'>Please explain what happened and why you believe this transaction should be disputed.</p>
                <textarea required name="reason" id="reason" placeholder='Describe what went wrong...' />
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
            <div className='form-actions'>
                <button type='button' className='cancel-button' onClick={() => navigate('/transactions')}>
                    Cancel
                </button>
                <button type='submit' className='submit-button'>
                    Submit Dispute
                </button>
            </div>
            </form>
        </div>
        
    )
    }

export default DisputeForm;