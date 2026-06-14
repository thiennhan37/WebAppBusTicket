import React from "react";

export default function BrutalCard({
  children,
  className = "",
  noHover = false,
  ...props
}) {
  const baseClass = "brutal-card";
  const hoverClass = noHover ? `${baseClass}--no-hover` : "";

  return (
    <div
      className={`${baseClass} ${hoverClass} ${className}`.trim()}
      {...props}
    >
      {children}
    </div>
  );
}
