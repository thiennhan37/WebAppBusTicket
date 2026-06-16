import React, { useContext, useEffect, useState } from 'react';
import { X, User, Key, Phone, Mail, Shield, Calendar, Users, Edit2, Save } from 'lucide-react';
import AuthContext from '../../context/AuthContext';
import AuthenticateService from '../../Services/authenticate';
import ChangePassword from './ChangePassword';
import { toVN } from '../../utils/translate';
import StaffService from '../../Services/StaffService';
import { toast } from 'sonner';
import { useMutation } from '@tanstack/react-query';

const UserProfile = ({ isOpen, onClose }) => {
  const { user, setUser, company, refreshUser } = useContext(AuthContext) || {};
  const isStaff = user?.role === 'STAFF';
  const [tab, setTab] = useState('profile'); // 'profile' | 'password'
  const [form, setForm] = useState({ fullName: '', email: '', phone: '', role: '', dob: '', gender: ''});
  const [isEditing, setIsEditing] = useState(false);

  useEffect(() => {
    if (!user) return;
    const newForm = {
      id: user.id || '',
      busCompanyId: company?.id || '',
      fullName: user.fullName || '',
      email: user.email || '',
      phone: user.phone || '',
      role: user.role || '', 
      dob: user.dob || '',
      gender: user.gender || ''
    };

    // If user is staff, ensure editing mode is disabled (defer to avoid sync setState in effect)
    if (isStaff) {
      const clear = window.setTimeout(() => setIsEditing(false), 0);
      // ensure we clear if effect re-runs
      return () => window.clearTimeout(clear);
    }

    // Only update local form if it differs to avoid unnecessary re-renders.
    const needsUpdate =
      String(newForm.id) !== String(form.id) ||
      newForm.fullName !== form.fullName ||
      newForm.email !== form.email ||
      newForm.phone !== form.phone ||
      newForm.role !== form.role ||
      newForm.dob !== form.dob ||
      newForm.gender !== form.gender ||
      isOpen;

    if (needsUpdate) {
      const t = window.setTimeout(() => setForm(newForm), 0);
      return () => window.clearTimeout(t);
    }
    return undefined;
  }, [user, isOpen, company?.id, isStaff, form.id, form.fullName, form.email, form.phone, form.role, form.dob, form.gender]);

  const { mutate: handleSaveProfile, isPending: saving } = useMutation({
    mutationFn: async () => {
      if (StaffService.updateStaff) {
        const req = {...form, gender:toVN(form.gender) }
        return await StaffService.updateStaff(req);
        
      } else {
        console.warn('StaffService.updateStaff not implemented');
        return Promise.resolve();
      }
    },
    onSuccess: () => {
      if (setUser) setUser(prev => ({ ...(prev || {}), ...form }));
      toast.success('Cập nhật thông tin thành công');
      refreshUser();
      setIsEditing(false);
    },
    onError: (err) => {
      console.log("ERROR", err);
      toast.error(err?.response?.data?.message || err?.message || 'Lỗi khi lưu thông tin.');
    }
  });

  const handleCancelEdit = () => {
    if (user) {
      setForm({
        fullName: user.fullName || '',
        email: user.email || '',
        phone: user.phone || '',
        role: user.role || '', 
        dob: user.dob || '',
        gender: user.gender || ''
      });
    }
    setIsEditing(false);
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[120] flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-slate-900/60" onClick={onClose}></div>
      <div className="relative bg-white rounded-2xl p-6 w-full max-w-3xl shadow-2xl">
        <button onClick={onClose} className="absolute top-4 right-4 text-gray-400 hover:text-gray-600"><X size={18} /></button>
        <div className="flex gap-6">
          <div className="w-48 border-r pr-4">
            <button onClick={() => { setTab('profile'); setIsEditing(false); }}
              className={`flex items-center gap-2  w-full py-2 text-left ${tab === 'profile' ? 'font-semibold' : ''}`}>
              <User size={16} /> Thông tin cá nhân
            </button>
            <button onClick={() => { setTab('password'); setIsEditing(false); }}
              className={`flex items-center gap-2 w-full py-2 text-left ${tab === 'password' ? 'font-semibold' : ''}`}>
              <Key size={16} /> Đổi mật khẩu
            </button>
          </div>

          <main className="flex-1">
            {tab === 'profile' && (
              <div className="animate-in fade-in slide-in-from-right-4 duration-300">
                {/* Header Section */}
                <div className="flex items-center justify-between mb-8">
                  <div className="flex items-center space-x-4">
                    <div className="p-2 bg-emerald-50 text-emerald-600 rounded-lg">
                      <User size={24} />
                    </div>
                    <div>
                      <h3 className="text-base font-bold text-slate-800">Thông tin cá nhân</h3>
                      <p className="text-sm text-slate-500">Quản lý và cập nhật thông tin tài khoản</p>
                    </div>
                  </div>
                  {!isEditing && !isStaff ? (
                    <button 
                      onClick={() => setIsEditing(true)}
                      className="flex items-center gap-1 px-2.5 py-2 bg-emerald-50 text-emerald-600 rounded-lg hover:bg-emerald-100 transition-colors text-sm font-semibold"
                    >
                      <Edit2 size={16} /> Chỉnh sửa
                    </button>
                  ) : (
                   <div className="flex items-center gap-2">
                     <button 
                       onClick={handleCancelEdit}
                       disabled={saving}
                       className="px-4 py-2 bg-slate-100 text-slate-600 rounded-lg hover:bg-slate-200 transition-colors text-sm font-semibold disabled:opacity-50"
                     >
                       Hủy
                     </button>
                     <button 
                       onClick={handleSaveProfile}
                       disabled={saving}
                       className="flex items-center gap-2 px-4 py-2 bg-emerald-600 text-white rounded-lg hover:bg-emerald-700 transition-colors text-sm font-semibold disabled:opacity-50"
                     >
                       <Save size={16} /> {saving ? 'Đang lưu...' : 'Lưu'}
                     </button>
                   </div>
                  )}
                </div>

                {/* Info Cards/List */}
                <div className="bg-slate-50/50 rounded-2xl border border-slate-100 overflow-hidden">
                  <div className="divide-y divide-slate-200/60">
                    {[
                      { key: 'fullName', label: "Họ và tên", value: form.fullName, icon: <User size={16} />, editable: false },
                      { key: 'email', label: "Email", value: form.email, icon: <Mail size={16} />, editable: false },
                      { key: 'phone', label: "Số điện thoại", value: form.phone, icon: <Phone size={16} />, editable: true, type: 'text' },
                      { 
                        key: 'role',
                        label: "Chức vụ", 
                        value: toVN(form.role), 
                        icon: <Shield size={16} />,
                        isBadge: true,
                        editable: false
                      },
                      { key: 'dob', label: "Ngày sinh", value: form.dob, icon: <Calendar size={16} />, editable: true, type: 'date' },
                      { key: 'gender', label: "Giới tính", value: form.gender, icon: <Users size={16} />, editable: true, type: 'select' },
                    ].map((item, idx) => (
                      <div key={idx} className="flex items-center justify-between p-2 hover:bg-white transition-colors group min-h-[48px]">
                        <div className="flex items-center space-x-3 w-1/3">
                          <div className="p-2 bg-white rounded-lg border border-slate-100 text-slate-400 group-hover:text-emerald-500 group-hover:border-emerald-100 transition-all shadow-sm">
                            {item.icon}
                          </div>
                          <span className="text-sm font-medium text-slate-500">{item.label}</span>
                        </div>
                        
                        <div className="flex-1 flex justify-end">
                          {isEditing && item.editable && !isStaff ? (
                            item.type === 'select' ? (
                              <select
                                value={form[item.key]}
                                onChange={(e) => setForm({...form, [item.key]: e.target.value})}
                                className="w-full max-w-[200px] p-2 text-sm border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 bg-white"
                              >
                                <option value="">Chọn giới tính</option>
                                <option value="MALE">Nam</option>
                                <option value="FEMALE">Nữ</option>
                                <option value="OTHER">Khác</option>
                              </select>
                            ) : (
                              <input
                                type={item.type}
                                value={form[item.key] || ''}
                                onChange={(e) => setForm({...form, [item.key]: e.target.value})}
                                className="w-full max-w-[200px] p-2 text-sm border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 bg-white"
                                placeholder={`Nhập ${item.label.toLowerCase()}`}
                              />
                            )
                          ) : item.isBadge ? (
                            <span className="px-3 py-1 bg-emerald-100 text-emerald-700 rounded-full text-xs font-bold uppercase tracking-wider">
                              {item.value}
                            </span>
                          ) : (
                            <span className="text-sm font-semibold text-slate-900">
                              {item.key === 'gender' ? toVN(item.value) : item.value || "---"}
                            </span>
                          )}
                        </div>
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