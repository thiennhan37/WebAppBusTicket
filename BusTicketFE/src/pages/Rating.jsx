import React from 'react';
import { Star, MessageSquare } from 'lucide-react';
import { useSearchParams } from 'react-router-dom';
import { keepPreviousData, useQuery } from '@tanstack/react-query';
import Pagination from '../components/other/Pagination';
import RatingService from '../Services/RatingService';

const ProgressBar = ({ label, value }) => {
  return (
    <div className='space-y-2'>
      <div className='flex items-center justify-between text-sm'>
        <span className='text-gray-700 font-medium'>{label}</span>
        <span className='text-gray-500'>{value.toFixed(1)}</span>
      </div>

      <div className='h-2.5 w-full rounded-full bg-gray-100 overflow-hidden'>
        <div
          className='h-full rounded-full bg-blue-600'
          style={{ width: `${(value / 5) * 100}%` }}
        />
      </div>
    </div>
  );
};

const SmallProgress = ({ label, value }) => {
  return (
    <div className='space-y-1'>
      <div className='flex items-center justify-between text-sm'>
        <span className='text-gray-700'>{label}</span>
        <span className='text-lime-600 font-semibold'>{value}</span>
      </div>

      <div className='h-2 rounded-full bg-gray-100 overflow-hidden'>
        <div
          className='h-full rounded-full bg-blue-600'
          style={{ width: `${(value / 5) * 100}%` }}
        />
      </div>
    </div>
  );
};

const ReviewCard = ({ review }) => {
  const date = new Date(review.createdAt);
  const formattedDate = !isNaN(date.getTime()) ? date.toLocaleDateString('vi-VN') : review.createdAt;

  return (
    <div className='bg-white rounded-3xl border border-gray-100 shadow-sm p-6 hover:shadow-lg transition-all duration-300'>
      <div className='flex flex-col lg:flex-row gap-8'>
        {/* Left */}
        <div className='flex-1'>
          <div className='flex items-start justify-between mb-4'>
            <div>
              <h3 className='font-semibold text-lg text-gray-800'>
                {review.customerName}
              </h3>

              <p className='text-sm text-gray-500 mt-1'>{review.routeName}</p>
            </div>

            <div className='flex items-center gap-1 bg-yellow-50 px-3 py-1 rounded-full'>
              <Star size={16} className='fill-yellow-400 text-yellow-400' />
              <span className='font-semibold text-gray-700'>
                {review.averageStars?.toFixed(1) || '0.0'}
              </span>
            </div>
          </div>

          <div className='flex items-center gap-1 mb-5'>
            {[...Array(Math.floor(review.averageStars || 0))].map((_, index) => (
              <Star
                key={index}
                size={18}
                className='fill-yellow-400 text-yellow-400'
              />
            ))}
          </div>

          <p className='text-gray-600 leading-7 mb-5'>{review.description ? review.description : ""}</p>

          <div className='flex items-center justify-between'>
            <span className='text-sm text-gray-400'>
              Đánh giá ngày {formattedDate}
            </span>

            {/* <button className='flex items-center gap-2 text-sm bg-blue-50 hover:bg-blue-100 text-blue-600 px-4 py-2 rounded-xl transition'>
              <MessageSquare size={16} />
              Trả lời
            </button> */}
          </div>
        </div>

        {/* Right */}
        <div className='lg:w-[320px] grid grid-cols-1 gap-4'>
          <SmallProgress
            label='Chất lượng dịch vụ'
            value={review.serviceQuality}
          />

          <SmallProgress
            label='Đúng giờ'
            value={review.punctuality}
          />

          <SmallProgress
            label='An toàn'
            value={review.safety}
          />

          <SmallProgress
            label='Sạch sẽ'
            value={review.cleanliness}
          />
        </div>
      </div>
    </div>
  );
};

