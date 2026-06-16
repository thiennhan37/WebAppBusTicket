import React from "react";

export default function BrutalSelect({
  label,
  id,
  options = [], // [{ value, label }] or string array
  className = "",
  error,
  placeholder,
  ...props
}) {
  return (
    <div className="brutal-select-wrapper" style={{ width: "100%", marginBottom: "1.25rem" }}>
      {label && (
        <label htmlFor={id} className="brutal-label">
          {label}
        </label>
      )}
      <select
        id={id}
        className={`brutal-select ${className}`.trim()}
        {...props}
      >
        {placeholder && <option value="">{placeholder}</option>}
        {options.map((opt, index) => {
          const val = typeof opt === "object" ? opt.value : opt;
          const lbl = typeof opt === "object" ? opt.label : opt;
          return (
            <option key={index} value={val}>
              {lbl}
            </option>
          );
        })}
      </select>
      {error && (
        <span
          className="brutal-select-error"
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
