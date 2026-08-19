function TextInput({
  label,
  id,
  name,
  type = "text",
  value,
  defaultValue,
  placeholder = "",
  onChange,
  onBlur,
  disabled = false,
  readOnly = false,
  required = false,
  error = "",
  helperText = "",
  fullWidth = false,
  className = "",
  ...props
}) {
  const inputId = id || name;

  const wrapperClassName = [
    "ui-field",
    fullWidth ? "ui-field-full-width" : "",
    className,
  ]
    .filter(Boolean)
    .join(" ");

  return (
    <div className={wrapperClassName}>
      {label && (
        <label className="ui-label" htmlFor={inputId}>
          {label}

          {required && <span className="ui-required"> *</span>}
        </label>
      )}

      <input
        id={inputId}
        name={name}
        type={type}
        value={value}
        defaultValue={defaultValue}
        placeholder={placeholder}
        onChange={onChange}
        onBlur={onBlur}
        disabled={disabled}
        readOnly={readOnly}
        required={required}
        className={`ui-input ${error ? "ui-input-error" : ""}`}
        {...props}
      />

      {error && <p className="ui-error-message">{error}</p>}

      {!error && helperText && (
        <p className="ui-helper-text">{helperText}</p>
      )}
    </div>
  );
}

export default TextInput;