export default function Rating() {
  const [searchParams, setSearchParams] = useSearchParams();

  const page = Number(searchParams.get('page')) || 1;
  const selectedRating = searchParams.get('selectedRating') || 'all';
  const sortStar = searchParams.get('sortStar') || 'averageStars,desc';
  const sortTime = searchParams.get('sortTime') || 'createdAt,desc';

  const updateFilter = ({ field, value }) => {
    const currentParams = new URLSearchParams(searchParams);
    if (value) currentParams.set(field, value);
    else currentParams.delete(field);
    
    if (field !== 'page') currentParams.set('page', 1);
    setSearchParams(currentParams);
  };

  const { data: ratingStats } = useQuery({
    queryKey: ['ratingStats'],
    queryFn: async () => {
      const response = await RatingService.getCompanyRating();
      return response.data?.result || {};
    }
  });

  const { data: pageData } = useQuery({
    queryKey: ['ratingList', page, selectedRating, sortStar, sortTime],
    queryFn: async () => {
      const response = await RatingService.getRatingPage({
        page,
        size: 3,
        sortStar,
        sortTime,
        selectedRating
      });
      return response.data?.result || { content: [], page: { totalPages: 1 } };
    },
    placeholderData: keepPreviousData,
  });

  const totalPage = pageData?.page?.totalPages || 1;
  const ratingPage = pageData?.content || [];

  const onPageChange = (newPage) => {
    updateFilter({ field: "page", value: newPage });
  };

  return (
    <div className='min-h-screen bg-[#f5f7fb] py-5 px-4'>
      <div className='max-w-7xl mx-auto'>
        {/* Header */}
        <div className='bg-white rounded-[32px] shadow-sm border border-gray-100 p-8 lg:p-10'>
          <div className='flex flex-col xl:flex-row gap-10'>
            {/* Rating Circle */}
            <div className='flex flex-col items-center justify-center min-w-[170px]'>
              <div className='relative w-36 h-36 rounded-full border-[10px] border-blue-500 flex items-center justify-center'>
                <div className='text-center'>
                  <h2 className='text-4xl font-bold text-gray-800'>
                    {ratingStats?.averageStars?.toFixed(1) || '0.0'}
                  </h2>

                  <div className='flex justify-center mt-2 gap-1'>
                    {[...Array(5)].map((_, i) => (
                      <Star
                        key={i}
                        size={14}
                        className='fill-yellow-400 text-yellow-400'
                      />
                    ))}
                  </div>
                </div>
              </div>

              <p className='mt-5 text-gray-600 font-medium'>
                {ratingStats?.ratingCount || 0} đánh giá
              </p>
            </div>

            {/* Overview */}
            <div className='flex-1 grid grid-cols-1 md:grid-cols-2 gap-8'>
              <div className='space-y-6'>
                <ProgressBar label='Chất lượng dịch vụ' value={ratingStats?.serviceQualityAvg || 0} />
                <ProgressBar label='Đúng giờ' value={ratingStats?.punctualityAvg || 0} />
              </div>

              <div className='space-y-6'>
                <ProgressBar label='An toàn' value={ratingStats?.safetyAvg || 0} />
                <ProgressBar label='Sạch sẽ' value={ratingStats?.cleanlinessAvg || 0} />
              </div>
            </div>
          </div>

          {/* Filters */}
          <div className='mt-10 flex flex-col lg:flex-row gap-4 lg:items-center lg:justify-end'>
            <div className='flex flex-col sm:flex-row gap-4'>
              <div className='flex items-center gap-3'>
                <span className='text-sm font-medium text-gray-700 whitespace-nowrap'>
                  Đánh giá theo
                </span>

                <select
                  value={selectedRating}
                  onChange={e => updateFilter({ field: 'selectedRating', value: e.target.value })}
                  className='h-9 rounded-2xl border border-gray-200 bg-white pr-4 pl-2 text-sm outline-none focus:ring-2 focus:ring-blue-500'
                > 
                  <option value='all'>Tất cả</option>
                  <option value='5'>5 sao</option>
                  <option value='4'>4 sao</option>
                  <option value='3'>3 sao</option>
                  <option value='2'>2 sao</option>
                  <option value='1'>1 sao</option>
                </select>
              </div>

              <div className='flex items-center gap-3'>
                <span className='text-sm font-medium text-gray-700 whitespace-nowrap'>
                  Điểm số
                </span>
                <select
                  value={sortStar}
                  onChange={e => updateFilter({ field: 'sortStar', value: e.target.value })}
                  className='h-9 rounded-2xl border border-gray-200 bg-white px-4 pl-2 text-sm outline-none focus:ring-2 focus:ring-blue-500'
                >
                  <option value='averageStars,desc'>Điểm cao nhất</option>
                  <option value='averageStars,asc'>Điểm thấp nhất</option>
                </select>
              </div>

              <div className='flex items-center gap-3'>
                <span className='text-sm font-medium text-gray-700 whitespace-nowrap'>
                  Thời gian
                </span>
                <select
                  value={sortTime}
                  onChange={e => updateFilter({ field: 'sortTime', value: e.target.value })}
                  className='h-9 rounded-2xl border border-gray-200 bg-white px-4 pl-2 text-sm outline-none focus:ring-2 focus:ring-blue-500'
                >
                  <option value='createdAt,desc'>Mới nhất</option>
                  <option value='createdAt,asc'>Cũ nhất</option>
                </select>
              </div>

            </div>
          </div>
        </div>

        {/* Reviews */}
        <div className='mt-8 space-y-6'>
          {ratingPage.map(review => (
            <ReviewCard key={review.id} review={review} />
          ))}
        </div>

        {/* Pagination */}
        <div className='mt-8'>
          <Pagination page={page} onPageChange={onPageChange} totalPages={totalPage} />
        </div>

      </div>
    </div>
  );
}