import React, { useState } from 'react';
import { UserPlus, Award, ShieldCheck, LockKeyhole, BookUser} from 'lucide-react';
import StatCards from './StatCards';
import StaffListHeader from './StaffListHeader';
import InputGroup from '../../components/other/InputGroup';
import Pagination from '../../components/other/Pagination';
import StaffService from '../../Services/StaffService';
import StaffInfo from './StaffInfo';
import StaffCreate from './StaffCreate';
import { useQuery, keepPreviousData, useQueryClient, useMutation } from '@tanstack/react-query';
import StatusModal from '../../components/other/StatusModal';
import LoadingOverlay from '../../components/other/LoadingOverlay';
import ConfirmModal from '../../components/other/ConfirmModal';
import { useSearchParams } from 'react-router-dom';
import { toEng, toVN } from '../../utils/translate';
const StaffManagement = () => {
  console.log("reload StaffManagement")
  const queryClient = useQueryClient();
  const [rightPanelMode, setRightPanelMode] = useState('none');

  const [selectedStaff, setSelectedStaff] = useState({
      id: '',
      fullName: '',
      role: '',
      phone: '',
      email: '',
      dob: '',
      gender: '',
      createdAt: '',
      status: '',
  });
  const handleRowClick = (staff) => {
    // queryClient.invalidateQueries({ queryKey: ['staffStats'] });
    setRightPanelMode("view");
    setSelectedStaff({...staff, gender:toVN(staff.gender)});
  };
  const [searchParams, setSearchParams] = useSearchParams();

  const getFilterParams = () => ({
    page: Number(searchParams.get('page')) || 1,
    role: searchParams.get('role') ? toVN(searchParams.get('role')) : 'Tất Cả',
    status: searchParams.get('status') ? toVN(searchParams.get('status')) : 'Tất Cả',
    keyword: searchParams.get('keyword'),
  });

  const filterParams = getFilterParams();

  const updateFilterParams = (updater) => {
    const params = {
      page: String(updater.page || 1),
      role: updater.role ? toEng(updater.role) : 'ALL',
      status: updater.status ? toEng(updater.status) : 'ALL',
      keyword: updater.keyword || ""
    };
    setSearchParams(params);
  };
  const onPageChange = (newPage) => {
    updateFilterParams({...filterParams, page: newPage });
  }
  const {data: result} = useQuery({
    queryKey: ['staffs', filterParams], 
    queryFn: async () => {
      try{
        const result = (await StaffService.getStaff(filterParams)).data.result;
        return result;
      }catch(error){
        console.log(error);
      }
    }, 
    placeholderData: keepPreviousData,
    staleTime: 0, 
  });

  const staffList = result?.content || []; 
  const totalPages = result?.page.totalPages || 1;

  const [newStaff, setNewStaff] = useState({fullName: '',role: 'Quản lí',phone: '',email: '',dob: '', gender: 'MALE'});
  
  const { mutate:mutateCreate, error : errorCreate } = useMutation({
    mutationFn: (newStaff) => StaffService.createStaff(newStaff),
    onSuccess: () => {
        setNewStaff({ fullName: '', role: '', phone: '', email: '', dob: '', gender: '' });
        // Làm mới danh sách nhân viên
        queryClient.invalidateQueries({ queryKey: ['staffs'] });
        queryClient.invalidateQueries({ queryKey: ['staffStats'] });
        setReportCreate('success')
      },
    onError: () => {
      setReportCreate('error')
    }, 
    onMutate: () => {
      setReportCreate('pending')
    }
  });
  const [reportCreate, setReportCreate] = useState("") 
  const hideReportCreate = () => {
    setReportCreate("");
  }
  
  const handleCreateStaff = () => mutateCreate(newStaff);
  
  const { mutate:mutateUpdate, error : errorUpdate } = useMutation({
    mutationFn: (selectedStaff) => StaffService.updateStaff(selectedStaff),
    onSuccess: () => {
        // Làm mới danh sách nhân viên
      
        queryClient.invalidateQueries({ queryKey: ['staffs'] });
        queryClient.invalidateQueries({ queryKey: ['staffStats'] });
        setReportUpdate('success')
      },
    onError: () => {
      setReportUpdate('error')
    }, 
    onMutate: () => {
      setReportUpdate('pending')
    }
  });
  const [reportUpdate, setReportUpdate] = useState("") 
  const hideReportUpdate = () => {
    setReportUpdate("");
  }
  const handleUpdateStaff = () => mutateUpdate(selectedStaff)
  const [showConfirm, setShowConfirm] = useState(false);

  return (
    <div className="w-full max-h-screen overflow-auto bg-slate-50 p-4 lg:p-4">
      <StatCards></StatCards>

      <div className="flex flex-col relative xl:flex-row gap-6"> 
        {/* 2. Bảng Danh Sách - Chiếm không gian lớn */}
        <div className="flex-1 flex flex-col min-h-[494px] bg-white 
        rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
          <StaffListHeader setRightPanelMode={setRightPanelMode} 
            filterParams={filterParams} setFilterParams={updateFilterParams}></StaffListHeader>
          
          <div className="flex-1 overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-slate-50/80 text-slate-500 text-[11px] uppercase tracking-widest font-bold"
                  
                >
                  <th className="px-4 py-2 text-center">Mã NV</th>
                  <th className="px-4 py-2 ">Họ Tên</th>
                  <th className="px-1 py-2 ">Chức vụ</th>
                  <th className="px-1 py-2 ">Số điện thoại</th>
                  <th className="px-1 py-2  text-center">Trạng thái</th>
                  <th className="px-1 py-2  text-center">Hành động</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {staffList.map((staff) => (
                  <tr key={staff.id} className="hover:bg-slate-50/50 transition-colors" >
                    <td className="px-4 py-2 font-bold text-slate-700 text-center">{staff.id}</td>
                    <td className="px-1 py-2 font-medium text-slate-800">{staff.fullName}</td>
                    <td className="px-1 py-2 text-slate-600 text-ms">{toVN(staff.role)}</td>
                    <td className="px-1 py-2 text-slate-500  text-ms">{staff.phone}</td>
                    <td className="px-1 py-2 text-center">
                      <StatusBadge type={staff.status} />
                    </td>
                    <td className="px-4 py-2">
                      <div className="flex justify-center gap-1">
                        <button className="py-2 px-1 text-orange-600 hover:bg-orange-50 rounded-lg transition-colors"
                          onClick={() => handleRowClick(staff)} ><BookUser size={21}/></button>
                        <button className="py-2 px-1 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors 
                            disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-transparent" 
                          disabled={staff.status === "ACTIVE" || staff.role == "MANAGER"}
                          onClick={() => {setSelectedStaff({...staff, status: "ACTIVE"}); setShowConfirm(true);}}><ShieldCheck size={21}/> </button>
                        <button className="py-2 px-1 text-rose-600 hover:bg-rose-50 rounded-lg transition-colors
                          disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-transparent"
                          disabled={staff.status === "BLOCKED" || staff.role == "MANAGER"}
                          onClick={() => {setSelectedStaff({...staff, status: "BLOCKED"}); setShowConfirm(true);}}><LockKeyhole size={21}/></button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            <ConfirmModal 
                view={"absolute"}
                isOpen={showConfirm}
                onClose={() => setShowConfirm(false)}
                onConfirm={handleUpdateStaff}
                title="Cập nhật thông tin"
                message={`Bạn có chắc chắn muốn ${selectedStaff.status === "BLOCKED" ? "khóa" : "kích hoạt"} tài khoản này?`}
                />
          </div>
            
          <Pagination page={filterParams.page} totalPages={totalPages} onPageChange={onPageChange}/>
        </div>

        <div className="w-full xl:w-[400px] relative">
            
            {/* Component Xem/Sửa: Luôn trong DOM, ẩn bằng CSS */}
            <div className={rightPanelMode === 'view' ? "block" : "hidden"}>
                
              
              <StaffInfo 
                selectedStaff={selectedStaff} 
                setSelectedStaff={setSelectedStaff}
                setRightPanelMode={setRightPanelMode}
                rightPanelMode = {rightPanelMode}
                handleUpdateStaff={handleUpdateStaff}
              />
            </div>

            {/* Component Tạo mới: Luôn trong DOM, ẩn bằng CSS */}
            <div className={`${rightPanelMode === 'create' ? "block" : "hidden"} relative overflow-hidden`}>
              
              
              <StaffCreate 
                newStaff={newStaff} 
                setNewStaff={setNewStaff}
                setRightPanelMode={setRightPanelMode}
                rightPanelMode = {rightPanelMode}
                handleCreateStaff = {handleCreateStaff}
                
              />
            </div>

            {/* Placeholder (Tùy chọn): Hiển thị khi không có mode nào để vùng 400px không bị trống trải */}
            {rightPanelMode === 'none' && (
              <div className="h-[490px] border-2 border-dashed border-slate-200 rounded-2xl flex items-center justify-center text-slate-400">
                Chọn một nhân viên để xem chi tiết
              </div>
            )}
        </div>
         {reportUpdate === "error" && <StatusModal type="error" message={errorUpdate.response.data.message} 
            onClose={hideReportUpdate}></StatusModal>}
          {reportUpdate === "pending" && <LoadingOverlay onClose={hideReportUpdate}></LoadingOverlay>}
          {reportUpdate === "success" && <StatusModal type="success" message={"Cập nhật thành công"} 
            onClose={hideReportUpdate}></StatusModal>}

          {reportCreate === "error" && <StatusModal type="error" message={errorCreate.response.data.message} 
              onClose={hideReportCreate}></StatusModal>}
          {reportCreate === "pending" && <LoadingOverlay onClose={hideReportCreate}></LoadingOverlay>}
          {reportCreate === "success" && <StatusModal type="success" message={"Đăng kí nhân viên thành công"} 
            onClose={hideReportCreate}></StatusModal>}
      </div>
    </div>
  );
};

// --- Sub-Components ---



const StatusBadge = ({ type }) => {
  const styles = {
    ACTIVE: { bg: 'bg-emerald-50', text: 'text-emerald-600', label: 'Đang hoạt động' },
    BLOCKED: { bg: 'bg-rose-50', text: 'text-rose-600', label: 'Đã khóa' },
    // pending: { bg: 'bg-slate-100', text: 'text-slate-600', label: 'Đang chờ' },
  };
  const s = styles[type] || styles.pending;
  return (
    <span className={`px-4 py-1.5 rounded-lg text-xs font-bold ${s.bg} ${s.text} border border-current/10`}>
      {s.label}
    </span>
  );
};





export default StaffManagement;