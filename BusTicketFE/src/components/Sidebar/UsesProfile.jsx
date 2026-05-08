import React, { useContext, useEffect, useState } from 'react';
import { X, User, Key, Phone, Mail, Shield, Calendar, Users } from 'lucide-react';
import AuthContext from '../../context/AuthContext';
import AuthenticateService from '../../Services/authenticate';
import ChangePassword from './ChangePassword';
import { toVN } from '../../utils/translate';

const UserProfile = ({ isOpen, onClose }) => {
  const { user, setUser } = useContext(AuthContext) || {};
  const [tab, setTab] = useState('profile'); // 'profile' | 'password'
  const [form, setForm] = useState({ fullName: '', email: '', phone: '', role: '', dob: '', gender: ''});
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (user) {
      setForm({
        fullName: user.fullName || '',
        email: user.email || '',
        phone: user.phone || '',
        role: user.role || '', 
        dob: user.dob || '',
        gender: user.gender || ''
      })
    }
  }, [user, isOpen]);

  if (!isOpen) return null;

  // const handleSaveProfile = async () => {
  //   setSaving(true);
  //   try {
  //     if (AuthenticateService.updateProfile) {
  //       await AuthenticateService.updateProfile(form);
  //     } else {
  //       console.warn('AuthenticateService.updateProfile not implemented');
  //     }
  //     if (setUser) setUser(prev => ({ ...(prev || {}), ...form }));
  //     alert('Cập nhật thông tin thành công');
  //     onClose();
  //   } catch (err) {
  //     alert(err?.response?.data?.message || err?.message || 'Lỗi khi lưu thông tin.');
  //   } finally {
  //     setSaving(false);
  //   }
  // };

  return (
    <div className="fixed inset-0 z-[120] flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-slate-900/60" onClick={onClose}></div>
      <div className="relative bg-white rounded-2xl p-6 w-full max-w-2xl shadow-2xl">
        <button onClick={onClose} className="absolute top-4 right-4 text-gray-400 hover:text-gray-600"><X size={18} /></button>
        <div className="flex gap-6">
          <div className="w-48 border-r pr-4">
            <button onClick={() => setTab('profile')}
              className={`flex items-center gap-2  w-full py-2 text-left ${tab === 'profile' ? 'font-semibold' : ''}`}>
              <User size={16} /> Thông tin cá nhân
            </button>
            <button onClick={() => setTab('password')}
              className={`flex items-center gap-2 w-full py-2 text-left ${tab === 'password' ? 'font-semibold' : ''}`}>
              <Key size={16} /> Đổi mật khẩu
            </button>
          </div>

          <main className="flex-1">
            {tab === 'profile' && (
              <div className="animate-in fade-in slide-in-from-right-4 duration-300">
                {/* Header Section */}
                <div className="flex items-center space-x-4 mb-8">
                  <div className="p-2 bg-emerald-50 text-emerald-600 rounded-lg">
                    <User size={24} />
                  </div>
                  <div>
                    <h3 className="text-base font-bold text-slate-800">Thông tin cá nhân</h3>
                    <p className="text-sm text-slate-500">Quản lý và cập nhật thông tin tài khoản của bạn</p>
                  </div>
                </div>

                {/* Info Cards/List */}
                <div className="bg-slate-50/50 rounded-2xl border border-slate-100 overflow-hidden">
                  <div className="divide-y divide-slate-200/60">
                    {[
                      { label: "Họ và tên", value: form.fullName, icon: <User size={16} /> },
                      { label: "Email", value: form.email, icon: <Mail size={16} /> },
                      { label: "Số điện thoại", value: form.phone, icon: <Phone size={16} /> },
                      { 
                        label: "Chức vụ", 
                        value: toVN(form.role), 
                        icon: <Shield size={16} />,
                        isBadge: true 
                      },
                      { label: "Ngày sinh", value: form.dob, icon: <Calendar size={16} /> },
                      { label: "Giới tính", value: toVN(form.gender), icon: <Users size={16} /> },
                    ].map((item, idx) => (
                      <div key={idx} className="flex items-center justify-between p-2 hover:bg-white transition-colors group">
                        <div className="flex items-center space-x-3">
                          <div className="p-2 bg-white rounded-lg border border-slate-100 text-slate-400 group-hover:text-emerald-500 group-hover:border-emerald-100 transition-all shadow-sm">
                            {item.icon}
                          </div>
                          <span className="text-sm font-medium text-slate-500">{item.label}</span>
                        </div>
                        
                        {item.isBadge ? (
                          <span className="px-3 py-1 bg-emerald-100 text-emerald-700 rounded-full text-xs font-bold uppercase tracking-wider">
                            {item.value}
                          </span>
                        ) : (
                          <span className="text-sm font-semibold text-slate-900">{item.value || "---"}</span>
                        )}
                      </div>
                      ))}
                    </div>
                  </div>
                </div>
                )}

            {tab === 'password' && (
              <ChangePassword onSuccess={() => { alert('Đổi mật khẩu thành công'); onClose(); }} />
            )}
          </main>
        </div>
      </div>
    </div>
  );
};

export default UserProfile;