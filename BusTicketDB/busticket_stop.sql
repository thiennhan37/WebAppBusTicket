-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: busticket
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `stop`
--

DROP TABLE IF EXISTS `stop`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stop` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) NOT NULL,
  `Address` varchar(255) NOT NULL,
  `Province_ID` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `Province_ID` (`Province_ID`),
  CONSTRAINT `stop_ibfk_1` FOREIGN KEY (`Province_ID`) REFERENCES `province` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stop`
--

LOCK TABLES `stop` WRITE;
/*!40000 ALTER TABLE `stop` DISABLE KEYS */;
INSERT INTO `stop` VALUES (1,'Bến xe Miền Đông mới','Số 501 Hoàng Hữu Nam, Phường Long Bình, TP. Thủ Đức, TP. HCM','HCM'),(2,'Bến xe Miền Đông cũ','Số 292 Đinh Bộ Lĩnh, Phường 26, Quận Bình Thạnh, TP. HCM','HCM'),(3,'Bến xe Miền Tây','Số 395 Kinh Dương Vương, Phường An Lạc, Quận Bình Tân, TP. HCM','HCM'),(4,'Bến xe An Sương','Quốc Lộ 22, Xã Bà Điểm, Huyện Hóc Môn, TP. HCM','HCM'),(5,'Bến xe Ngã Tư Ga','Số 720 Quốc Lộ 1A, Phường Thạnh Lộc, Quận 12, TP. HCM','HCM'),(6,'Văn phòng Tân Bình (Nhà xe Tiến Oanh)','Số 266 Đồng Đen, Phường 10, Quận Tân Bình, TP. HCM','HCM'),(7,'Trạm xe Phương Trang Lê Hồng Phong','Số 233 Lê Hồng Phong, Phường 4, Quận 5, TP. HCM','HCM'),(8,'Văn phòng Hàng Xanh (Nhà xe Kumho Samco)','Số 491L Điện Biên Phủ, Phường 25, Quận Bình Thạnh, TP. HCM','HCM'),(9,'Bến xe phía Bắc Buôn Ma Thuột','Số 71 Nguyễn Chí Thanh, Phường Tân An, TP. Buôn Ma Thuột, Đắk Lắk','DLK'),(10,'Bến xe phía Nam Buôn Ma Thuột','Võ Văn Kiệt, Phường Khánh Xuân, TP. Buôn Ma Thuột, Đắk Lắk','DLK'),(11,'Bến xe liên tỉnh Đắk Lắk','Km 4 + 500 Nguyễn Chí Thanh, Phường Tân An, TP. Buôn Ma Thuột, Đắk Lắk','DLK'),(12,'Bến xe Buôn Hồ','Số 406 Hùng Vương, Phường An Bình, TX. Buôn Hồ, Đắk Lắk','DLK'),(13,'Bến xe Ea Kar','Km 52, Quốc lộ 26, Thị trấn Ea Kar, Huyện Ea Kar, Đắk Lắk','DLK'),(14,'Văn phòng Hai Bà Trưng (Nhà xe Tiến Oanh)','Số 134 Hai Bà Trưng, Phường Thắng Lợi, TP. Buôn Ma Thuột, Đắk Lắk','DLK'),(15,'Coop Mart Buôn Ma Thuột (Điểm đón)','Số 71 Nguyễn Tất Thành, Phường Tân An, TP. Buôn Ma Thuột, Đắk Lắk','DLK'),(16,'Bến xe Quảng Ngãi','Số 02 Trần Khánh Dư, Phường Nghĩa Chánh, TP. Quảng Ngãi, Quảng Ngãi','QNG'),(17,'Bến xe Chợ Chùa','Thị trấn Chợ Chùa, Huyện Nghĩa Hành, Quảng Ngãi','QNG'),(18,'Bến xe Đức Phổ','Khối 5, Thị trấn Đức Phổ, Huyện Đức Phổ, Quảng Ngãi','QNG'),(19,'Văn phòng Quảng Ngãi (Nhà xe Chín Nghĩa)','Số 06 Hà Huy Tập, Phường Nghĩa Chánh, TP. Quảng Ngãi, Quảng Ngãi','QNG'),(20,'Bến xe Trà Bồng','Thị trấn Trà Xuân, Huyện Trà Bồng, Quảng Ngãi','QNG'),(21,'Trạm xe Thành Bưởi Xa Lộ Hà Nội','Số 97 Xa lộ Hà Nội, Phường Hiệp Phú, TP. Thủ Đức, TP. HCM','HCM'),(22,'Cổng Đại học Nông Lâm (Điểm đón)','Quốc lộ 1A, Phường Linh Trung, TP. Thủ Đức, TP. HCM','HCM'),(23,'Văn phòng An Sương (Nhà xe Phương Trang)','Số 14 Quốc Lộ 22, Xã Bà Điểm, Huyện Hóc Môn, TP. HCM','HCM'),(24,'Bến xe Sơn Hà','Thị trấn Di Lăng, Huyện Sơn Hà, Quảng Ngãi','QNG'),(25,'Văn phòng Quảng Ngãi (Nhà xe Mai Linh)','Số 02 Cao Bá Quát, Phường Nghĩa Chánh, TP. Quảng Ngãi, Quảng Ngãi','QNG'),(26,'Ngã ba Dốc Sỏi (Bình Sơn)','Quốc lộ 1A, Xã Bình Chánh, Huyện Bình Sơn, Quảng Ngãi','QNG');
/*!40000 ALTER TABLE `stop` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-16 16:07:38
