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
const TripUpdate = ({selectedTrip, setSelectedTrip,  setIsUpdateOpen}) => {
  // console.log(selectedTrip);
  // const [selectedTrip, setselectedTrip] = useState({route: null, licensePlate: "", driver: "", 
  //   busType: {id:"", name:""}, price: null})
  const handleSelectedTrip = (field, value) => {
    setSelectedTrip((prev) => ({
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
          if(result){
            const busType = result.find(bus => bus.name === selectedTrip.busType.name) || null;
            if(busType) handleSelectedTrip('busType', busType);
          }
      } catch (error) {
        console.log(error);
      }
    }
    loadBusType();
  }, []);

  const queryClient = useQueryClient();
  const [reportUpdate, setReportUpdate] = useState("") 
  const [showConfirm, setShowConfirm] = useState(false);
  const hideReportUpdate = () => {
    if(reportUpdate === "success") setIsUpdateOpen(false);
    setReportUpdate("");
  }
 
  const { mutate:mutateUpdate } = useMutation({
    mutationFn: (selectedTrip) =>{
        return TripService.updateTrip(selectedTrip);
    }, 
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tripList'] });
        setReportUpdate('success')
      },
    onError: () => {
      setReportUpdate('error')
    }
  });

  return ( 
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-sm animate-in fade-in duration-200">
        <ConfirmModal 
              view={"absolute"}
              isOpen={showConfirm}
              onClose={() => setShowConfirm(false)}
              onConfirm={() => mutateUpdate(selectedTrip)}
              title={`Cập nhật chuyến đi ${selectedTrip.id}`}
              message={`Bạn có chắc chắn muốn cập nhật thông tin chuyến đi?`}
            />
          {reportUpdate === "error" && <StatusModal type="error"  
              onClose={hideReportUpdate}></StatusModal>}
          {reportUpdate === "success" && <StatusModal type="success" message={"Lưu chuyến đi thành công"} 
            onClose={hideReportUpdate}></StatusModal>}
            
        <div className="bg-white rounded-3xl shadow-2xl w-[750px] h-[1300px] overflow-hidden flex flex-col max-h-[90vh]">
          
          <div className="flex items-center justify-between p-6 border-b border-slate-100">
            <h2 className="text-xl font-bold text-slate-900">Cập nhật chuyến đi</h2>
            <button 
              onClick={() => setIsUpdateOpen(false)}
              className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
            >
              <X size={20} />
            </button>
          </div>

          <div className="p-6 overflow-y-auto ">
            <form className="flex gap-4">
              
              <div className="flex-1 flex flex-col gap-3">
                <SearchRoutes onChange={handleSelectedTrip} field={"route"} disabled={selectedTrip.status === "OPEN"}
                  label="Tuyến đường" placeholder="Tìm kiếm" initialValue={selectedTrip.route.name}></SearchRoutes>
                
                <InputGroup label="Thời gian khởi hành" type="datetime-local" value={selectedTrip.departureTime} 
                  onChange={(e) => handleSelectedTrip("departureTime", e.target.value)} disabled={selectedTrip.status === "OPEN"}/> 
                
                <InputGroup label="Giá vé" type="number" value={selectedTrip.price}
                  onChange={(e) => handleSelectedTrip("price", Number(e.target.value))}/> 
                <InputGroup label="Mã số phương tiện" type="text" value={selectedTrip.licensePlate}
                  onChange={(e) => handleSelectedTrip("licensePlate", e.target.value.trimStart())}/> 
                <InputGroup label="Tài xế" type="text" value={selectedTrip.driver}
                  onChange={(e) => handleSelectedTrip("driver", e.target.value.trimStart())}/> 
              </div>
              
              <div className="w-[340px] h-[400px] flex-0.8 flex flex-col">
                <InputGroup label="Loại phương tiện" type="select" options={busTypeList} placeholder={"Chọn loại phương tiện"}
                  disabled={selectedTrip.status === "OPEN"}
                  value={selectedTrip?.busType?.name} onChange={(e) => {
                    const selectedName =  e.target.value;
                    const busType = busTypeList.find(bus => bus.name === selectedName) || {id:"", name:"", diagram:""};
                    handleSelectedTrip('busType', busType);
                  }} />
                  {selectedTrip?.busType?.diagram ? 
                    <SeatDiagram diagram={selectedTrip.busType.diagram}></SeatDiagram>
                    : <></>
                  }
              </div>
            </form>
          </div>
          
          <p className="text-[13px] text-center text-gray-400 italic">
            * Vui lòng chọn tuyến đường, loại phương tiện, giá vé và thời gian khởi hành để hoàn tất
          </p>
          <div className="p-6 border-t border-slate-100 bg-slate-50 flex justify-end gap-3 rounded-b-3xl">
            <button 
              onClick={() => setIsUpdateOpen(false)}
              className="px-5 py-2.5 text-sm font-medium text-slate-600 bg-white border border-slate-200 rounded-xl hover:bg-slate-50 transition-colors"
            >
              Hủy bỏ
            </button>
            <button className="px-5 py-2.5 text-sm font-medium text-white bg-emerald-600 rounded-xl hover:bg-emerald-700 transition-colors 
              shadow-sm shadow-emerald-600/20 disabled:bg-gray-200 disabled:text-gray-400 disabled:cursor-not-allowed" 
              disabled={!(selectedTrip?.busType?.id && selectedTrip?.route?.id && selectedTrip?.departureTime && selectedTrip?.price)}
              onClick={() => setShowConfirm(true)}>
              Cập nhật chuyến đi
            </button>
          </div>
        </div>
    </div>
  );
};

export default TripUpdate;
