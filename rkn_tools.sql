-- MySQL dump 10.13  Distrib 5.7.33, for FreeBSD11.4 (amd64)
--
-- Host: localhost    Database: rkn_tools
-- ------------------------------------------------------
-- Server version	5.7.33

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `domain_all`
--

DROP TABLE IF EXISTS `domain_all`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `domain_all` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `domain` varchar(2048) DEFAULT NULL,
  `content_id` bigint(20) unsigned DEFAULT '0',
  `block_type` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `domain_all`
--

LOCK TABLES `domain_all` WRITE;
/*!40000 ALTER TABLE `domain_all` DISABLE KEYS */;
/*!40000 ALTER TABLE `domain_all` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ip_all`
--

DROP TABLE IF EXISTS `ip_all`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ip_all` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ip` varchar(64) DEFAULT NULL,
  `content_id` bigint(20) unsigned DEFAULT '0',
  `block_type` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ip_all`
--

LOCK TABLES `ip_all` WRITE;
/*!40000 ALTER TABLE `ip_all` DISABLE KEYS */;
/*!40000 ALTER TABLE `ip_all` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ip_resolv`
--

DROP TABLE IF EXISTS `ip_resolv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ip_resolv` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ip` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ip_resolv`
--

LOCK TABLES `ip_resolv` WRITE;
/*!40000 ALTER TABLE `ip_resolv` DISABLE KEYS */;
/*!40000 ALTER TABLE `ip_resolv` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subnet_all`
--

DROP TABLE IF EXISTS `subnet_all`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subnet_all` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `subnet` varchar(64) DEFAULT NULL,
  `content_id` bigint(20) unsigned DEFAULT '0',
  `block_type` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subnet_all`
--

LOCK TABLES `subnet_all` WRITE;
/*!40000 ALTER TABLE `subnet_all` DISABLE KEYS */;
/*!40000 ALTER TABLE `subnet_all` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-05-31 15:27:54
