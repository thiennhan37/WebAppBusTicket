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
-- Table structure for table `province`
--

DROP TABLE IF EXISTS `province`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `province` (
  `ID` varchar(20) NOT NULL,
  `Name` varchar(255) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `province`
--

LOCK TABLES `province` WRITE;
/*!40000 ALTER TABLE `province` DISABLE KEYS */;
INSERT INTO `province` VALUES ('AGI','An Giang'),('BDI','Bình Định'),('BDU','Bình Dương'),('BGI','Bắc Giang'),('BKA','Bắc Kạn'),('BLI','Bạc Liêu'),('BNI','Bắc Ninh'),('BPH','Bình Phước'),('BRVT','Bà Rịa - Vũng Tàu'),('BTH','Bình Thuận'),('BTR','Bến Tre'),('CBA','Cao Bằng'),('CMA','Cà Mau'),('CTH','Cần Thơ'),('DBI','Điện Biên'),('DLK','Đắk Lắk'),('DNA','Đồng Nai'),('DNG','Đà Nẵng'),('DNO','Đắk Nông'),('DTH','Đồng Tháp'),('GLA','Gia Lai'),('HAGI','Hà Giang'),('HBI','Hòa Bình'),('HCM','TP Hồ Chí Minh'),('HDU','Hải Dương'),('HNA','Hà Nam'),('HNO','Hà Nội'),('HPH','Hải Phòng'),('HTI','Hà Tĩnh'),('HUGI','Hậu Giang'),('HYE','Hưng Yên'),('KGI','Kiên Giang'),('KHO','Khánh Hòa'),('KTU','Kon Tum'),('LAN','Long An'),('LCA','Lào Cai'),('LCH','Lai Châu'),('LDO','Lâm Đồng'),('LSO','Lạng Sơn'),('NAN','Nghệ An'),('NBI','Ninh Bình'),('NDI','Nam Định'),('NTH','Ninh Thuận'),('PTH','Phú Thọ'),('PYE','Phú Yên'),('QBI','Quảng Bình'),('QNA','Quảng Nam'),('QNG','Quảng Ngãi'),('QNI','Quảng Ninh'),('QTR','Quảng Trị'),('SLA','Sơn La'),('STR','Sóc Trăng'),('TBI','Thái Bình'),('TGI','Tiền Giang'),('THH','Thanh Hóa'),('TNG','Thái Nguyên'),('TNI','Tây Ninh'),('TQU','Tuyên Quang'),('TTH','Thừa Thiên Huế'),('TVI','Trà Vinh'),('VLO','Vĩnh Long'),('VPH','Vĩnh Phúc'),('YBA','Yên Bái');
/*!40000 ALTER TABLE `province` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-16 16:07:37
