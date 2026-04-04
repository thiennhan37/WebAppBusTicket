import React from 'react';

const ConfirmModal = ({ isOpen, onClose, onConfirm, title = "Xác nhận", message = "Bạn có chắc chắn muốn thực hiện hành động này?",
  confirmText = "Xác nhận",cancelText = "Hủy", type = "primary", view = "fixed" }) => {
  if (!isOpen) return null;

  const confirmButtonColor = type === 'danger' 
    ? 'bg-rose-600 hover:bg-rose-700 shadow-rose-100' 
    : 'bg-blue-600 hover:bg-blue-700 shadow-blue-100';

  return (
    <div className={`${view} inset-0 z-[999] flex items-center justify-center p-4 `}>
      {/* Backdrop mờ */}
      <div 
        className="absolute inset-0 bg-slate-900/40 backdrop-blur-[2px] transition-opacity"
        onClick={onClose}
      />

      {/* Nội dung Modal */}
      <div className="relative bg-white w-full max-w-sm rounded-2xl shadow-2xl border border-slate-100 p-6 transform transition-all scale-100 animate-in zoom-in-95 duration-200">
        <h3 className="text-xl font-bold text-slate-800 mb-2"> {title} </h3>
        <p className="text-slate-600 text-sm leading-relaxed mb-6"> {message}</p>

        <div className="flex gap-3">
          <button
            onClick={onClose}
            className="flex-1 py-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-600 font-bold transition-colors text-sm"
          >
            {cancelText}
          </button>
          
          <button onClick={() => {onConfirm(); onClose();}}
            className={`flex-1 py-2.5 rounded-xl text-white font-bold shadow-lg transition-all text-sm ${confirmButtonColor}`}
          >
            {confirmText}
          </button>
        </div>
      </div>
    </div>
  );
};

export default ConfirmModal;