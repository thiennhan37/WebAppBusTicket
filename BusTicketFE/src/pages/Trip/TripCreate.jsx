import { X } from "lucide-react";
import React, { useEffect, useState } from "react";
import InputGroup from "../../components/other/InputGroup";
import SearchRoutes from "./SearchRoutes";
import BusService from "../../Services/BusService";
import ConfirmModal from "../../components/other/ConfirmModal";
import TripService from "../../Services/TripService";
import { useQueryClient, useMutation } from "@tanstack/react-query";
import StatusModal from "../../components/other/StatusModal"
import SeatDiagram from "../../components/other/SeatDiagram";
const TripCreate = ({ setIsAddModalOpen}) => {
  
  const [newTrip, setNewTrip] = useState({route: null, licensePlate: "", driver: "", 
    busType: {id:"", name:""}, price: 0})
  const handleNewTrip = (field, value) => {
    setNewTrip((prev) => ({
      ...prev, 
      [field]: value
    }))
  }
  const [busTypeList, setBusTypeList] = useState([]);
  useEffect(() => {
    const loadBusType = async () => {
      try {
          const result = (await BusService.getBusTypeList())?.data?.result || [];
          setBusTypeList(result);
      } catch (error) {
        console.log(error);
      }
    }
    loadBusType();
  }, []);

  const [reportCreate, setReportCreate] = useState("") 
  const [showConfirm, setShowConfirm] = useState(false);
  const queryClient = useQueryClient();

  const { mutate:mutateCreate } = useMutation({
    mutationFn: (newTrip) =>{
        return TripService.createTrip(newTrip);
    }, 
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tripList'] });
        setReportCreate('success')
      },
    onError: (error) => {
      console.log("error in create trip", error.response);
      setReportCreate("error: " + error.response?.data?.message);
    }
  });
  
  const hideReportCreate = () => {
    if(reportCreate === "success") setIsAddModalOpen(false);
    setReportCreate("");
  }
  const handleCreateTrip = () => mutateCreate(newTrip);
  

  return ( 
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-sm animate-in fade-in duration-200">
        <ConfirmModal 
              view={"absolute"}
              isOpen={showConfirm}
              onClose={() => setShowConfirm(false)}
              onConfirm={handleCreateTrip}
              title="Thêm chuyến đi mới"
              message={`Bạn có chắc chắn muốn lưu chuyến đi vào hệ thống?`}
            />
          {reportCreate.startsWith("error") && <StatusModal type="error" message={reportCreate.split(":")[1]} 
              onClose={hideReportCreate}></StatusModal>}
          {reportCreate === "success" && <StatusModal type="success" message={"Lưu chuyến đi thành công"} 
            onClose={hideReportCreate}></StatusModal>}
        <div className="bg-white rounded-3xl shadow-2xl w-[750px] h-[1300px] overflow-hidden flex flex-col max-h-[90vh]">
          
          <div className="flex items-center justify-between p-6 border-b border-slate-100">
            <h2 className="text-xl font-bold text-slate-900">Thêm chuyến đi mới</h2>
            <button 
              onClick={() => setIsAddModalOpen(false)}
              className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
            >
              <X size={20} />
            </button>
          </div>

          <div className="p-6 overflow-y-auto ">
            <form className="flex gap-4">
              
              <div className="flex-1 flex flex-col gap-3">
                <SearchRoutes onChange={handleNewTrip} field={"route"} 
                  label="Tuyến đường" placeholder="Tìm kiếm"></SearchRoutes>

                <InputGroup label="Thời gian khởi hành" type="datetime-local" value={newTrip.departureTime}
                  onChange={(e) => handleNewTrip("departureTime", e.target.value)}/> 

                <InputGroup label="Giá vé" type="number" value={newTrip.price}
                  onChange={(e) => handleNewTrip("price", Number(e.target.value))}/> 
                <InputGroup label="Mã số phương tiện" type="text" value={newTrip.licensePlate}
                  onChange={(e) => handleNewTrip("licensePlate", e.target.value.trimStart())}/> 
                <InputGroup label="Tài xế" type="text" value={newTrip.driver}
                  onChange={(e) => handleNewTrip("driver", e.target.value.trimStart())}/> 
              </div>
              
              <div className="w-[340px] h-[400px] flex-0.8 flex flex-col">
                <InputGroup label="Loại phương tiện" type="select" options={busTypeList} placeholder={"Chọn loại phương tiện"}
                  value={newTrip.busType.name} onChange={(e) => {
                    const selectedName =  e.target.value;
                    const busType = busTypeList.find(bus => bus.name === selectedName) || {id:"", name:"", diagram:""};
                    handleNewTrip('busType', busType);
                  }} />
                  {newTrip?.busType?.diagram ? 
                    <SeatDiagram diagram={newTrip.busType.diagram}></SeatDiagram>
                    : <div>
                      </div>
                  }
              </div>
              
            
              
            </form>
          </div>
          
          <p className="text-[13px] text-center text-gray-400 italic">
            * Vui lòng chọn tuyến đường, loại phương tiện, giá vé và thời gian khởi hành để hoàn tất
          </p>
          <div className="p-6 border-t border-slate-100 bg-slate-50 flex justify-end gap-3 rounded-b-3xl">
            <button 
              onClick={() => setIsAddModalOpen(false)}
              className="px-5 py-2.5 text-sm font-medium text-slate-600 bg-white border border-slate-200 rounded-xl hover:bg-slate-50 transition-colors"
            >
              Hủy bỏ
            </button>
            <button className="px-5 py-2.5 text-sm font-medium text-white bg-emerald-600 rounded-xl hover:bg-emerald-700 transition-colors 
              shadow-sm shadow-emerald-600/20 disabled:bg-gray-200 disabled:text-gray-400 disabled:cursor-not-allowed" 
              disabled={!(newTrip?.busType?.id && newTrip?.route?.id && newTrip?.departureTime && newTrip?.price)}
              onClick={() => setShowConfirm(true)}>
              Lưu chuyến đi
            </button>
          </div>
        </div>
    </div>
  );
};

export default TripCreate;
