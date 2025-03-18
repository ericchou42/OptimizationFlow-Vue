import mysql.connector
from mysql.connector import Error
import socket
import sys
import os
import datetime
import logging

# 設定日誌記錄
logging.basicConfig(
    filename='label_log.txt',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    encoding='utf-8'  # 添加明確的編碼設定
)

def connect_to_database():
    try:
        connection = mysql.connector.connect(
            host="127.0.0.1",
            database="excel_manager",
            user="root",
            password=""
        )
        if connection.is_connected():
            return connection
    except Error as e:
        logging.error(f"資料庫連接錯誤: {e}")
        print(f"資料庫連接錯誤: {e}")
    return None

def get_work_order_data(connection, work_order_number):
    try:
        cursor = connection.cursor(dictionary=True)
        query = """
        SELECT * FROM `機台看板` 
        WHERE 工單號 = %s
        """
        cursor.execute(query, (work_order_number,))
        result = cursor.fetchone()
        cursor.close()
        return result
    except Error as e:
        logging.error(f"查詢錯誤: {e}")
        print(f"查詢錯誤: {e}")
        return None

def print_zebra_label(data):
    try:
        logging.info(f"準備列印標籤: {data}")

        # 獲取當前日期
        current_date = datetime.datetime.now().strftime("%Y/%m/%d")

        # 定義標籤參數
        # XY軸位置
        x_position = 60
        x_position_right = 670
        y_position = 50

        # 條碼高度和模組寬度
        barcode_height = 100

        # 條碼模組寬度(1-10)，數字越大條碼越寬，超過5可能會過版
        module_width = 5
        
        # 準備ZPL命令 - 使用英文標籤避免編碼問題
        zpl_command = "^XA"  # 開始ZPL命令

        # 設定中文碼頁
        zpl_command += "^CI28" # 使用 Big5 編碼 (台灣繁體中文)
        
        # 設定條碼起始位置
        zpl_command += f"^FO{x_position},{y_position}" 

        # 添加工單號條碼尺寸
        zpl_command += f"^BY{module_width}"

        # 設定 Code 128 條碼參數
        zpl_command += f"^BCN,{barcode_height},Y,N,N"
        
        # 構建條碼，格式為工單號+機台+箱數
        barcode_value = data['工單號'] + data['機台'] + data['箱數']
        zpl_command += f"^FD{barcode_value}^FS"
        
        # 日期
        zpl_command += f"^FO{x_position},{y_position + barcode_height + 100}"
        zpl_command += "^A@N,60,60,E:ARIAL.TTF"
        zpl_command += f"^FD日期:{current_date}^FS"

        # 工單號
        zpl_command += f"^FO{x_position},{y_position + barcode_height + 200}"
        zpl_command += "^A@N,60,60,E:ARIAL.TTF"
        zpl_command += f"^FD工單號:{data['工單號']}^FS"

        # 品名
        zpl_command += f"^FO{x_position},{y_position + barcode_height + 300}"
        zpl_command += "^A@N,60,60,E:ARIAL.TTF"
        zpl_command += f"^FD品名:{data['品名']}^FS"

        # 人員
        zpl_command += f"^FO{x_position},{y_position + barcode_height + 400}"
        zpl_command += "^A@N,60,60,E:ARIAL.TTF"
        zpl_command += f"^FD顧車:{data['顧車']}^FS"

        # 工序
        zpl_command += f"^FO{x_position_right},{y_position + barcode_height + 100}"
        zpl_command += "^A@N,60,60,E:ARIAL.TTF"
        zpl_command += f"^FD工序:10^FS"

        # 機台
        zpl_command += f"^FO{x_position_right},{y_position + barcode_height + 200}"
        zpl_command += "^A@N,60,60,E:ARIAL.TTF"
        zpl_command += f"^FD機台:{data['機台']}^FS"

        # 箱數
        zpl_command += f"^FO{x_position_right},{y_position + barcode_height + 300}"
        zpl_command += "^A@N,60,60,E:ARIAL.TTF"
        zpl_command += f"^FD箱數:{data['箱數']}^FS"

        # 班別
        zpl_command += f"^FO{x_position_right},{y_position + barcode_height + 400}"
        zpl_command += "^A@N,60,60,E:ARIAL.TTF"
        zpl_command += f"^FD班別:{data['班別']}^FS"

        zpl_command += "^XZ"  # 結束ZPL命令
        
        # 使用網路打印
        try:
            printer_ip = "172.29.123.150"
            printer_port = 9100
            logging.info(f"正在連接打印機 {printer_ip}:{printer_port}")
            printer_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            printer_socket.connect((printer_ip, printer_port))

            # 將 ZPL 命令編碼為 UTF-8
            encoded_command = zpl_command.encode('utf-8')
            printer_socket.send(encoded_command)
            printer_socket.close()
            
            logging.info("標籤已發送到打印機")
            print("標籤已發送到打印機")
            return True
        except Exception as e:
            logging.error(f"連接打印機錯誤: {e}")
            print(f"連接打印機錯誤: {e}")
            return False
        
    except Exception as e:
        logging.error(f"打印機錯誤: {e}")
        print(f"打印機錯誤: {e}")
        return False

# main() 函數
def main():
    logging.info("程式啟動")
    logging.info(f"命令行參數: {sys.argv}")
    
    try:
        # 檢查是否有命令行參數
        if len(sys.argv) >= 8:
            # 記錄當前工作目錄，幫助調試
            current_dir = os.getcwd()
            logging.info(f"當前工作目錄: {current_dir}")
            
            # 直接從命令行參數獲取資訊
            barcode_id = sys.argv[1]
            work_order = sys.argv[2]
            product_name = sys.argv[3]
            operator = sys.argv[4]
            machine = sys.argv[5]
            box_number = sys.argv[6]
            shift = sys.argv[7]
            
            # 記錄參數
            logging.info(f"條碼 ID: {barcode_id}")
            logging.info(f"工單號: {work_order}")
            logging.info(f"品名: {product_name}")
            logging.info(f"顧車: {operator}")
            logging.info(f"機台: {machine}")
            logging.info(f"箱數: {box_number}")
            logging.info(f"班別: {shift}")
            
            # 創建資料結構
            data = {
                '工單號': work_order,
                '機台': machine,
                '品名': product_name,
                '顧車': operator,
                '箱數': box_number,
                '班別': shift
            }
            
            # 列印標籤
            success = print_zebra_label(data)
            
            # 設置退出代碼
            sys.exit(0 if success else 1)
        else:
            error_msg = "參數不足，請確保提供所有必要參數"
            logging.error(error_msg)
            print(error_msg)
            print("使用方式: python barcode.py [條碼編號] [工單號] [品名] [顧車] [機台] [箱數] [班別]")
            sys.exit(1)
    except Exception as e:
        logging.error(f"執行錯誤: {e}")
        print(f"執行錯誤: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()