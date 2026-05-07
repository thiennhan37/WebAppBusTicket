import React, { useState } from 'react';
import AuthenticateService from '../../Services/authenticate';
import { ShieldCheck } from 'lucide-react'; 
import PasswordInput from './PasswordInput';
import { useMutation } from '@tanstack/react-query';
import LoadingOverlay from '../other/LoadingOverlay';
import StatusModal from '../other/StatusModal';

const ChangePassword = ({ onSuccess }) => {
  const [oldPwd, setOldPwd] = useState('');
  const [newPwd, setNewPwd] = useState('');
  const [confirmPwd, setConfirmPwd] = useState('');
  const [loading, setLoading] = useState(false);
  const [showCurrentPwd, setShowCurrentPwd] = useState(false);
  const [showNewPwd, setShowNewPwd] = useState(false);
  const [showConfirmPwd, setShowConfirmPwd] = useState(false);

  const [errorReport, setErrorReport] = useState("");
  const [report, setReport] = useState("");
  const [error, setError] = useState("");
  const {mutate: mutateChangePassword, isPending} = useMutation({
    mutationFn: async () => {
      if(oldPwd.length < 6 || newPwd.length < 6 || confirmPwd.length < 6) 
        throw new Error("Mật khẩu phải có ít nhất 6 ký tự");
      if(newPwd !== confirmPwd) throw new Error("Mật khẩu mới không khớp");
      if(newPwd === oldPwd) throw new Error("Mật khẩu mới không được trùng với mật khẩu cũ");
      const response = await AuthenticateService.changePassword({ oldPassword: oldPwd, newPassword: newPwd });
      return response?.data?.result;
    },
    onSuccess: () => {
      setOldPwd(''); setNewPwd(''); setConfirmPwd('');
      setReport("success:Đổi mật khẩu thành công");
    },
    onError: (error) => {
      if(error?.response){
        setReport("error:"+ error?.response?.data?.message || 'Lỗi khi đổi mật khẩu.');
      }
      else{
        setError(error.message);
      }
    }, 
    onMutate: () => {
      setError("");
    }
  })


  return (
    <div className="max-w-md mx-auto bg-white rounded-2xl shadow-sm border border-slate-100 p-6">
      {/* {report.startsWith("pending") && <LoadingOverlay message={report.split(":")[1]}></LoadingOverlay>} */}
      {report.startsWith("error") && <StatusModal type="error" message={report.split(":")[1]} onClose={() => setReport("")}></StatusModal>}
      {report.startsWith("success") && <StatusModal type="success" message={"Đổi mật khẩu thành công"} onClose={() => setReport("")}></StatusModal>}
      <div className="flex items-center space-x-3 mb-6">
        <div className="p-2 bg-emerald-50 text-emerald-600 rounded-lg">
          <ShieldCheck size={24} />
        </div>
        <div>
          <h3 className="text-base font-bold text-slate-800">Bảo mật tài khoản</h3>
          <p className="text-sm text-slate-500">Vui lòng nhập mật khẩu mới để bảo vệ tài khoản</p>
        </div>
      </div>

      <div className="space-y-3">
        <PasswordInput label="Mật khẩu hiện tại" value={oldPwd} onChange={setOldPwd} 
          placeholder="••••••••" showPwd={showCurrentPwd} setShowPwd={setShowCurrentPwd}/>
        
        <hr className="border-slate-100 my-2" />

        <PasswordInput label="Mật khẩu mới" value={newPwd} onChange={setNewPwd} 
          placeholder="Tối thiểu 6 ký tự" showPwd={showNewPwd} setShowPwd={setShowNewPwd}/>

        <PasswordInput label="Xác nhận mật khẩu" value={confirmPwd} onChange={setConfirmPwd} 
          placeholder="Nhập lại mật khẩu mới" showPwd={showConfirmPwd} setShowPwd={setShowConfirmPwd}/>

        <div className="min-h-[26px] pl-4">
            {error && (
                <p className="text-sm text-red-500 font-medium animate-in fade-in slide-in-from-top-1">
                    {error}
                </p>
            )}
        </div>
        <div className="pt-2">
          <button disabled={isPending} onClick={mutateChangePassword}
            className="w-full py-3 px-4 rounded-xl bg-emerald-600 text-white font-semibold text-sm
                       hover:bg-emerald-700 active:transform active:scale-[0.98] 
                       disabled:opacity-60 disabled:cursor-not-allowed
                       shadow-lg shadow-emerald-200 transition-all flex justify-center items-center space-x-2"
          > Đổi mật khẩu </button>
        </div>
      </div>
    </div>
  );
};

export default ChangePassword;