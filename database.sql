-- 建立資料庫
CREATE DATABASE IF NOT EXISTS excel_manager CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE excel_manager;

-- 登入紀錄
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 建立一個使用者名稱為 'admin'，密碼為 'password' 的帳號
INSERT INTO users (username, password) 
VALUES ('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');

-- 上傳資料
CREATE TABLE `uploaded_data` (
  `工單號` varchar(50) NOT NULL,
  `料號` varchar(50) DEFAULT NULL,
  `品名` text NOT NULL,
  `交期` varchar(50) DEFAULT NULL,
  `工單數` int(11) DEFAULT NULL,
  `實際入庫` int(11) DEFAULT NULL,
  `產速` decimal(10,2) DEFAULT NULL,
  `台數` int(11) DEFAULT NULL,
  `日產量` int(11) DEFAULT NULL,
  `架機說明` text DEFAULT NULL,
  `架機日期` varchar(50) DEFAULT NULL,
  `機台(預)` varchar(50) DEFAULT NULL,
  `利潤中心` varchar(50) DEFAULT NULL,
  `實際完成` varchar(50) DEFAULT NULL,
  `落後百分比` decimal(5,2) DEFAULT NULL,
  `車製回覆完成日` varchar(50) DEFAULT NULL,
  `狀態` int(11) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO uploaded_data (工單號,品名,`機台(預)`) 
    VALUES ('123','456','A01');

CREATE TABLE IF NOT EXISTS 機台狀態 (
    代碼 VARCHAR(5) PRIMARY KEY,
    狀態 VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO 機台狀態 (代碼, 狀態) VALUES 
('1', '正常運轉'),('A', '架機(改車)'),('B', '待排程'),('C', '待確認'),('D', '生產(繼續車)日期未到'),
('E', '待訂單'),('0', '零件維修'),('F', '委外維修'),('G', '待機(繼續車)'),('H', '待訂');

CREATE TABLE IF NOT EXISTS 機台看板 (
    機台 VARCHAR(10) NOT NULL PRIMARY KEY,
    狀態 VARCHAR(5) DEFAULT '1',
    工單號 VARCHAR(50),
    箱數 INT,
    支數 VARCHAR(50),
    送料機 VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

TRUNCATE TABLE 機台看板;
INSERT INTO 機台看板 (機台) VALUES 
('A01'),('A02'),('A03'),('A04'),('A05'),('A06'),('A07'),('A08'),('A09'),('A10'),
('A11'),('A12'),('A13'),('A14'),('A15'),('A16'),('A17'),('A18'),('A19'),('A20'),
('A21'),('A22'),('B01'),('B02'),('B03'),('B04'),('B05'),('B06'),('B07'),('B08'),
('B09'),('B10'),('B11'),('B12'),('B13'),('B14'),('B15'),('C01'),('C02'),('C03'),
('C04'),('C05'),('C06'),('C07'),('C08'),('C09'),('C10'),('C11'),('C12'),('C13'),
('C14'),('C15'),('C16'),('C17'),('F01'),('F02'),('F03'),('F04'),('F05'),('F06'),
('F07'),('F08'),('F09'),('F10'),('F11'),('F12'),('F13'),('F14'),('F15'),('F16');

CREATE TABLE IF NOT EXISTS 生產紀錄表 (
    條碼編號 VARCHAR(20) NOT NULL PRIMARY KEY,
    工單號 VARCHAR(50) NOT NULL,
    品名 VARCHAR(50) NOT NULL,
    顧車 VARCHAR(50),
    機台 VARCHAR(10) NOT NULL,
    箱數 VARCHAR(2) NOT NULL,
    班別 VARCHAR(10),
    建立時間 TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    檢驗人 VARCHAR(50),
    重量 DECIMAL(10,3),
    單重 DECIMAL(10,3),
    數量 INT,
    檢驗時間 TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    檢驗狀態 TINYINT DEFAULT 0,
    後續單位 VARCHAR(50) DEFAULT '電' AFTER 班別,
    異常 TINYINT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS 圖號表 (
    品名 VARCHAR(50) NOT NULL PRIMARY KEY,
    圖號 VARCHAR(50) NOT NULL,
    規格 VARCHAR(10) NOT NULL,
    材料外徑 DECIMAL(5,2) NOT NULL,
    材質 VARCHAR(50) NOT NULL,
    只_2_5M INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO 圖號表 (品名, 圖號, 規格, 材料外徑, 材質, 只_2_5M) VALUES
('023-HH', '0-41', 'ø', 8.5, 'C3604', 420),
('081-5052-1', '0-43', 'ø', 8.5, 'C3604', 140),
('180086', '1-03', 'H', 11.0, 'C3604', 286),
('1513119-A', '1-118', '□', 9.5, 'C3604', 132),
('180231-02', '1-122', 'H', 11.0, '直花', 256),
('187614', '1-177', 'ø', 10.0, 'C3604', 282),
('246022-02', '2-05', 'ø', 11.7, 'C3603', 126),
('246386-02', '2-104', 'ø', 8.6, 'C3604', 113),
('244083', '2-106', 'ø', 11.0, 'C3604', 190),
('246216-01', '2-11', 'ø', 8.5, 'C3604', 116),
('246062-01', '2-110', 'ø', 11.7, 'C3603', 128),
('246324-01', '2-130', 'ø', 9.5, 'C3604', 149),
('246312-EZ-01', '2-82', 'ø', 8.5, 'C3604', 116),
('245316-U', '2-86', 'ø', 9.7, 'EF料', 170),
('246346-U', '2-87', 'ø', 8.5, 'C3604', 148),
('415-SMAM-N', '4-06', 'H', 8.0, 'C3604', 259),
('534831-009-B-03', '5-11', 'ø', 12.3, 'C3604', 122),
('89570004-B', '8-20', 'H', 19.0, 'C3604', 126),
('99901310-A1-01', '9-05', 'H', 11.0, 'C3604', 286),
('99901320-C-01', '9-10', 'ø', 8.5, 'C3604', 148),
('ATT-A', 'A-05', 'ø', 10.8, 'C3604', 103),
('ASFPSLCQ-B', 'A-15', 'ø', 9.5, 'C3604', 128),
('ASFPSLCQ-NUT', 'A-16', 'H', 11.0, 'C3604', 258),
('ASFPSLCQ-D', 'A-20', 'ø', 8.5, 'C3604', 312),
('ASFPSLCQ-PT', 'A-27', 'ø', 7.0, 'PTFE(J)', 273),
('CSI-CPE-F-H', 'C-93', 'ø', 15.87, 'C3604', 1294),
('DBTCCSC-B', 'D-36', 'ø', 6.5, 'C3604', 195),
('EZ-246028', 'E-01', 'ø', 10.8, 'C3603', 126),
('FS-PF-59-RING-02', 'F-106', 'ø', 8.0, 'C3604', 190),
('F81S', 'F-22', 'H', 11.0, 'C3604', 109),
('F-81-HQ-D-A', 'F-70', 'H', 11.0, 'C3604', 89),
('FS-PF-59-C', 'F-96', 'ø', 9.0, 'C3604', 488),
('G-F81FZ-H-01', 'G-43', 'ø', 8.5, 'C3604', 642),
('G-PCBV-SL-F', 'G-59', 'ø', 13.3, 'C3604', 416),
('G-PCBV-SL-A', 'G-60', 'ø', 12.3, 'C3604', 151),
('N1-T200-PT', 'N-138', 'ø', 10.0, 'PTFE', 70),
('NS-11618-1-03', 'N-81', 'ø', 14.5, 'C3604', 81),
('NEC-11-N-01', 'N-91', 'H', 11.0, 'C3604', 175),
('NS-11617-1-02', 'N-99', 'ø', 16.5, 'C3604', 151),
('PCB90-RHT-B-01', 'P-30', 'ø', 9.7, 'C3604', 90),
('PCB90-RHT-A', 'P-45', '□', 9.5, 'C3604', 141),
('SLCU-6-CC', 'S-103', 'ø', 10.0, 'C3604', 410),
('SLC1855Q-FP-C-01', 'S-136', 'ø', 6.5, 'C3604', 141),
('SLC1855-BNCFPU-R', 'S-138', 'ø', 11.1, 'C3604', 202),
('SLC11A-R-01', 'S-15', 'ø', 15.5, 'C3604', 121),
('SLC1855-BNCFPU-A-01', 'S-19', 'ø', 10.8, 'C3604', 87),
('SLCU-6QB-B', 'S-48', 'ø', 10.8, 'C3604', 267),
('SMBM-179DC-F', 'S-89', 'ø', 6.5, 'C3604', 280),
('SLC1855Q-FP-R-01', 'S-95', 'ø', 11.1, 'C3604', 185),
('SLCU-6A-R-02', 'S-97', 'ø', 11.1, 'C3604', 137),
('SLCU-6A-C', 'S-98', 'ø', 8.5, 'C3604', 110),
('XVDV812-086-NUT', 'X-03', 'H', 11.0, 'C3604', 246);