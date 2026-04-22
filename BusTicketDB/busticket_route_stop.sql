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
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `route_stop`
--

LOCK TABLES `route_stop` WRITE;
/*!40000 ALTER TABLE `route_stop` DISABLE KEYS */;
INSERT INTO `route_stop` VALUES (1,13,25,'UP'),(2,13,26,'UP'),(3,13,24,'UP'),(4,13,1,'DOWN'),(5,13,2,'DOWN'),(16,19,20,'UP'),(17,19,19,'UP'),(18,19,24,'UP'),(19,19,1,'DOWN'),(20,19,2,'DOWN'),(21,20,1,'UP'),(22,20,2,'UP'),(23,20,16,'DOWN'),(24,20,17,'DOWN'),(25,22,1,'UP'),(26,22,17,'DOWN'),(27,23,1,'UP'),(28,23,2,'UP'),(29,23,3,'UP'),(30,23,17,'DOWN'),(31,24,16,'UP'),(32,24,17,'UP'),(33,24,2,'DOWN'),(34,25,1,'UP'),(35,25,2,'DOWN'),(36,26,1,'UP'),(37,26,19,'DOWN'),(38,27,1,'UP'),(39,27,2,'UP'),(40,27,25,'DOWN'),(41,27,26,'DOWN');
/*!40000 ALTER TABLE `route_stop` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-16 16:07:36
