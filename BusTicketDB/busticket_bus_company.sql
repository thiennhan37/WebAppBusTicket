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
-- Table structure for table `bus_company`
--

DROP TABLE IF EXISTS `bus_company`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bus_company` (
  `ID` varchar(20) NOT NULL,
  `host_name` varchar(255) NOT NULL,
  `hotline` varchar(20) NOT NULL,
  `avatar_url` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `Policy` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `company_name` varchar(255) NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `hotline` (`hotline`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bus_company`
--

LOCK TABLES `bus_company` WRITE;
/*!40000 ALTER TABLE `bus_company` DISABLE KEYS */;
INSERT INTO `bus_company` VALUES ('H1I5XL2B00','Nguyễn Tấn Sĩ','1903 2412',NULL,'siha@gmail.com','Hỗ trợ đặt vé qua App, xe trung chuyển miễn phí tại nội thành Quảng Ngãi','2026-03-15 15:45:01','Xe Khách Sĩ Hà'),('L2I5XL2B2A','','1900 2679',NULL,'lienhungbus@gmail.com','Giá vé bao gồm bảo hiểm hành khách, không bắt khách dọc đường.','2026-03-15 15:45:01','Nhà Xe Liên Hưng'),('S4I5XL2B7K','','1900 558874',NULL,'contact@xetsontung.com','Miễn phí nước suối, khăn lạnh, hỗ trợ đổi trả vé trước 12h khởi hành.','2026-03-15 15:45:01','Nhà Xe Sơn Tùng'),('T5I5XL2BA8','','0257 3822046',NULL,'thuanthao.py@gmail.com','Nhà xe uy tín lâu đời tại Phú Yên, phục vụ tận tình, chuyên nghiệp.','2026-03-15 15:45:01','Xe Khách Thuận Thảo'),('V3I5XL2B4W','','1900 1231',NULL,'vanminhbus@nghean.vn','Dịch vụ xe giường nằm cao cấp, cam kết đúng giờ, không nhồi nhét khách.','2026-03-15 15:45:01','Xe Khách Văn Minh');
/*!40000 ALTER TABLE `bus_company` ENABLE KEYS */;
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
