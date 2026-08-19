function SecondaryButton({
  children,
  type = "button",
  onClick,
  disabled = false,
  loading = false,
  fullWidth = false,
  className = "",
  ...props
}) {
  const buttonClassName = [
    "ui-button",
    "ui-button-secondary",
    fullWidth ? "ui-button-full-width" : "",
    className,
  ]
    .filter(Boolean)
    .join(" ");

  return (
    <button
      type={type}
      className={buttonClassName}
      onClick={onClick}
      disabled={disabled || loading}
      {...props}
    >
      {loading ? "Loading..." : children}
    </button>
  );
}

export default SecondaryButton;