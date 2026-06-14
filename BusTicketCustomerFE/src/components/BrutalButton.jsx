import React from "react";

export default function BrutalButton({
  children,
  onClick,
  type = "button",
  className = "",
  variant = "default", // default, primary, danger
  size = "medium", // medium, large
  disabled = false,
  ...props
}) {
  const baseClass = "brutal-btn";
  const variantClass = variant !== "default" ? `${baseClass}--${variant}` : "";
  const sizeClass = size === "large" ? `${baseClass}--large` : "";
  const disabledClass = disabled ? `${baseClass}--disabled` : "";

  return (
    <button
      type={type}
      className={`${baseClass} ${variantClass} ${sizeClass} ${disabledClass} ${className}`.trim()}
      onClick={onClick}
      disabled={disabled}
      {...props}
    >
      {children}
    </button>
  );
}
