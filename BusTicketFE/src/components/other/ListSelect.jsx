import { useState } from "react";
import { ChevronDown } from "lucide-react";

const ListSelect = ({
  list = [],
  value = "",
  onChange,
  placeholder = "Chọn tuyến đường",
}) => {
  const [open, setOpen] = useState(false);

  const selected = list.find(t => String(t.id) === String(value));

  return (
    <div className="relative w-full">
      {/* Label (optional) */}
      <div className="mb-1 text-sm font-semibold text-gray-700 uppercase">
        Tuyến đường
      </div>

      {/* Selected */}
      <div
        onClick={() => setOpen(!open)}
        className={`
          flex items-center justify-between
          px-4 py-2.5 rounded-xl cursor-pointer
          border transition-all
          ${open ? "border-blue-500 ring-2 ring-blue-200" : "border-gray-300"}
          bg-gray-100 hover:bg-gray-200
        `}
      >
        <span className={`${!value ? "text-gray-400" : "text-gray-800"}`}>
          {selected ? selected.name : placeholder}
        </span>

        <ChevronDown
          size={18}
          className={`transition-transform text-gray-500 ${
            open ? "rotate-180" : ""
          }`}
        />
      </div>

      {/* Dropdown */}
      {open && (
        <div className="absolute w-full mt-2 rounded-xl border border-gray-200 bg-white shadow-lg max-h-52 overflow-y-auto z-50">
          
          {/* Placeholder */}
          <div
            onClick={() => {
              onChange("");
              setOpen(false);
            }}
            className="px-4 py-2.5 text-gray-400 hover:bg-gray-100 cursor-pointer"
          >
            {placeholder}
          </div>

          {list.map(item => {
            const isSelected = String(item.id) === String(value);

            return (
              <div
                key={item.id}
                onClick={() => {
                  onChange(item.id);
                  setOpen(false);
                }}
                className={`
                  px-4 py-2.5 cursor-pointer
                  ${
                    isSelected
                      ? "bg-gray-400 text-white"
                      : "text-gray-800 hover:bg-gray-100"
                  }
                `}
              >
                {item.name}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default ListSelect;