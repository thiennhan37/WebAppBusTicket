import React from "react";

export default function BrutalInput({
  label,
  id,
  type = "text",
  className = "",
  error,
  ...props
}) {
  return (
    <div className="brutal-input-wrapper" style={{ width: "100%", marginBottom: "1.25rem" }}>
      {label && (
        <label htmlFor={id} className="brutal-label">
          {label}
        </label>
      )}
      <input
        id={id}
        type={type}
        className={`brutal-input ${className}`.trim()}
        {...props}
      />
      {error && (
        <span
          className="brutal-input-error"
          style={{
            display: "block",
            color: "var(--color-red)",
            fontFamily: "var(--font-mono)",
            fontSize: "var(--font-size-xs)",
            fontWeight: "700",
            marginTop: "0.25rem",
          }}
        >
          {error}
        </span>
      )}
    </div>
  );
}
