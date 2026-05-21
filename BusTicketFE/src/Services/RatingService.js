import api from "./api";

const RatingService = {
    getCompanyRating(){
        return api.get("/nhaxe/rating");
    },
    getRatingPage(filterParams){
        const { page, size, sortStar, sortTime, selectedRating } = filterParams;
        const params = new URLSearchParams();
        
        params.append('page', (page - 1).toString());
        params.append('size', (size || 3).toString());
        
        if (sortStar) {
            params.append('sort', sortStar);
        }
        if (sortTime) {
            params.append('sort', sortTime);
        } 



        if (selectedRating && selectedRating !== 'all') {
            params.append('avgStars', selectedRating);
        }

        return api.get("/nhaxe/rating-page", { params });
    }
}

export default RatingService;
