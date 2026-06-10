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
import * as XLSX from 'xlsx';
import { toast } from 'sonner';

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

  const [newStaff, setNewStaff] = useState({fullName: '',role: 'Quản lí',phone: '',email: '',dob: '', gender: 'Nam'});
  
  const { mutate:mutateCreate, error : errorCreate } = useMutation({
    mutationFn: (newStaff) => StaffService.createStaff(newStaff),
    onSuccess: () => {
        setNewStaff({ fullName: '', role: 'Quản lí', phone: '', email: '', dob: '', gender: 'Nam' });
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
  
  const [isImporting, setIsImporting] = useState(false);
  const [excelFile, setExcelFile] = useState(null);
  const [excelPreviewData, setExcelPreviewData] = useState(null);
  const [showPreviewModal, setShowPreviewModal] = useState(false);

  const { mutate: mutateImportExcel } = useMutation({
    mutationFn: async(file) => {
      const response = await StaffService.importStaffExcel(file);
      const result = response.data.result;
      if(result.line !== 0) throw new Error(result.message + " - lỗi tại dòng: " + result.line);
      console.log("result import excel: ", result);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['staffs'] });
      queryClient.invalidateQueries({ queryKey: ['staffStats'] });
      toast.success("Import nhân viên thành công!");
      setShowPreviewModal(false);
      setExcelFile(null);
      setExcelPreviewData(null);
    },
    onError: (error) => {
      toast.error(error.response?.data?.message || error.message || "Có lỗi xảy ra khi import file!");
    },
    onMutate: () => {
      setIsImporting(true);
    },
    onSettled: () => {
      setIsImporting(false);
    }
  });
  

  const handleDownloadSample = () => {
    const ws = XLSX.utils.json_to_sheet([
      {
        "STT": 1, 
        "Họ Tên": "Nguyễn Văn A",
        "Email": "nguyenvana@gmail.com",
        "Số điện thoại": "0123456789", 
        "Chức vụ": "STAFF",   
        "Giới tính": "MALE", 
        "Ngày sinh": "mm/dd/yyyy"
      }
    ]);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Nhân sự");
    XLSX.writeFile(wb, "Mau_Them_Nhan_Vien.xlsx");
  };

  const handleImportExcel = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = async (event) => {
      try {
        const data = new Uint8Array(event.target.result);
        const workbook = XLSX.read(data, { type: 'array' });
        const sheetName = workbook.SheetNames[0];
        const worksheet = workbook.Sheets[sheetName];
        const jsonData = XLSX.utils.sheet_to_json(worksheet, { raw: false, dateNF: 'yyyy-mm-dd' });
        
        setExcelPreviewData(jsonData);
        setExcelFile(file);
        setShowPreviewModal(true);
      } catch (error) {
         toast.error('Lỗi khi đọc file Excel!');
      } finally {
        e.target.value = null; // reset file input
      }
    };
    reader.readAsArrayBuffer(file);
  };

  return (
    <div className="w-full max-h-screen overflow-auto bg-slate-50 p-4 lg:p-4">
      {isImporting && <LoadingOverlay onClose={() => setIsImporting(false)}></LoadingOverlay>}
      <StatCards></StatCards>

      <div className="flex flex-col relative xl:flex-row gap-6"> 
        {/* 2. Bảng Danh Sách - Chiếm không gian lớn */}
        <div className="flex-1 flex flex-col min-h-[494px] bg-white 
        rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
          <StaffListHeader setRightPanelMode={setRightPanelMode} 
            filterParams={filterParams} setFilterParams={updateFilterParams}
            handleImportExcel={handleImportExcel} handleDownloadSample={handleDownloadSample}
          ></StaffListHeader>
          
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

      {showPreviewModal && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center bg-slate-900/50 backdrop-blur-sm">
          <div className="bg-white rounded-2xl shadow-xl w-full max-w-5xl max-h-[90vh] flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">
            <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50/50">
              <div>
                <h3 className="text-xl font-bold text-slate-800">Xem trước dữ liệu Import</h3>
                <p className="text-sm text-slate-500 mt-1">Vui lòng kiểm tra lại thông tin trước khi xác nhận nhập dữ liệu.</p>
              </div>
              <button onClick={() => setShowPreviewModal(false)} className="w-8 h-8 flex items-center justify-center rounded-full bg-slate-100 text-slate-500 hover:bg-slate-200 hover:text-slate-700 transition-colors">
                ✕
              </button>
            </div>
            
            <div className="flex-1 overflow-auto p-6 bg-slate-50">
              <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
                <table className="w-full text-left text-sm">
                  <thead className="bg-slate-50/80 text-slate-600 font-medium">
                    <tr>
                      <th className="px-4 py-3 border-b border-slate-200 text-center">STT</th>
                      <th className="px-4 py-3 border-b border-slate-200">Họ Tên</th>
                      <th className="px-4 py-3 border-b border-slate-200">Chức vụ</th>
                      <th className="px-4 py-3 border-b border-slate-200">Số điện thoại</th>
                      <th className="px-4 py-3 border-b border-slate-200">Email</th>
                      <th className="px-4 py-3 border-b border-slate-200">Ngày sinh</th>
                      <th className="px-4 py-3 border-b border-slate-200">Giới tính</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {excelPreviewData?.map((row, index) => (
                      <tr key={index} className="hover:bg-slate-50/50 transition-colors">
                        <td className="px-4 py-3 text-center font-medium text-slate-500">{row["STT"] || index + 1}</td>
                        <td className="px-4 py-3 font-medium text-slate-800">{row["Họ Tên"] || row["fullName"] || row["Họ và Tên"]}</td>
                        <td className="px-4 py-3 text-slate-600">
                           <span className="px-2.5 py-1 bg-slate-100 rounded-md text-xs font-medium text-slate-600">{row["Chức vụ"] || row["role"]}</span>
                        </td>
                        <td className="px-4 py-3 text-slate-600">{row["Số điện thoại"] || row["phone"]}</td>
                        <td className="px-4 py-3 text-slate-600">{row["Email"] || row["email"]}</td>
                        <td className="px-4 py-3 text-slate-600">{row["Ngày sinh"] || row["dob"]}</td>
                        <td className="px-4 py-3 text-slate-600">{row["Giới tính"] || row["gender"]}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
            
            <div className="px-6 py-4 border-t border-slate-100 flex justify-end gap-3 bg-white">
              <button 
                className="px-5 py-2.5 rounded-xl font-medium text-slate-600 bg-slate-100 hover:bg-slate-200 transition-colors"
                onClick={() => setShowPreviewModal(false)}
              >
                Hủy
              </button>
              <button 
                className="px-6 py-2.5 rounded-xl font-medium text-white bg-blue-600 hover:bg-blue-700 transition-colors shadow-lg shadow-blue-100 flex items-center gap-2"
                onClick={() => mutateImportExcel(excelFile)}
              >
                Xác nhận Import ({excelPreviewData?.length || 0} mục)
              </button>
            </div>
          </div>
        </div>
      )}
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