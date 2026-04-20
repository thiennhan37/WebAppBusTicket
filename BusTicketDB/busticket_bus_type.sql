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
-- Table structure for table `bus_type`
--

DROP TABLE IF EXISTS `bus_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bus_type` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `diagram` json NOT NULL,
  `total_seat` int NOT NULL,
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
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-16 16:07:37
