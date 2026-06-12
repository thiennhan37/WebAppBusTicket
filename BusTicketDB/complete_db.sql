-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: bus-ticket-db.ct08sy4g6odv.ap-southeast-2.rds.amazonaws.com    Database: BusTicket
-- ------------------------------------------------------
-- Server version	8.4.8

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
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '';

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin` (
  `ID` varchar(50) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `gender` enum('MALE','FEMALE','OTHER') DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `status` enum('ACTIVE','BLOCKED') DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin`
--

LOCK TABLES `admin` WRITE;
/*!40000 ALTER TABLE `admin` DISABLE KEYS */;
INSERT INTO `admin` VALUES ('9252d9f9-f644-4b9a-9418-9d712c41d150','admin@gmail.com','$2a$10$YbsrvmI8O2E3DC7JlSDf2.MTVhQLjrznL954fcNgE0gC1mmOHI1P2','Nguyễn Thiện Nhân','MALE','2026-05-16','0789789789','ACTIVE','2026-05-16 09:31:11');
/*!40000 ALTER TABLE `admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `booking_order`
--

DROP TABLE IF EXISTS `booking_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking_order` (
  `ID` varchar(50) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `customer_name` varchar(255) NOT NULL,
  `customer_phone` varchar(50) NOT NULL,
  `customer_email` varchar(255) DEFAULT NULL,
  `trip_id` varchar(50) DEFAULT NULL,
  `booking_user_id` varchar(50) DEFAULT NULL,
  `creating_staff_id` varchar(50) DEFAULT NULL,
  `total_cost` int NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `trip_id` (`trip_id`),
  KEY `booking_user_id` (`booking_user_id`),
  KEY `creating_staff_id` (`creating_staff_id`),
  CONSTRAINT `booking_order_ibfk_1` FOREIGN KEY (`trip_id`) REFERENCES `trip` (`ID`),
  CONSTRAINT `booking_order_ibfk_2` FOREIGN KEY (`booking_user_id`) REFERENCES `customer` (`ID`),
  CONSTRAINT `booking_order_ibfk_3` FOREIGN KEY (`creating_staff_id`) REFERENCES `company_user` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `booking_order`
--

LOCK TABLES `booking_order` WRITE;
/*!40000 ALTER TABLE `booking_order` DISABLE KEYS */;
INSERT INTO `booking_order` VALUES ('0I5C5G8HDZ','2026-06-11 13:09:59','Trần Tấn Phát','0706110630','programmingwithphat@gmail.com','ZB0N8PD6JW','CUST-0001',NULL,20000),('0JRG9QWP0Q','2026-05-14 15:35:58','asc','0123123123','thiennhan11a1@gmail.com','VLLTWTBDIB','CUST-0003','U1MN00I26Q',2000),('1KF87T8SB6','2026-06-08 09:51:30','assc','0123123123','thiennhan11a1@gmail.com','RPNK4HUJTL','CUST-0002','N2MNG1LS59',1000),('1N83XE9TUI','2026-05-05 14:16:43','scasc','0987456456','thiennhan11a1@gmail.com','KQL08ODWOI',NULL,'U1MN00I26Q',240000),('1TU4JVV1AJ','2026-05-05 14:21:29','cccc','098712312','thiennhan11a1@gmail.com','RPNK4HUJTL',NULL,'U1MN00I26Q',2000),('24QG6W36SK','2026-05-18 15:13:22','asc','0123123123','asc@gmail.com','MSY3J0SQZX','CUST-0001','P7MNGRZP7B',10000),('5P5FBQQH1E','2026-06-08 09:30:12','thiện nhân','0987123123','thiennhan11a1@gmail.com','RPNK4HUJTL',NULL,'U1MN00I26Q',1000),('5QLFVTMC3S','2026-05-14 01:05:46','Trần Tấn Phát','0706110630','programmingwithphat@gmail.com','RPNK4HUJTL','CUST-0001',NULL,1000),('6Z86KPNGCN','2026-05-14 15:30:49','asc','0987123123','asc@gmail.com','VLLTWTBDIB',NULL,'U1MN00I26Q',4000),('8W28G5GWOK','2026-05-15 14:38:08','asc','0987345345','thiennhan11a1@gmail.com','O436AMLNX4',NULL,'U1MN00I26Q',6000),('9BNDF191JJ','2026-06-11 13:16:40','Phát Trần','9999999','tahpnatnart@gmail.com','ZB0N8PD6JW','GTWUJ2Y9HK',NULL,20000),('A1SDUL3AXA','2026-05-12 07:53:11','Trần Tấn Phát','0706110630','programmingwithphat@gmail.com','RPNK4HUJTL','CUST-0001',NULL,1000),('A7322X1VDD','2026-06-11 15:28:14','booked','0956123123','thiennhan11a1@gmail.com','LHW3CJO3RD',NULL,'P7MNGRZP7B',10000),('AGBG7LOQSG','2026-05-13 08:34:18','asc','0123123123','asc@g.c','RPNK4HUJTL',NULL,'U1MN00I26Q',2000),('BMPKWF25GQ','2026-05-13 08:43:41','cccc','123123','12312313@gmail.com','RPNK4HUJTL',NULL,'U1MN00I26Q',2000),('C499087RYH','2026-05-11 09:12:58','Thiện Nhân','0395213106','thiennhan11a1@gmail.com','KQL08ODWOI',NULL,'U1MN00I26Q',240000),('CKQ7QHXDG5','2026-05-18 15:48:05','bbb',' 0987123123','thiennhan11a1@gmail.com','9HVPRF2WRF',NULL,'P7MNGRZP7B',1000),('CLD9VPH1YU','2026-05-14 01:20:28','Trần Tấn Phát','0706110630','programmingwithphat@gmail.com','RPNK4HUJTL','CUST-0001',NULL,1000),('DY562ZEWNL','2026-05-12 07:29:43','phat','0706110633','programmingwithphat@gmail.com','RPNK4HUJTL','CUST-0001',NULL,4000),('EIFGRWYG8T','2026-06-11 08:59:35','test 1','0975123543','thiennhan11a1@gmail.com','5VMU3PF7CM',NULL,'U1MN00I26Q',20000),('FJPDBME1FT','2026-05-13 08:32:02','asc','0987123123','adsc@gmail.com','RPNK4HUJTL',NULL,'U1MN00I26Q',2000),('FS8IKK5VMF','2026-05-13 07:29:28','Trần Tấn Phát','0706110630','programmingwithphat@gmail.com','RPNK4HUJTL','CUST-0001',NULL,2000),('GI68B74WMO','2026-05-18 14:21:55','test1 ','0987123123','thiennhan11a1@gmail.com','FOGGXJ3UR1',NULL,'P7MNGRZP7B',20000),('GKVZ40ZBOR','2026-05-15 13:28:32','asc','091123321','thiennhan11a1@gmail.com','VPIUD51XBB',NULL,'U1MN00I26Q',12000),('H6QW7MNZ13','2026-05-14 00:30:02','Trần Tấn Phát','0706110630','programmingwithphat@gmail.com','RPNK4HUJTL','CUST-0001',NULL,1000),('HAKID8G4HN','2026-05-19 10:19:56','Thiện Nhân','0395213106','thiennhan11a1@gmail.com','C2I3OOBEPA',NULL,'U1MN00I26Q',6000),('HR1QGOZ60M','2026-05-18 15:48:26','ccc',' 0987123123','cc@gmail.com','9HVPRF2WRF',NULL,'P7MNGRZP7B',1000),('IMDPQAJ5U2','2026-05-14 01:21:43','Trần Tấn Phát','0706110630','programmingwithphat@gmail.com','RPNK4HUJTL','CUST-0001',NULL,1000),('IOFPQ6B2ZT','2026-05-18 14:22:33','test 2 ','0912312323','thiennhan11a1@gmail.com','FOGGXJ3UR1',NULL,'P7MNGRZP7B',10000),('IRBSYIT8GL','2026-05-13 08:36:53','asc','0987123123','thiennhan11a1@gmail.com','RPNK4HUJTL',NULL,'U1MN00I26Q',1000),('IX7K94V8OL','2026-05-18 15:47:42','aaa','0987123123','thiennhan11a1@gmail.com','9HVPRF2WRF',NULL,'P7MNGRZP7B',1000),('J1RDWZSD1J','2026-05-13 07:30:32','Trần Tấn Phát','0706110630','programmingwithphat@gmail.com','RPNK4HUJTL','CUST-0001',NULL,1000),('J2WZZCQLO8','2026-05-18 20:56:39','Nhân','0987123123','thiennhan11a1@gmail.com','GX4ML4QSBX',NULL,'P7MNGRZP7B',4000),('JZI5P4BXG1','2026-05-20 16:35:09','asc','0123123123','asc@gmail.com','B2250NHQAO',NULL,'U1MN00I26Q',100000),('MPJKY06RMM','2026-05-20 15:58:43','Nhân tesst','0123123123','thiennhan11a1@gmail.com','HDGNUABOFH',NULL,'P7MNGRZP7B',20000),('N13XUM50LI','2026-05-18 14:47:15','test1 ','0987123123','thiennhan11a1@gmail.com','MSY3J0SQZX',NULL,'P7MNGRZP7B',20000),('N2939DK4YR','2026-05-13 08:42:44','cccc','123123','12312313@gmail.com','RPNK4HUJTL',NULL,'U1MN00I26Q',2000),('O04T42R650','2026-05-15 13:45:36','asc','0987123123','thiennhan11a1@gmail.com','VPIUD51XBB',NULL,'U1MN00I26Q',12000),('OGFS0O2JGD','2026-05-12 06:57:12','Trần Tấn Phát','0706110633','programmingwithphat@gmail.com','KQL08ODWOI','CUST-0001',NULL,240000),('P4U6U5FMFK','2026-06-08 09:53:25','asc','0123123123','thiennhan11a1@gmail.com','RPNK4HUJTL',NULL,'N2MNG1LS59',1000),('PA3ONDRR6Y','2026-05-13 08:42:01','cccc','123123','12312313@gmail.com','RPNK4HUJTL',NULL,'U1MN00I26Q',2000),('PAZS0JMQCM','2026-06-11 15:24:41','cancel','0712234234','thiennhan11a1@gmail.com','LHW3CJO3RD',NULL,'P7MNGRZP7B',20000),('RMRZIAMH5J','2026-05-05 14:11:19','Thiện Nhân','0987456456','thiennhan11a1@gmail.com','KQL08ODWOI','CUST-0002','U1MN00I26Q',240000),('SH5E02WIH8','2026-05-20 16:34:34','aasc','0123123123','thiennhan11a1@gmail.com','B2250NHQAO','CUST-0002','U1MN00I26Q',100000),('SODMRNMLND','2026-05-12 06:59:51','Nguyễn Thiện Nhân','0395321321','programmingwithphat@gmail.com','RPNK4HUJTL','CUST-0001',NULL,2000),('STLE8XQCBO','2026-06-11 15:32:19','rrrr','0777111222','thiennhan11a1@gmail.com','LHW3CJO3RD',NULL,'P7MNGRZP7B',20000),('U7HAEQHW83','2026-06-11 15:59:24','yyy','0666777888','thiennhan11a1@gmail.com','LHW3CJO3RD',NULL,'P7MNGRZP7B',10000),('U7Q4EPZWPR','2026-05-12 07:11:33','tran tan phat','0706110600','programmingwithphat@gmail.com','RPNK4HUJTL','CUST-0001',NULL,1000),('UI7U5I8G5C','2026-05-12 08:31:32','Trần Tấn Phát','0706110633','programmingwithphat@gmail.com','RPNK4HUJTL','CUST-0001',NULL,1000),('VMG4323JVD','2026-05-12 07:57:58','Trần Tấn Phát','0706110630','programmingwithphat@gmail.com','RPNK4HUJTL','CUST-0001',NULL,1000),('WEB9ONR5A6','2026-06-11 13:17:06','Trần Tấn Phát','0706110630','programmingwithphat@gmail.com','ZB0N8PD6JW','CUST-0001',NULL,20000),('WYBX22OTIQ','2026-05-15 14:10:18','asc','0987456456','thiennhan11a1@gmail.com','VPIUD51XBB',NULL,'U1MN00I26Q',12000),('X27EDW9WZ6','2026-05-12 08:13:44','Trần Tấn Phát','0706110634','programmingwithphat@gmail.com','RPNK4HUJTL','CUST-0001',NULL,2000),('XSLQNNLYDU','2026-05-18 14:50:05','test2','0987123123','thiennhan11a1@gmail.com','MSY3J0SQZX',NULL,'P7MNGRZP7B',10000),('Y2W3ML8FPR','2026-06-11 15:34:42','held','0967123345','asc@gmail.com','LHW3CJO3RD',NULL,'P7MNGRZP7B',30000);
/*!40000 ALTER TABLE `booking_order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bus_company`
--

DROP TABLE IF EXISTS `bus_company`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bus_company` (
  `ID` varchar(50) NOT NULL,
  `host_name` varchar(255) NOT NULL,
  `hotline` varchar(50) NOT NULL,
  `avatar_url` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `Policy` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `company_name` varchar(255) NOT NULL,
  `status` enum('ACTIVE','BLOCKED') DEFAULT 'ACTIVE',
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
INSERT INTO `bus_company` VALUES ('H1I5XL2B00','Nguyễn Tấn Sĩ','1903 2412','https://bus-ticket-images.s3.ap-southeast-2.amazonaws.com/baff166f-733a-4b77-8b05-0ba135121c29_VeXeDat_Logo.png','siha@gmail.com','Hỗ trợ đặt vé qua App, xe trung chuyển miễn phí tại nội thành Quảng Ngãi\r\nTrẻ em, người già, phụ nữ mang thai, sinh con trẻ sơ sinh và trẻ nhỏ được miễn giảm toàn bộ chi phí.','2026-03-15 15:45:01','Xe Khách Sĩ Hà','ACTIVE'),('L2I5XL2B2A','Trần Liên Hưng','1900 2679',NULL,'lienhungbus@gmail.com','Giá vé bao gồm bảo hiểm hành khách, không bắt khách dọc đường.','2026-03-16 15:45:01','Nhà Xe Liên Hưng','ACTIVE'),('NU65UOOM4E','test hnay','0987456546',NULL,'thiennhan11a1@gmail.com',NULL,'2026-05-26 08:57:35','company test','ACTIVE'),('S4I5XL2B7K','Trần Sơn Tùng','1900 558874','https://bus-ticket-images.s3.ap-southeast-2.amazonaws.com/634f59a0-5596-4e3c-9d48-e7d9fe440d78_VeXeDat_Logo.png','contact@xetsontung.com','Miễn phí nước suối, khăn lạnh, hỗ trợ đổi trả vé trước 12h khởi hành.','2026-03-17 15:45:01','Nhà Xe Sơn Tùng','ACTIVE'),('T5I5XL2BA8','','0257 3822046',NULL,'thuanthao.py@gmail.com','Nhà xe uy tín lâu đời tại Phú Yên, phục vụ tận tình, chuyên nghiệp.','2026-03-18 15:45:01','Xe Khách Thuận Thảo','BLOCKED'),('V3I5XL2B4W','','1900 1231','https://bus-ticket-images.s3.ap-southeast-2.amazonaws.com/9ade62f0-2af6-4589-a72b-ba838712e397_57abd6f9-f56d-4026-b52d-80d6adbbb9b2.jfif','vanminhbus@nghean.vn','....','2026-03-19 15:45:01','Xe Khách Văn Minh','ACTIVE');
/*!40000 ALTER TABLE `bus_company` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bus_type`
--

DROP TABLE IF EXISTS `bus_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bus_type` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `diagram` json NOT NULL,
  `total_seats` int NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bus_type`
--

LOCK TABLES `bus_type` WRITE;
/*!40000 ALTER TABLE `bus_type` DISABLE KEYS */;
INSERT INTO `bus_type` VALUES (1,'Xe giường nằm VIP','{\"row\": 6, \"floor\": 2, \"column\": 3, \"seatList\": [[[\"A1\", null, \"A2\"], [\"A3\", \"A4\", \"A5\"], [\"A6\", \"A7\", \"A8\"], [\"A9\", \"A10\", \"A11\"], [\"A12\", \"A13\", \"A14\"], [\"A15\", \"A16\", \"A17\"]], [[\"B1\", null, \"B2\"], [\"B3\", \"B4\", \"B5\"], [\"B6\", \"B7\", \"B8\"], [\"B9\", \"B10\", \"B11\"], [\"B12\", \"B13\", \"B14\"], [\"B15\", \"B16\", \"B17\"]]]}',34),(2,'Xe Limousine giường nằm','{\"row\": 6, \"floor\": 2, \"column\": 3, \"seatList\": [[[\"A1\", null, \"A2\"], [\"A3\", \"A4\", \"A5\"], [\"A6\", \"A7\", \"A8\"], [\"A9\", \"A10\", \"A11\"], [\"A12\", \"A13\", \"A14\"], [\"A15\", \"A16\", \"A17\"]], [[\"B1\", null, \"B2\"], [\"B3\", \"B4\", \"B5\"], [\"B6\", \"B7\", \"B8\"], [\"B9\", \"B10\", \"B11\"], [\"B12\", \"B13\", \"B14\"], [\"B15\", \"B16\", \"B17\"]]]}',34),(25,'Xe Limousine giường phòng','{\"row\": 6, \"floor\": 2, \"column\": 2, \"seatList\": [[[\"A1\", \"A2\"], [\"A3\", \"A4\"], [\"A5\", \"A6\"], [\"A7\", \"A8\"], [\"A9\", \"A10\"], [\"A11\", \"A12\"]], [[\"B1\", \"B2\"], [\"B3\", \"B4\"], [\"B5\", \"B6\"], [\"B7\", \"B8\"], [\"B9\", \"B10\"], [\"B11\", \"B12\"]]]}',24),(26,'Xe giường nằm phổ thông','{\"row\": 6, \"floor\": 2, \"column\": 3, \"seatList\": [[[\"A1\", \"A2\", \"A3\"], [\"A4\", \"A5\", \"A6\"], [\"A7\", \"A8\", \"A9\"], [\"A10\", \"A11\", \"A12\"], [\"A13\", \"A14\", \"A15\"], [\"A16\", \"A17\", \"A18\"]], [[\"B1\", \"B2\", \"B3\"], [\"B4\", \"B5\", \"B6\"], [\"B7\", \"B8\", \"B9\"], [\"B10\", \"B11\", \"B12\"], [\"B13\", \"B14\", \"B15\"], [\"B16\", \"B17\", \"B18\"]]]}',36),(27,'bustype 5','{\"row\": 2, \"floor\": 1, \"column\": 3, \"seatList\": [[[\"A1\", \"A2\", null], [\"A3\", \"A4\", null]]]}',4);
/*!40000 ALTER TABLE `bus_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company_register`
--

DROP TABLE IF EXISTS `company_register`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `company_register` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `host_Name` varchar(255) NOT NULL,
  `company_Name` varchar(255) NOT NULL,
  `hotline` varchar(50) NOT NULL,
  `email` varchar(255) NOT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('ACCEPTED','REJECTED','PENDING') DEFAULT NULL,
  `reviewed_by` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `reviewed_by` (`reviewed_by`),
  CONSTRAINT `company_register_ibfk_1` FOREIGN KEY (`reviewed_by`) REFERENCES `admin` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_register`
--

LOCK TABLES `company_register` WRITE;
/*!40000 ALTER TABLE `company_register` DISABLE KEYS */;
INSERT INTO `company_register` VALUES (7,'Nguyễn Tấn Sĩ','Xe Khách Sĩ Hà','1903 2412','siha@gmail.com','2026-03-15 14:45:01','ACCEPTED','9252d9f9-f644-4b9a-9418-9d712c41d150'),(8,'Trần Liên Hưng','Nhà Xe Liên Hưng','1900 2679','lienhungbus@gmail.com','2026-03-16 14:45:01','ACCEPTED','9252d9f9-f644-4b9a-9418-9d712c41d150'),(9,'Lê Sơn Tùng','Nhà Xe Sơn Tùng','1900 558874','contact@xetsontung.com','2026-03-17 14:45:01','ACCEPTED','9252d9f9-f644-4b9a-9418-9d712c41d150'),(10,'Ngô Thanh Thảo','Xe Khách Thuận Thảo','0257 3822046','thuanthao.py@gmail.com','2026-03-18 05:45:01','ACCEPTED','9252d9f9-f644-4b9a-9418-9d712c41d150'),(11,'Nguyễn Văn Minh','Xe Khách Văn Minh','1900 1231','vanminhbus@nghean.vn','2026-03-19 14:45:01','ACCEPTED','9252d9f9-f644-4b9a-9418-9d712c41d150'),(19,'Trần Hà My','Nhà Xe Hà My','0345123123','thiennhan11a1@gmail.com','2026-05-20 14:38:10','REJECTED','9252d9f9-f644-4b9a-9418-9d712c41d150'),(20,'test nhan','nhan test ','0345345345','testtesst1@gmail.com','2026-05-26 00:47:38','PENDING','9252d9f9-f644-4b9a-9418-9d712c41d150'),(21,'test hnay','company test','0987456546','thiennhan11a1@gmail.com','2026-05-26 08:57:35','ACCEPTED','9252d9f9-f644-4b9a-9418-9d712c41d150'),(22,'tetetete','con bìm bịp','0912789654','n23dccn110@student.ptithcm.edu.vn','2026-06-11 14:40:54','REJECTED','9252d9f9-f644-4b9a-9418-9d712c41d150'),(23,'hahaha','con cò lặn lội bờ ao','0567345987','n23dccn110@student.ptithcm.edu.vn','2026-06-11 14:41:29','PENDING',NULL);
/*!40000 ALTER TABLE `company_register` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company_user`
--

DROP TABLE IF EXISTS `company_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `company_user` (
  `ID` varchar(50) NOT NULL,
  `Bus_Company_ID` varchar(50) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `Phone` varchar(50) DEFAULT NULL,
  `full_Name` varchar(255) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `gender` enum('MALE','FEMALE','OTHER') DEFAULT NULL,
  `role` enum('MANAGER','STAFF') DEFAULT NULL,
  `status` enum('ACTIVE','BLOCKED') DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_company_created` (`Bus_Company_ID`,`created_at`),
  CONSTRAINT `company_user_ibfk_1` FOREIGN KEY (`Bus_Company_ID`) REFERENCES `bus_company` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_user`
--

LOCK TABLES `company_user` WRITE;
/*!40000 ALTER TABLE `company_user` DISABLE KEYS */;
INSERT INTO `company_user` VALUES ('0OP3QG1GKJ','V3I5XL2B4W','syfnn@gmail.com','$2a$10$9jlJ9zI7w7lpTR7cjrLpDuONgNTUre.mX/xXX1LI7xbD3U08kFolu','0123456789','BBB','2000-12-24','MALE','STAFF','ACTIVE','2026-06-11 14:31:24'),('0P2SJVE2EO','H1I5XL2B00','ccc@gmail.com','$2a$10$wM8W8wmtDbPqjFimnJDpBOt4vZ2DBmtH3MujBjSDNIHPBCrxy8vHK','0123456789','BBB','2000-12-24','MALE','STAFF','ACTIVE','2026-06-05 09:58:39'),('3G9L7MJ4MI','V3I5XL2B4W','aaa@student.ptithcm.edu.vn','$2a$10$K51v4KyV7VWSZJulHH4WG.CGpF58cGn9/1ty.Qyd2cG7mpvuMRajS','0987456654','test ','2000-02-02','FEMALE','STAFF','ACTIVE','2026-06-10 07:48:01'),('3YXCCJ31YW','V3I5XL2B4W','nmheb@gmail.com','$2a$10$KApiW9hQYA.Y4zTQMX7/2Oh45WNQ02XJW/12Km8zQvFbDDnfd17Ha','0123456789','Nguyễn Văn A','2000-12-23','MALE','STAFF','ACTIVE','2026-06-11 14:31:23'),('76T7T8KO7K','V3I5XL2B4W','ynbd@gmail.com','$2a$10$XmpcH..fUxuMtJWrS7bd.OebV.a1ouewWVSUiuR.//SQWllf0H9.K','0123456789','Nguyễn Văn A','2000-12-23','MALE','STAFF','ACTIVE','2026-06-11 14:28:44'),('8FINM23N6R','H1I5XL2B00','ddd@gmail.com','$2a$10$glJWLAJcuWE1bQaXbclvQOKK46YT5oPpFHjueyA2CmX7/qi/g8/Nu','0123456789','Nguyễn Văn A','2000-12-23','MALE','STAFF','ACTIVE','2026-06-05 09:58:39'),('9AP9KN0FW3','V3I5XL2B4W','abc@gmail.com','$2a$10$DFCoumLSJegdKs5OkSk.2.h4E0qYOxTEYWcbTwNr2JNn/394lwYoS','0912345345','Nguyễn thành danh','2000-01-01',NULL,'STAFF','BLOCKED','2026-06-10 07:44:01'),('B4MNGS0RU6','S4I5XL2B7K','staff_005@gmail.com','$2a$10$QaJ8dsESzYEamvDSGQ9G8uZNSLk6lz0ptcMN0P7MFG3nj6ytR3oMC','0975363111','nguyen nhu quynh','2000-12-24','FEMALE','STAFF','ACTIVE','2026-04-02 01:08:48'),('CIQD1JKV6N','V3I5XL2B4W','xzy001@gmail.com','$2a$10$l7JBqX8NBt9JLgxaExRZ2uIQAK4SD5LeSOePgmrMmK0DU0llGUdkO','0987456789','nahn ','2000-01-01','OTHER','STAFF','ACTIVE','2026-06-10 08:00:38'),('E2MNOPTATC','H1I5XL2B00','staff_010@gmail.com','$2a$10$gB5H5uYl8nISnAqV6E76Suhq38cIbl9RyvWJHfXSdmrpx0a1.1bEK','0937123123','abc fff','1111-11-11','MALE','MANAGER','BLOCKED','2026-04-07 14:29:10'),('F3JGZDK8UT','V3I5XL2B4W','staff_111@gmail.com','$2a$10$Zh9.d2ifqO9LFstlGWmCjuS4lwai42vLwI0MqO.XoKcJHLXyk.N8y','0978234432','ác','1111-11-11','FEMALE','STAFF','ACTIVE','2026-06-10 08:18:08'),('GMK7V2EMUU','H1I5XL2B00','staff_016@gmail.com','$2a$10$Ic4EEeDJz.DVMlYWyVhF1eMZjyTDp/h7pZh/Rim2B53j5IND0GYVq','0975363143','qqq qqq','2000-12-24','FEMALE','STAFF','ACTIVE','2026-05-15 13:06:59'),('H1MNOV661H','H1I5XL2B00','staff_014@gmail.com','$2a$10$S7tO6QkswUUXYsnHfg35WefKrqY/O3CKV6i62yk7hHukrgUzHBcGy','0375123234','qqq ','1111-11-11','FEMALE','STAFF','BLOCKED','2026-04-07 16:59:08'),('M3MNOSL4FD','H1I5XL2B00','staff_011@gmail.com','$2a$10$VP4RhcfTW4CYcPbeH.EeCeZVOmOpRz9TBUmHdeBdfh2s1Cv7dFl7m','0375111111','ttt','1111-11-11','OTHER','MANAGER','ACTIVE','2026-04-07 15:46:47'),('N2MNG1LS59','H1I5XL2B00','staff_002@gmail.com','$2a$10$SAOl.3yZAgHLzpVAMqGVzudEDQ27AZmXFFynash7anaAN5xkhAGK.','0975363111','qwerty','2000-12-24','MALE','STAFF','ACTIVE','2026-04-01 12:49:20'),('N2MNG1LS60','H1I5XL2B00','staff_003@gmail.com','$2a$10$SAOl.3yZAgHLzpVAMqGVzudEDQ27AZmXFFynash7anaAN5xkhAGK.','0975363111','avf sav','2000-12-24','FEMALE','STAFF','ACTIVE','2026-04-02 12:49:20'),('N2MNG1LS61','H1I5XL2B00','staff_007@gmail.com','$2a$10$SAOl.3yZAgHLzpVAMqGVzudEDQ27AZmXFFynash7anaAN5xkhAGK.','0975363112','ttt ddd','2000-12-25','OTHER','STAFF','BLOCKED','2026-04-02 12:50:20'),('N2MNG1LS62','H1I5XL2B00','staff_008@gmail.com','$2a$10$SAOl.3yZAgHLzpVAMqGVzudEDQ27AZmXFFynash7anaAN5xkhAGK.','0975363111','ttt aaa','2000-12-24','FEMALE','STAFF','BLOCKED','2026-04-02 12:50:20'),('N2MNG1LS63','H1I5XL2B00','staff_009@gmail.com','$2a$10$SAOl.3yZAgHLzpVAMqGVzudEDQ27AZmXFFynash7anaAN5xkhAGK.','0975363111','ttt aaa','2000-12-24','MALE','STAFF','ACTIVE','2026-04-02 12:50:20'),('N4MNGS0I5D','S4I5XL2B7K','staff_004@gmail.com','$2a$10$6ndspff7VR/tuiPPkqnrQOdGM4AxQNdS7WOcWtJM2w.CqD1j2BbHW','0975363111','nguyen tran thien nhan','2000-12-24','FEMALE','STAFF','ACTIVE','2026-04-02 01:08:35'),('P7MNGRZP7B','S4I5XL2B7K','manager_002@gmail.com','$2a$10$ulVzQF1RtwolEG8ytRF/geyfctgVupFkKOJqwY6r.qZ2CXFjp4Zt.','0975363111','st mng','2000-12-24','MALE','MANAGER','ACTIVE','2026-04-02 01:07:58'),('R6MNOSNKWX','H1I5XL2B00','staff_012@gmail.com','$2a$10$a15xq074p5cjT2E6Wdw0zuhXJU.8qvDJzkdbWKtVYTYjMcV6EyCLC','0375112112','ddd','1111-11-11','OTHER','STAFF','ACTIVE','2026-04-07 15:48:42'),('S2MNOSX7RC','H1I5XL2B00','staff_013@gmail.com','$2a$10$vmVsWTDNIHVuhjtL6VKcn.HhSXbP/9LovA6pzwajgok9TOUCg0x2y','0975123123','ffff','1111-11-11',NULL,'STAFF','ACTIVE','2026-04-07 15:56:11'),('SEUTEECLE0','V3I5XL2B4W','adbbd@gmail.com','$2a$10$43P3wYyH095SFXUuppO2MO5VBrXPhqgQDMOE47y32RBfqOEbK0EJW','0123456789','BBB','2000-12-24','MALE','STAFF','ACTIVE','2026-06-11 14:28:46'),('U1MN00I25N','H1I5XL2B00','staff_001@gmail.com','$2a$10$YlyCtTDpAwAcYZePb4Pto.w4zZTNduVLu48N6epWlAeadcHEpomyC','0975363111','thien nhan','2000-12-24','MALE','STAFF','ACTIVE','2026-03-21 07:34:07'),('U1MN00I26Q','H1I5XL2B00','manager_001@gmail.com','$2a$10$gjptrEAN3COy1W.0Kyznoex2mV2kaKs5QThIeqQdHnipN2/VQt37u','0975363600','Nguyễn Như Quỳnh','2026-12-24','FEMALE','MANAGER','ACTIVE','2026-03-18 07:54:05'),('U3MNGS10EK','S4I5XL2B7K','staff_006@gmail.com','$2a$10$9uMPZyAtdA0mx8gzpKryv.GSI/IEZ0Nghj5cMFqtDmMFoml/qGhHq','0975363111','qqq qqq','2000-12-24','FEMALE','STAFF','ACTIVE','2026-04-02 01:08:59'),('U9MNGRZVRX','V3I5XL2B4W','manager_004@gmail.com','$2a$10$2I3kFAcxd6pmbKi9p.cFIO6YgLZFlFBXudn3f5tznEFN1/UgPzVKi','0975363111','vminh mng','2000-12-24','MALE','MANAGER','ACTIVE','2026-04-02 01:08:06'),('W5DXXK2IOR','V3I5XL2B4W','ewr@student.ptithcm.edu.vn','$2a$10$93HM3EJv9YjYXj.M9uCRYORdY6Qa/vtkiBYowZq4lRsxusW4.pT9i','0989123123','ác','1111-11-11','FEMALE','STAFF','ACTIVE','2026-06-11 14:26:28'),('W5MNG4NN0L','H1I5XL2B00','asc@gmail.com','$2a$10$CvAZBTevd9pFPq/IoC0b.exwdKPnB1/6UXHNN20mMQxdog.PYFlVO','0975363111','asc','1111-11-11','MALE','MANAGER','ACTIVE','2026-04-01 14:14:44'),('Y8MNXARVSR','H1I5XL2B00','test123@gmail.com','$2a$10$5T62K9mEnMt1qWigX7EI1.unSgPKroc8U2CSbB/llQlJt7WQZNF7m','0978123345','test 123','2000-04-28','FEMALE','MANAGER','ACTIVE','2026-05-13 14:38:05');
/*!40000 ALTER TABLE `company_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `conversation`
--

DROP TABLE IF EXISTS `conversation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `conversation` (
  `id` int NOT NULL AUTO_INCREMENT,
  `customer_Id` varchar(50) DEFAULT NULL,
  `bus_company_Id` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `last_Message_At` datetime DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_Id` (`customer_Id`),
  KEY `company_Id` (`bus_company_Id`),
  CONSTRAINT `conversation_ibfk_1` FOREIGN KEY (`customer_Id`) REFERENCES `customer` (`ID`),
  CONSTRAINT `conversation_ibfk_2` FOREIGN KEY (`bus_company_Id`) REFERENCES `bus_company` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conversation`
--

LOCK TABLES `conversation` WRITE;
/*!40000 ALTER TABLE `conversation` DISABLE KEYS */;
INSERT INTO `conversation` VALUES (1,'CUST-0002','H1I5XL2B00','2026-06-01 13:56:16','2026-06-11 08:53:09','OPEN'),(2,'CUST-0001','H1I5XL2B00','2026-06-01 13:56:16','2026-06-11 14:56:25','OPEN'),(3,'CUST-0002','L2I5XL2B2A','2026-06-09 10:41:42','2026-06-09 10:41:42','OPEN'),(4,'CUST-0002','S4I5XL2B7K','2026-06-09 10:41:55','2026-06-11 13:54:21','OPEN'),(6,'CUST-0001','S4I5XL2B7K','2026-06-11 14:55:40','2026-06-11 14:55:40','OPEN');
/*!40000 ALTER TABLE `conversation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer` (
  `ID` varchar(50) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `full_Name` varchar(255) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `gender` enum('MALE','FEMALE','OTHER') DEFAULT NULL,
  `status` enum('ACTIVE','BLOCKED') DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `id_region` varchar(4) DEFAULT NULL,
  `role` enum('CUSTOMER','ADMIN','STAFF') DEFAULT 'CUSTOMER',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES ('CUST-0001','programmingwithphat@gmail.com','0706110630','Trần Tấn Phát','2005-01-17','FEMALE','ACTIVE','2026-04-12 06:56:16','+1','CUSTOMER'),('CUST-0002','nhanprovip37@gmail.com','0395213106','Nguyễn Thiện Nhân','2000-01-01','MALE','ACTIVE','2026-05-12 06:56:16','+1','CUSTOMER'),('CUST-0003','abc@gmail.com','072727272','Test','2000-01-01','MALE','ACTIVE','2026-05-12 06:56:16','+1','CUSTOMER'),('GTWUJ2Y9HK','tahpnatnart@gmail.com','9999999','Phát Trần','2003-06-11','OTHER','ACTIVE','2026-06-11 13:14:21',NULL,'CUSTOMER');
/*!40000 ALTER TABLE `customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `history_booking`
--

DROP TABLE IF EXISTS `history_booking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `history_booking` (
  `id` int NOT NULL AUTO_INCREMENT,
  `booking_order_id` varchar(50) DEFAULT NULL,
  `actor_ID` varchar(50) DEFAULT NULL,
  `customer_Id` varchar(50) DEFAULT NULL,
  `type` enum('BOOKING','CANCEL','PAYMENT','REFUND') DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `booking_order_id` (`booking_order_id`),
  KEY `actor_ID` (`actor_ID`),
  KEY `customer_Id` (`customer_Id`),
  CONSTRAINT `history_booking_ibfk_1` FOREIGN KEY (`booking_order_id`) REFERENCES `booking_order` (`ID`),
  CONSTRAINT `history_booking_ibfk_2` FOREIGN KEY (`actor_ID`) REFERENCES `company_user` (`ID`),
  CONSTRAINT `history_booking_ibfk_3` FOREIGN KEY (`customer_Id`) REFERENCES `customer` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=94 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `history_booking`
--

LOCK TABLES `history_booking` WRITE;
/*!40000 ALTER TABLE `history_booking` DISABLE KEYS */;
INSERT INTO `history_booking` VALUES (39,'RMRZIAMH5J','U1MN00I26Q',NULL,'BOOKING','2026-05-05 14:11:19'),(40,'1N83XE9TUI','U1MN00I26Q',NULL,'BOOKING','2026-05-05 14:16:43'),(41,'1TU4JVV1AJ','U1MN00I26Q',NULL,'BOOKING','2026-05-05 14:21:29'),(42,'C499087RYH','U1MN00I26Q',NULL,'BOOKING','2026-05-11 09:12:58'),(43,'OGFS0O2JGD',NULL,'CUST-0001','BOOKING','2026-05-12 06:57:12'),(44,'SODMRNMLND',NULL,'CUST-0001','BOOKING','2026-05-12 06:59:51'),(45,'U7Q4EPZWPR',NULL,'CUST-0001','BOOKING','2026-05-12 07:11:33'),(46,'DY562ZEWNL',NULL,'CUST-0001','BOOKING','2026-05-12 07:29:44'),(47,'A1SDUL3AXA',NULL,'CUST-0001','BOOKING','2026-05-12 07:53:11'),(48,'VMG4323JVD',NULL,'CUST-0001','BOOKING','2026-05-12 07:57:58'),(49,'X27EDW9WZ6',NULL,'CUST-0001','BOOKING','2026-05-12 08:13:44'),(50,'UI7U5I8G5C',NULL,'CUST-0001','BOOKING','2026-05-12 08:31:32'),(51,'FS8IKK5VMF',NULL,'CUST-0001','BOOKING','2026-05-13 07:29:28'),(52,'J1RDWZSD1J',NULL,'CUST-0001','BOOKING','2026-05-13 07:30:32'),(53,'FJPDBME1FT','U1MN00I26Q',NULL,'BOOKING','2026-05-13 08:32:02'),(54,'AGBG7LOQSG','U1MN00I26Q',NULL,'BOOKING','2026-05-13 08:34:18'),(55,'IRBSYIT8GL','U1MN00I26Q',NULL,'BOOKING','2026-05-13 08:36:54'),(56,'PA3ONDRR6Y','U1MN00I26Q',NULL,'BOOKING','2026-05-13 08:42:02'),(57,'N2939DK4YR','U1MN00I26Q',NULL,'BOOKING','2026-05-13 08:42:45'),(58,'BMPKWF25GQ','U1MN00I26Q',NULL,'BOOKING','2026-05-13 08:43:41'),(59,'H6QW7MNZ13',NULL,'CUST-0001','BOOKING','2026-05-14 00:30:03'),(60,'5QLFVTMC3S',NULL,'CUST-0001','BOOKING','2026-05-14 01:05:46'),(61,'CLD9VPH1YU',NULL,'CUST-0001','BOOKING','2026-05-14 01:20:29'),(62,'IMDPQAJ5U2',NULL,'CUST-0001','BOOKING','2026-05-14 01:21:43'),(63,'6Z86KPNGCN','U1MN00I26Q',NULL,'BOOKING','2026-05-14 15:30:49'),(64,'0JRG9QWP0Q','U1MN00I26Q',NULL,'BOOKING','2026-05-14 15:35:58'),(65,'GKVZ40ZBOR','U1MN00I26Q',NULL,'BOOKING','2026-05-15 13:28:32'),(66,'O04T42R650','U1MN00I26Q',NULL,'BOOKING','2026-05-15 13:45:36'),(67,'WYBX22OTIQ','U1MN00I26Q',NULL,'BOOKING','2026-05-15 14:10:18'),(68,'8W28G5GWOK','U1MN00I26Q',NULL,'BOOKING','2026-05-15 14:38:08'),(69,'GI68B74WMO','P7MNGRZP7B',NULL,'BOOKING','2026-05-18 14:21:55'),(70,'IOFPQ6B2ZT','P7MNGRZP7B',NULL,'BOOKING','2026-05-18 14:22:33'),(71,'N13XUM50LI','P7MNGRZP7B',NULL,'BOOKING','2026-05-18 14:47:15'),(72,'XSLQNNLYDU','P7MNGRZP7B',NULL,'BOOKING','2026-05-18 14:50:05'),(73,'24QG6W36SK','P7MNGRZP7B',NULL,'BOOKING','2026-05-18 15:13:22'),(74,'IX7K94V8OL','P7MNGRZP7B',NULL,'BOOKING','2026-05-18 15:47:42'),(75,'CKQ7QHXDG5','P7MNGRZP7B',NULL,'BOOKING','2026-05-18 15:48:05'),(76,'HR1QGOZ60M','P7MNGRZP7B',NULL,'BOOKING','2026-05-18 15:48:26'),(77,'J2WZZCQLO8','P7MNGRZP7B',NULL,'BOOKING','2026-05-18 20:56:39'),(78,'HAKID8G4HN','U1MN00I26Q',NULL,'BOOKING','2026-05-19 10:19:57'),(79,'MPJKY06RMM','P7MNGRZP7B',NULL,'BOOKING','2026-05-20 15:58:43'),(80,'SH5E02WIH8','U1MN00I26Q',NULL,'BOOKING','2026-05-20 16:34:34'),(81,'JZI5P4BXG1','U1MN00I26Q',NULL,'BOOKING','2026-05-20 16:35:09'),(82,'5P5FBQQH1E','U1MN00I26Q',NULL,'BOOKING','2026-06-08 09:30:12'),(83,'1KF87T8SB6','N2MNG1LS59',NULL,'BOOKING','2026-06-08 09:51:30'),(84,'P4U6U5FMFK','N2MNG1LS59',NULL,'BOOKING','2026-06-08 09:53:25'),(85,'EIFGRWYG8T','U1MN00I26Q',NULL,'BOOKING','2026-06-11 08:59:35'),(86,'PAZS0JMQCM','P7MNGRZP7B',NULL,'BOOKING','2026-06-11 15:24:42'),(87,'A7322X1VDD','P7MNGRZP7B',NULL,'BOOKING','2026-06-11 15:28:14'),(88,'STLE8XQCBO','P7MNGRZP7B',NULL,'BOOKING','2026-06-11 15:32:19'),(89,'Y2W3ML8FPR','P7MNGRZP7B',NULL,'BOOKING','2026-06-11 15:34:42'),(90,'U7HAEQHW83','P7MNGRZP7B',NULL,'BOOKING','2026-06-11 15:59:24'),(91,'0I5C5G8HDZ',NULL,'CUST-0001','BOOKING','2026-06-11 13:09:59'),(92,'9BNDF191JJ',NULL,'GTWUJ2Y9HK','BOOKING','2026-06-11 13:16:41'),(93,'WEB9ONR5A6',NULL,'CUST-0001','BOOKING','2026-06-11 13:17:07');
/*!40000 ALTER TABLE `history_booking` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `history_detail`
--

DROP TABLE IF EXISTS `history_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `history_detail` (
  `id` int NOT NULL AUTO_INCREMENT,
  `history_booking_id` int DEFAULT NULL,
  `ticket_id` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `history_booking_id` (`history_booking_id`),
  KEY `ticket_id` (`ticket_id`),
  CONSTRAINT `history_detail_ibfk_1` FOREIGN KEY (`history_booking_id`) REFERENCES `history_booking` (`id`),
  CONSTRAINT `history_detail_ibfk_2` FOREIGN KEY (`ticket_id`) REFERENCES `ticket` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=149 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `history_detail`
--

LOCK TABLES `history_detail` WRITE;
/*!40000 ALTER TABLE `history_detail` DISABLE KEYS */;
INSERT INTO `history_detail` VALUES (63,39,'J2UG9X1SSC'),(64,39,'JH20J7UZPI'),(65,40,'ITR76J8XQE'),(66,40,'JEOYC7L8NW'),(67,41,'BHSB5Q8HEX'),(68,41,'R7UW88GQIU'),(69,42,'E2OO20VFM3'),(70,42,'XS2MEJEPSN'),(71,43,'ZX9QITD3Z3'),(72,43,'666JKRUCGL'),(73,44,'B2ECI8VFL6'),(74,44,'8EI0PVK0WE'),(75,45,'KZVUYCPYOI'),(76,46,'PXCG2A4UJX'),(77,46,'PF8XM2HZYT'),(78,46,'8U0GHCFCW2'),(79,46,'8JNTAXAH8C'),(80,47,'DOOQCTR3FN'),(81,48,'9HZCU2Q88M'),(82,49,'LC99MZPZ17'),(83,49,'Y2WXH6H6F9'),(84,50,'JP7J6FHWEQ'),(85,51,'MR060TZPVJ'),(86,51,'Y29F2AONW5'),(87,52,'ZF9CSF0W0Y'),(88,53,'LFR4GRDBGO'),(89,53,'EXB1VTXI4J'),(90,54,'LLJ0ZLC1QF'),(91,54,'P3HAPQIX3Y'),(92,55,'FG65UBG7U0'),(93,56,'PSGHIK1NRT'),(94,56,'J1CEW13909'),(95,57,'PI6J46OXHK'),(96,57,'Q8UP7LNB5F'),(97,58,'D3JFR89BOK'),(98,58,'CSRJGONHZU'),(99,59,'D4FLY3UDYK'),(100,60,'M958EOM6V8'),(101,61,'NTNU5N42XA'),(102,62,'WP2D44OYTF'),(103,63,'7CR9YVFENT'),(104,63,'216UK9TMMM'),(105,64,'IYVMQT8ZDM'),(106,65,'VQI4XRH88M'),(107,66,'L8EU53OGT8'),(108,67,'UJ1AU6VZWQ'),(109,68,'O1U2AEN8I0'),(110,68,'YFF7P1HOZD'),(111,69,'1FMFBTADP0'),(112,69,'SFDAEL6YK5'),(113,70,'VRAMASBB59'),(114,71,'OJJT3G78MX'),(115,71,'IXO71DVNE5'),(116,72,'1Q1UG42TOO'),(117,73,'J2BPZ28C79'),(118,74,'JRE5JOF8IR'),(119,75,'47154CLW0O'),(120,76,'48TDUAPI6J'),(121,77,'KDYRPF0C2P'),(122,77,'7B32ACECCF'),(123,78,'CTKP96TZ0K'),(124,78,'WUFZ2RAKHK'),(125,79,'HZ32IJW4XF'),(126,79,'S7FO8ZHGR4'),(127,80,'7A4VXLOU9J'),(128,81,'N4JH5BNJOJ'),(129,82,'85S4OBELJN'),(130,83,'BILKF031MC'),(131,84,'SLV9DCU80U'),(132,85,'4W20HHM5Q0'),(133,85,'AR70B6UCAR'),(134,86,'3DTICSN69Y'),(135,86,'HGFQ46GTO2'),(136,87,'NVDFHBJJAG'),(137,88,'U6F0RMYDGK'),(138,88,'Y7CVSVVFKD'),(139,89,'C3ORQTHLKA'),(140,89,'7AOTD3LFOG'),(141,89,'VF1I2AXI7Q'),(142,90,'G45KP55XY7'),(143,91,'XG0O13FMTO'),(144,91,'RMWR2UEODO'),(145,92,'LW9TK661BS'),(146,92,'5O4PVQP3NA'),(147,93,'YIUZPCG2KG'),(148,93,'O3PKIC23QN');
/*!40000 ALTER TABLE `history_detail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message`
--

DROP TABLE IF EXISTS `message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `message` (
  `id` int NOT NULL AUTO_INCREMENT,
  `conversation_Id` int DEFAULT NULL,
  `content` text,
  `sent_at` datetime DEFAULT NULL,
  `sender_Id` varchar(50) DEFAULT NULL,
  `sender_Role` varchar(50) DEFAULT NULL,
  `unread_Customer_Count` int DEFAULT (0),
  `unread_Company_Count` int DEFAULT (0),
  PRIMARY KEY (`id`),
  KEY `conversation_Id` (`conversation_Id`),
  CONSTRAINT `message_ibfk_1` FOREIGN KEY (`conversation_Id`) REFERENCES `conversation` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=127 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message`
--

LOCK TABLES `message` WRITE;
/*!40000 ALTER TABLE `message` DISABLE KEYS */;
INSERT INTO `message` VALUES (1,1,'khach hang day ne ne ne ','2026-06-01 13:56:16','CUST-0002','CUSTOMER',0,0),(2,2,'khach hang 2','2026-06-01 13:56:16','CUST-0001','CUSTOMER',0,0),(3,1,'nhân nè','2026-06-08 09:17:08','U1MN00I26Q','MANAGER',0,0),(4,1,'alo','2026-06-08 09:18:30','U1MN00I25N','STAFF',0,0),(5,1,'hú hú','2026-06-08 09:49:23','N2MNG1LS59','STAFF',0,0),(6,1,'hahaha','2026-06-08 09:49:56','N2MNG1LS59','STAFF',0,0),(7,1,'hú hú','2026-06-08 09:50:00','N2MNG1LS59','STAFF',0,0),(8,1,'oh no','2026-06-08 10:10:41','U1MN00I26Q','MANAGER',0,0),(9,1,'sacas','2026-06-08 21:35:25','U1MN00I26Q','MANAGER',0,0),(10,1,'asc','2026-06-08 21:35:26','U1MN00I26Q','MANAGER',0,0),(11,1,'a','2026-06-08 21:35:26','U1MN00I26Q','MANAGER',0,0),(12,1,'asc','2026-06-08 21:35:26','U1MN00I26Q','MANAGER',0,0),(13,1,'as','2026-06-08 21:35:26','U1MN00I26Q','MANAGER',0,0),(14,1,'cas','2026-06-08 21:35:27','U1MN00I26Q','MANAGER',0,0),(15,1,'c','2026-06-08 21:35:27','U1MN00I26Q','MANAGER',0,0),(16,1,'asc','2026-06-08 21:35:27','U1MN00I26Q','MANAGER',0,0),(17,1,'as','2026-06-08 21:35:27','U1MN00I26Q','MANAGER',0,0),(18,1,'c','2026-06-08 21:35:27','U1MN00I26Q','MANAGER',0,0),(19,1,'asc','2026-06-08 21:35:27','U1MN00I26Q','MANAGER',0,0),(20,1,'as','2026-06-08 21:35:27','U1MN00I26Q','MANAGER',0,0),(21,1,'i love you so','2026-06-08 21:47:09','U1MN00I26Q','MANAGER',0,0),(22,1,'anh i make my mine','2026-06-08 21:47:15','U1MN00I26Q','MANAGER',0,0),(23,1,'and you said','2026-06-08 21:47:19','U1MN00I26Q','MANAGER',0,0),(24,1,'i love you so','2026-06-08 21:47:27','U1MN00I26Q','MANAGER',0,0),(25,1,'when you say my so','2026-06-08 21:47:49','U1MN00I26Q','MANAGER',0,0),(26,1,'asc','2026-06-08 21:47:51','U1MN00I26Q','MANAGER',0,0),(27,1,'asc','2026-06-08 21:47:52','U1MN00I26Q','MANAGER',0,0),(28,1,'\\asc','2026-06-08 21:47:52','U1MN00I26Q','MANAGER',0,0),(29,1,'asc','2026-06-08 21:47:52','U1MN00I26Q','MANAGER',0,0),(30,1,'a','2026-06-08 21:47:52','U1MN00I26Q','MANAGER',0,0),(31,1,'sc','2026-06-08 21:47:52','U1MN00I26Q','MANAGER',0,0),(32,1,'asc','2026-06-08 21:47:52','U1MN00I26Q','MANAGER',0,0),(33,1,'as','2026-06-08 21:47:53','U1MN00I26Q','MANAGER',0,0),(34,1,'cas','2026-06-08 21:47:53','U1MN00I26Q','MANAGER',0,0),(35,1,'c','2026-06-08 21:47:53','U1MN00I26Q','MANAGER',0,0),(36,1,'asc','2026-06-08 21:47:53','U1MN00I26Q','MANAGER',0,0),(37,1,'as','2026-06-08 21:47:53','U1MN00I26Q','MANAGER',0,0),(38,1,'c','2026-06-08 21:47:53','U1MN00I26Q','MANAGER',0,0),(39,1,'asc','2026-06-08 21:47:54','U1MN00I26Q','MANAGER',0,0),(40,1,'asc','2026-06-08 21:47:55','U1MN00I26Q','MANAGER',0,0),(41,1,'cc','2026-06-09 10:11:54','CUST-0002','CUSTOMER',0,0),(42,1,'cc','2026-06-09 10:12:05','CUST-0002','CUSTOMER',0,0),(43,1,'ccc','2026-06-09 10:12:08','CUST-0002','CUSTOMER',0,0),(44,1,'I love you so','2026-06-09 10:12:42','CUST-0002','CUSTOMER',0,0),(45,1,'i love you so','2026-06-09 10:20:23','CUST-0002','CUSTOMER',0,0),(46,4,'i love you so','2026-06-09 10:42:03','CUST-0002','CUSTOMER',0,0),(47,1,'i love you so','2026-06-09 10:44:40','CUST-0002','CUSTOMER',0,0),(48,1,'alo','2026-06-09 10:45:10','U1MN00I26Q','MANAGER',0,0),(49,1,'hello','2026-06-09 10:46:20','U1MN00I26Q','MANAGER',0,0),(50,1,'hll','2026-06-09 10:46:28','U1MN00I26Q','MANAGER',0,0),(51,1,'hll','2026-06-09 10:46:44','U1MN00I26Q','MANAGER',0,0),(52,1,'xỹ','2026-06-09 10:46:47','U1MN00I26Q','MANAGER',0,0),(53,1,'ọ','2026-06-09 10:47:22','U1MN00I26Q','MANAGER',0,0),(54,1,'alo','2026-06-09 10:48:04','CUST-0002','CUSTOMER',0,0),(55,1,'realtime','2026-06-09 10:48:20','CUST-0002','CUSTOMER',0,0),(56,1,'asc','2026-06-09 13:09:42','N2MNG1LS59','STAFF',0,0),(57,1,'ccc','2026-06-09 13:10:04','N2MNG1LS59','STAFF',0,0),(58,1,'cccm','2026-06-09 13:26:52','N2MNG1LS59','STAFF',0,0),(59,1,'ác','2026-06-09 13:37:39','N2MNG1LS59','STAFF',0,0),(60,1,'xxxx','2026-06-09 13:37:49','N2MNG1LS59','STAFF',0,0),(61,1,'yyy','2026-06-09 13:37:54','U1MN00I26Q','MANAGER',0,0),(62,1,'moi khi','2026-06-09 13:58:04','CUST-0002','CUSTOMER',0,0),(63,1,'c','2026-06-09 13:58:29','CUST-0002','CUSTOMER',0,0),(64,1,'sao v','2026-06-09 13:58:46','U1MN00I26Q','MANAGER',0,0),(65,1,'khong co gi','2026-06-09 13:58:59','CUST-0002','CUSTOMER',0,0),(66,1,'hgaha','2026-06-09 14:05:36','CUST-0002','CUSTOMER',0,0),(67,1,'haha','2026-06-09 14:05:41','CUST-0002','CUSTOMER',0,0),(68,1,'hihi','2026-06-09 14:05:50','CUST-0002','CUSTOMER',0,0),(69,1,'cuowfi con cac','2026-06-09 14:06:34','U1MN00I26Q','MANAGER',0,0),(70,1,'asc','2026-06-09 14:14:04','CUST-0002','CUSTOMER',0,0),(71,1,'haha','2026-06-09 14:16:42','U1MN00I26Q','MANAGER',0,0),(72,1,'hihi','2026-06-09 14:16:59','U1MN00I26Q','MANAGER',0,0),(73,1,'cái j','2026-06-09 14:19:19','U1MN00I26Q','MANAGER',0,0),(74,1,'ccc','2026-06-09 14:19:32','U1MN00I26Q','MANAGER',0,0),(75,1,'a','2026-06-09 14:19:38','U1MN00I26Q','MANAGER',0,0),(76,1,'b','2026-06-09 14:19:57','U1MN00I26Q','MANAGER',0,0),(77,1,'casc','2026-06-09 14:20:51','CUST-0002','CUSTOMER',0,0),(78,1,'khong cos','2026-06-09 14:20:56','U1MN00I26Q','MANAGER',0,0),(79,1,'c','2026-06-09 14:21:09','U1MN00I26Q','MANAGER',0,0),(80,1,'hihi','2026-06-09 14:29:43','U1MN00I26Q','MANAGER',0,0),(81,1,'ok','2026-06-09 14:30:00','U1MN00I26Q','MANAGER',0,0),(82,1,'lo','2026-06-09 14:30:12','U1MN00I26Q','MANAGER',0,0),(83,1,'ok','2026-06-09 14:30:18','U1MN00I26Q','MANAGER',0,0),(84,1,'ll','2026-06-09 14:31:05','U1MN00I26Q','MANAGER',0,0),(85,1,'ko','2026-06-09 14:31:15','CUST-0002','CUSTOMER',0,0),(86,1,'ok','2026-06-09 14:31:24','U1MN00I26Q','MANAGER',0,0),(87,1,'...','2026-06-09 14:40:28','U1MN00I26Q','MANAGER',0,0),(88,1,'h','2026-06-09 14:40:38','U1MN00I26Q','MANAGER',0,0),(89,1,'c','2026-06-09 14:41:11','CUST-0002','CUSTOMER',0,0),(90,1,'c','2026-06-09 14:41:41','CUST-0002','CUSTOMER',0,0),(91,1,'k','2026-06-09 14:43:46','U1MN00I26Q','MANAGER',0,0),(92,1,'k','2026-06-09 14:44:05','CUST-0002','CUSTOMER',0,0),(93,1,'o','2026-06-09 14:44:27','CUST-0002','CUSTOMER',0,0),(94,1,'ok','2026-06-09 14:44:31','U1MN00I26Q','MANAGER',0,0),(95,1,'ok','2026-06-09 14:44:42','U1MN00I26Q','MANAGER',0,0),(96,1,'k','2026-06-09 14:44:47','U1MN00I26Q','MANAGER',0,0),(97,1,'l','2026-06-09 14:44:56','U1MN00I26Q','MANAGER',0,0),(98,1,'lo','2026-06-09 14:45:35','U1MN00I26Q','MANAGER',0,0),(99,1,'l','2026-06-09 14:48:29','U1MN00I26Q','MANAGER',0,0),(100,1,'cá','2026-06-09 14:57:53','U1MN00I26Q','MANAGER',0,0),(101,1,'kj','2026-06-09 14:58:25','CUST-0002','CUSTOMER',0,0),(102,2,'cx','2026-06-09 14:58:31','U1MN00I26Q','MANAGER',0,0),(103,1,'rd','2026-06-09 14:58:55','CUST-0002','CUSTOMER',0,0),(104,1,'cá','2026-06-09 14:59:03','U1MN00I26Q','MANAGER',0,0),(105,1,'cc','2026-06-09 14:59:05','CUST-0002','CUSTOMER',0,0),(106,1,'cc','2026-06-09 14:59:11','CUST-0002','CUSTOMER',0,0),(107,1,'cc','2026-06-09 14:59:21','CUST-0002','CUSTOMER',0,0),(108,2,'ok','2026-06-09 14:59:29','U1MN00I26Q','MANAGER',0,0),(109,1,'ok','2026-06-09 14:59:34','U1MN00I26Q','MANAGER',0,0),(110,1,'kl','2026-06-09 15:10:18','U1MN00I26Q','MANAGER',0,0),(111,1,'vvv','2026-06-09 16:30:13','U1MN00I26Q','MANAGER',0,0),(112,1,'ok','2026-06-09 16:30:19','CUST-0002','CUSTOMER',0,0),(113,1,'ko bk nx','2026-06-09 16:30:27','U1MN00I26Q','MANAGER',0,0),(114,1,'haha','2026-06-09 16:30:35','CUST-0002','CUSTOMER',0,0),(115,1,'hihi','2026-06-09 16:30:50','CUST-0002','CUSTOMER',0,0),(116,1,'pk','2026-06-09 16:31:30','CUST-0002','CUSTOMER',0,0),(117,1,'rr','2026-06-09 16:31:35','CUST-0002','CUSTOMER',0,0),(118,1,'ok\nkkk','2026-06-09 16:31:43','CUST-0002','CUSTOMER',0,0),(119,1,'kukuk','2026-06-09 16:31:47','CUST-0002','CUSTOMER',0,0),(120,2,'abc','2026-06-09 16:31:47','CUST-0002','CUSTOMER',0,0),(121,1,'xyzz','2026-06-11 08:53:09','U1MN00I26Q','MANAGER',1,0),(122,4,'à à','2026-06-11 13:52:32','P7MNGRZP7B','MANAGER',1,0),(123,4,'ok','2026-06-11 13:53:59','U3MNGS10EK','STAFF',2,0),(124,4,'hihi','2026-06-11 13:54:21','P7MNGRZP7B','MANAGER',3,0),(125,2,'Gia ve ngay x la bao nhieu','2026-06-11 14:56:06','CUST-0001','CUSTOMER',0,0),(126,2,'Do ban biet day','2026-06-11 14:56:25','U1MN00I26Q','MANAGER',0,0);
/*!40000 ALTER TABLE `message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment`
--

DROP TABLE IF EXISTS `payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment` (
  `id` varchar(255) NOT NULL,
  `momo_order_id` varchar(100) DEFAULT NULL COMMENT 'Momo orderId, nullable',
  `booking_order_id` varchar(50) DEFAULT NULL,
  `type` enum('PAYMENT','REFUND') DEFAULT NULL,
  `status` enum('PENDING','SUCCESSFUL','FAILED') DEFAULT NULL,
  `trans_id` bigint DEFAULT NULL,
  `parent_trans_id` bigint DEFAULT NULL,
  `amount` bigint DEFAULT NULL,
  `updated_at` datetime NOT NULL,
  `vnpay_order_id` varchar(100) DEFAULT NULL COMMENT 'VNPay transaction number (vnp_TransactionNo), nullable',
  `payment_method` varchar(20) DEFAULT NULL COMMENT 'Phuong thuc thanh toan: MOMO | VNPAY',
  PRIMARY KEY (`id`),
  KEY `payment` (`booking_order_id`),
  KEY `idx_payment_vnpay_order_id` (`vnpay_order_id`),
  CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`booking_order_id`) REFERENCES `booking_order` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment`
--

LOCK TABLES `payment` WRITE;
/*!40000 ALTER TABLE `payment` DISABLE KEYS */;
INSERT INTO `payment` VALUES ('00a9d848-1a99-4ed8-85ea-ad642f4f64c2','069684ad-1244-4ed3-8ccc-51004beb585a','SODMRNMLND','PAYMENT','SUCCESSFUL',4744311150,NULL,2000,'2026-05-12 07:00:04',NULL,NULL),('049b92be-db88-41d7-aa32-1d722758f494','9c488317-abf7-4bcf-a52b-c66299db0fc6','XSLQNNLYDU','PAYMENT','SUCCESSFUL',4749872814,NULL,10000,'2026-05-18 15:13:45',NULL,NULL),('0829312a-9e46-4cb7-990d-504c617ce929','4605cec2-330a-42c9-89d0-c30397e37450','8W28G5GWOK','PAYMENT','SUCCESSFUL',4747240364,NULL,6000,'2026-05-15 14:40:53',NULL,NULL),('11befa12-7c92-4890-a163-40c8f41a6954',NULL,'PA3ONDRR6Y','PAYMENT','PENDING',NULL,NULL,2000,'2026-05-13 08:42:03',NULL,NULL),('139cb27f-2d53-4823-a4c0-e021d2465be0','a32eac19-c505-42d8-85d8-b423c438ed50','1KF87T8SB6','PAYMENT','SUCCESSFUL',4758297290,NULL,1000,'2026-06-08 09:51:59',NULL,NULL),('13f20314-842c-4e8d-93b8-f172b8c6df2b','6d3ef203-0e18-4f3e-a745-51f5598ef932','DY562ZEWNL','PAYMENT','SUCCESSFUL',4744291777,NULL,4000,'2026-05-12 07:30:07',NULL,NULL),('18fc7f01-dceb-4658-b23b-251670953e01',NULL,'Y2W3ML8FPR','PAYMENT','PENDING',NULL,NULL,30000,'2026-06-11 15:34:42',NULL,NULL),('1984bc62-85d1-4b16-9c6d-769beb0b9518','24972f65-fcf7-4a85-8d09-dfe803397460','IX7K94V8OL','REFUND','SUCCESSFUL',4749927362,4749908613,1000,'2026-05-18 15:49:33',NULL,NULL),('1ab59a9b-d2cf-4688-a2b8-d612a64a499e','ad7cccf0-4e62-4b73-bf40-e00989f16fd8','N13XUM50LI','PAYMENT','SUCCESSFUL',4749891226,NULL,20000,'2026-05-18 15:12:46',NULL,NULL),('1d49a887-43ae-4b1a-b1f9-521495c76bd9',NULL,'0I5C5G8HDZ','PAYMENT','PENDING',NULL,NULL,20000,'2026-06-11 13:10:11',NULL,NULL),('20c1ce47-3bea-463f-8b60-7c1c410ae345','6185ae86-9af5-49be-af35-06013e2575e3','XSLQNNLYDU','REFUND','SUCCESSFUL',4749893908,4749872814,10000,'2026-05-18 15:29:12',NULL,NULL),('2206fb6e-5073-4142-923c-83fbd249ccf9','2f170660-4cea-456a-b0ed-97850294989f','A1SDUL3AXA','PAYMENT','SUCCESSFUL',4744332267,NULL,1000,'2026-05-12 07:53:58',NULL,NULL),('22298f44-2b44-4908-8fe5-859c1816ce18','5cee28ed-4da5-48e0-a7c7-f97912237165','EIFGRWYG8T','PAYMENT','SUCCESSFUL',4760354043,NULL,20000,'2026-06-11 09:03:37',NULL,NULL),('2d866fe6-c28d-4327-a821-a57a6c1d4651',NULL,'IOFPQ6B2ZT','PAYMENT','PENDING',NULL,NULL,10000,'2026-05-18 14:22:33',NULL,NULL),('35477153-1c96-41bb-a440-b353efaf610c',NULL,'FJPDBME1FT','PAYMENT','PENDING',NULL,NULL,2000,'2026-05-13 08:32:03',NULL,NULL),('3759f94f-34c8-41bc-9c28-bc8eca2398fa','cc762409-d391-4bdc-991c-a8e5e2d4416b','1TU4JVV1AJ','REFUND','SUCCESSFUL',4739046600,4739056170,2000,'2026-05-05 14:23:14',NULL,NULL),('376b89c4-70dc-4fa5-9ea4-3ed5b8954531','64a8ab0d-294c-4bdc-804c-fa713062733c','1N83XE9TUI','PAYMENT','SUCCESSFUL',4739044989,NULL,240000,'2026-05-05 14:17:29',NULL,NULL),('3a0b5dba-eac6-4c0c-9b0e-ed0b1699c216',NULL,'WEB9ONR5A6','PAYMENT','SUCCESSFUL',15579796,NULL,20000,'2026-06-11 13:18:53','3a0b5dba-eac6-4c0c-9b0e-ed0b1699c216','VNPAY'),('3be71b29-e67c-4aa7-9603-8bbec0efe7e7','be561b24-4119-4c52-bf0f-2fa89632ddc0','PAZS0JMQCM','REFUND','SUCCESSFUL',4759884765,4759884732,10000,'2026-06-11 15:26:57',NULL,'MOMO'),('3c17cacb-6d16-4e69-856c-0994b20dfa78','ded90c19-b9b1-4b44-b5b4-16ebafb459ad','MPJKY06RMM','PAYMENT','SUCCESSFUL',4751177140,NULL,20000,'2026-05-20 16:00:03',NULL,NULL),('3d7a659b-e7b2-480d-a933-4199e42a8d72','b0e10b73-3d42-4fb6-a011-be190c0f7d76','STLE8XQCBO','PAYMENT','SUCCESSFUL',4760608566,NULL,20000,'2026-06-11 15:35:14',NULL,NULL),('45c22189-2da0-43bb-b2c0-db050f332a55',NULL,'VMG4323JVD','PAYMENT','PENDING',NULL,NULL,1000,'2026-05-12 07:57:59',NULL,NULL),('5255ccd7-4b99-422a-8f8f-8d075b1f2834',NULL,'IRBSYIT8GL','PAYMENT','PENDING',NULL,NULL,1000,'2026-05-13 08:36:54',NULL,NULL),('585f2fbf-c099-4df9-8f5f-1283e65bb832',NULL,'GI68B74WMO','PAYMENT','PENDING',NULL,NULL,20000,'2026-05-18 14:21:55',NULL,NULL),('61df727d-1960-454a-9688-75e2da7954f0','99eab425-e0ae-4ba8-9aa2-a1fad9bb898f','WYBX22OTIQ','PAYMENT','SUCCESSFUL',4747259861,NULL,12000,'2026-05-15 14:39:52',NULL,NULL),('6422c5be-09c1-48a0-85ad-bd9d7e6322b4','6980523f-39e3-4749-9b8e-67746c9ab64c','O04T42R650','PAYMENT','SUCCESSFUL',4747195274,NULL,12000,'2026-05-15 14:03:53',NULL,NULL),('645b8701-3c5d-4e85-9608-583538b9f4ea',NULL,'P4U6U5FMFK','PAYMENT','PENDING',NULL,NULL,1000,'2026-06-08 09:53:25',NULL,NULL),('64eb115f-bdae-49c5-9bc7-8874f106279e','adcdf741-cded-4211-90c0-973f90749ae0','WEB9ONR5A6','REFUND','SUCCESSFUL',4760803447,4760813447,20000,'2026-06-11 13:19:13',NULL,'MOMO'),('661d505f-158f-419d-b0f3-6631be0ad0f4','8bcd8152-7ef6-403b-8bef-1c43f2472a1d','8W28G5GWOK','REFUND','SUCCESSFUL',4747250082,4747240364,3000,'2026-05-15 14:42:02',NULL,NULL),('681b9159-c1b1-4e82-a7d9-932b17fcc5aa',NULL,'SH5E02WIH8','PAYMENT','PENDING',NULL,NULL,100000,'2026-05-20 16:34:34',NULL,NULL),('6b87e0aa-7efb-400f-bc8d-46ef3f074338',NULL,'CKQ7QHXDG5','PAYMENT','PENDING',NULL,NULL,1000,'2026-05-18 15:48:05',NULL,NULL),('6ba523df-72b5-48c7-a740-de6accd5fb5d',NULL,'HR1QGOZ60M','PAYMENT','PENDING',NULL,NULL,1000,'2026-05-18 15:48:26',NULL,NULL),('6e48bc63-729e-449e-a943-4a966ec5d0f5',NULL,'24QG6W36SK','PAYMENT','PENDING',NULL,NULL,10000,'2026-05-18 15:13:23',NULL,NULL),('72a8acb4-0db0-4d88-8eaa-994e09642a00','34ccafe7-8a24-4abe-ba9f-091b2cc750fe','N13XUM50LI','REFUND','SUCCESSFUL',4749875291,4749891226,20000,'2026-05-18 15:29:12',NULL,NULL),('74b35140-8b3b-421c-83b2-03373c36a2a3',NULL,'5QLFVTMC3S','PAYMENT','PENDING',NULL,NULL,1000,'2026-05-14 01:05:47',NULL,NULL),('78bbd84f-0fbb-4bbe-bd04-f7df8e528c08','368c066a-3733-4eb4-a423-981f5bf1feda','J1RDWZSD1J','PAYMENT','SUCCESSFUL',4745328894,NULL,1000,'2026-05-13 07:35:57',NULL,NULL),('7c4672c6-f136-4e61-90b3-2df9aec50de2',NULL,'N2939DK4YR','PAYMENT','PENDING',NULL,NULL,2000,'2026-05-13 08:42:46',NULL,NULL),('8dde17ff-142b-43a3-9859-224b6029cda1','6e83f4b7-ceb5-4389-be3f-d9f9b2dce848','5P5FBQQH1E','PAYMENT','SUCCESSFUL',4758306617,NULL,1000,'2026-06-08 09:30:55',NULL,NULL),('8ebcf2d0-c890-46ae-ab67-e232dd66582a',NULL,'OGFS0O2JGD','PAYMENT','PENDING',NULL,NULL,240000,'2026-05-12 06:57:13',NULL,NULL),('9799d901-793b-4bd9-9ca0-5eef6817c02a',NULL,'J2WZZCQLO8','PAYMENT','PENDING',NULL,NULL,4000,'2026-05-18 20:56:39',NULL,NULL),('97db2e02-1780-42d4-b37b-09626b75bbb8',NULL,'BMPKWF25GQ','PAYMENT','PENDING',NULL,NULL,2000,'2026-05-13 08:43:42',NULL,NULL),('9a100ca4-d09b-4285-87da-e74b9bc81e5d',NULL,'6Z86KPNGCN','PAYMENT','PENDING',NULL,NULL,4000,'2026-05-14 15:30:50',NULL,NULL),('a388f214-06af-4b42-bb2d-16be6d652861','2a9434d2-06ab-4800-8ab6-16bfc82651f4','RMRZIAMH5J','PAYMENT','SUCCESSFUL',4739053906,NULL,240000,'2026-05-05 14:15:00',NULL,NULL),('a6a58c29-8076-4de4-b1ee-7c3575f0888a','9ee7b12c-afa0-47f0-b4f7-93be18a59db0','CLD9VPH1YU','PAYMENT','SUCCESSFUL',4745660234,NULL,1000,'2026-05-14 01:20:59',NULL,NULL),('afeccda7-58e5-4e84-92d8-aa3a494caafb',NULL,'JZI5P4BXG1','PAYMENT','PENDING',NULL,NULL,100000,'2026-05-20 16:35:09',NULL,NULL),('b7b1cb23-5047-4998-af83-eebf48104bf8',NULL,'UI7U5I8G5C','PAYMENT','PENDING',NULL,NULL,1000,'2026-05-12 08:31:33',NULL,NULL),('bbb4e6fa-af08-4b22-a37a-0ded5c1e6dea',NULL,'0I5C5G8HDZ','REFUND','SUCCESSFUL',NULL,NULL,20000,'2026-06-11 13:11:45','15579793','VNPAY'),('bcd718c0-6644-4e9d-83bc-7577dc016ee7','f8848cf8-d832-49c7-a85e-9671072c29f7','HAKID8G4HN','PAYMENT','SUCCESSFUL',4750409390,NULL,6000,'2026-05-19 10:22:32',NULL,NULL),('c10ef9f8-cade-4d1a-a288-43c7de587ea0',NULL,'U7Q4EPZWPR','PAYMENT','PENDING',NULL,NULL,1000,'2026-05-12 07:11:34',NULL,NULL),('c271c843-6d1e-4c08-a54b-33fec725ef78','b9763f80-8797-48a6-9b00-995cfbd6cc74','IMDPQAJ5U2','PAYMENT','SUCCESSFUL',4745701553,NULL,1000,'2026-05-14 01:33:14',NULL,NULL),('c573fada-250a-449d-8974-e72cceb51f2e','e6135806-353d-49f8-9938-ef6263f27cba','U7HAEQHW83','PAYMENT','SUCCESSFUL',4760687542,NULL,10000,'2026-06-11 16:00:04',NULL,NULL),('c9da60df-7a98-4736-92e9-aefd5f40bed2',NULL,'X27EDW9WZ6','PAYMENT','PENDING',NULL,NULL,2000,'2026-05-12 08:13:45',NULL,NULL),('cb1774f5-2853-4aa5-ae09-ecd8acb20db0','b4a8e65f-56a5-45db-8d4f-bc89c7086178','IX7K94V8OL','PAYMENT','SUCCESSFUL',4749908613,NULL,1000,'2026-05-18 15:49:00',NULL,NULL),('d02ee2f8-fa7d-4ccd-9d7b-1029e7d460f3','52c7bfdc-e157-4094-9ce7-2a4f4d0851cd','1TU4JVV1AJ','REFUND','SUCCESSFUL',4739067048,4739065548,1000,'2026-05-05 14:28:28',NULL,NULL),('d27a9657-f434-4eca-8c92-c9bf8017e68b',NULL,'GKVZ40ZBOR','PAYMENT','PENDING',NULL,NULL,12000,'2026-05-15 13:28:33',NULL,NULL),('d5b1e381-ba90-4fe1-bcc1-3d35cb2606f4','52c24362-533b-4427-85bd-00e1007f0ef4','0I5C5G8HDZ','PAYMENT','SUCCESSFUL',4760792825,NULL,20000,'2026-06-11 13:11:00',NULL,'MOMO'),('e1339dfd-3682-44b0-b865-f2c84d369f2f','ae607f2b-057b-4a57-a452-d7e3b423443b','A7322X1VDD','PAYMENT','SUCCESSFUL',4760608403,NULL,10000,'2026-06-11 15:28:57',NULL,NULL),('e9db146f-03c2-465c-9c88-257124552336','4c26c280-58c2-4ce5-ba7d-6e2e338001e3','H6QW7MNZ13','PAYMENT','SUCCESSFUL',4745633667,NULL,1000,'2026-05-14 00:38:16',NULL,NULL),('f4e60b4c-3ad4-4078-8790-0779ff318710','abe59b05-c91d-463e-86f5-ff748d49c95d','0JRG9QWP0Q','PAYMENT','SUCCESSFUL',4746105368,NULL,2000,'2026-05-14 15:50:04',NULL,NULL),('f6e84249-0ec2-4649-9bb2-2088b153b998',NULL,'AGBG7LOQSG','PAYMENT','PENDING',NULL,NULL,2000,'2026-05-13 08:34:19',NULL,NULL),('f70e05aa-8ea3-4b31-b12b-9da29a2bdb75','3145b04e-82c8-40c4-9464-149d9cef1c50','FS8IKK5VMF','PAYMENT','SUCCESSFUL',4745288214,NULL,2000,'2026-05-13 07:29:44',NULL,NULL),('f96fb4b8-b6f0-491b-bc60-04187710531a','bf468ae1-cf9f-4413-9e19-ea28aacd191f','1TU4JVV1AJ','PAYMENT','SUCCESSFUL',4739065548,NULL,2000,'2026-05-05 14:23:00',NULL,NULL),('f9ab4aff-2def-4757-a433-0ea7e4af34a8',NULL,'C499087RYH','PAYMENT','PENDING',NULL,NULL,240000,'2026-05-11 09:12:59',NULL,NULL),('fac079c3-3801-47be-b0fa-1dd02cabb93a','133158ab-333e-46b3-ba5c-aec143159942','PAZS0JMQCM','PAYMENT','SUCCESSFUL',4759884732,NULL,20000,'2026-06-11 15:25:29',NULL,NULL);
/*!40000 ALTER TABLE `payment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `province`
--

DROP TABLE IF EXISTS `province`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `province` (
  `ID` varchar(50) NOT NULL,
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

--
-- Table structure for table `route`
--

DROP TABLE IF EXISTS `route`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `route` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) NOT NULL,
  `bus_company_ID` varchar(50) DEFAULT NULL,
  `arrival_ID` varchar(50) DEFAULT NULL,
  `destination_ID` varchar(50) DEFAULT NULL,
  `duration_minutes` int DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Name` (`Name`,`bus_company_ID`),
  KEY `bus_company_ID` (`bus_company_ID`),
  KEY `arrival_ID` (`arrival_ID`),
  KEY `destination_ID` (`destination_ID`),
  CONSTRAINT `route_ibfk_1` FOREIGN KEY (`bus_company_ID`) REFERENCES `bus_company` (`ID`),
  CONSTRAINT `route_ibfk_2` FOREIGN KEY (`arrival_ID`) REFERENCES `province` (`ID`),
  CONSTRAINT `route_ibfk_3` FOREIGN KEY (`destination_ID`) REFERENCES `province` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `route`
--

LOCK TABLES `route` WRITE;
/*!40000 ALTER TABLE `route` DISABLE KEYS */;
INSERT INTO `route` VALUES (13,'test route 13','H1I5XL2B00','QNG','HCM',750),(19,'route 191','H1I5XL2B00','QNG','HCM',840),(20,'route 20','H1I5XL2B00','HCM','QNG',840),(22,'route 22','H1I5XL2B00','HCM','QNG',840),(23,'Miền Đông mới - Bến xe Chợ Chùa','H1I5XL2B00','HCM','QNG',840),(24,'route 24','H1I5XL2B00','QNG','HCM',840),(25,'route 25','H1I5XL2B00','HCM','HCM',840),(26,'route 26','H1I5XL2B00','HCM','QNG',840),(27,'route 27','H1I5XL2B00','HCM','QNG',840),(28,'Bến xe Trà Bồng - Miền Đông mới','H1I5XL2B00','QNG','HCM',840),(29,'BX An Sương - BX Chợ Chùa','H1I5XL2B00','HCM','QNG',840),(32,'ccc','H1I5XL2B00','QNG','HCM',730),(33,'bbb','H1I5XL2B00','QNG','HCM',660),(34,'BMT - Miền Đông mới ','S4I5XL2B7K','DLK','HCM',600),(35,'test hidden','H1I5XL2B00','HCM','QNG',720),(37,'Đức Phổ - BX Miền Tây','S4I5XL2B7K','QNG','HCM',600),(38,'DL-HCM','H1I5XL2B00','DLK','HCM',NULL),(39,'QN - BX 2 Miền','V3I5XL2B4W','QNG','HCM',660),(40,'test','V3I5XL2B4W','DLK','HCM',360),(41,'QN','S4I5XL2B7K','QNG','HCM',480);
/*!40000 ALTER TABLE `route` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `route_stop`
--

DROP TABLE IF EXISTS `route_stop`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `route_stop` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `route_ID` int DEFAULT NULL,
  `stop_ID` int DEFAULT NULL,
  `type` enum('UP','DOWN') DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `route_ID` (`route_ID`),
  KEY `stop_ID` (`stop_ID`),
  CONSTRAINT `route_stop_ibfk_1` FOREIGN KEY (`route_ID`) REFERENCES `route` (`ID`),
  CONSTRAINT `route_stop_ibfk_2` FOREIGN KEY (`stop_ID`) REFERENCES `stop` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `route_stop`
--

LOCK TABLES `route_stop` WRITE;
/*!40000 ALTER TABLE `route_stop` DISABLE KEYS */;
INSERT INTO `route_stop` VALUES (1,13,25,'UP'),(2,13,26,'UP'),(3,13,24,'UP'),(4,13,1,'DOWN'),(5,13,2,'DOWN'),(16,19,20,'UP'),(17,19,19,'UP'),(18,19,24,'UP'),(19,19,1,'DOWN'),(20,19,2,'DOWN'),(21,20,1,'UP'),(22,20,2,'UP'),(23,20,16,'DOWN'),(24,20,17,'DOWN'),(25,22,1,'UP'),(26,22,17,'DOWN'),(27,23,1,'UP'),(28,23,2,'UP'),(29,23,3,'UP'),(30,23,17,'DOWN'),(31,24,16,'UP'),(32,24,17,'UP'),(33,24,2,'DOWN'),(34,25,1,'UP'),(35,25,2,'DOWN'),(36,26,1,'UP'),(37,26,19,'DOWN'),(38,27,1,'UP'),(39,27,2,'UP'),(40,27,25,'DOWN'),(41,27,26,'DOWN'),(42,28,20,'UP'),(43,28,18,'UP'),(44,28,1,'DOWN'),(45,29,4,'UP'),(46,29,17,'DOWN'),(61,13,3,'DOWN'),(62,13,18,'UP'),(65,32,16,'UP'),(66,32,23,'DOWN'),(67,33,17,'UP'),(68,33,3,'DOWN'),(69,34,9,'UP'),(70,34,11,'UP'),(71,34,1,'DOWN'),(72,34,3,'DOWN'),(73,13,16,'UP'),(74,33,16,'UP'),(75,35,1,'UP'),(76,35,18,'DOWN'),(77,37,16,'UP'),(78,37,17,'UP'),(79,37,18,'UP'),(80,37,3,'DOWN'),(81,37,4,'DOWN'),(82,38,9,'UP'),(83,38,10,'UP'),(84,38,15,'UP'),(85,38,14,'UP'),(86,38,4,'DOWN'),(87,38,3,'DOWN'),(88,38,1,'DOWN'),(89,39,16,'UP'),(90,39,17,'UP'),(91,39,18,'UP'),(92,39,2,'DOWN'),(93,39,3,'DOWN'),(94,40,9,'UP'),(95,40,10,'UP'),(96,40,2,'DOWN'),(97,40,3,'DOWN'),(98,13,22,'DOWN'),(99,41,16,'UP'),(100,41,17,'UP'),(101,41,18,'UP'),(102,41,23,'DOWN'),(103,41,22,'DOWN'),(104,41,21,'DOWN');
/*!40000 ALTER TABLE `route_stop` ENABLE KEYS */;
UNLOCK TABLES;

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
  `Province_ID` varchar(50) DEFAULT NULL,
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

