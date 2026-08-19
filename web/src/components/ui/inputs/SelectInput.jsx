function SelectInput({
  label,
  id,
  name,
  value,
  defaultValue,
  options = [],
  placeholder = "Select an option",
  onChange,
  onBlur,
  disabled = false,
  required = false,
  error = "",
  helperText = "",
  fullWidth = false,
  className = "",
  ...props
}) {
  const selectId = id || name;

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
        <label className="ui-label" htmlFor={selectId}>
          {label}

          {required && <span className="ui-required"> *</span>}
        </label>
      )}

      <select
        id={selectId}
        name={name}
        value={value}
        defaultValue={defaultValue}
        onChange={onChange}
        onBlur={onBlur}
        disabled={disabled}
        required={required}
        className={`ui-select ${error ? "ui-select-error" : ""}`}
        {...props}
      >
        <option value="" disabled>
          {placeholder}
        </option>

        {options.map((option) => {
          const optionValue =
            typeof option === "object" ? option.value : option;

          const optionLabel =
            typeof option === "object" ? option.label : option;

          return (
            <option key={optionValue} value={optionValue}>
              {optionLabel}
            </option>
          );
        })}
      </select>

      {error && <p className="ui-error-message">{error}</p>}

      {!error && helperText && (
        <p className="ui-helper-text">{helperText}</p>
      )}
    </div>
  );
}

export default SelectInput;