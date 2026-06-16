import React, { useState, useRef, useContext, useEffect } from 'react';
import { 
  Star, Ticket, Users, Bus
} from 'lucide-react';
import OverviewHeader from './OverViewHeader';
import CompanyAvatar from './CompanyAvatar';
import DetailedForm from './DetailedForm';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import AuthContext from '../../context/AuthContext';
import BusCompanyService from '../../Services/BusCompanyService';
import { toast } from 'sonner';
import LoadingOverlay from '../../components/other/LoadingOverlay';


const Overview = () => {
    console.log("reload overview");
  const [isEditing, setIsEditing] = useState(false);
  const queryClient = useQueryClient();
  const { user, company } = useContext(AuthContext);
  const [avatarFile, setAvatarFile] = useState(null);
  
  const { data, isLoading, error } = useQuery({
    queryKey: ['busCompany', company?.id],
    queryFn: async () => {
      const res = await BusCompanyService.getBusCompanyById(company.id);
      return res.data.result;
    },
    enabled: !!company?.id, // chỉ chạy khi có company.id
    refetchOnMount: true,
  });

  const [busCompany, setBusCompany] = useState({});
  const [formData, setFormData] = useState({});
  const [report, setReport] = useState("");

  useEffect(() => {
    if (data) {
      setBusCompany(data);
      setFormData(data);
    }
  }, [data]);
  const handleEdit = () => {
    setIsEditing(true);
  };

  const handleCancel = () => {
    setAvatarFile(null);
    setFormData(busCompany);
    setIsEditing(false);
  };


  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const formatDate = (dateString) => {
    const options = { year: 'numeric', month: 'long', day: 'numeric' };
    return new Date(dateString).toLocaleDateString('vi-VN', options);
  };

  const fileInputRef = useRef(null);
  
  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      // Kiểm tra định dạng (tùy chọn)
      if (!file.type.startsWith('image/')) {
        toast.error('Vui lòng chọn file hình ảnh!');
        e.target.value = null;
        return;
      }
      setAvatarFile(file);
      // Tạo URL tạm thời để preview
      const previewUrl = URL.createObjectURL(file);
      setFormData(prev => ({ ...prev, avatarUrl: previewUrl }));
    }
    e.target.value = null;
  };

  const triggerFileSelect = () => {
    if (isEditing) fileInputRef.current.click();
  };
  const {mutate:updateCompany} = useMutation({
    mutationFn: async () => {
      const params = {policy: formData.policy, avatarFile}
      const res = await BusCompanyService.updateBusCompany({companyId: company.id, params});
      return res.data;  
    },
    onSuccess: () => {
      queryClient.invalidateQueries(['busCompany', company.id]);
      toast.success('Cập nhật thông tin thành công!');
      setReport("");
      setIsEditing(false);
    },
    onError: (error) => {
      toast.error('Cập nhật thông tin thất bại!');
      console.log(error.message);
      setReport("");
    }, 
    onMutate: () => {
      setReport("pending");
    }
  });

  return (
    <div className="min-h-screen bg-slate-50 p-4 md:p-8 text-slate-900 font-sans">
      <div className="max-w-7xl mx-auto space-y-6">
        {report === "pending" && <LoadingOverlay />}
        <OverviewHeader 
          isEditing={isEditing}
          handleEdit={handleEdit}
          handleCancel={handleCancel}
          handleUpdate={updateCompany}/>

        {/* Stats Section */}
        {/* <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {statsData.map((stat, index) => (
            <div 
              key={index} 
              className={`${stat.over_bg} p-5 rounded-2xl border border-slate-100 shadow-sm hover:shadow-md transition-shadow duration-300 group`}
            >
              <div className="flex items-center gap-4">
                <div className={`p-3 rounded-xl ${stat.bg} ${stat.color} group-hover:scale-110 transition-transform duration-300`}>
                  <stat.icon className="w-6 h-6" />
                </div>
                <div>
                  <p className="text-sm text-slate-800 font-medium">{stat.label}</p>
                  <h3 className="text-2xl font-bold text-white mt-0.5">{stat.value}</h3>
                </div>
              </div>
            </div>
          ))}
        </div> */}

        {/* Main Content Split Layout */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
           
          {/* Left Column: Avatar & Quick Info */}
          <CompanyAvatar formData={formData} formatDate={formatDate} 
            triggerFileSelect={triggerFileSelect} fileInputRef={fileInputRef} 
            handleFileChange={handleFileChange} isEditing={isEditing} />

          {/* Right Column: Detailed Form */}
          <DetailedForm
            formData={formData}
            isEditing={isEditing}
            handleChange={handleChange}
          />
        </div>
      </div>
    </div>
  );
};

export default Overview;