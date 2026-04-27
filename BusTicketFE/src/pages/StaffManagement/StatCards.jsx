import { Users, Tickets, UserCog, LockKeyhole } from "lucide-react";
import StatCard from "../../components/other/StatCard";
import StaffService from "../../Services/StaffService";
import { useQuery } from "@tanstack/react-query";
import LoadingOverlay from "../../components/other/LoadingOverlay";
const StatCards = () =>{

  const { data: info, isLoading, isError } = useQuery({
    queryKey: ['staffStats'], 
    queryFn: async () => {
      // console.log("Fetching staff stats...");
      const staffsCount = (await StaffService.getStaff({status: "Đang hoạt động", role: "Nhân viên"})).data.result.page.totalElements;
      const managersCount = (await StaffService.getStaff({status: "Đang hoạt động", role: "Quản lí"})).data.result.page.totalElements;
      const lockedAccountsCount = (await StaffService.getStaff({status: "Đã khóa"})).data.result.page.totalElements;
      // console.log("Staff stats: ", {staffsCount, managersCount, lockedAccountsCount});
      return {
        totalStaff: staffsCount + managersCount,
        staffsCount,
        managersCount,
        lockedAccountsCount
      };
    },
    staleTime: 0, 
  });
    return (
      <div className="relative">
        {isLoading || isError ? <div /> :
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-10 mb-4">
            <StatCard title="Tổng Nhân viên" count={info.totalStaff} icon={<Users />} colorClass="bg-blue-600" textColor="text-white" />
            <StatCard title="Nhân viên bán vé" count={info.staffsCount} icon={<Tickets />} colorClass="bg-emerald-500" textColor="text-white" />
            <StatCard title="Quản lí" count={info.managersCount} icon={<UserCog />} colorClass="bg-amber-500" textColor="text-white" />
            <StatCard title="Tài khoản bị khóa" count={info.lockedAccountsCount} icon={<LockKeyhole />} colorClass="bg-rose-500" textColor="text-white"/>
          </div>
        }
      </div>
    )
}

export default StatCards