--
-- Table structure for table `ticket`
--

DROP TABLE IF EXISTS `ticket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ticket` (
  `ID` varchar(50) NOT NULL,
  `Trip_Seat_ID` varchar(50) DEFAULT NULL,
  `booking_order_id` varchar(50) DEFAULT NULL,
  `arrival_id` int DEFAULT NULL,
  `destination_id` int DEFAULT NULL,
  `price` int NOT NULL,
  `status` enum('HOLDING','PAID','CANCELLED','EXPIRED') DEFAULT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `inx_unique_trip_seat` (((case when (`status` in (_utf8mb4'SUCCESS',_utf8mb4'HOLDING')) then `Trip_Seat_ID` else NULL end))),
  KEY `Trip_Seat_ID` (`Trip_Seat_ID`),
  KEY `booking_order_id` (`booking_order_id`),
  KEY `arrival_id` (`arrival_id`),
  KEY `destination_id` (`destination_id`),
  CONSTRAINT `ticket_ibfk_1` FOREIGN KEY (`Trip_Seat_ID`) REFERENCES `trip_seat` (`ID`),
  CONSTRAINT `ticket_ibfk_2` FOREIGN KEY (`booking_order_id`) REFERENCES `booking_order` (`ID`),
  CONSTRAINT `ticket_ibfk_3` FOREIGN KEY (`arrival_id`) REFERENCES `route_stop` (`ID`),
  CONSTRAINT `ticket_ibfk_4` FOREIGN KEY (`destination_id`) REFERENCES `route_stop` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket`
--

LOCK TABLES `ticket` WRITE;
/*!40000 ALTER TABLE `ticket` DISABLE KEYS */;
INSERT INTO `ticket` VALUES ('1FMFBTADP0','ENYO2GXTD1','GI68B74WMO',69,72,10000,'CANCELLED','2026-05-18 14:21:55'),('1Q1UG42TOO','TLPDUUJU2K','XSLQNNLYDU',69,72,10000,'CANCELLED','2026-05-18 14:50:05'),('216UK9TMMM','ZD42J6EWR1','6Z86KPNGCN',1,4,2000,'EXPIRED','2026-05-14 15:30:49'),('3DTICSN69Y','4QOO9WSAV2','PAZS0JMQCM',79,80,10000,'CANCELLED','2026-06-11 15:24:41'),('47154CLW0O','31WZXTTF5J','CKQ7QHXDG5',70,72,1000,'CANCELLED','2026-05-18 15:48:05'),('48TDUAPI6J','0DH0NYLB88','HR1QGOZ60M',69,72,1000,'CANCELLED','2026-05-18 15:48:26'),('4W20HHM5Q0','KH9THV1RRH','EIFGRWYG8T',25,26,10000,'PAID','2026-06-11 08:59:35'),('5O4PVQP3NA','SBJ6EE95L2','9BNDF191JJ',82,88,10000,'CANCELLED','2026-06-11 13:16:40'),('666JKRUCGL','YSZ0THBOJ3','OGFS0O2JGD',1,61,120000,'EXPIRED','2026-05-12 06:57:12'),('7A4VXLOU9J','7CEPLX75CX','SH5E02WIH8',42,44,100000,'EXPIRED','2026-05-20 16:34:34'),('7AOTD3LFOG','52UU7IHCBH','Y2W3ML8FPR',79,81,10000,'HOLDING','2026-06-11 15:34:42'),('7B32ACECCF','6JCJE4ZMZV','J2WZZCQLO8',69,71,2000,'CANCELLED','2026-05-18 20:56:39'),('7CR9YVFENT','HG1UIOYJI9','6Z86KPNGCN',1,4,2000,'EXPIRED','2026-05-14 15:30:49'),('85S4OBELJN','PTE2N7LTUZ','5P5FBQQH1E',42,44,1000,'PAID','2026-06-08 09:30:12'),('8EI0PVK0WE','QRCQ3H70S4','SODMRNMLND',42,44,1000,'PAID','2026-05-12 06:59:51'),('8JNTAXAH8C','XQP72U279R','DY562ZEWNL',42,44,1000,'PAID','2026-05-12 07:29:43'),('8U0GHCFCW2','B2BKW59U1K','DY562ZEWNL',42,44,1000,'PAID','2026-05-12 07:29:43'),('9HZCU2Q88M','EKT5OB217X','VMG4323JVD',42,44,1000,'EXPIRED','2026-05-12 07:57:58'),('AR70B6UCAR','P7IJXAZJ56','EIFGRWYG8T',25,26,10000,'PAID','2026-06-11 08:59:35'),('B2ECI8VFL6','C0KFERYC0U','SODMRNMLND',42,44,1000,'PAID','2026-05-12 06:59:51'),('BHSB5Q8HEX','5X3YZAQV9Y','1TU4JVV1AJ',42,44,1000,'CANCELLED','2026-05-05 14:21:29'),('BILKF031MC','EKT5OB217X','1KF87T8SB6',42,44,1000,'PAID','2026-06-08 09:51:30'),('C3ORQTHLKA','0AXETETQNV','Y2W3ML8FPR',79,81,10000,'HOLDING','2026-06-11 15:34:42'),('CSRJGONHZU','XSET6DG4BO','BMPKWF25GQ',42,44,1000,'EXPIRED','2026-05-13 08:43:41'),('CTKP96TZ0K','HZY6ZY9SU4','HAKID8G4HN',42,44,3000,'PAID','2026-05-19 10:19:56'),('D3JFR89BOK','KYMK1WT3BY','BMPKWF25GQ',42,44,1000,'EXPIRED','2026-05-13 08:43:41'),('D4FLY3UDYK','VD1DKG7RA9','H6QW7MNZ13',42,44,1000,'EXPIRED','2026-05-14 00:30:02'),('DOOQCTR3FN','5X3YZAQV9Y','A1SDUL3AXA',42,44,1000,'PAID','2026-05-12 07:53:11'),('E2OO20VFM3','P2FZ38IX2I','C499087RYH',1,5,120000,'EXPIRED','2026-05-11 09:12:58'),('EXB1VTXI4J','EKT5OB217X','FJPDBME1FT',42,44,1000,'CANCELLED','2026-05-13 08:32:02'),('FG65UBG7U0','EKT5OB217X','IRBSYIT8GL',42,44,1000,'EXPIRED','2026-05-13 08:36:53'),('G45KP55XY7','G3493ZLRQZ','U7HAEQHW83',77,80,10000,'PAID','2026-06-11 15:59:24'),('HGFQ46GTO2','NYKGC0UPOQ','PAZS0JMQCM',79,80,10000,'PAID','2026-06-11 15:24:41'),('HZ32IJW4XF','2CX19GYW3F','MPJKY06RMM',69,72,10000,'PAID','2026-05-20 15:58:43'),('ITR76J8XQE','1GG9QQM37A','1N83XE9TUI',1,4,120000,'PAID','2026-05-05 14:16:43'),('IXO71DVNE5','IFW5VUKYFO','N13XUM50LI',69,71,10000,'CANCELLED','2026-05-18 14:47:15'),('IYVMQT8ZDM','QCBJ5POGFO','0JRG9QWP0Q',1,4,2000,'PAID','2026-05-14 15:35:58'),('J1CEW13909','XSET6DG4BO','PA3ONDRR6Y',42,44,1000,'CANCELLED','2026-05-13 08:42:01'),('J2BPZ28C79','4V7BQDFEFE','24QG6W36SK',69,71,10000,'CANCELLED','2026-05-18 15:13:22'),('J2UG9X1SSC','28R9ONWS04','RMRZIAMH5J',1,4,120000,'PAID','2026-05-05 14:11:19'),('JEOYC7L8NW','BB6YFDE8KK','1N83XE9TUI',1,4,120000,'PAID','2026-05-05 14:16:43'),('JH20J7UZPI','ABKE5V9E36','RMRZIAMH5J',1,4,120000,'PAID','2026-05-05 14:11:19'),('JP7J6FHWEQ','XSET6DG4BO','UI7U5I8G5C',42,44,1000,'EXPIRED','2026-05-12 08:31:32'),('JRE5JOF8IR','XQI1MJT4U8','IX7K94V8OL',69,71,1000,'CANCELLED','2026-05-18 15:47:42'),('KDYRPF0C2P','0423JQ7ZGE','J2WZZCQLO8',69,71,2000,'CANCELLED','2026-05-18 20:56:39'),('KZVUYCPYOI','1L0TYHMANU','U7Q4EPZWPR',42,44,1000,'EXPIRED','2026-05-12 07:11:33'),('L8EU53OGT8','ZHTCO9460W','O04T42R650',31,33,12000,'PAID','2026-05-15 13:45:36'),('LC99MZPZ17','20LRIUMUDH','X27EDW9WZ6',42,44,1000,'EXPIRED','2026-05-12 08:13:44'),('LFR4GRDBGO','1PJ3WFCQII','FJPDBME1FT',42,44,1000,'CANCELLED','2026-05-13 08:32:02'),('LLJ0ZLC1QF','HK0E8STX3N','AGBG7LOQSG',42,44,1000,'CANCELLED','2026-05-13 08:34:18'),('LW9TK661BS','2S2QORXLWU','9BNDF191JJ',82,88,10000,'CANCELLED','2026-06-11 13:16:40'),('M958EOM6V8','VD1DKG7RA9','5QLFVTMC3S',42,44,1000,'EXPIRED','2026-05-14 01:05:46'),('MR060TZPVJ','20LRIUMUDH','FS8IKK5VMF',42,44,1000,'PAID','2026-05-13 07:29:28'),('N4JH5BNJOJ','5W1EPLTWOA','JZI5P4BXG1',42,44,100000,'HOLDING','2026-05-20 16:35:09'),('NTNU5N42XA','VD1DKG7RA9','CLD9VPH1YU',42,44,1000,'PAID','2026-05-14 01:20:28'),('NVDFHBJJAG','4QOO9WSAV2','A7322X1VDD',77,81,10000,'PAID','2026-06-11 15:28:14'),('O1U2AEN8I0','E6COVMXT06','8W28G5GWOK',42,44,3000,'PAID','2026-05-15 14:38:08'),('O3PKIC23QN','JTQQ0CSND4','WEB9ONR5A6',82,88,10000,'PAID','2026-06-11 13:17:06'),('OJJT3G78MX','B369WILAMI','N13XUM50LI',69,71,10000,'CANCELLED','2026-05-18 14:47:15'),('P3HAPQIX3Y','NH6EW6V6RI','AGBG7LOQSG',42,44,1000,'CANCELLED','2026-05-13 08:34:18'),('PF8XM2HZYT','6HUYV3K0BM','DY562ZEWNL',42,44,1000,'PAID','2026-05-12 07:29:43'),('PI6J46OXHK','6Q8MG2K1CZ','N2939DK4YR',42,44,1000,'CANCELLED','2026-05-13 08:42:44'),('PSGHIK1NRT','KYMK1WT3BY','PA3ONDRR6Y',42,44,1000,'CANCELLED','2026-05-13 08:42:01'),('PXCG2A4UJX','49E8WBV6UL','DY562ZEWNL',42,44,1000,'PAID','2026-05-12 07:29:43'),('Q8UP7LNB5F','EUKZ9WIXLW','N2939DK4YR',42,44,1000,'CANCELLED','2026-05-13 08:42:44'),('R7UW88GQIU','GF9WKJVY27','1TU4JVV1AJ',42,44,1000,'PAID','2026-05-05 14:21:29'),('RMWR2UEODO','U3ODI5B96A','0I5C5G8HDZ',82,88,10000,'PAID','2026-06-11 13:09:59'),('S7FO8ZHGR4','NTOGRZVAX7','MPJKY06RMM',69,72,10000,'PAID','2026-05-20 15:58:43'),('SFDAEL6YK5','SIXFKCJ1MO','GI68B74WMO',69,72,10000,'CANCELLED','2026-05-18 14:21:55'),('SLV9DCU80U','1PJ3WFCQII','P4U6U5FMFK',42,44,1000,'HOLDING','2026-06-08 09:53:25'),('U6F0RMYDGK','4GUWAZIMEA','STLE8XQCBO',78,80,10000,'PAID','2026-06-11 15:32:19'),('UJ1AU6VZWQ','570X5UVS6P','WYBX22OTIQ',31,33,12000,'PAID','2026-05-15 14:10:18'),('VF1I2AXI7Q','54K0BDGMF5','Y2W3ML8FPR',79,81,10000,'HOLDING','2026-06-11 15:34:42'),('VQI4XRH88M','ZHTCO9460W','GKVZ40ZBOR',31,33,12000,'EXPIRED','2026-05-15 13:28:32'),('VRAMASBB59','YJWZ0JRI3A','IOFPQ6B2ZT',69,71,10000,'CANCELLED','2026-05-18 14:22:33'),('WP2D44OYTF','XSET6DG4BO','IMDPQAJ5U2',42,44,1000,'EXPIRED','2026-05-14 01:21:43'),('WUFZ2RAKHK','KCX4YSNO8C','HAKID8G4HN',42,44,3000,'PAID','2026-05-19 10:19:56'),('XG0O13FMTO','REA3UDKJMH','0I5C5G8HDZ',82,88,10000,'PAID','2026-06-11 13:09:59'),('XS2MEJEPSN','VQV6C0SRUE','C499087RYH',1,5,120000,'EXPIRED','2026-05-11 09:12:58'),('Y29F2AONW5','IJFGUG4QB6','FS8IKK5VMF',42,44,1000,'PAID','2026-05-13 07:29:28'),('Y2WXH6H6F9','IJFGUG4QB6','X27EDW9WZ6',42,44,1000,'EXPIRED','2026-05-12 08:13:44'),('Y7CVSVVFKD','D6OQR1R33Y','STLE8XQCBO',78,80,10000,'PAID','2026-06-11 15:32:19'),('YFF7P1HOZD','LB89QLA5PD','8W28G5GWOK',42,44,3000,'CANCELLED','2026-05-15 14:38:08'),('YIUZPCG2KG','JC7HZCF4HT','WEB9ONR5A6',82,88,10000,'PAID','2026-06-11 13:17:06'),('ZF9CSF0W0Y','2JFD2YRECG','J1RDWZSD1J',42,44,1000,'PAID','2026-05-13 07:30:32'),('ZX9QITD3Z3','P9ORDRAMNO','OGFS0O2JGD',1,61,120000,'EXPIRED','2026-05-12 06:57:12');
/*!40000 ALTER TABLE `ticket` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trip`
--

DROP TABLE IF EXISTS `trip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trip` (
  `ID` varchar(50) NOT NULL,
  `Bus_Company_ID` varchar(50) DEFAULT NULL,
  `Route_ID` int DEFAULT NULL,
  `Bus_Type_ID` int DEFAULT NULL,
  `License_Plate` varchar(50) DEFAULT NULL,
  `Driver` varchar(255) DEFAULT NULL,
  `status` enum('SCHEDULED','OPEN','CLOSED','CANCELLED') DEFAULT 'SCHEDULED',
  `departure_time` timestamp NOT NULL,
  `price` int DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `Route_ID` (`Route_ID`),
  KEY `Bus_Type_ID` (`Bus_Type_ID`),
  KEY `idx_company_route` (`Bus_Company_ID`,`Route_ID`),
  KEY `idx_company_departure` (`Bus_Company_ID`,`departure_time`),
  CONSTRAINT `trip_ibfk_1` FOREIGN KEY (`Bus_Company_ID`) REFERENCES `bus_company` (`ID`),
  CONSTRAINT `trip_ibfk_2` FOREIGN KEY (`Route_ID`) REFERENCES `route` (`ID`),
  CONSTRAINT `trip_ibfk_3` FOREIGN KEY (`Bus_Type_ID`) REFERENCES `bus_type` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trip`
--

LOCK TABLES `trip` WRITE;
/*!40000 ALTER TABLE `trip` DISABLE KEYS */;
INSERT INTO `trip` VALUES ('094BSO43UC','H1I5XL2B00',23,2,NULL,NULL,'SCHEDULED','2026-09-06 01:00:00',1000),('1PMJJG0SRV','H1I5XL2B00',38,1,'123312','12331','OPEN','2026-06-12 14:30:00',10000),('3RGT72SCZ4','H1I5XL2B00',20,27,NULL,NULL,'CLOSED','2026-05-14 17:00:00',3000),('5HET65CKFG','H1I5XL2B00',20,27,NULL,NULL,'SCHEDULED','2026-05-14 16:00:00',4000),('5VMU3PF7CM','H1I5XL2B00',22,1,NULL,NULL,'CLOSED','2026-06-11 03:00:00',10000),('9HVPRF2WRF','S4I5XL2B7K',34,25,NULL,NULL,'CLOSED','2026-05-20 05:00:00',1000),('B2250NHQAO','H1I5XL2B00',28,27,'76A-123456',NULL,'OPEN','2026-12-24 04:00:00',100000),('BOL2DTHP5W','H1I5XL2B00',23,27,'aaa',NULL,'OPEN','2026-12-24 04:00:00',100000),('C2I3OOBEPA','H1I5XL2B00',28,1,NULL,NULL,'CLOSED','2026-05-19 05:00:00',3000),('DYOHIZ2V1D','S4I5XL2B7K',34,25,NULL,NULL,'SCHEDULED','2026-05-19 08:00:00',12000),('E4KH8EOA5I','H1I5XL2B00',38,1,'312123','123123','OPEN','2026-06-14 14:30:00',10000),('FOGGXJ3UR1','S4I5XL2B7K',34,25,NULL,NULL,'CLOSED','2026-05-20 06:00:00',10000),('GX4ML4QSBX','S4I5XL2B7K',34,1,NULL,NULL,'CANCELLED','2026-05-20 13:00:00',2000),('GXHGR5JAOV','V3I5XL2B4W',39,2,NULL,NULL,'OPEN','2026-06-12 05:00:00',12000),('HDGNUABOFH','S4I5XL2B7K',34,27,NULL,NULL,'CLOSED','2026-12-24 03:00:00',10000),('HQ95GOU7PC','S4I5XL2B7K',34,25,NULL,NULL,'CANCELLED','2026-05-18 10:15:00',3000),('KQL08ODWOI','H1I5XL2B00',13,1,NULL,NULL,'OPEN','2026-12-24 03:00:00',120000),('LHW3CJO3RD','S4I5XL2B7K',37,25,NULL,NULL,'OPEN','2026-06-11 13:00:00',10000),('MSY3J0SQZX','S4I5XL2B7K',34,25,NULL,NULL,'CANCELLED','2026-05-20 13:00:00',10000),('MXJOQWK19D','S4I5XL2B7K',37,1,NULL,NULL,'OPEN','2026-06-12 13:00:00',12000),('NY1HVU27ZH','V3I5XL2B4W',39,25,'123321','123312','OPEN','2026-12-24 15:00:00',15000),('O436AMLNX4','H1I5XL2B00',28,1,NULL,NULL,'CLOSED','2026-05-17 15:00:00',3000),('P41A1PMG3J','S4I5XL2B7K',41,1,'123123','3123123','OPEN','2026-12-24 15:50:00',20000),('PWC5D4YC31','H1I5XL2B00',23,1,NULL,NULL,'SCHEDULED','2026-09-06 01:00:00',2000),('QQLIEYJYZZ','V3I5XL2B4W',40,27,NULL,NULL,'SCHEDULED','2026-06-12 04:00:00',10000),('RPNK4HUJTL','H1I5XL2B00',28,1,NULL,NULL,'OPEN','2026-12-24 00:00:00',1000),('RQKL886XN5','H1I5XL2B00',13,1,NULL,NULL,'CLOSED','2026-06-11 01:00:00',2000),('T36DIA8YD2','H1I5XL2B00',38,1,'123456','123456','OPEN','2026-06-11 14:40:00',10000),('UXEI02KBGL','H1I5XL2B00',23,1,NULL,NULL,'OPEN','2026-12-24 00:00:00',1000),('V7WE0SKYXP','V3I5XL2B4W',40,1,NULL,NULL,'OPEN','2026-06-12 06:00:00',2000),('VLLTWTBDIB','H1I5XL2B00',13,1,NULL,NULL,'CLOSED','2026-05-14 14:00:00',2000),('VPIUD51XBB','H1I5XL2B00',24,27,NULL,NULL,'CLOSED','2026-05-20 16:00:00',12000),('XBW0ZMRSJZ','H1I5XL2B00',23,26,NULL,NULL,'OPEN','2026-08-17 13:00:00',3000),('ZB0N8PD6JW','H1I5XL2B00',38,1,'123312','123123','OPEN','2026-06-11 14:30:00',10000);
/*!40000 ALTER TABLE `trip` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trip_rating`
--

DROP TABLE IF EXISTS `trip_rating`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trip_rating` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `service_quality` int NOT NULL,
  `punctuality` int NOT NULL,
  `safety` int NOT NULL,
  `cleanliness` int NOT NULL,
  `average_stars` double NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `booking_order_id` varchar(50) NOT NULL,
  `customer_id` varchar(50) NOT NULL,
  `bus_company_id` varchar(50) NOT NULL,
  `description` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_trip_rating_booking_order` (`booking_order_id`),
  KEY `idx_trip_rating_company` (`bus_company_id`),
  KEY `idx_trip_rating_customer` (`customer_id`),
  CONSTRAINT `fk_trip_rating_booking_order` FOREIGN KEY (`booking_order_id`) REFERENCES `booking_order` (`ID`),
  CONSTRAINT `fk_trip_rating_company` FOREIGN KEY (`bus_company_id`) REFERENCES `bus_company` (`ID`),
  CONSTRAINT `fk_trip_rating_customer` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`ID`),
  CONSTRAINT `chk_trip_rating_cleanliness` CHECK ((`cleanliness` between 1 and 5)),
  CONSTRAINT `chk_trip_rating_punctuality` CHECK ((`punctuality` between 1 and 5)),
  CONSTRAINT `chk_trip_rating_safety` CHECK ((`safety` between 1 and 5)),
  CONSTRAINT `chk_trip_rating_service_quality` CHECK ((`service_quality` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trip_rating`
--

LOCK TABLES `trip_rating` WRITE;
/*!40000 ALTER TABLE `trip_rating` DISABLE KEYS */;
INSERT INTO `trip_rating` VALUES (1,1,2,3,4,2.5,'2026-05-18 00:00:00','5QLFVTMC3S','CUST-0001','H1I5XL2B00','test description 1'),(2,2,3,4,5,3.5,'2026-05-18 01:00:00','A1SDUL3AXA','CUST-0001','H1I5XL2B00','test description 2');
/*!40000 ALTER TABLE `trip_rating` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trip_seat`
--

DROP TABLE IF EXISTS `trip_seat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trip_seat` (
  `ID` varchar(50) NOT NULL,
  `Seat` varchar(50) DEFAULT NULL,
  `Trip_ID` varchar(50) DEFAULT NULL,
  `status` enum('HELD','AVAILABLE','BOOKED') DEFAULT 'AVAILABLE',
  `price` int NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Trip_ID` (`Trip_ID`,`Seat`),
  CONSTRAINT `trip_seat_ibfk_1` FOREIGN KEY (`Trip_ID`) REFERENCES `trip` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trip_seat`
--

LOCK TABLES `trip_seat` WRITE;
/*!40000 ALTER TABLE `trip_seat` DISABLE KEYS */;
INSERT INTO `trip_seat` VALUES ('01PL4DZJQ9','A7','XBW0ZMRSJZ','AVAILABLE',3000),('02XFRA4LSI','A1','O436AMLNX4','AVAILABLE',3000),('03LXX5GKCB','B11','E4KH8EOA5I','AVAILABLE',10000),('0423JQ7ZGE','B2','GX4ML4QSBX','HELD',2000),('07QNXDD7F5','B7','O436AMLNX4','AVAILABLE',3000),('0AB4ND1M1G','A6','O436AMLNX4','AVAILABLE',3000),('0AXETETQNV','B5','LHW3CJO3RD','HELD',10000),('0CCCKA9O7D','A8','GXHGR5JAOV','AVAILABLE',12000),('0D8VG7D256','B8','V7WE0SKYXP','AVAILABLE',2000),('0DANU57K11','A5','9HVPRF2WRF','AVAILABLE',1000),('0DH0NYLB88','B2','9HVPRF2WRF','AVAILABLE',1000),('0FL93Y593P','B6','9HVPRF2WRF','AVAILABLE',1000),('0K2DOHM4RH','A16','C2I3OOBEPA','AVAILABLE',3000),('0O8IGY4YVT','A4','XBW0ZMRSJZ','AVAILABLE',3000),('0RDW8IFQEJ','B2','NY1HVU27ZH','AVAILABLE',15000),('0ZVU30G4VN','B17','5VMU3PF7CM','AVAILABLE',10000),('1118GUR01J','A13','5VMU3PF7CM','AVAILABLE',10000),('11JMSW9298','B9','9HVPRF2WRF','AVAILABLE',1000),('13NUSRF6RY','B13','UXEI02KBGL','AVAILABLE',1000),('14CARTBOGE','B7','ZB0N8PD6JW','AVAILABLE',10000),('15FDIP4JYF','A5','ZB0N8PD6JW','AVAILABLE',10000),('15J5G054V0','B16','V7WE0SKYXP','AVAILABLE',2000),('17F5MHL919','A7','P41A1PMG3J','AVAILABLE',20000),('17KRAIBSSU','A1','V7WE0SKYXP','AVAILABLE',2000),('19G0ZK3PTL','B5','XBW0ZMRSJZ','AVAILABLE',3000),('1D08OXNCW4','B1','V7WE0SKYXP','AVAILABLE',2000),('1EYDY6T4MW','A9','MXJOQWK19D','AVAILABLE',12000),('1GG9QQM37A','A5','KQL08ODWOI','BOOKED',120000),('1JM562HRVC','B14','MXJOQWK19D','AVAILABLE',12000),('1L0TYHMANU','A17','RPNK4HUJTL','AVAILABLE',1000),('1L3GRNM6O9','A5','T36DIA8YD2','AVAILABLE',10000),('1MB06PFLCX','B4','9HVPRF2WRF','AVAILABLE',1000),('1O1GBY7O84','B7','LHW3CJO3RD','AVAILABLE',10000),('1PJ3WFCQII','B4','RPNK4HUJTL','HELD',1000),('1R0UJO4P4B','B12','MXJOQWK19D','AVAILABLE',12000),('1R8O69JNWM','B5','ZB0N8PD6JW','AVAILABLE',10000),('1RTB6V5WUE','B8','GXHGR5JAOV','AVAILABLE',12000),('1SBOISXPHI','A10','O436AMLNX4','AVAILABLE',3000),('1VKDY3KWAC','A8','GX4ML4QSBX','AVAILABLE',2000),('1VTGFB7LDI','A3','9HVPRF2WRF','AVAILABLE',1000),('1X7DKCUPPX','B3','FOGGXJ3UR1','AVAILABLE',10000),('1XYIKW7SGZ','B11','LHW3CJO3RD','AVAILABLE',10000),('20F4GG2CDI','B11','KQL08ODWOI','AVAILABLE',120000),('20LRIUMUDH','B5','RPNK4HUJTL','BOOKED',1000),('20R7QL2F03','B11','HQ95GOU7PC','AVAILABLE',3000),('223LRSZJCS','A11','GX4ML4QSBX','AVAILABLE',2000),('22A9B5BAWA','B2','C2I3OOBEPA','AVAILABLE',3000),('22ZHN10W1G','A8','UXEI02KBGL','AVAILABLE',1000),('28GQ7DMD9N','B15','P41A1PMG3J','AVAILABLE',20000),('28R9ONWS04','B2','KQL08ODWOI','BOOKED',120000),('2AE4LFJVCX','B15','RQKL886XN5','AVAILABLE',2000),('2CTNOQVIUP','B5','C2I3OOBEPA','AVAILABLE',3000),('2CX19GYW3F','A1','HDGNUABOFH','BOOKED',10000),('2I7MYWBL4T','A2','V7WE0SKYXP','AVAILABLE',2000),('2IH7FFEJSY','B9','P41A1PMG3J','AVAILABLE',20000),('2JFD2YRECG','B8','RPNK4HUJTL','BOOKED',1000),('2MM4W9KTR6','B16','KQL08ODWOI','AVAILABLE',120000),('2NEMR530CW','B17','GXHGR5JAOV','AVAILABLE',12000),('2OPQLBLLGG','B9','T36DIA8YD2','AVAILABLE',10000),('2OWW2PBFFW','B3','GXHGR5JAOV','AVAILABLE',12000),('2PJQ5EMP2U','B8','VLLTWTBDIB','AVAILABLE',2000),('2Q9AG96ZXE','B11','C2I3OOBEPA','AVAILABLE',3000),('2QD0DOTJW4','A10','GXHGR5JAOV','AVAILABLE',12000),('2QT2LMUWOA','A9','GX4ML4QSBX','AVAILABLE',2000),('2RDQWBQ95U','A5','1PMJJG0SRV','AVAILABLE',10000),('2S2QORXLWU','A6','ZB0N8PD6JW','AVAILABLE',10000),('2TSJ8GWBKM','A13','ZB0N8PD6JW','AVAILABLE',10000),('2V1YNXTAXF','A1','RQKL886XN5','AVAILABLE',2000),('2WGZ0IV2UA','A16','5VMU3PF7CM','AVAILABLE',10000),('2WR1B1GZ2Q','A8','RPNK4HUJTL','AVAILABLE',1000),('2ZIR8OIJD8','A1','1PMJJG0SRV','AVAILABLE',10000),('30CO3WC3IJ','A17','UXEI02KBGL','AVAILABLE',1000),('313C38XNFU','B16','C2I3OOBEPA','AVAILABLE',3000),('31WZXTTF5J','A2','9HVPRF2WRF','AVAILABLE',1000),('32BIK1T0NJ','A3','MSY3J0SQZX','AVAILABLE',10000),('33GG29MXE9','A6','P41A1PMG3J','AVAILABLE',20000),('34SKF4HGG3','A6','T36DIA8YD2','AVAILABLE',10000),('35KM6A9O5O','A6','9HVPRF2WRF','AVAILABLE',1000),('366QPN5C1B','A3','GX4ML4QSBX','AVAILABLE',2000),('37JO6IIQ8C','A12','T36DIA8YD2','AVAILABLE',10000),('38FBDB2FLG','A6','C2I3OOBEPA','AVAILABLE',3000),('3GFX34W1RR','A4','UXEI02KBGL','AVAILABLE',1000),('3IT8Q3CGCP','A4','ZB0N8PD6JW','AVAILABLE',10000),('3IZ7945DK4','B9','V7WE0SKYXP','AVAILABLE',2000),('3JBNE3WDRY','A6','GXHGR5JAOV','AVAILABLE',12000),('3K7IZUKD6B','A8','LHW3CJO3RD','AVAILABLE',10000),('3KVO4E34DG','B2','MXJOQWK19D','AVAILABLE',12000),('3M8UZAJZDD','A1','VLLTWTBDIB','AVAILABLE',2000),('3RP4138KMJ','B3','MXJOQWK19D','AVAILABLE',12000),('3SE0JO86VE','A10','MXJOQWK19D','AVAILABLE',12000),('3T9XKV6BU3','A4','LHW3CJO3RD','AVAILABLE',10000),('3Z9MH12WN3','B6','C2I3OOBEPA','AVAILABLE',3000),('40HP37XTZ9','B7','NY1HVU27ZH','AVAILABLE',15000),('436I6CZUJC','A12','V7WE0SKYXP','AVAILABLE',2000),('4569UGP64M','B9','GXHGR5JAOV','AVAILABLE',12000),('45KB1Z3VMD','B14','5VMU3PF7CM','AVAILABLE',10000),('4675YXRAK2','B3','MSY3J0SQZX','AVAILABLE',10000),('49E8WBV6UL','A15','RPNK4HUJTL','BOOKED',1000),('4C2GGU3L9T','A17','O436AMLNX4','AVAILABLE',3000),('4EK5K4ENKD','B6','KQL08ODWOI','AVAILABLE',120000),('4EMQ54SIA5','A4','BOL2DTHP5W','AVAILABLE',100000),('4GHZ3C2OSQ','B9','KQL08ODWOI','AVAILABLE',120000),('4GUWAZIMEA','A1','LHW3CJO3RD','BOOKED',10000),('4GX272HP6I','A5','GXHGR5JAOV','AVAILABLE',12000),('4HAD0YXY82','B14','GXHGR5JAOV','AVAILABLE',12000),('4K6JEF8N5R','A5','VLLTWTBDIB','AVAILABLE',2000),('4KFUQMO2U5','A9','XBW0ZMRSJZ','AVAILABLE',3000),('4OQ6VDHBGW','B16','P41A1PMG3J','AVAILABLE',20000),('4P73RWT6ZB','B8','NY1HVU27ZH','AVAILABLE',15000),('4QEUUVOWLF','B16','MXJOQWK19D','AVAILABLE',12000),('4QOO9WSAV2','B1','LHW3CJO3RD','BOOKED',10000),('4TH92Q5FNE','B2','V7WE0SKYXP','AVAILABLE',2000),('4V7BQDFEFE','A4','MSY3J0SQZX','HELD',10000),('4XMBTGUHIU','A12','O436AMLNX4','AVAILABLE',3000),('52BS5DDXYV','A10','9HVPRF2WRF','AVAILABLE',1000),('52SMSVVJ6G','B6','V7WE0SKYXP','AVAILABLE',2000),('52UU7IHCBH','B6','LHW3CJO3RD','HELD',10000),('54K0BDGMF5','A6','LHW3CJO3RD','HELD',10000),('55MPSSXXJ3','A16','T36DIA8YD2','AVAILABLE',10000),('55YI9DRP6G','B3','XBW0ZMRSJZ','AVAILABLE',3000),('570X5UVS6P','A1','VPIUD51XBB','BOOKED',12000),('57NNXA95H0','B8','UXEI02KBGL','AVAILABLE',1000),('5EH2F5RIHX','B14','C2I3OOBEPA','AVAILABLE',3000),('5F9SFNX601','B6','MSY3J0SQZX','AVAILABLE',10000),('5FKAMTPY9N','A3','BOL2DTHP5W','AVAILABLE',100000),('5H99R0VMMP','A9','VLLTWTBDIB','AVAILABLE',2000),('5JZZB63WSQ','A11','NY1HVU27ZH','AVAILABLE',15000),('5KAWWC754T','B5','GXHGR5JAOV','AVAILABLE',12000),('5M5QX1DB7I','B4','E4KH8EOA5I','AVAILABLE',10000),('5MU3CU6ZIF','B3','GX4ML4QSBX','AVAILABLE',2000),('5QPMDFBG9Z','B8','LHW3CJO3RD','AVAILABLE',10000),('5S23S0043C','A11','RPNK4HUJTL','AVAILABLE',1000),('5SMNEH53FL','A14','MXJOQWK19D','AVAILABLE',12000),('5UR903G92M','A7','9HVPRF2WRF','AVAILABLE',1000),('5W1EPLTWOA','A1','B2250NHQAO','HELD',100000),('5X3YZAQV9Y','B1','RPNK4HUJTL','BOOKED',1000),('5XPFLETIXS','B7','FOGGXJ3UR1','AVAILABLE',10000),('5YF1JPEIS3','A3','RQKL886XN5','AVAILABLE',2000),('622B8ZXWY6','A5','XBW0ZMRSJZ','AVAILABLE',3000),('62M23G2GUG','B17','RQKL886XN5','AVAILABLE',2000),('655Z6UH9WW','B4','UXEI02KBGL','AVAILABLE',1000),('68X13PUHU4','B11','GX4ML4QSBX','AVAILABLE',2000),('6A55NCVPUW','A6','MXJOQWK19D','AVAILABLE',12000),('6CQNNP91EE','B12','HQ95GOU7PC','AVAILABLE',3000),('6DXY9LX1O3','B15','C2I3OOBEPA','AVAILABLE',3000),('6FWFJ7GXR4','A17','VLLTWTBDIB','AVAILABLE',2000),('6FZQLEFI72','A11','E4KH8EOA5I','AVAILABLE',10000),('6GONBFUGX3','A10','E4KH8EOA5I','AVAILABLE',10000),('6HUYV3K0BM','A9','RPNK4HUJTL','BOOKED',1000),('6JCCPJN8WU','A2','P41A1PMG3J','AVAILABLE',20000),('6JCJE4ZMZV','B1','GX4ML4QSBX','HELD',2000),('6JUGXECQ19','B5','T36DIA8YD2','AVAILABLE',10000),('6L4WHW2HL6','A3','MXJOQWK19D','AVAILABLE',12000),('6NDE6IIHIV','A14','T36DIA8YD2','AVAILABLE',10000),('6P8BIM5AEA','B12','GXHGR5JAOV','AVAILABLE',12000),('6Q8MG2K1CZ','B14','RPNK4HUJTL','AVAILABLE',1000),('6R84QM2ZE3','B6','ZB0N8PD6JW','AVAILABLE',10000),('71FU94OIYT','B1','XBW0ZMRSJZ','AVAILABLE',3000),('78GHRWT60U','B11','UXEI02KBGL','AVAILABLE',1000),('78H4JDA68A','A12','MXJOQWK19D','AVAILABLE',12000),('7CEPLX75CX','A2','B2250NHQAO','HELD',100000),('7DDXBLD58T','A6','KQL08ODWOI','AVAILABLE',120000),('7DJRXOJN69','B11','XBW0ZMRSJZ','AVAILABLE',3000),('7FOGL7KEJ9','B4','1PMJJG0SRV','AVAILABLE',10000),('7JUW2B5I9V','A12','HQ95GOU7PC','AVAILABLE',3000),('7JXIV246MK','A1','9HVPRF2WRF','AVAILABLE',1000),('7K3TFGLLBC','A10','LHW3CJO3RD','AVAILABLE',10000),('7L87FGB0L8','A17','XBW0ZMRSJZ','AVAILABLE',3000),('7N3CATVBBW','B5','MXJOQWK19D','AVAILABLE',12000),('7QUE6JCDZ1','A14','UXEI02KBGL','AVAILABLE',1000),('7QVIHMPNFO','A11','HQ95GOU7PC','AVAILABLE',3000),('7SEDSLH0T0','A5','E4KH8EOA5I','AVAILABLE',10000),('7SWY97VY90','B11','RQKL886XN5','AVAILABLE',2000),('7TJ2KSS9K4','A13','O436AMLNX4','AVAILABLE',3000),('7V3DVO1UNT','B12','MSY3J0SQZX','AVAILABLE',10000),('81E021HKG6','A14','V7WE0SKYXP','AVAILABLE',2000),('827AGH5SM2','A8','5VMU3PF7CM','AVAILABLE',10000),('82PRZDFJMT','B17','UXEI02KBGL','AVAILABLE',1000),('8557ZQIVRL','A4','VPIUD51XBB','AVAILABLE',12000),('85T137GG15','B13','ZB0N8PD6JW','AVAILABLE',10000),('88QDMTXL4X','B18','XBW0ZMRSJZ','AVAILABLE',3000),('89EQARZYQF','A15','GXHGR5JAOV','AVAILABLE',12000),('89P05RFGLY','A9','C2I3OOBEPA','AVAILABLE',3000),('8DTJW397ZC','B9','UXEI02KBGL','AVAILABLE',1000),('8G557R53NG','A3','3RGT72SCZ4','AVAILABLE',3000),('8H0GXI8WDF','B12','KQL08ODWOI','AVAILABLE',120000),('8HC80I9ZMG','B13','E4KH8EOA5I','AVAILABLE',10000),('8L08VH3669','B17','T36DIA8YD2','AVAILABLE',10000),('8L9GHVA7PK','B4','T36DIA8YD2','AVAILABLE',10000),('8OCG8UVIVP','A4','KQL08ODWOI','AVAILABLE',120000),('8OTHHJF0OW','B5','NY1HVU27ZH','AVAILABLE',15000),('8QJ9O2EL2Q','A1','NY1HVU27ZH','AVAILABLE',15000),('8RTH92GRJ6','A12','UXEI02KBGL','AVAILABLE',1000),('8ZIZOAZBQR','B15','KQL08ODWOI','AVAILABLE',120000),('8ZU8M63304','B1','MXJOQWK19D','AVAILABLE',12000),('91QSWAHVX5','B17','1PMJJG0SRV','AVAILABLE',10000),('92X3EQ3OZG','A6','NY1HVU27ZH','AVAILABLE',15000),('94Z2KSZCBG','B15','MXJOQWK19D','AVAILABLE',12000),('95LI64GLGC','A2','ZB0N8PD6JW','AVAILABLE',10000),('97FCN7584Q','A11','5VMU3PF7CM','AVAILABLE',10000),('97MZOQXVIY','B12','NY1HVU27ZH','AVAILABLE',15000),('9838Y2DM7D','A2','MXJOQWK19D','AVAILABLE',12000),('9BIC3ZDRF0','B11','5VMU3PF7CM','AVAILABLE',10000),('9EEM0X4OFM','B4','C2I3OOBEPA','AVAILABLE',3000),('9F6AS1O0OC','A1','T36DIA8YD2','AVAILABLE',10000),('9FG3T90L7C','A16','1PMJJG0SRV','AVAILABLE',10000),('9GGKGLN4AR','A15','RQKL886XN5','AVAILABLE',2000),('9HPHNCTWWA','A8','9HVPRF2WRF','AVAILABLE',1000),('9KHVLJCOCU','B8','HQ95GOU7PC','AVAILABLE',3000),('9L5ETNH8U3','A2','XBW0ZMRSJZ','AVAILABLE',3000),('9M9LMCCMUK','B9','HQ95GOU7PC','AVAILABLE',3000),('9N91KCSHMA','A6','HQ95GOU7PC','AVAILABLE',3000),('9NPA9KOL41','B5','UXEI02KBGL','AVAILABLE',1000),('9OQPQYNWRO','A17','KQL08ODWOI','AVAILABLE',120000),('9OU42RPZ1T','A10','RPNK4HUJTL','AVAILABLE',1000),('9Q4B01831R','A4','V7WE0SKYXP','AVAILABLE',2000),('9QJX3ZZM8K','A16','RQKL886XN5','AVAILABLE',2000),('9SOXFHMPRZ','A9','1PMJJG0SRV','AVAILABLE',10000),('9UI9RC1MIF','A4','T36DIA8YD2','AVAILABLE',10000),('9UTTZ4Z931','B6','GXHGR5JAOV','AVAILABLE',12000),('9WDGX9P84P','B12','C2I3OOBEPA','AVAILABLE',3000),('A46KUG5464','B5','HQ95GOU7PC','AVAILABLE',3000),('A6FCLRMS0Y','B13','XBW0ZMRSJZ','AVAILABLE',3000),('AA6H7PTQ0W','A9','V7WE0SKYXP','AVAILABLE',2000),('ABKE5V9E36','B1','KQL08ODWOI','BOOKED',120000),('ACQ0DQPGK6','A3','B2250NHQAO','AVAILABLE',100000),('AD0HZT8V4O','B11','FOGGXJ3UR1','AVAILABLE',10000),('AFFTKVUUII','A5','HQ95GOU7PC','AVAILABLE',3000),('AI50W4S6OL','B3','VLLTWTBDIB','AVAILABLE',2000),('AIZWODFBOZ','A14','P41A1PMG3J','AVAILABLE',20000),('ALS6JJBHUJ','B3','1PMJJG0SRV','AVAILABLE',10000),('AN23PHNMUF','B9','NY1HVU27ZH','AVAILABLE',15000),('AN6A62WJSU','B3','5VMU3PF7CM','AVAILABLE',10000),('ANAH0CPMPF','B6','MXJOQWK19D','AVAILABLE',12000),('ANN7N9ANYI','A8','ZB0N8PD6JW','AVAILABLE',10000),('AOLL7T1MJ6','B14','P41A1PMG3J','AVAILABLE',20000),('AOQYWFROJE','B14','GX4ML4QSBX','AVAILABLE',2000),('APADTE3GJS','B9','LHW3CJO3RD','AVAILABLE',10000),('AR8FIQZY34','B8','GX4ML4QSBX','AVAILABLE',2000),('ATHW0FTBBS','A16','P41A1PMG3J','AVAILABLE',20000),('ATJBCG9O15','B8','5VMU3PF7CM','AVAILABLE',10000),('AVOJC6GU9G','B17','MXJOQWK19D','AVAILABLE',12000),('AYB3108VKO','A4','9HVPRF2WRF','AVAILABLE',1000),('AYXBXC5GD7','B15','ZB0N8PD6JW','AVAILABLE',10000),('AYZ8292VLL','A12','1PMJJG0SRV','AVAILABLE',10000),('B0557DB2BA','B9','C2I3OOBEPA','AVAILABLE',3000),('B08BVZPD5M','B5','O436AMLNX4','AVAILABLE',3000),('B19JEVITV0','B16','O436AMLNX4','AVAILABLE',3000),('B2BKW59U1K','A12','RPNK4HUJTL','BOOKED',1000),('B2Y3MH6MI8','B4','RQKL886XN5','AVAILABLE',2000),('B369WILAMI','B1','MSY3J0SQZX','AVAILABLE',10000),('B39MGAGORK','B13','T36DIA8YD2','AVAILABLE',10000),('B4DEIJEP7C','A7','VLLTWTBDIB','AVAILABLE',2000),('B5VENVJ4U1','B2','GXHGR5JAOV','AVAILABLE',12000),('B81O4Q0G7B','A14','E4KH8EOA5I','AVAILABLE',10000),('B8EHKR6CZO','B17','KQL08ODWOI','AVAILABLE',120000),('B90VJJPZWL','A11','T36DIA8YD2','AVAILABLE',10000),('BAY899YNPT','A17','E4KH8EOA5I','AVAILABLE',10000),('BB6YFDE8KK','A2','KQL08ODWOI','BOOKED',120000),('BCE9NM136Q','B11','P41A1PMG3J','AVAILABLE',20000),('BETXVAQ93T','A8','P41A1PMG3J','AVAILABLE',20000),('BHK9DP5N7J','B14','T36DIA8YD2','AVAILABLE',10000),('BIED16RCTN','B5','MSY3J0SQZX','AVAILABLE',10000),('BJ4X8O4WRF','A10','MSY3J0SQZX','AVAILABLE',10000),('BMQ4IEKQLM','B9','MXJOQWK19D','AVAILABLE',12000),('BQURRNYTWB','B5','P41A1PMG3J','AVAILABLE',20000),('BSTTPDZQTV','A5','V7WE0SKYXP','AVAILABLE',2000),('BSU5E4AP8P','B17','VLLTWTBDIB','AVAILABLE',2000),('BVPPIBYWKI','B4','GX4ML4QSBX','AVAILABLE',2000),('BYS1GNSTS2','A8','VLLTWTBDIB','AVAILABLE',2000),('BZKGCVOXRT','B13','RQKL886XN5','AVAILABLE',2000),('C029TT5CE5','B4','XBW0ZMRSJZ','AVAILABLE',3000),('C0KFERYC0U','A1','RPNK4HUJTL','BOOKED',1000),('C23QD3JJ6I','A8','HQ95GOU7PC','AVAILABLE',3000),('C3NKMOIULN','B15','T36DIA8YD2','AVAILABLE',10000),('C7MQ9W61VL','B13','1PMJJG0SRV','AVAILABLE',10000),('C9H37B747R','B11','GXHGR5JAOV','AVAILABLE',12000),('CA9OSUA2LM','A12','GX4ML4QSBX','AVAILABLE',2000),('CC7YLH9AYR','B11','T36DIA8YD2','AVAILABLE',10000),('CE4SKK38CA','A13','P41A1PMG3J','AVAILABLE',20000),('CGHS0P4F6H','A2','HQ95GOU7PC','AVAILABLE',3000),('CGYZ3WRUJN','A3','VPIUD51XBB','AVAILABLE',12000),('CHPNQ2GW8Q','A15','5VMU3PF7CM','AVAILABLE',10000),('CMKRI6TJ4U','A9','RQKL886XN5','AVAILABLE',2000),('CS6LVVZA3B','A9','HQ95GOU7PC','AVAILABLE',3000),('CSBSCW5BBQ','B1','UXEI02KBGL','AVAILABLE',1000),('CTQLHY2FRN','A7','MSY3J0SQZX','AVAILABLE',10000),('CUM76K0KRI','B6','P41A1PMG3J','AVAILABLE',20000),('CUMJGLZY6P','B8','9HVPRF2WRF','AVAILABLE',1000),('CVQV8RE26S','A11','XBW0ZMRSJZ','AVAILABLE',3000),('D1FO7ZEDPR','A6','E4KH8EOA5I','AVAILABLE',10000),('D1NL8GU10M','B7','XBW0ZMRSJZ','AVAILABLE',3000),('D44FBK004G','B6','1PMJJG0SRV','AVAILABLE',10000),('D4T0K2A3CJ','B3','9HVPRF2WRF','AVAILABLE',1000),('D4ZH8Z77X8','B4','P41A1PMG3J','AVAILABLE',20000),('D6NRSLMLQC','A9','E4KH8EOA5I','AVAILABLE',10000),('D6OQR1R33Y','A3','LHW3CJO3RD','BOOKED',10000),('D88RPLDPF8','B14','VLLTWTBDIB','AVAILABLE',2000),('D9VMAKIR69','B4','HQ95GOU7PC','AVAILABLE',3000),('DAMPFFTTPS','B12','ZB0N8PD6JW','AVAILABLE',10000),('DBP2I55QRR','B3','ZB0N8PD6JW','AVAILABLE',10000),('DM8EIHN5B9','B7','P41A1PMG3J','AVAILABLE',20000),('DQ931C65QU','B6','VLLTWTBDIB','AVAILABLE',2000),('DRBB9DHLBM','B13','5VMU3PF7CM','AVAILABLE',10000),('DSKTNG0PMH','A11','RQKL886XN5','AVAILABLE',2000),('DW2FQOX96V','B10','MSY3J0SQZX','AVAILABLE',10000),('DWDQPAV9JL','B8','KQL08ODWOI','AVAILABLE',120000),('DZDQ96L0RI','B12','5VMU3PF7CM','AVAILABLE',10000),('DZNYQY11D0','A8','O436AMLNX4','AVAILABLE',3000),('E0ZV807WD7','B15','XBW0ZMRSJZ','AVAILABLE',3000),('E13DK030EW','B14','KQL08ODWOI','AVAILABLE',120000),('E5WU0I9JJY','B1','HQ95GOU7PC','AVAILABLE',3000),('E6COVMXT06','B2','O436AMLNX4','BOOKED',3000),('E7L3IC9NWY','B4','GXHGR5JAOV','AVAILABLE',12000),('E7MASE5X7I','A2','UXEI02KBGL','AVAILABLE',1000),('E8BWRUR4HB','B7','RQKL886XN5','AVAILABLE',2000),('EC2ZE9KBNY','A15','XBW0ZMRSJZ','AVAILABLE',3000),('EGAL43FS9S','B12','V7WE0SKYXP','AVAILABLE',2000),('EJ3HP4AU5S','A13','1PMJJG0SRV','AVAILABLE',10000),('EKT5OB217X','B3','RPNK4HUJTL','BOOKED',1000),('EMZCQX7R8K','B16','GX4ML4QSBX','AVAILABLE',2000),('ENYO2GXTD1','B1','FOGGXJ3UR1','AVAILABLE',10000),('EOCKVM51KV','B1','P41A1PMG3J','AVAILABLE',20000),('EP9Q9L1S4R','A2','5VMU3PF7CM','AVAILABLE',10000),('ERBKJE6229','A10','V7WE0SKYXP','AVAILABLE',2000),('EROKYOK4VK','B17','V7WE0SKYXP','AVAILABLE',2000),('ESWT7SRCI7','B16','VLLTWTBDIB','AVAILABLE',2000),('EUKZ9WIXLW','B13','RPNK4HUJTL','AVAILABLE',1000),('EUP7X0CD2A','A11','P41A1PMG3J','AVAILABLE',20000),('F125UHI0IP','A1','P41A1PMG3J','AVAILABLE',20000),('F2Y2BQWK0M','B13','GXHGR5JAOV','AVAILABLE',12000),('F42DDIE9LX','B3','HQ95GOU7PC','AVAILABLE',3000),('F4JG9GV7C5','B13','GX4ML4QSBX','AVAILABLE',2000),('FA5UG7YJL5','A2','T36DIA8YD2','AVAILABLE',10000),('FCPQ51I10P','B12','LHW3CJO3RD','AVAILABLE',10000),('FDT7WT201L','A13','MXJOQWK19D','AVAILABLE',12000),('FG0DYIZ38V','B4','NY1HVU27ZH','AVAILABLE',15000),('FISDSDD999','B10','MXJOQWK19D','AVAILABLE',12000),('FJVBDHVXL0','A7','1PMJJG0SRV','AVAILABLE',10000),('FLUVVMIEVJ','A11','MSY3J0SQZX','AVAILABLE',10000),('FMQJJISQB7','A7','C2I3OOBEPA','AVAILABLE',3000),('FO6LRH4GD5','A4','1PMJJG0SRV','AVAILABLE',10000),('FQCAUD7CBI','B10','P41A1PMG3J','AVAILABLE',20000),('FTO58DDHBL','B10','5VMU3PF7CM','AVAILABLE',10000),('FTQ1ZLMNBB','B11','9HVPRF2WRF','AVAILABLE',1000),('FU90J7H0DE','B2','E4KH8EOA5I','AVAILABLE',10000),('FUF343JH2R','B11','NY1HVU27ZH','AVAILABLE',15000),('FY04AVPKYL','A15','GX4ML4QSBX','AVAILABLE',2000),('FZ3XL5HL89','B16','E4KH8EOA5I','AVAILABLE',10000),('G2TKBLCKPD','B10','T36DIA8YD2','AVAILABLE',10000),('G3493ZLRQZ','A2','LHW3CJO3RD','BOOKED',10000),('G3GMMR5HIP','A3','V7WE0SKYXP','AVAILABLE',2000),('G5GRAUVOMZ','B11','V7WE0SKYXP','AVAILABLE',2000),('G6J2DAKK8H','B8','XBW0ZMRSJZ','AVAILABLE',3000),('G96MDC78PQ','A7','GXHGR5JAOV','AVAILABLE',12000),('GF9WKJVY27','A2','RPNK4HUJTL','BOOKED',1000),('GG6DGD4MU4','B1','GXHGR5JAOV','AVAILABLE',12000),('GHGETKF5B9','A7','ZB0N8PD6JW','AVAILABLE',10000),('GMYJF03H64','A15','O436AMLNX4','AVAILABLE',3000),('GNIRHCOOKP','B12','1PMJJG0SRV','AVAILABLE',10000),('GQDUM8470B','B6','NY1HVU27ZH','AVAILABLE',15000),('GRZ92K02C7','B6','E4KH8EOA5I','AVAILABLE',10000),('GT9TBRTFH2','A14','5VMU3PF7CM','AVAILABLE',10000),('GTXCS80PDK','B10','ZB0N8PD6JW','AVAILABLE',10000),('GUA5XF5V40','A17','5VMU3PF7CM','AVAILABLE',10000),('GUKZSIRYYM','B15','VLLTWTBDIB','AVAILABLE',2000),('GWGI0DN56E','B1','RQKL886XN5','AVAILABLE',2000),('H0GXWJ4QWE','B16','ZB0N8PD6JW','AVAILABLE',10000),('H1T9YTI6LO','B5','RQKL886XN5','AVAILABLE',2000),('H337ABWNBI','A8','FOGGXJ3UR1','AVAILABLE',10000),('H4KSGSPMMD','A7','RPNK4HUJTL','AVAILABLE',1000),('H5FGNYXF52','A9','9HVPRF2WRF','AVAILABLE',1000),('H5LI2VBVIG','B16','GXHGR5JAOV','AVAILABLE',12000),('H6YMPE6LG1','B10','KQL08ODWOI','AVAILABLE',120000),('H9M5WVP7YF','A5','5VMU3PF7CM','AVAILABLE',10000),('HEPN0D8TW9','A13','E4KH8EOA5I','AVAILABLE',10000),('HG1UIOYJI9','A2','VLLTWTBDIB','AVAILABLE',2000),('HGAURIX90H','A5','MSY3J0SQZX','AVAILABLE',10000),('HH0CQ8E1F5','B7','E4KH8EOA5I','AVAILABLE',10000),('HIN9IUTY6N','B17','E4KH8EOA5I','AVAILABLE',10000),('HK0E8STX3N','B7','RPNK4HUJTL','AVAILABLE',1000),('HKI4OYV76K','B3','C2I3OOBEPA','AVAILABLE',3000),('HLDCD60MYO','B13','KQL08ODWOI','AVAILABLE',120000),('HLMMSYFT6X','A14','GX4ML4QSBX','AVAILABLE',2000),('HM4651ZV36','A1','5VMU3PF7CM','AVAILABLE',10000),('HMITBY6O6P','B7','MXJOQWK19D','AVAILABLE',12000),('HOOGS26TQN','A12','GXHGR5JAOV','AVAILABLE',12000),('HPRJDWQ83T','A16','MXJOQWK19D','AVAILABLE',12000),('HSS7EGSHU6','A13','V7WE0SKYXP','AVAILABLE',2000),('HUQZA5TCP7','B10','C2I3OOBEPA','AVAILABLE',3000),('HUVUUYWCSF','B7','HQ95GOU7PC','AVAILABLE',3000),('HWNWV1NQZS','A13','GXHGR5JAOV','AVAILABLE',12000),('HZY6ZY9SU4','A2','C2I3OOBEPA','BOOKED',3000),('I2LRJN9CSN','B16','1PMJJG0SRV','AVAILABLE',10000),('I2P0VUIQ73','B7','GX4ML4QSBX','AVAILABLE',2000),('I38X705IW8','A3','T36DIA8YD2','AVAILABLE',10000),('I4DCB3YAQK','A1','XBW0ZMRSJZ','AVAILABLE',3000),('I4VUPVY3DE','A2','RQKL886XN5','AVAILABLE',2000),('I78SB1GUCT','B11','MXJOQWK19D','AVAILABLE',12000),('I7IH9G7YKF','B10','1PMJJG0SRV','AVAILABLE',10000),('I7OES0YMZD','A5','RQKL886XN5','AVAILABLE',2000),('IANFBCOKOY','B10','GXHGR5JAOV','AVAILABLE',12000),('ID5Y3MA89X','B13','O436AMLNX4','AVAILABLE',3000),('IF93ARU9VE','B17','C2I3OOBEPA','AVAILABLE',3000),('IFW5VUKYFO','B2','MSY3J0SQZX','AVAILABLE',10000),('IHSAMW85A7','B3','UXEI02KBGL','AVAILABLE',1000),('IHVXO0N5SI','B12','E4KH8EOA5I','AVAILABLE',10000),('IJAH6IS7YZ','A4','FOGGXJ3UR1','AVAILABLE',10000),('IJFGUG4QB6','B2','RPNK4HUJTL','BOOKED',1000),('IJZ32IXNV2','B2','P41A1PMG3J','AVAILABLE',20000),('IJZRGA8DLV','A13','KQL08ODWOI','AVAILABLE',120000),('IM78SOHO9F','B11','ZB0N8PD6JW','AVAILABLE',10000),('IQTVB5BMT0','A10','FOGGXJ3UR1','AVAILABLE',10000),('IR40A37YVO','B8','ZB0N8PD6JW','AVAILABLE',10000),('IRQ7ITAT08','A11','VLLTWTBDIB','AVAILABLE',2000),('IUN1REBW3A','B9','O436AMLNX4','AVAILABLE',3000),('IWJUSOQGFE','B5','1PMJJG0SRV','AVAILABLE',10000),('IXZMFBA47B','A15','E4KH8EOA5I','AVAILABLE',10000),('IYI7TD1JN9','A3','HDGNUABOFH','AVAILABLE',10000),('IZBUBPFR5N','A6','GX4ML4QSBX','AVAILABLE',2000),('J24JXMR3KY','A5','GX4ML4QSBX','AVAILABLE',2000),('J52WLW8SLG','B12','9HVPRF2WRF','AVAILABLE',1000),('J5GLMJNUSU','A2','O436AMLNX4','AVAILABLE',3000),('J6FFWJDP3N','B6','HQ95GOU7PC','AVAILABLE',3000),('J9E04KDLIV','A12','MSY3J0SQZX','AVAILABLE',10000),('JA7LUORR98','B15','V7WE0SKYXP','AVAILABLE',2000),('JA9YZTXJ4A','A12','C2I3OOBEPA','AVAILABLE',3000),('JAKG2YMBBH','B4','VLLTWTBDIB','AVAILABLE',2000),('JC7HZCF4HT','A15','ZB0N8PD6JW','BOOKED',10000),('JCR7EVXKC9','B10','NY1HVU27ZH','AVAILABLE',15000),('JDV1A8XZ1S','A9','KQL08ODWOI','AVAILABLE',120000),('JEWWFMI9QB','A15','T36DIA8YD2','AVAILABLE',10000),('JFS9306CWU','B9','RQKL886XN5','AVAILABLE',2000),('JGJJX8WZD3','A2','1PMJJG0SRV','AVAILABLE',10000),('JJ8TS2BE4P','A11','O436AMLNX4','AVAILABLE',3000),('JK3SV9TADU','B2','RQKL886XN5','AVAILABLE',2000),('JK9G64GYG2','B9','FOGGXJ3UR1','AVAILABLE',10000),('JLDXOP5EHW','B12','UXEI02KBGL','AVAILABLE',1000),('JLOTS4PEAR','A15','VLLTWTBDIB','AVAILABLE',2000),('JQHCKI5VR9','B1','1PMJJG0SRV','AVAILABLE',10000),('JS0E3538TJ','B3','V7WE0SKYXP','AVAILABLE',2000),('JTQQ0CSND4','A12','ZB0N8PD6JW','BOOKED',10000),('JVDAPDK8L4','B3','LHW3CJO3RD','AVAILABLE',10000),('JWHJQ6Z5PP','A7','HQ95GOU7PC','AVAILABLE',3000),('JYNJLB16L8','B11','MSY3J0SQZX','AVAILABLE',10000),('JZS946D8U5','B8','E4KH8EOA5I','AVAILABLE',10000),('K68GH765NF','A8','RQKL886XN5','AVAILABLE',2000),('K77E90XCZ8','A16','GXHGR5JAOV','AVAILABLE',12000),('K7AVL2CG0C','B8','1PMJJG0SRV','AVAILABLE',10000),('K96TBFV4HC','B2','UXEI02KBGL','AVAILABLE',1000),('KCX4YSNO8C','B1','C2I3OOBEPA','BOOKED',3000),('KH9THV1RRH','B2','5VMU3PF7CM','BOOKED',10000),('KJM9UVM5VA','A8','MXJOQWK19D','AVAILABLE',12000),('KKUNLAN0O1','B10','RPNK4HUJTL','AVAILABLE',1000),('KL49VNNJWM','B9','GX4ML4QSBX','AVAILABLE',2000),('KMB61RZZXQ','B7','1PMJJG0SRV','AVAILABLE',10000),('KMTDA606WS','A3','C2I3OOBEPA','AVAILABLE',3000),('KOL287Y4BO','B14','E4KH8EOA5I','AVAILABLE',10000),('KPCPECZSJ7','B2','1PMJJG0SRV','AVAILABLE',10000),('KSN717B6Z3','B8','C2I3OOBEPA','AVAILABLE',3000),('KTAF6H93XW','B9','VLLTWTBDIB','AVAILABLE',2000),('KTFUAXBROY','A3','O436AMLNX4','AVAILABLE',3000),('KTIREIK31M','B8','O436AMLNX4','AVAILABLE',3000),('KTTGP0KCDR','A4','O436AMLNX4','AVAILABLE',3000),('KW5VA94FH7','A1','HQ95GOU7PC','AVAILABLE',3000),('KWHV99OIZ4','B5','V7WE0SKYXP','AVAILABLE',2000),('KXA9TU5OE4','B12','RQKL886XN5','AVAILABLE',2000),('KXGPYHNU1P','B5','VLLTWTBDIB','AVAILABLE',2000),('KYMK1WT3BY','B16','RPNK4HUJTL','AVAILABLE',1000),('KYPCZUZTTA','A11','KQL08ODWOI','AVAILABLE',120000),('L1YVVJC7EL','A15','P41A1PMG3J','AVAILABLE',20000),('L2XTQ7Q2X9','B16','UXEI02KBGL','AVAILABLE',1000),('L369HNZ9AB','A17','GXHGR5JAOV','AVAILABLE',12000),('L53PWHQGTN','A8','T36DIA8YD2','AVAILABLE',10000),('L53T5JTMJ6','B10','9HVPRF2WRF','AVAILABLE',1000),('L6AIDJC7L3','B5','KQL08ODWOI','AVAILABLE',120000),('L9QLG02RL1','B14','1PMJJG0SRV','AVAILABLE',10000),('LB89QLA5PD','B1','O436AMLNX4','AVAILABLE',3000),('LC9IC85X7H','A7','RQKL886XN5','AVAILABLE',2000),('LEGA16O6A3','B4','LHW3CJO3RD','AVAILABLE',10000),('LEPRWVZ6KX','B4','V7WE0SKYXP','AVAILABLE',2000),('LHJX1XPL2Q','A4','3RGT72SCZ4','AVAILABLE',3000),('LOGRJK9SW7','A9','NY1HVU27ZH','AVAILABLE',15000),('LOWZ1COZHB','B4','MSY3J0SQZX','AVAILABLE',10000),('LOXUM2E7EY','A14','KQL08ODWOI','AVAILABLE',120000),('LPH72R8YTP','A1','3RGT72SCZ4','AVAILABLE',3000),('LPOZA4PH82','A9','LHW3CJO3RD','AVAILABLE',10000),('LQ1IMDWO3N','A8','KQL08ODWOI','AVAILABLE',120000),('LR9391OP1D','A8','C2I3OOBEPA','AVAILABLE',3000),('LTAWST9R3U','B8','T36DIA8YD2','AVAILABLE',10000),('LUO7HD5OID','B1','T36DIA8YD2','AVAILABLE',10000),('LUW9PQZ9FD','B2','HQ95GOU7PC','AVAILABLE',3000),('LX3M9N6BI2','A4','GXHGR5JAOV','AVAILABLE',12000),('LZ53ZO4JVH','B3','RQKL886XN5','AVAILABLE',2000),('LZHP7MZUCK','A8','NY1HVU27ZH','AVAILABLE',15000),('M0FNF343ZV','B10','XBW0ZMRSJZ','AVAILABLE',3000),('M31868DRKJ','A8','XBW0ZMRSJZ','AVAILABLE',3000),('M4BL7G1B7Q','A17','V7WE0SKYXP','AVAILABLE',2000),('M69QMC83UO','A7','MXJOQWK19D','AVAILABLE',12000),('M6OF7NN02A','A3','FOGGXJ3UR1','AVAILABLE',10000),('M6W6T6VXKB','A7','FOGGXJ3UR1','AVAILABLE',10000),('MBVHTY0JYA','B9','MSY3J0SQZX','AVAILABLE',10000),('MEDJWFAZXJ','B6','5VMU3PF7CM','AVAILABLE',10000),('MIFCHKUUBL','B8','RQKL886XN5','AVAILABLE',2000),('MK5VPJJHXY','B5','5VMU3PF7CM','AVAILABLE',10000),('MN54IJWUW0','A1','UXEI02KBGL','AVAILABLE',1000),('MN69H6R5NV','B10','LHW3CJO3RD','AVAILABLE',10000),('MO5UXQGU7U','B15','5VMU3PF7CM','AVAILABLE',10000),('MQHHFC8L89','B6','UXEI02KBGL','AVAILABLE',1000),('MQHTPJ31G5','A3','VLLTWTBDIB','AVAILABLE',2000),('MRACI8C0TZ','B5','FOGGXJ3UR1','AVAILABLE',10000),('MTAI6IDH12','B11','O436AMLNX4','AVAILABLE',3000),('MUD2J6C6IC','A1','MSY3J0SQZX','AVAILABLE',10000),('MZZW4RICAZ','B4','ZB0N8PD6JW','AVAILABLE',10000),('N26Q44FZS6','A10','GX4ML4QSBX','AVAILABLE',2000),('NBDJVZ9DAN','A18','XBW0ZMRSJZ','AVAILABLE',3000),('NGMRO399XT','A4','HQ95GOU7PC','AVAILABLE',3000),('NH6EW6V6RI','B6','RPNK4HUJTL','AVAILABLE',1000),('NICFUJQLG4','B9','ZB0N8PD6JW','AVAILABLE',10000),('NIP9SAEA77','B3','E4KH8EOA5I','AVAILABLE',10000),('NIZRQYGK3C','A10','HQ95GOU7PC','AVAILABLE',3000),('NL2XYQ34EB','A12','RQKL886XN5','AVAILABLE',2000),('NL89TCYHAR','B14','O436AMLNX4','AVAILABLE',3000),('NNS20VS7ON','A6','FOGGXJ3UR1','AVAILABLE',10000),('NO82JRFYBS','B10','V7WE0SKYXP','AVAILABLE',2000),('NSWRO3DDFF','A1','GX4ML4QSBX','AVAILABLE',2000),('NTOGRZVAX7','A2','HDGNUABOFH','BOOKED',10000),('NX9X5RA3ER','A16','VLLTWTBDIB','AVAILABLE',2000),('NYKGC0UPOQ','B2','LHW3CJO3RD','BOOKED',10000),('NYZY69FQ9U','B15','E4KH8EOA5I','AVAILABLE',10000),('O0F22MBC72','B2','T36DIA8YD2','AVAILABLE',10000),('O24IZYPOP1','B5','E4KH8EOA5I','AVAILABLE',10000),('O3ERAJ2RF3','A14','1PMJJG0SRV','AVAILABLE',10000),('O3XPUF8GYC','A6','UXEI02KBGL','AVAILABLE',1000),('O4QLX27ME9','A4','NY1HVU27ZH','AVAILABLE',15000),('O4ZND5CN1Z','A16','UXEI02KBGL','AVAILABLE',1000),('O5ZSB9YHT8','A14','RPNK4HUJTL','AVAILABLE',1000),('O6FTHLFQPM','B17','O436AMLNX4','AVAILABLE',3000),('O8B4NIRTR9','A4','5VMU3PF7CM','AVAILABLE',10000),('OAWPA7ZRBF','A4','E4KH8EOA5I','AVAILABLE',10000),('OB184F8ENT','A3','NY1HVU27ZH','AVAILABLE',15000),('OEBVHKRCUW','A14','RQKL886XN5','AVAILABLE',2000),('OEJK5PECEK','B15','O436AMLNX4','AVAILABLE',3000),('OFGQDUNOOU','A11','MXJOQWK19D','AVAILABLE',12000),('OGSMJ8LFME','B7','GXHGR5JAOV','AVAILABLE',12000),('OL82CL45CP','A7','5VMU3PF7CM','AVAILABLE',10000),('ON004VJE1A','A5','NY1HVU27ZH','AVAILABLE',15000),('ONOQ1MRXWL','A13','T36DIA8YD2','AVAILABLE',10000),('OOVXKRS45P','B9','1PMJJG0SRV','AVAILABLE',10000),('ORIF0K291Y','A10','RQKL886XN5','AVAILABLE',2000),('OSNKH60B54','A9','FOGGXJ3UR1','AVAILABLE',10000),('OTPWBICC8H','A17','T36DIA8YD2','AVAILABLE',10000),('OXXUITN2MR','B10','FOGGXJ3UR1','AVAILABLE',10000),('OYH729ZB46','A3','1PMJJG0SRV','AVAILABLE',10000),('OYT97LXOF0','A16','O436AMLNX4','AVAILABLE',3000),('OYYF45D6WJ','B17','ZB0N8PD6JW','AVAILABLE',10000),('P0RKCTMTZI','A6','V7WE0SKYXP','AVAILABLE',2000),('P1MDDE3Y3S','A13','VLLTWTBDIB','AVAILABLE',2000),('P2FZ38IX2I','B3','KQL08ODWOI','AVAILABLE',120000),('P49MQT6E7Q','B12','VLLTWTBDIB','AVAILABLE',2000),('P4S4MI5OEX','A17','C2I3OOBEPA','AVAILABLE',3000),('P7IJXAZJ56','B1','5VMU3PF7CM','BOOKED',10000),('P9ORDRAMNO','A1','KQL08ODWOI','AVAILABLE',120000),('P9QL7U9E2R','B3','O436AMLNX4','AVAILABLE',3000),('PB86KO53TF','B4','FOGGXJ3UR1','AVAILABLE',10000),('PFUS5M5ULF','A7','LHW3CJO3RD','AVAILABLE',10000),('PHFWEC3WRC','A14','ZB0N8PD6JW','AVAILABLE',10000),('PJP2K3TL7V','A17','GX4ML4QSBX','AVAILABLE',2000),('PJV65T25RA','A10','KQL08ODWOI','AVAILABLE',120000),('PNORKVV29S','B10','GX4ML4QSBX','AVAILABLE',2000),('PP8V1MY56J','B11','1PMJJG0SRV','AVAILABLE',10000),('PR2IPMJ797','B9','XBW0ZMRSJZ','AVAILABLE',3000),('PR2TM0AX5G','A12','E4KH8EOA5I','AVAILABLE',10000),('PSU90XQINC','A10','XBW0ZMRSJZ','AVAILABLE',3000),('PTBUPKLB27','A11','ZB0N8PD6JW','AVAILABLE',10000),('PTE2N7LTUZ','A5','RPNK4HUJTL','BOOKED',1000),('PTYFQRKBSM','B15','UXEI02KBGL','AVAILABLE',1000),('PVDQJNY4LT','A5','LHW3CJO3RD','AVAILABLE',10000),('PWHLHS9KLA','A8','1PMJJG0SRV','AVAILABLE',10000),('PYPI2DKMBQ','A5','UXEI02KBGL','AVAILABLE',1000),('PZGW5R9509','A6','5VMU3PF7CM','AVAILABLE',10000),('Q40MCD4HLE','A4','VLLTWTBDIB','AVAILABLE',2000),('Q6KQ2VTLNG','A12','KQL08ODWOI','AVAILABLE',120000),('Q7CNX5YSWR','A6','XBW0ZMRSJZ','AVAILABLE',3000),('Q9LA8KRCW8','A6','RQKL886XN5','AVAILABLE',2000),('QB1ZME2PF5','A14','XBW0ZMRSJZ','AVAILABLE',3000),('QCBJ5POGFO','B2','VLLTWTBDIB','BOOKED',2000),('QCYW1UZMEJ','B2','ZB0N8PD6JW','AVAILABLE',10000),('QELDH1RM2G','A5','MXJOQWK19D','AVAILABLE',12000),('QEYI0DEVZX','B12','O436AMLNX4','AVAILABLE',3000),('QHQXL967P5','B8','FOGGXJ3UR1','AVAILABLE',10000),('QIJBKQDITF','B12','XBW0ZMRSJZ','AVAILABLE',3000),('QKXY0OJK6X','B4','5VMU3PF7CM','AVAILABLE',10000),('QL91K76GZV','A14','VLLTWTBDIB','AVAILABLE',2000),('QLW7OHSZ8Y','B13','VLLTWTBDIB','AVAILABLE',2000),('QMSGX5TKL9','A1','MXJOQWK19D','AVAILABLE',12000),('QQ89IP5BYC','B14','V7WE0SKYXP','AVAILABLE',2000),('QRCQ3H70S4','A3','RPNK4HUJTL','BOOKED',1000),('QSG9RV8KDQ','B14','RQKL886XN5','AVAILABLE',2000),('QSHKKKSU2A','A17','1PMJJG0SRV','AVAILABLE',10000),('QSYE1UF4LX','B15','1PMJJG0SRV','AVAILABLE',10000),('QTNIAVFOB6','A7','O436AMLNX4','AVAILABLE',3000),('QUG2X0DW5W','A16','XBW0ZMRSJZ','AVAILABLE',3000),('QVA678W4V5','A1','E4KH8EOA5I','AVAILABLE',10000),('QVCC5V2RP5','A13','RQKL886XN5','AVAILABLE',2000),('QWOCG0KXY2','B14','XBW0ZMRSJZ','AVAILABLE',3000),('R477UY8QDW','B6','RQKL886XN5','AVAILABLE',2000),('R7QM9F2L2K','B15','GXHGR5JAOV','AVAILABLE',12000),('RATSK7B2RY','B10','O436AMLNX4','AVAILABLE',3000),('RD0PCGXO1J','A7','T36DIA8YD2','AVAILABLE',10000),('REA3UDKJMH','A1','ZB0N8PD6JW','BOOKED',10000),('RFH6I8K2DI','B7','5VMU3PF7CM','AVAILABLE',10000),('RFTSZYQJNB','A9','5VMU3PF7CM','AVAILABLE',10000),('RFUNTM86LP','B13','MXJOQWK19D','AVAILABLE',12000),('RGH8WPXDXM','A4','GX4ML4QSBX','AVAILABLE',2000),('RIKK7IBZE7','A14','GXHGR5JAOV','AVAILABLE',12000),('RL1FSZ6UY7','A5','FOGGXJ3UR1','AVAILABLE',10000),('RMRY1ZZI7K','B7','T36DIA8YD2','AVAILABLE',10000),('RN2ST6G71P','A3','XBW0ZMRSJZ','AVAILABLE',3000),('ROG0XQDFTF','B12','T36DIA8YD2','AVAILABLE',10000),('RVXKDPAUWD','B6','XBW0ZMRSJZ','AVAILABLE',3000),('RZ7IDK5RFF','A10','NY1HVU27ZH','AVAILABLE',15000),('S0RCLWFVS1','B8','P41A1PMG3J','AVAILABLE',20000),('S14ZCWZ1R2','B1','NY1HVU27ZH','AVAILABLE',15000),('S322PFZSVM','B4','O436AMLNX4','AVAILABLE',3000),('S38UEQ44D1','A12','P41A1PMG3J','AVAILABLE',20000),('S65MRZ44QC','A15','MXJOQWK19D','AVAILABLE',12000),('S7I41XOKM3','A8','V7WE0SKYXP','AVAILABLE',2000),('S9DQJ8YDYN','A15','1PMJJG0SRV','AVAILABLE',10000),('SBJ6EE95L2','A9','ZB0N8PD6JW','AVAILABLE',10000),('SBMFCK52Y9','A12','XBW0ZMRSJZ','AVAILABLE',3000),('SC7L1WH2CW','A2','GX4ML4QSBX','AVAILABLE',2000),('SCZJ8ES1IF','A3','UXEI02KBGL','AVAILABLE',1000),('SGWIUHLZTR','A9','P41A1PMG3J','AVAILABLE',20000),('SIXFKCJ1MO','B2','FOGGXJ3UR1','AVAILABLE',10000),('SKJUN0BZYK','A4','P41A1PMG3J','AVAILABLE',20000),('SNAPX2CSI7','A10','UXEI02KBGL','AVAILABLE',1000),('SNEQG9B5AJ','B13','C2I3OOBEPA','AVAILABLE',3000),('SO1B5V6KZF','A16','E4KH8EOA5I','AVAILABLE',10000),('SOHOK4YXSO','B7','C2I3OOBEPA','AVAILABLE',3000),('SPHZUP54SI','A3','E4KH8EOA5I','AVAILABLE',10000),('SU660A7H47','A10','VLLTWTBDIB','AVAILABLE',2000),('SWH6XAGBW5','B5','9HVPRF2WRF','AVAILABLE',1000),('SWM5PODVGJ','A11','C2I3OOBEPA','AVAILABLE',3000),('SZ3RK4HQ2S','B4','MXJOQWK19D','AVAILABLE',12000),('T0V62L8E3D','A17','RQKL886XN5','AVAILABLE',2000),('T1YOJ9MJGK','A4','RPNK4HUJTL','AVAILABLE',1000),('T4ZYFEW4FK','A12','9HVPRF2WRF','AVAILABLE',1000),('T7B0PRQQPJ','A11','UXEI02KBGL','AVAILABLE',1000),('T811KJVNEA','A1','FOGGXJ3UR1','AVAILABLE',10000),('T8BWS74YER','A13','GX4ML4QSBX','AVAILABLE',2000),('T8UEH3HFLJ','A1','BOL2DTHP5W','AVAILABLE',100000),('T9X9TE5QBH','B7','KQL08ODWOI','AVAILABLE',120000),('TD1OWWL8KE','A2','E4KH8EOA5I','AVAILABLE',10000),('TDX4324JY1','B17','P41A1PMG3J','AVAILABLE',20000),('TFKHXMN05L','A2','NY1HVU27ZH','AVAILABLE',15000),('TFPZC672JQ','B16','T36DIA8YD2','AVAILABLE',10000),('TLPDUUJU2K','A2','MSY3J0SQZX','AVAILABLE',10000),('TN2K3GPKEI','B12','GX4ML4QSBX','AVAILABLE',2000),('TO4OVOPL6G','A1','GXHGR5JAOV','AVAILABLE',12000),('TOUEW4SZI0','A13','UXEI02KBGL','AVAILABLE',1000),('TQSKLX5WJ2','A14','O436AMLNX4','AVAILABLE',3000),('TRGOJLTUAW','A10','ZB0N8PD6JW','AVAILABLE',10000),('TS08M94HFR','B17','XBW0ZMRSJZ','AVAILABLE',3000),('TSK3NQP2HK','A7','GX4ML4QSBX','AVAILABLE',2000),('TTBK5RPZ79','A12','VLLTWTBDIB','AVAILABLE',2000),('TWKVJPVPMK','A11','LHW3CJO3RD','AVAILABLE',10000),('TYS25LYSP2','B7','UXEI02KBGL','AVAILABLE',1000),('U00NXDKZ4Y','A6','MSY3J0SQZX','AVAILABLE',10000),('U0YV1Q1ET4','A2','BOL2DTHP5W','AVAILABLE',100000),('U3ODI5B96A','A3','ZB0N8PD6JW','BOOKED',10000),('U8J6ZZDHUY','A4','RQKL886XN5','AVAILABLE',2000),('U92AQ4GF6U','B10','VLLTWTBDIB','AVAILABLE',2000),('U9NR142AK3','A16','KQL08ODWOI','AVAILABLE',120000),('UAGC5CVUWU','B16','XBW0ZMRSJZ','AVAILABLE',3000),('UCJ70LNHVV','A12','5VMU3PF7CM','AVAILABLE',10000),('UH903SQ4DP','B7','VLLTWTBDIB','AVAILABLE',2000),('UN8K8OEF0Q','A7','KQL08ODWOI','AVAILABLE',120000),('UPD17CSU35','A16','ZB0N8PD6JW','AVAILABLE',10000),('UT8LW3FHC9','A10','T36DIA8YD2','AVAILABLE',10000),('UU14WQCVT9','B6','O436AMLNX4','AVAILABLE',3000),('UUQAFPM4HX','A9','UXEI02KBGL','AVAILABLE',1000),('UUQXMTCF3I','A9','O436AMLNX4','AVAILABLE',3000),('UWME0ZCM6I','A10','5VMU3PF7CM','AVAILABLE',10000),('UWTLEP7TKJ','A5','P41A1PMG3J','AVAILABLE',20000),('UYO1ZZ5IBL','A7','UXEI02KBGL','AVAILABLE',1000),('V3CJGDZVNJ','A12','LHW3CJO3RD','AVAILABLE',10000),('V5G7ORAAEN','B6','T36DIA8YD2','AVAILABLE',10000),('V5L35ETY9A','A17','P41A1PMG3J','AVAILABLE',20000),('V9B75LB0YS','A10','C2I3OOBEPA','AVAILABLE',3000),('VB6G5ZUK4C','A11','V7WE0SKYXP','AVAILABLE',2000),('VBHNGQXO25','A8','E4KH8EOA5I','AVAILABLE',10000),('VD1DKG7RA9','A16','RPNK4HUJTL','BOOKED',1000),('VEOSZFKR7Y','A9','MSY3J0SQZX','AVAILABLE',10000),('VGZTSSTIS5','A3','GXHGR5JAOV','AVAILABLE',12000),('VM1PXD4ILM','B3','NY1HVU27ZH','AVAILABLE',15000),('VNU2MFDEOW','A7','E4KH8EOA5I','AVAILABLE',10000),('VQV6C0SRUE','B4','KQL08ODWOI','AVAILABLE',120000),('VQX1CW6OD0','B10','E4KH8EOA5I','AVAILABLE',10000),('VSQ2LHCJEH','A17','MXJOQWK19D','AVAILABLE',12000),('VTHNIJT0S5','B13','V7WE0SKYXP','AVAILABLE',2000),('VULG3OUAL0','B5','GX4ML4QSBX','AVAILABLE',2000),('W09YFJAMHF','A7','V7WE0SKYXP','AVAILABLE',2000),('W0HXSB6H20','A4','B2250NHQAO','AVAILABLE',100000),('W687JFMPUM','A16','V7WE0SKYXP','AVAILABLE',2000),('WB1L8FN1LA','A6','VLLTWTBDIB','AVAILABLE',2000),('WC5P5DF2NZ','B16','5VMU3PF7CM','AVAILABLE',10000),('WCD8UCFNWK','B9','E4KH8EOA5I','AVAILABLE',10000),('WDY53X56ZD','B14','UXEI02KBGL','AVAILABLE',1000),('WGEBH9R2WO','A9','GXHGR5JAOV','AVAILABLE',12000),('WMDNWDN1YL','A2','3RGT72SCZ4','AVAILABLE',3000),('WMYVDHY3FF','B7','MSY3J0SQZX','AVAILABLE',10000),('WOAN3XJ0Z7','B16','RQKL886XN5','AVAILABLE',2000),('WOIADMOAMG','A16','GX4ML4QSBX','AVAILABLE',2000),('WRJBRG5D4D','B15','RPNK4HUJTL','AVAILABLE',1000),('WU573PXPUM','B17','GX4ML4QSBX','AVAILABLE',2000),('WXE8V2ABFB','B1','E4KH8EOA5I','AVAILABLE',10000),('WZUPEV42LF','A13','C2I3OOBEPA','AVAILABLE',3000),('X449NZ1DP8','A15','C2I3OOBEPA','AVAILABLE',3000),('X59HHIK6GI','B6','GX4ML4QSBX','AVAILABLE',2000),('X5ZJ2JJL17','B7','9HVPRF2WRF','AVAILABLE',1000),('XB0F7XMW3H','B8','MSY3J0SQZX','AVAILABLE',10000),('XF1SE23F2V','A3','HQ95GOU7PC','AVAILABLE',3000),('XF451BGK56','A6','1PMJJG0SRV','AVAILABLE',10000),('XI9BHENF0D','A14','C2I3OOBEPA','AVAILABLE',3000),('XII9BH31X5','B9','5VMU3PF7CM','AVAILABLE',10000),('XKLI817WZI','A4','C2I3OOBEPA','AVAILABLE',3000),('XL70OEWCNJ','A9','T36DIA8YD2','AVAILABLE',10000),('XQI1MJT4U8','B1','9HVPRF2WRF','AVAILABLE',1000),('XQP72U279R','A6','RPNK4HUJTL','BOOKED',1000),('XSET6DG4BO','B17','RPNK4HUJTL','AVAILABLE',1000),('XVFXNLKX3N','A3','5VMU3PF7CM','AVAILABLE',10000),('Y0X4RBZHMN','A11','1PMJJG0SRV','AVAILABLE',10000),('Y3RLPCUFZX','A7','NY1HVU27ZH','AVAILABLE',15000),('Y49KYTSULP','A5','C2I3OOBEPA','AVAILABLE',3000),('Y52YET2TSE','A11','9HVPRF2WRF','AVAILABLE',1000),('Y7ZAE09U35','A5','O436AMLNX4','AVAILABLE',3000),('Y94GBKAQ6U','A17','ZB0N8PD6JW','AVAILABLE',10000),('YCVBNCZ5BN','B11','RPNK4HUJTL','AVAILABLE',1000),('YD2YXAO77M','A10','1PMJJG0SRV','AVAILABLE',10000),('YER4T4BPT6','B6','FOGGXJ3UR1','AVAILABLE',10000),('YF4VRXBVXL','A1','C2I3OOBEPA','AVAILABLE',3000),('YFJLUWFBZI','A15','UXEI02KBGL','AVAILABLE',1000),('YJWZ0JRI3A','A2','FOGGXJ3UR1','AVAILABLE',10000),('YMEYN8QK1N','A4','HDGNUABOFH','AVAILABLE',10000),('YO7IWH3GOK','B2','XBW0ZMRSJZ','AVAILABLE',3000),('YSZ0THBOJ3','A3','KQL08ODWOI','AVAILABLE',120000),('YTA1YJ723S','A13','XBW0ZMRSJZ','AVAILABLE',3000),('YTCFF9ZZOA','A11','GXHGR5JAOV','AVAILABLE',12000),('YTIGXA9ZIO','B3','T36DIA8YD2','AVAILABLE',10000),('YUZ10S40I4','B15','GX4ML4QSBX','AVAILABLE',2000),('YY21O225R8','B9','RPNK4HUJTL','AVAILABLE',1000),('Z2MABJFH8Z','A4','MXJOQWK19D','AVAILABLE',12000),('Z68PVYPLEZ','A11','FOGGXJ3UR1','AVAILABLE',10000),('Z6A89NIUX5','A12','NY1HVU27ZH','AVAILABLE',15000),('Z8F37U4TZ0','A2','GXHGR5JAOV','AVAILABLE',12000),('Z9IAB60JID','B13','P41A1PMG3J','AVAILABLE',20000),('ZAAPQO4P0S','B10','RQKL886XN5','AVAILABLE',2000),('ZAJ8UW9HQS','A12','FOGGXJ3UR1','AVAILABLE',10000),('ZASKQ67O4I','B7','V7WE0SKYXP','AVAILABLE',2000),('ZBX8GN58KE','B12','P41A1PMG3J','AVAILABLE',20000),('ZCOAKUPZM3','B12','RPNK4HUJTL','AVAILABLE',1000),('ZD42J6EWR1','B1','VLLTWTBDIB','AVAILABLE',2000),('ZDHJJWOB58','B12','FOGGXJ3UR1','AVAILABLE',10000),('ZF4Z8QMOLL','B14','ZB0N8PD6JW','AVAILABLE',10000),('ZFMSYLMOHO','B3','P41A1PMG3J','AVAILABLE',20000),('ZH4KV3HUCZ','A3','P41A1PMG3J','AVAILABLE',20000),('ZHTCO9460W','A2','VPIUD51XBB','BOOKED',12000),('ZJ381XVYPB','B10','HQ95GOU7PC','AVAILABLE',3000),('ZJ8NKDP6Y2','B1','ZB0N8PD6JW','AVAILABLE',10000),('ZMC8S02DSR','B10','UXEI02KBGL','AVAILABLE',1000),('ZST9YO1XS3','A13','RPNK4HUJTL','AVAILABLE',1000),('ZT99PPXLZ0','B11','VLLTWTBDIB','AVAILABLE',2000),('ZUNK9FX7WX','B8','MXJOQWK19D','AVAILABLE',12000),('ZUYRASNYKO','A10','P41A1PMG3J','AVAILABLE',20000),('ZVLBLADVGS','A15','V7WE0SKYXP','AVAILABLE',2000),('ZXTU201S23','A8','MSY3J0SQZX','AVAILABLE',10000),('ZY9E4XHDM6','A15','KQL08ODWOI','AVAILABLE',120000);
/*!40000 ALTER TABLE `trip_seat` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_device_token`
--

DROP TABLE IF EXISTS `user_device_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_device_token` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) NOT NULL,
  `device_token` varchar(512) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_device_token` (`device_token`),
  KEY `fk_device_token_customer` (`user_id`),
  CONSTRAINT `fk_device_token_customer` FOREIGN KEY (`user_id`) REFERENCES `customer` (`ID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_device_token`
--

LOCK TABLES `user_device_token` WRITE;
/*!40000 ALTER TABLE `user_device_token` DISABLE KEYS */;
INSERT INTO `user_device_token` VALUES (1,'CUST-0002','cBswGC5AR_SNPVlD3830vj:APA91bGQKfYSz14zu0c7VuhXML_iJUDAUCyIEbol3wzmBWP8zjuoSDOtdmpINHpaTTA55w6mjXNDWgOgc4QBdlBjH6cUU6L6dAl3oaoK557AlgTlyRENBhY','2026-06-09 02:59:50','2026-06-09 02:59:50'),(2,'CUST-0001','dfZUAkevT_y0V7OEHlhZE9:APA91bGgwzJU8m6COWnn4keI2p74LhutrYR0TgRKrm2-jMMbZQiyC28rVL5Q71SFDT4aKF3IZlhQ3sXuF7FperXfDLjEhCL4ZIVVAzmQy_5IGTSIyg8i_a8','2026-06-11 12:52:50','2026-06-11 12:52:50'),(3,'GTWUJ2Y9HK','elgHZw5HTfGI7HY_UUMetx:APA91bG-ORWdJmPPh1bUkakL-zE5WZiMMjNwKHDWri81PMpFLZFwBa2vnBtcW3zJyr_EcE746cKtDF3iBQPU0Pm6siWoryM74KoHasTa95tBhnwXMWfGfTA','2026-06-11 13:14:23','2026-06-11 13:14:23');
/*!40000 ALTER TABLE `user_device_token` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-12  7:10:38
