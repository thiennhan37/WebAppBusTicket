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
-- Table structure for table `booking_order`
--

DROP TABLE IF EXISTS `booking_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking_order` (
  `ID` varchar(20) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `customer_name` varchar(255) NOT NULL,
  `customer_phone` varchar(20) NOT NULL,
  `customer_email` varchar(255) DEFAULT NULL,
  `trip_id` varchar(20) DEFAULT NULL,
  `booking_user_id` varchar(20) DEFAULT NULL,
  `creating_staff_id` varchar(20) DEFAULT NULL,
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
/*!40000 ALTER TABLE `booking_order` ENABLE KEYS */;
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
