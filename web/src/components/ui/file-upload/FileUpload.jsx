import { useRef, useState } from "react";

function FileUpload({
  label = "Upload File",
  accept,
  multiple = false,
  onChange,
  disabled = false,
  required = false,
  error = "",
  helperText = "",
  fullWidth = false,
  className = "",
}) {
  const inputRef = useRef(null);
  const [fileNames, setFileNames] = useState([]);

  const wrapperClassName = [
    "ui-field",
    fullWidth ? "ui-field-full-width" : "",
    className,
  ]
    .filter(Boolean)
    .join(" ");

  const handleFileChange = (event) => {
    const selectedFiles = Array.from(event.target.files || []);

    setFileNames(selectedFiles.map((file) => file.name));

    if (onChange) {
      onChange(selectedFiles);
    }
  };

  const handleBrowse = () => {
    if (!disabled) {
      inputRef.current?.click();
    }
  };

  return (
    <div className={wrapperClassName}>
      {label && (
        <label className="ui-label">
          {label}

          {required && <span className="ui-required"> *</span>}
        </label>
      )}

      <input
        ref={inputRef}
        type="file"
        accept={accept}
        multiple={multiple}
        disabled={disabled}
        required={required}
        onChange={handleFileChange}
        className="ui-file-input"
      />

      <button
        type="button"
        className="ui-file-upload"
        onClick={handleBrowse}
        disabled={disabled}
      >
        <span className="ui-file-upload-icon">↑</span>

        <span className="ui-file-upload-text">
          <strong>Choose file{multiple ? "s" : ""}</strong>
          <small>Click to browse from your device</small>
        </span>
      </button>

      {fileNames.length > 0 && (
        <div className="ui-file-list">
          {fileNames.map((fileName) => (
            <div className="ui-file-item" key={fileName}>
              <span>{fileName}</span>
            </div>
          ))}
        </div>
      )}

      {error && <p className="ui-error-message">{error}</p>}

      {!error && helperText && (
        <p className="ui-helper-text">{helperText}</p>
      )}
    </div>
  );
}

export default FileUpload;