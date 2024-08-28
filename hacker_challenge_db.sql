-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : mer. 28 août 2024 à 01:15
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `hacker_challenge_db`
--

-- --------------------------------------------------------

--
-- Structure de la table `questions`
--

CREATE TABLE `questions` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `question` text NOT NULL,
  `answer` text DEFAULT NULL,
  `answered` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `questions`
--

INSERT INTO `questions` (`id`, `username`, `question`, `answer`, `answered`, `created_at`) VALUES
(1, 'cherif', 'comment devenir plus inteligent ?', 'il faudra beaucoup apprendre', 1, '2024-08-27 03:39:23'),
(2, 'cherif', 'c\'est quoi la side ?', 'il sagis d\'un programme', 1, '2024-08-27 04:02:31'),
(3, 'cherif', 'le side c\'est quoi ?', 'pourquoi cette question\n', 1, '2024-08-27 04:03:57'),
(4, 'hiver', 'c\'est quoi le side ?', 'bonne question', 1, '2024-08-27 04:13:49'),
(5, 'hiver', 'c\'est quoi le side', 'systeme complexe', 1, '2024-08-27 04:22:11'),
(6, 'hiver', 'la side toujours', 'bonne question', 1, '2024-08-27 04:34:47'),
(7, 'stephane', 'bonjour', 'bonjour', 1, '2024-08-27 06:11:14'),
(8, 'stephane', 'qui est tu ?', 'l\'homme', 1, '2024-08-27 06:12:08'),
(9, 'stephane', 'bye', 'merci', 1, '2024-08-27 06:13:42'),
(10, 'vincen', 'hello', 'bonjour', 1, '2024-08-27 15:47:38'),
(11, 'vincen', 'comment tu vas', 'je vais bien et toi', 1, '2024-08-27 15:48:15'),
(12, 'vincen', 'bien aussi', 'ok', 1, '2024-08-27 15:48:53'),
(13, 'ben', 'c\'est quoi le side ?', 'je sais pas mon reuf', 1, '2024-08-27 15:55:55'),
(14, 'ben', 'ok', 'oui', 1, '2024-08-27 15:59:08'),
(15, 'ben', 'merci', 'je t\'en prie', 1, '2024-08-27 16:39:35');

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `jokers_left` int(11) DEFAULT 3
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password_hash`, `created_at`, `jokers_left`) VALUES
(1, 'cherif', 'chaoussicherif@gmail.com', '$2b$10$z2LipaAI7PncmlfdVdlFKOeNuJ2P8kL.IlWI.aAMMgRidJD8GX.z6', '2024-08-26 05:25:34', 0),
(2, 'hiver', 'hiver@gmail.com', '$2b$10$u04bmyOvAtcH781Qz5dmsO4fThfDlgIuO5M6VIypLEt4wHuCXcAIe', '2024-08-26 06:29:55', 0),
(3, 'stephane', 'stephane@gmail.com', '$2b$10$UfnAdrKMHhulvfUJHMiuK.Yv4T.cEQt8s/SHexmNC3yKnmWZT5H7.', '2024-08-27 06:08:38', 0),
(4, 'vincen', 'vicen@gmail.com', '$2b$10$58J1.NdL8sOIJAF0BGBO5.XhOiwHc4svC9al5SfFAP9Zdblvm.cI.', '2024-08-27 15:46:32', 0),
(5, 'ben', 'ben@gmail.com', '$2b$10$.iPGQ1T31HeQ.4gG..Id6eoQpDp4D/NP6DiqtZcCkj9dFsFSY3Mqm', '2024-08-27 15:54:58', 0);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `questions`
--
ALTER TABLE `questions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `username` (`username`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `questions`
--
ALTER TABLE `questions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT pour la table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `questions`
--
ALTER TABLE `questions`
  ADD CONSTRAINT `questions_ibfk_1` FOREIGN KEY (`username`) REFERENCES `users` (`username`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
